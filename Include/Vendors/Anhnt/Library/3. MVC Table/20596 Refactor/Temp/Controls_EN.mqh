//+------------------------------------------------------------------+
//|                                                     Controls.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include "Base_En.mqh"

#ifndef MOVE_TO_CONTROLSDEFINES_MQH
#define MOVE_TO_CONTROLSDEFINES_MQH
      // //+------------------------------------------------------------------+
   // // | Macro substitutions |
   // //+------------------------------------------------------------------+
   //    #define  DEF_LABEL_W                50          // Default text label width
   //    #define  DEF_LABEL_H                16          // Default text label height
   //    #define  DEF_BUTTON_W               60          // Default button width
   //    #define  DEF_BUTTON_H               16          // Default button height
   //    #define  DEF_TABLE_ROW_H            16          // Default table row height
   //    #define  DEF_TABLE_HEADER_H         20          // Default table header height
   //    #define  DEF_TABLE_ROWS_HEADER_W    24          // Minimum width of table row headers
   //    #define  DEF_TABLE_COLUMN_MIN_W     12          // Minimum table column width
   //    #define  DEF_PANEL_W                80          // Default panel width
   //    #define  DEF_PANEL_H                80          // Default panel height
   //    #define  DEF_PANEL_MIN_W            60          // Minimum panel width
   //    #define  DEF_PANEL_MIN_H            60          // Minimum panel height
   //    #define  DEF_SCROLLBAR_TH           13          // Default scrollbar thickness
   //    #define  DEF_THUMB_MIN_SIZE         8           // Minimum scroll bar thickness
   //    #define  DEF_AUTOREPEAT_DELAY       500         // Delay before auto-repeat starts
   //    #define  DEF_AUTOREPEAT_INTERVAL    100         // Auto repeat frequency

   //    #define  DEF_HINT_NAME_TOOLTIP      "HintTooltip"     // Name of the tooltip
   //    #define  DEF_HINT_NAME_HORZ         "HintHORZ"        // Tooltip name "Double horizontal arrow"
   //    #define  DEF_HINT_NAME_VERT         "HintVERT"        // Tooltip name "Double vertical arrow"
   //    #define  DEF_HINT_NAME_NWSE         "HintNWSE"        // Tooltip name "Double arrow top-left" --- bottom-right (NorthWest-SouthEast)
   //    #define  DEF_HINT_NAME_NESW         "HintNESW"        // Tooltip name "Double arrow bottom-left" --- top-right (NorthEast-SouthWest)
   //    #define  DEF_HINT_NAME_SHIFT_HORZ   "HintShiftHORZ"   // Tooltip name "Horizontal offset arrow"
   //    #define  DEF_HINT_NAME_SHIFT_VERT   "HintShiftVERT"   // Tooltip name "Vertical offset arrow"
#endif // MOVE_TO_CONTROLSDEFINES_MQH

#ifndef MOVE_TO_CONTROLSENUMS_MQH
#define MOVE_TO_CONTROLSENUMS_MQH
   //+------------------------------------------------------------------+
   // //| Enums |
   // //+------------------------------------------------------------------+
   // enum ENUM_ELEMENT_SORT_BY                       // Comparable Properties
   //   {
   //    ELEMENT_SORT_BY_ID   =  BASE_SORT_BY_ID,     // Comparison by element ID
   //    ELEMENT_SORT_BY_NAME =  BASE_SORT_BY_NAME,   // Comparison by element name
   //    ELEMENT_SORT_BY_X    =  BASE_SORT_BY_X,      // Comparison by element's X coordinate
   //    ELEMENT_SORT_BY_Y    =  BASE_SORT_BY_Y,      // Comparison by element's Y coordinate
   //    ELEMENT_SORT_BY_WIDTH=  BASE_SORT_BY_WIDTH,  // Comparison by element width
   //    ELEMENT_SORT_BY_HEIGHT= BASE_SORT_BY_HEIGHT, // Comparison by element height
   //    ELEMENT_SORT_BY_ZORDER= BASE_SORT_BY_ZORDER, // Comparison by Z-order of an element
   //    ELEMENT_SORT_BY_TEXT,                        // Comparison by element text
   //    ELEMENT_SORT_BY_COLOR_BG,                    // Comparison by element background color
   //    ELEMENT_SORT_BY_ALPHA_BG,                    // Comparison of element background transparency
   //    ELEMENT_SORT_BY_COLOR_FG,                    // Comparison by element's foreground color
   //    ELEMENT_SORT_BY_ALPHA_FG,                    // Comparison by foreground element transparency
   //    ELEMENT_SORT_BY_STATE,                       // Comparison by item condition
   //    ELEMENT_SORT_BY_GROUP,                       // Comparison by element group
   //   };

   // enum ENUM_TABLE_SORT_MODE                       // Table column sorting modes
   //    {
   //       TABLE_SORT_MODE_NONE,                        // No sorting
   //       TABLE_SORT_MODE_ASC,                         // Sort in ascending order
   //       TABLE_SORT_MODE_DESC,                        // Sort in descending order
   //    };

   // enum ENUM_HINT_TYPE                             // Types of tooltips
   //   {
   //    HINT_TYPE_TOOLTIP,                           // Tooltip
   //    HINT_TYPE_ARROW_HORZ,                        // Double horizontal arrow
   //    HINT_TYPE_ARROW_VERT,                        // Double vertical arrow
   //    HINT_TYPE_ARROW_NWSE,                        // Double arrow top-left --- bottom-right (NorthWest-SouthEast)
   //    HINT_TYPE_ARROW_NESW,                        // Double arrow bottom-left --- top-right (NorthEast-SouthWest)
   //    HINT_TYPE_ARROW_SHIFT_HORZ,                  // Horizontal offset arrow
   //    HINT_TYPE_ARROW_SHIFT_VERT,                  // Vertical offset arrow
   //   };

   // enum ENUM_ROWS_HIGHLIGHT_MODE                   // Table row/cell highlighting modes
   //   {
   //    ROWS_HIGHLIGHT_MODE_CELLS,                   // Highlight individual cells (cell mode)
   //    ROWS_HIGHLIGHT_MODE_ROW,                     // Highlight the entire line (line mode)
   //   };  
#endif // MOVE_TO_CONTROLSENUMS_MQH

#ifndef MOVE_TO_LISTELM_MQH
#define MOVE_TO_LISTELM_MQH
   //+------------------------------------------------------------------+
   // // | Linked List of Graphics Class |
   // //+------------------------------------------------------------------+
   // class CListElm : public CList
   // {
   //    protected:
   //       ENUM_ELEMENT_TYPE m_element_type;   // The type of the object being created in CreateElement()
   //    public:
   //    // --- Setting element type
   //       void              SetElementType(const ENUM_ELEMENT_TYPE type) { this.m_element_type=type;   }
         
   //    // --- Virtual method (1) loading a list from a file, (2) creating a list element
   //       virtual bool      Load(const int file_handle);
   //       virtual CObject  *CreateElement(void);
   // };
   // #ifndef CLISTELM_IMPLEMENTATION
   // #define CLISTELM_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | Loading a list from a file |
   //    //+------------------------------------------------------------------+
   //    bool CListElm::Load(const int file_handle)
   //    {
   //       // --- Variables
   //          CObject *node;
   //          bool     result=true;
   //       // --- Checking the handle
   //          if(file_handle==INVALID_HANDLE)
   //             return(false);
   //       // --- Loading and checking the list start marker - 0xFFFFFFFFFFFFFFFF
   //          if(::FileReadLong(file_handle)!=MARKER_START_DATA)
   //             return(false);
   //       // --- Loading and checking list type
   //          if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
   //             return(false);
   //       // --- Read list size (number of objects)
   //          uint num=::FileReadInteger(file_handle,INT_VALUE);
            
   //       // --- We sequentially re-create the list elements by calling the Load() method of node objects
   //          this.Clear();
   //          for(uint i=0; i<num; i++)
   //          {
   //             // --- Read and check the object data start marker - 0xFFFFFFFFFFFFFFFF
   //             if(::FileReadLong(file_handle)!=MARKER_START_DATA)
   //                return false;
   //             // --- Read the object type
   //             this.m_element_type=(ENUM_ELEMENT_TYPE)::FileReadInteger(file_handle,INT_VALUE);
   //             node=this.CreateElement();
   //             if(node==NULL)
   //                return false;
   //             this.Add(node);
   //             // --- Now the file pointer is offset relative to the beginning of the object marker by 12 bytes (8 - marker, 4 - type)
   //             // --- Let's place a pointer to the beginning of the object's data and load the object's properties from the file using the Load() method of the node element.
   //             if(!::FileSeek(file_handle,-12,SEEK_CUR))
   //                return false;
   //             result &=node.Load(file_handle);
   //          }
   //       // --- Result
   //          return result;
   //    }
#endif // MOVE_TO_LISTELM_MQH

#ifndef MOVE_TO_DELIB_MQH
#define MOVE_TO_DELIB_MQH
   //+------------------------------------------------------------------+
   // // | List item creation method |
   // //+------------------------------------------------------------------+
   // CObject *CListElm::CreateElement(void)
   //    {
   //    // --- Depending on the object type in m_element_type, create a new object
   //    switch(this.m_element_type)
   //    {
   //       case ELEMENT_TYPE_BASE                       :  return new CBaseObj();           // Basic object of graphic elements
   //       case ELEMENT_TYPE_COLOR                      :  return new CColor();             // Color object
   //       case ELEMENT_TYPE_COLORS_ELEMENT             :  return new CColorElement();      // Graphics Element Colors Object
   //       case ELEMENT_TYPE_RECTANGLE_AREA             :  return new CBound();             // Rectangular element area
   //       case ELEMENT_TYPE_IMAGE_PAINTER              :  return new CImagePainter();      // Object for drawing images
   //       case ELEMENT_TYPE_CANVAS_BASE                :  return new CCanvasBase();        // Basic graphic element canvas object
   //       case ELEMENT_TYPE_ELEMENT_BASE               :  return new CElementBase();       // Basic object of graphic elements
   //       case ELEMENT_TYPE_HINT                       :  return new CVisualHint();        // Clue
   //       case ELEMENT_TYPE_LABEL                      :  return new CLabel();             // Text label
   //       case ELEMENT_TYPE_BUTTON                     :  return new CButton();            // Simple button
   //       case ELEMENT_TYPE_BUTTON_TRIGGERED           :  return new CButtonTriggered();   // Two-position button
   //       case ELEMENT_TYPE_BUTTON_ARROW_UP            :  return new CButtonArrowUp();     // Up arrow button
   //       case ELEMENT_TYPE_BUTTON_ARROW_DOWN          :  return new CButtonArrowDown();   // Down arrow button
   //       case ELEMENT_TYPE_BUTTON_ARROW_LEFT          :  return new CButtonArrowLeft();   // Left Arrow Button
   //       case ELEMENT_TYPE_BUTTON_ARROW_RIGHT         :  return new CButtonArrowRight();  // Right arrow button
   //       case ELEMENT_TYPE_CHECKBOX                   :  return new CCheckBox();          // CheckBox control
   //       case ELEMENT_TYPE_RADIOBUTTON                :  return new CRadioButton();       // RadioButton control
   //       case ELEMENT_TYPE_TABLE_CELL_VIEW            :  return new CTableCellView();     // Table cell (View)
   //       case ELEMENT_TYPE_TABLE_ROW_VIEW             :  return new CTableRowView();      // Table row (View)
   //       case ELEMENT_TYPE_TABLE_CAPTION_VIEW         :  return new CCaptionView();       // Basic header object (View)
   //       case ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW  :  return new CColumnCaptionView(); // Table Column Header (View)
   //       case ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW     :  return new CRowCaptionView();    // Table Row Header (View)
   //       case ELEMENT_TYPE_TABLE_HEADER_VIEW          :  return new CTableHeaderView();   // Table title (View)
   //       case ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW     :  return new CTableRowsHeaderView();// Vertical table header (View)
   //       case ELEMENT_TYPE_TABLE_VIEW                 :  return new CTableView();         // Table (View)
   //       case ELEMENT_TYPE_PANEL                      :  return new CPanel();             // Panel control
   //       case ELEMENT_TYPE_GROUPBOX                   :  return new CGroupBox();          // GroupBox control
   //       case ELEMENT_TYPE_CONTAINER                  :  return new CContainer();         // GroupBox control
   //       default                                      :  return NULL;
   //    }
   //    }
#endif // MOVE_TO_DELIB_MQH

#ifndef MOVE_TO_IMAGEPAINTER_MQH
#define MOVE_TO_IMAGEPAINTER_MQH
      // //+------------------------------------------------------------------+
   // //+------------------------------------------------------------------+
   // // | Picture Drawing Class |
   // //+------------------------------------------------------------------+
   // class CImagePainter : public CBaseObj
   // {
   //    protected:
   //       CCanvas          *m_canvas;                                 // Pointer to the canvas where we draw
   //       CBound            m_bound;                                  // Image coordinates and boundaries
   //       uchar             m_alpha;                                  // Transparency
         
   //    // --- Checks the validity of the canvas and the correct dimensions
   //       bool              CheckBound(const string source);

   //    public:
   //    // --- (1) Assigns canvas to draw, (2) sets, (3) returns transparency
   //       void              CanvasAssign(CCanvas *canvas)             { this.m_canvas=canvas;                }
   //       void              SetAlpha(const uchar value)               { this.m_alpha=value;                  }
   //       uchar             Alpha(void)                         const { return this.m_alpha;                 }
         
   //    // --- (1) Sets coordinates, (2) resizes area
   //       void              SetXY(const int x,const int y)            { this.m_bound.SetXY(x,y);             }
   //       void              SetSize(const int w,const int h)          { this.m_bound.Resize(w,h);            }
   //    // --- Sets the coordinates and dimensions of the area
   //       void              SetBound(const int x,const int y,const int w,const int h)
   //                         {
   //                            this.SetXY(x,y);
   //                            this.SetSize(w,h);
   //                         }

   //    // --- Returns the borders and dimensions of the picture
   //       int               X(void)                             const { return this.m_bound.X();             }
   //       int               Y(void)                             const { return this.m_bound.Y();             }
   //       int               Right(void)                         const { return this.m_bound.Right();         }
   //       int               Bottom(void)                        const { return this.m_bound.Bottom();        }
   //       int               Width(void)                         const { return this.m_bound.Width();         }
   //       int               Height(void)                        const { return this.m_bound.Height();        }
         
   //    // --- Clears the area
   //       bool              Clear(const int x,const int y,const int w,const int h,const bool update=true);
   //    // --- Draws a filled arrow (1) up, (2) down, (3) left, (4) right
   //       bool              ArrowUp(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   //       bool              ArrowDown(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   //       bool              ArrowLeft(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   //       bool              ArrowRight(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
         
   //    // --- Draws (1) horizontal 17x7, (2) vertical 7x17 double arrow
   //       bool              ArrowHorz(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true); 
   //       bool              ArrowVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true); 
         
   //    // --- Draws a diagonal (1) top-left --- down-right, (2) bottom-left --- up-right 17x17 double arrow
   //       bool              ArrowNWSE(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   //       bool              ArrowNESW(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
         
   //    // --- Draws an 18x18 offset arrow along (1) horizontal, (2) vertical
   //       bool              ArrowShiftHorz(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   //       bool              ArrowShiftVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
         
   //    // --- Draws a (1) checked, (2) unchecked CheckBox
   //       bool              CheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   //       bool              UncheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
         
   //    // --- Draws a (1) checked, (2) unchecked RadioButton
   //       bool              CheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   //       bool              UncheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);

   //    // --- Draws a frame for a group of elements
   //       bool              FrameGroupElements(const int x,const int y,const int w,const int h,const string text,
   //                                           const color clr_text,const color clr_dark,const color clr_light,
   //                                           const uchar alpha,const bool update=true);
         
   //    // --- Draws a filled triangle at (1) top-left, (2) bottom-left, (3) top-right, (4) bottom-right corner
   //       bool              TriangleLT(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   //       bool              TriangleLB(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   //       bool              TriangleRT(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   //       bool              TriangleRB(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);

   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0) const;
   //       virtual bool      Save(const int file_handle);
   //       virtual bool      Load(const int file_handle);
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_IMAGE_PAINTER);  }
         
   //    // --- Constructors/destructor
   //                         CImagePainter(void) : m_canvas(NULL)               { this.SetBound(1,1,DEF_BUTTON_H-2,DEF_BUTTON_H-2); this.SetName("Image Painter");  }
   //                         CImagePainter(CCanvas *canvas) : m_canvas(canvas)  { this.SetBound(1,1,DEF_BUTTON_H-2,DEF_BUTTON_H-2); this.SetName("Image Painter");  }
   //                         CImagePainter(CCanvas *canvas,const int id,const string name) : m_canvas(canvas)
   //                         {
   //                            this.m_id=id;
   //                            this.SetName(name);
   //                            this.SetBound(1,1,DEF_BUTTON_H-2,DEF_BUTTON_H-2);
   //                         }
   //                         CImagePainter(CCanvas *canvas,const int id,const int dx,const int dy,const int w,const int h,const string name) : m_canvas(canvas)
   //                         {
   //                            this.m_id=id;
   //                            this.SetName(name);
   //                            this.SetBound(dx,dy,w,h);
   //                         }
   //                      ~CImagePainter(void) {}
   // };
   // #ifndef CIMAGEPAINTER_IMPLEMENTATION
   // #define CIMAGEPAINTER_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    //| CImagePainter::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CImagePainter::Compare(const CObject *node,const int mode=0) const
   //       {
   //          if(node==NULL)
   //             return -1;
   //          const CImagePainter *obj=node;
   //          switch(mode)
   //          {
   //             case ELEMENT_SORT_BY_NAME     :  return(this.Name()   >obj.Name()    ? 1 : this.Name()    <obj.Name()    ? -1 : 0);
   //             case ELEMENT_SORT_BY_ALPHA_FG :
   //             case ELEMENT_SORT_BY_ALPHA_BG :  return(this.Alpha()  >obj.Alpha()   ? 1 : this.Alpha()   <obj.Alpha()   ? -1 : 0);
   //             case ELEMENT_SORT_BY_X        :  return(this.X()      >obj.X()       ? 1 : this.X()       <obj.X()       ? -1 : 0);
   //             case ELEMENT_SORT_BY_Y        :  return(this.Y()      >obj.Y()       ? 1 : this.Y()       <obj.Y()       ? -1 : 0);
   //             case ELEMENT_SORT_BY_WIDTH    :  return(this.Width()  >obj.Width()   ? 1 : this.Width()   <obj.Width()   ? -1 : 0);
   //             case ELEMENT_SORT_BY_HEIGHT   :  return(this.Height() >obj.Height()  ? 1 : this.Height()  <obj.Height()  ? -1 : 0);
   //             default                       :  return(this.ID()     >obj.ID()      ? 1 : this.ID()      <obj.ID()      ? -1 : 0);
   //          }
   //       }
   //    //+------------------------------------------------------------------+
   //    // |CImagePainter::Checks the validity of the canvas and the correct dimensions|
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::CheckBound(const string source)
   //       {
   //          if(this.m_canvas==NULL)
   //          {
   //             ::PrintFormat("%s: Error. First you need to assign the canvas using the CanvasAssign() method",__FUNCTION__);
   //             return false;
   //          }
   //          if(this.Width()==0 || this.Height()==0)
   //          {
   //             ::PrintFormat("%s::%s Error: (w %d, h %d). First you need to set the area size using the SetSize() or SetImageBound() methods",source,__FUNCTION__,this.Width(),this.Height());
   //             return false;
   //          }
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Clears an area |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::Clear(const int x,const int y,const int w,const int h,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;
   //       // --- Clear the entire image area with a transparent color
   //          this.m_canvas.FillRectangle(x,y,x+w-1,y+h-1,clrNULL);
   //       // --- If indicated, update the canvas
   //          if(update)
   //             this.m_canvas.Update(false);
   //       // --- Everything is successful
   //          return true;   
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws a filled up arrow |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::ArrowUp(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Calculate the coordinates of the arrow corners inside the image area
   //          int hw=(int)::floor(w/2);  // Half width
   //          if(hw==0)
   //             hw=1;

   //          int x1 = x + 1;            // X. Base (left point)
   //          int y1 = y + h - 4;        // Y. Left base point
   //          int x2 = x1 + hw;          // X. Apex (central top point)
   //          int y2 = y + 3;            // Y. Apex (highest point)
   //          int x3 = x1 + w - 1;       // X. Base (right point)
   //          int y3 = y1;               // Y. Base (right point)

   //       // --- Draw a triangle
   //          this.m_canvas.FillTriangle(x1, y1, x2, y2, x3, y3, ::ColorToARGB(clr, alpha));
   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;   
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws a filled down arrow |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::ArrowDown(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Calculate the coordinates of the arrow corners inside the image area
   //          int hw=(int)::floor(w/2);  // Half width
   //          if(hw==0)
   //             hw=1;

   //          int x1=x+1;                // X. Base (left point)
   //          int y1=y+4;                // Y. Left base point
   //          int x2=x1+hw;              // X. Apex (central lowest point)
   //          int y2=y+h-3;              // Y. Apex (lowest point)
   //          int x3=x1+w-1;             // X. Base (right point)
   //          int y3=y1;                 // Y. Base (right point)

   //       // --- Draw a triangle
   //          this.m_canvas.FillTriangle(x1, y1, x2, y2, x3, y3, ::ColorToARGB(clr, alpha));
   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;   
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws a filled left arrow |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::ArrowLeft(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Calculate the coordinates of the arrow corners inside the image area
   //          int hh=(int)::floor(h/2);  // Half height
   //          if(hh==0)
   //             hh=1;

   //          int x1=x+w-4;              // X. Base (right side)
   //          int y1=y+1;                // Y. Upper corner of base
   //          int x2=x+3;                // X. Vertex (left center point)
   //          int y2=y1+hh;              // Y. Center point (vertex)
   //          int x3=x1;                 // X. Bottom corner of base
   //          int y3=y1+h-1;             // Y. Bottom corner of base

   //       // --- Draw a triangle
   //          this.m_canvas.FillTriangle(x1, y1, x2, y2, x3, y3, ::ColorToARGB(clr, alpha));

   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws a filled right arrow |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::ArrowRight(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Calculate the coordinates of the arrow corners inside the image area
   //          int hh=(int)::floor(h/2);  // Half height
   //          if(hh==0)
   //             hh=1;

   //          int x1=x+4;                // X. Triangle base (left side)
   //          int y1=y+1;                // Y. Upper corner of base
   //          int x2=x+w-3;              // X. Vertex (right center point)
   //          int y2=y1+hh;              // Y. Center point (vertex)
   //          int x3=x1;                 // X. Bottom corner of base
   //          int y3=y1+h-1;             // Y. Bottom corner of base

   //       // --- Draw a triangle
   //          this.m_canvas.FillTriangle(x1, y1, x2, y2, x3, y3, ::ColorToARGB(clr, alpha));
   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws a horizontal 17x7 double arrow |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::ArrowHorz(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;
            
   //       // --- Shape coordinates
   //          int arrx[15]={0, 3, 4, 4, 12, 12, 13, 16, 13, 12, 12, 4, 4, 3, 0};
   //          int arry[15]={3, 0, 0, 2,  2,  0,  0,  3,  6,  6,  4, 4, 6, 6, 3};
            
   //       // --- Draw a white background
   //          this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

   //       // --- Draw a line of arrows
   //          this.m_canvas.Line(1,3, 15,3,::ColorToARGB(clr,alpha));
   //       // --- Draw the left triangle
   //          this.m_canvas.Line(1,3, 1,3,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(2,2, 2,4,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(3,1, 3,5,::ColorToARGB(clr,alpha));
   //       // --- Draw the right triangle
   //          this.m_canvas.Line(13,1, 13,5,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(14,2, 14,4,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(15,3, 15,3,::ColorToARGB(clr,alpha));
            
   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws a vertical 7x17 double arrow |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::ArrowVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Shape coordinates
   //          int arrx[15]={3, 6, 6, 4,  4,  6,  6,  3,  0,  0,  2, 2, 0, 0, 3};
   //          int arry[15]={0, 3, 4, 4, 12, 12, 13, 16, 13, 12, 12, 4, 4, 3, 0};
            
   //       // --- Draw a white background
   //          this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

   //       // --- Draw a line of arrows
   //          this.m_canvas.Line(3,1, 3,15,::ColorToARGB(clr,alpha));
   //       // --- Draw the upper triangle
   //          this.m_canvas.Line(3,1, 3,1,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(2,2, 4,2,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(1,3, 5,3,::ColorToARGB(clr,alpha));
   //       // --- Draw the lower triangle
   //          this.m_canvas.Line(1,13, 5,13,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(2,14, 4,14,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(3,15, 3,15,::ColorToARGB(clr,alpha));

   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws an 18x18 horizontal offset arrow |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::ArrowShiftHorz(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Shape coordinates
   //          int arrx[25]={0, 3, 4, 4, 7, 7, 10, 10, 13, 13, 14, 17, 17, 14, 13, 13, 10, 10,  7,  7,  4,  4,  3, 0, 0};
   //          int arry[25]={8, 5, 5, 7, 7, 0,  0,  7,  7,  5,  5,  8,  9, 12, 12, 10, 10, 17, 17, 10, 10, 12, 12, 9, 8};
            
   //       // --- Draw a white background
   //          this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

   //       // --- Draw a line of arrows
   //          this.m_canvas.FillRectangle(1,8, 16,9,::ColorToARGB(clr,alpha));
   //       // --- Draw a dividing line
   //          this.m_canvas.FillRectangle(8,1, 9,16,::ColorToARGB(clr,alpha));
   //       // --- Draw the left triangle
   //          this.m_canvas.Line(2,7, 2,10,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(3,6, 3,11,::ColorToARGB(clr,alpha));
   //       // --- Draw the right triangle
   //          this.m_canvas.Line(14,6, 14,11,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(15,7, 15,10,::ColorToARGB(clr,alpha));

   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws an 18x18 vertical offset arrow |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::ArrowShiftVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;
   //          ///*
   //       // --- Shape coordinates
   //          int arrx[25]={0, 7, 7, 5, 5, 8, 9, 12, 12, 10, 10, 17, 17, 10, 10, 12, 12,  9,  8,  5,  5,  7,  7,  0, 0};
   //          int arry[25]={7, 7, 4, 4, 3, 0, 0,  3,  4,  4,  7,  7, 10, 10, 13, 13, 14, 17, 17, 14, 13, 13, 10, 10, 7};
            
   //       // --- Draw a white background
   //          this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

   //       // --- Draw a dividing line
   //          this.m_canvas.FillRectangle(1,8, 16,9,::ColorToARGB(clr,alpha));
   //       // --- Draw a line of arrows
   //          this.m_canvas.FillRectangle(8,1, 9,16,::ColorToARGB(clr,alpha));
   //       // --- Draw the upper triangle
   //          this.m_canvas.Line(7,2, 10,2,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(6,3, 11,3,::ColorToARGB(clr,alpha));
   //       // --- Draw the lower triangle
   //          this.m_canvas.Line(6,14, 11,14,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(7,15, 10,15,::ColorToARGB(clr,alpha));

   //          if(update)
   //             this.m_canvas.Update(false);
   //          //*/
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws a diagonal top-left --- bottom-right |
   //    // | 13x13 double arrow (NorthWest-SouthEast) |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::ArrowNWSE(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Shape coordinates
   //          int arrx[19]={0, 4, 5, 4, 4, 9, 10, 11, 12, 12,  8,  7,  8, 8, 3, 2, 1, 0, 0};
   //          int arry[19]={0, 0, 1, 2, 3, 8,  8,  7,  8, 12, 12, 11, 10, 9, 4, 4, 5, 4, 0};
            
   //       // --- Draw a white background
   //          this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

   //       // --- Draw a line of arrows
   //          this.m_canvas.Line(3,3, 9,9,::ColorToARGB(clr,alpha));
   //       // --- Draw the upper-left triangle
   //          this.m_canvas.Line(1,1, 4,1,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(1,2, 3,2,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(1,3, 3,3,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(1,4, 1,4,::ColorToARGB(clr,alpha));
   //       // --- Draw the lower-right triangle
   //          this.m_canvas.Line(11,8, 11, 8,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(9, 9, 11, 9,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(9,10, 11,10,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(8,11, 11,11,::ColorToARGB(clr,alpha));

   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws a diagonal bottom-left --- up-right |
   //    // | 13x13 double arrow (NorthEast-SouthWest) |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::ArrowNESW(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Shape coordinates
   //          int arrx[19]={ 0, 0, 1, 2, 3, 8, 8, 7, 8, 12, 12, 11, 10, 9, 4,  4,  5,  4,  0};
   //          int arry[19]={12, 8, 7, 8, 8, 3, 2, 1, 0,  0,  4,  5,  4, 4, 9, 10, 11, 12, 12};
            
   //       // --- Draw a white background
   //          this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

   //       // --- Draw a line of arrows
   //          this.m_canvas.Line(3,9, 9,3,::ColorToARGB(clr,alpha));
   //       // --- Draw the lower-left triangle
   //          this.m_canvas.Line(1, 8, 1,8, ::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(1, 9, 3,9, ::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(1,10, 3,10,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(1,11, 4,11,::ColorToARGB(clr,alpha));
   //       // --- Draw the upper-right triangle
   //          this.m_canvas.Line(8, 1, 11,1,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(9, 2, 11,2,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(9, 3, 11,3,::ColorToARGB(clr,alpha));
   //          this.m_canvas.Line(11,4, 11,4,::ColorToARGB(clr,alpha));

   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws a checked CheckBox |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::CheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Rectangle coordinates
   //          int x1=x+1;                // Upper left corner, X
   //          int y1=y+1;                // Upper left corner, Y
   //          int x2=x+w-2;              // Bottom right corner, X
   //          int y2=y+h-2;              // Bottom right corner, Y

   //       // --- Draw a rectangle
   //          this.m_canvas.Rectangle(x1, y1, x2, y2, ::ColorToARGB(clr, alpha));
            
   //       // --- Coordinates of the "tick"
   //          int arrx[3], arry[3];
            
   //          arrx[0]=x1+(x2-x1)/4;      // X. Left point
   //          arrx[1]=x1+w/3;            // X. Center point
   //          arrx[2]=x2-(x2-x1)/4;      // X. Right point
            
   //          arry[0]=y1+1+(y2-y1)/2;    // Y. Left point
   //          arry[1]=y2-(y2-y1)/3;      // Y. Center point
   //          arry[2]=y1+(y2-y1)/3;      // Y. Right point
            
   //       // --- Draw a “tick” with a line of double thickness
   //          this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr, alpha));
   //          arrx[0]++;
   //          arrx[1]++;
   //          arrx[2]++;
   //          this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr, alpha));
            
   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws an unchecked CheckBox |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::UncheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Rectangle coordinates
   //          int x1=x+1;                // Upper left corner, X
   //          int y1=y+1;                // Upper left corner, Y
   //          int x2=x+w-2;              // Bottom right corner, X
   //          int y2=y+h-2;              // Bottom right corner, Y

   //       // --- Draw a rectangle
   //          this.m_canvas.Rectangle(x1, y1, x2, y2, ::ColorToARGB(clr, alpha));
            
   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws the marked RadioButton |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::CheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Coordinates and radius of the circle
   //          int x1=x+1;                // Upper left corner of the circle area, X
   //          int y1=y+1;                // Upper left corner of circle area, Y
   //          int x2=x+w-2;              // Lower right corner of circle area, X
   //          int y2=y+h-2;              // Bottom right corner of circle area, Y
            
   //       // --- Coordinates and radius of the circle
   //          int d=::fmin(x2-x1,y2-y1); // Diameter on the smaller side (width or height)
   //          int r=d/2;                 // Radius
   //          if(r<2)
   //             r=2;
   //          int cx=x1+r;               // X coordinate of center
   //          int cy=y1+r;               // Center Y coordinate

   //       // --- Draw a circle
   //          this.m_canvas.CircleWu(cx, cy, r, ::ColorToARGB(clr, alpha));
            
   //       // --- "Mark" radius
   //          r/=2;
   //          if(r<1)
   //             r=1;
   //       // --- Draw a mark
   //          this.m_canvas.FillCircle(cx, cy, r, ::ColorToARGB(clr, alpha));
            
   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Draws an unchecked RadioButton |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::UncheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Coordinates and radius of the circle
   //          int x1=x+1;                // Upper left corner of the circle area, X
   //          int y1=y+1;                // Upper left corner of circle area, Y
   //          int x2=x+w-2;              // Lower right corner of circle area, X
   //          int y2=y+h-2;              // Bottom right corner of circle area, Y
            
   //       // --- Coordinates and radius of the circle
   //          int d=::fmin(x2-x1,y2-y1); // Diameter on the smaller side (width or height)
   //          int r=d/2;                 // Radius
   //          int cx=x1+r;               // X coordinate of center
   //          int cy=y1+r;               // Center Y coordinate

   //       // --- Draw a circle
   //          this.m_canvas.CircleWu(cx, cy, r, ::ColorToARGB(clr, alpha));
            
   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | Draws a frame for a group of elements |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::FrameGroupElements(const int x,const int y,const int w,const int h,const string text,
   //                                           const color clr_text,const color clr_dark,const color clr_light,
   //                                           const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Y coordinate adjustment
   //          int tw=0, th=0;
   //          if(text!="" && text!=NULL)
   //             this.m_canvas.TextSize(text,tw,th);
   //          int shift_v=int(th!=0 ? ::ceil(th/2) : 0);

   //       // --- Frame coordinates and dimensions
   //          int x1=x;                  // Top left corner of frame area, X
   //          int y1=y+shift_v;          // Top left corner of frame area, Y
   //          int x2=x+w-1;              // Bottom right corner of frame area, X
   //          int y2=y+h-1;              // Bottom right corner of frame area, Y
            
   //       // --- Draw the left-upper part of the frame
   //          int arrx[3], arry[3];
   //          arrx[0]=arrx[1]=x1;
   //          arrx[2]=x2-1;
   //          arry[0]=y2;
   //          arry[1]=arry[2]=y1;
   //          this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr_dark, alpha));
   //          arrx[0]++;
   //          arrx[1]++;
   //          arry[1]++;
   //          arry[2]++;
   //          this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr_light, alpha));
   //       // --- Draw the bottom-right part of the frame
   //          arrx[0]=arrx[1]=x2-1;
   //          arrx[2]=x1+1;
   //          arry[0]=y1;
   //          arry[1]=arry[2]=y2-1;
   //          this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr_dark, alpha));
   //          arrx[0]++;
   //          arrx[1]++;
   //          arry[1]++;
   //          arry[2]++;
   //          this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr_light, alpha));
            
   //          if(tw>0)
   //             this.m_canvas.FillRectangle(x+5,y,x+7+tw,y+th,clrNULL);
   //          this.m_canvas.TextOut(x+6,y-1,text,::ColorToARGB(clr_text, alpha));
            
   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | Draws a filled triangle in the upper-left corner |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::TriangleLT(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Shape coordinates
   //          int x1=x;
   //          int y1=y+h;
   //          int x2=x1;
   //          int y2=y;
   //          int x3=x2+w;
   //          int y3=y2;
            
   //       // --- Draw a triangle
   //          this.m_canvas.FillTriangle(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,alpha));

   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | Draws a filled triangle in the lower-left corner |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::TriangleLB(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Shape coordinates
   //          int x1=x;
   //          int y1=y;
   //          int x2=x1+w;
   //          int y2=y1+h;
   //          int x3=x1;
   //          int y3=y2;
            
   //       // --- Draw a triangle
   //          this.m_canvas.FillTriangle(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,alpha));

   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | Draws a filled triangle in the upper right corner |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::TriangleRT(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Shape coordinates
   //          int x1=x;
   //          int y1=y;
   //          int x2=x1+w;
   //          int y2=y;
   //          int x3=x2;
   //          int y3=y2+h;
            
   //       // --- Draw a triangle
   //          this.m_canvas.FillTriangle(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,alpha));

   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | Draws a filled triangle in the lower-right corner |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::TriangleRB(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   //       {
   //       // --- If the image area is not valid, return false
   //          if(!this.CheckBound(__FUNCTION__))
   //             return false;

   //       // --- Shape coordinates
   //          int x1=x+w;
   //          int y1=y;
   //          int x2=x1;
   //          int y2=y+h;
   //          int x3=x;
   //          int y3=y2;
            
   //       // --- Draw a triangle
   //          this.m_canvas.FillTriangle(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,alpha));

   //          if(update)
   //             this.m_canvas.Update(false);
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Saving to file |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::Save(const int file_handle)
   //       {
   //       // --- Save the data of the parent object
   //          if(!CBaseObj::Save(file_handle))
   //             return false;
         
   //       // --- Maintaining transparency
   //          if(::FileWriteInteger(file_handle,this.m_alpha,INT_VALUE)!=INT_VALUE)
   //             return false;
   //       // --- Save area data
   //          if(!this.m_bound.Save(file_handle))
   //             return false;
               
   //       // --- Everything is successful
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CImagePainter::Loading from file |
   //    //+------------------------------------------------------------------+
   //    bool CImagePainter::Load(const int file_handle)
   //       {
   //       // --- Loading the data of the parent object
   //          if(!CBaseObj::Load(file_handle))
   //             return false;
               
   //       // --- Loading transparency
   //          this.m_alpha=(uchar)::FileReadInteger(file_handle,INT_VALUE);
   //       // --- Loading area data
   //          if(!this.m_bound.Load(file_handle))
   //             return false;
            
   //       // --- Everything is successful
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   // #endif // CIMAGEPAINTER_IMPLEMENTATION
#endif // MOVE_TO_IMAGEPAINTER_MQH

//+------------------------------------------------------------------+
// | Classes |
//+------------------------------------------------------------------+

#ifndef MOVE_TO_ELEMENTBASE_MQH
#define MOVE_TO_ELEMENTBASE_MQH
      // //+------------------------------------------------------------------+
   // // | Graphic element base class |
   // //+------------------------------------------------------------------+
   // class CElementBase : public CCanvasBase
   //    {
   //    protected:
   //       CImagePainter     m_painter;                                // Drawing class
   //       CListElm          m_list_hints;                             // List of hints
   //       int               m_group;                                  // Group of elements
   //       bool              m_visible_in_container;                   // Container visibility flag

   //    // --- Adds the specified tooltip object to the list
   //       bool              AddHintToList(CVisualHint *obj);
   //    // --- Creates and adds a new tooltip object to the list
   //       CVisualHint      *CreateAndAddNewHint(const ENUM_HINT_TYPE type, const string user_name, const int w, const int h);
   //    // --- Adds an existing tooltip object to the list
   //       CVisualHint      *AddHint(CVisualHint *obj, const int dx, const int dy);
   //    // --- (1) Adds to the list, (2) removes arrow tooltip objects from the list
   //       virtual bool      AddHintsArrowed(void);
   //       bool              DeleteHintsArrowed(void);
   //    // --- Displays resizing cursor
   //       virtual bool      ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y);
         
   //    // --- Handler for dragging edges and corners of an element
   //       virtual void      ResizeActionDragHandler(const int x, const int y);
         
   //    // --- Handlers for resizing an element by sides and corners
   //       virtual bool      ResizeZoneLeftHandler(const int x, const int y);
   //       virtual bool      ResizeZoneRightHandler(const int x, const int y);
   //       virtual bool      ResizeZoneTopHandler(const int x, const int y);
   //       virtual bool      ResizeZoneBottomHandler(const int x, const int y);
   //       virtual bool      ResizeZoneLeftTopHandler(const int x, const int y);
   //       virtual bool      ResizeZoneRightTopHandler(const int x, const int y);
   //       virtual bool      ResizeZoneLeftBottomHandler(const int x, const int y);
   //       virtual bool      ResizeZoneRightBottomHandler(const int x, const int y);
         
   //    // --- Returns a pointer to a hint by (1) index, (2) identifier, (3) name
   //       CVisualHint      *GetHintAt(const int index);
   //       CVisualHint      *GetHint(const int id);
   //       CVisualHint      *GetHint(const string name);

   //    // --- Creates a new tooltip
   //       CVisualHint      *CreateNewHint(const ENUM_HINT_TYPE type, const string object_name, const string user_name, const int id, const int x, const int y, const int w, const int h);
   //    // --- (1) Displays the specified tooltip with arrows, (2) hides all tooltips
   //       void              ShowHintArrowed(const ENUM_HINT_TYPE type,const int x,const int y);
   //       void              HideHintsAll(const bool chart_redraw);

   //    public:
   //    // --- Returns itself
   //       CElementBase     *GetObject(void)                           { return &this;                     }
   //    // --- Returns a pointer to (1) the drawing class, (2) the list of tooltips
   //       CImagePainter    *Painter(void)                             { return &this.m_painter;           }
   //       CListElm         *GetListHints(void)                        { return &this.m_list_hints;        }

   //    // --- Creates and adds (1) a new, (2) a previously created tooltip object (tooltip only) to the list
   //       CVisualHint      *InsertNewTooltip(const ENUM_HINT_TYPE type, const string user_name, const int w, const int h);
   //       CVisualHint      *InsertTooltip(CVisualHint *obj, const int dx, const int dy);

   //    // --- (1) Sets coordinates, (2) resizes image area
   //       void              SetImageXY(const int x,const int y)       { this.m_painter.SetXY(x,y);        }
   //       void              SetImageSize(const int w,const int h)     { this.m_painter.SetSize(w,h);      }
   //    // --- Sets the coordinates and dimensions of the image area
   //       void              SetImageBound(const int x,const int y,const int w,const int h)
   //                         {
   //                            this.SetImageXY(x,y);
   //                            this.SetImageSize(w,h);
   //                         }
   //    // --- Returns the coordinates of the (1) X, (2) Y, (3) width, (4) height, (5) right, (6) bottom border of the image area
   //       int               ImageX(void)                        const { return this.m_painter.X();        }
   //       int               ImageY(void)                        const { return this.m_painter.Y();        }
   //       int               ImageWidth(void)                    const { return this.m_painter.Width();    }
   //       int               ImageHeight(void)                   const { return this.m_painter.Height();   }
   //       int               ImageRight(void)                    const { return this.m_painter.Right();    }
   //       int               ImageBottom(void)                   const { return this.m_painter.Bottom();   }

   //    // --- (1) Sets, (2) returns a group of elements
   //       virtual void      SetGroup(const int group)                 { this.m_group=group;               }
   //       int               Group(void)                         const { return this.m_group;              }
         
   //    // --- Sets the resizing flag
   //       virtual void      SetResizable(const bool flag);
         
   //    // --- (1) Sets, (2) returns the visibility flag in the container
   //       virtual void      SetVisibleInContainer(const bool flag)    { this.m_visible_in_container=flag; }
   //       bool              IsVisibleInContainer(void)          const { return this.m_visible_in_container;}

   //    // --- Returns a description of the object
   //       virtual string    Description(void);
         
   //    // --- Resize handler
   //       virtual void      OnResizeZoneEvent(const int id, const long lparam, const double dparam, const string sparam);
         
   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0) const;
   //       virtual bool      Save(const int file_handle);
   //       virtual bool      Load(const int file_handle);
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_ELEMENT_BASE);}

   //    // --- Constructors/destructor
   //                         CElementBase(void) { this.m_painter.CanvasAssign(this.GetForeground()); this.m_visible_in_container=true; }
   //                         CElementBase(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                         ~CElementBase(void) { this.m_list_hints.Clear(); }
   //    };
   // #ifndef CELEMENTBASE_IMPLEMENTATION
   // #define CELEMENTBASE_IMPLEMENTATION
   //    //+-----------------------------------------------------------------------+
   //    // | CElementBase::Parametric constructor. Builds an element at the specified |
   //    // | window of the specified graph with the specified text, coordinates and dimensions|
   //    //+-----------------------------------------------------------------------+
   //    CElementBase::CElementBase(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CCanvasBase(object_name,chart_id,wnd,x,y,w,h),m_group(-1)
   //    {
   //       // --- Assign the foreground canvas to the drawing object and
   //       // --- reset the coordinates and dimensions, which makes it inactive,
   //       // --- set the visibility flag of the element in the container
   //          this.m_painter.CanvasAssign(this.GetForeground());
   //          this.m_painter.SetXY(0,0);
   //          this.m_painter.SetSize(0,0);
   //          this.m_visible_in_container=true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CElementBase::Compare(const CObject *node,const int mode=0) const
   //    {
   //       if(node==NULL)
   //          return -1;
   //       const CElementBase *obj=node;
   //       switch(mode)
   //       {
   //          case ELEMENT_SORT_BY_NAME     :  return(this.Name()         >obj.Name()          ? 1 : this.Name()          <obj.Name()          ? -1 : 0);
   //          case ELEMENT_SORT_BY_X        :  return(this.X()            >obj.X()             ? 1 : this.X()             <obj.X()             ? -1 : 0);
   //          case ELEMENT_SORT_BY_Y        :  return(this.Y()            >obj.Y()             ? 1 : this.Y()             <obj.Y()             ? -1 : 0);
   //          case ELEMENT_SORT_BY_WIDTH    :  return(this.Width()        >obj.Width()         ? 1 : this.Width()         <obj.Width()         ? -1 : 0);
   //          case ELEMENT_SORT_BY_HEIGHT   :  return(this.Height()       >obj.Height()        ? 1 : this.Height()        <obj.Height()        ? -1 : 0);
   //          case ELEMENT_SORT_BY_COLOR_BG :  return(this.BackColor()    >obj.BackColor()     ? 1 : this.BackColor()     <obj.BackColor()     ? -1 : 0);
   //          case ELEMENT_SORT_BY_COLOR_FG :  return(this.ForeColor()    >obj.ForeColor()     ? 1 : this.ForeColor()     <obj.ForeColor()     ? -1 : 0);
   //          case ELEMENT_SORT_BY_ALPHA_BG :  return(this.AlphaBG()      >obj.AlphaBG()       ? 1 : this.AlphaBG()       <obj.AlphaBG()       ? -1 : 0);
   //          case ELEMENT_SORT_BY_ALPHA_FG :  return(this.AlphaFG()      >obj.AlphaFG()       ? 1 : this.AlphaFG()       <obj.AlphaFG()       ? -1 : 0);
   //          case ELEMENT_SORT_BY_STATE    :  return(this.State()        >obj.State()         ? 1 : this.State()         <obj.State()         ? -1 : 0);
   //          case ELEMENT_SORT_BY_GROUP    :  return(this.Group()        >obj.Group()         ? 1 : this.Group()         <obj.Group()         ? -1 : 0);
   //          case ELEMENT_SORT_BY_ZORDER   :  return(this.ObjectZOrder() >obj.ObjectZOrder()  ? 1 : this.ObjectZOrder()  <obj.ObjectZOrder()  ? -1 : 0);
   //          default                       :  return(this.ID()           >obj.ID()            ? 1 : this.ID()            <obj.ID()            ? -1 : 0);
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Returns the object description |
   //    //+------------------------------------------------------------------+
   //    string CElementBase::Description(void)
   //    {
   //       string nm=this.Name();
   //       string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   //       string area=::StringFormat("x %d, y %d, w %d, h %d, right %d, bottom %d",this.X(),this.Y(),this.Width(),this.Height(),this.Right(),this.Bottom());
   //       return ::StringFormat("%s%s (%s, %s): ID %d, Group %d, %s",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.NameBG(),this.NameFG(),this.ID(),this.Group(),area);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Sets the resizability flag |
   //    //+------------------------------------------------------------------+
   //    void CElementBase::SetResizable(const bool flag)
   //    {
   //       // --- Write a flag to the parent object
   //          CCanvasBase::SetResizable(flag);
   //       // --- If the flag is passed as true, we create four tooltips with arrows for the cursor,
   //          if(flag)
   //             this.AddHintsArrowed();
   //       // --- otherwise - remove hints with arrows for the cursor
   //          else
   //             this.DeleteHintsArrowed();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Returns a pointer to the tooltip by index |
   //    //+------------------------------------------------------------------+
   //    CVisualHint *CElementBase::GetHintAt(const int index)
   //    {
   //       return this.m_list_hints.GetNodeAtIndex(index);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Returns a pointer to a tooltip by ID|
   //    //+------------------------------------------------------------------+
   //    CVisualHint *CElementBase::GetHint(const int id)
   //    {
   //       int total=this.m_list_hints.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          CVisualHint *obj=this.GetHintAt(i);
   //          if(obj!=NULL && obj.ID()==id)
   //             return obj;
   //       }
   //       return NULL;
   //    }
   //    //+------------------------------------------------------------------+
   //    // |CElementBase:: Returns a pointer to the name hint |
   //    //+------------------------------------------------------------------+
   //    CVisualHint *CElementBase::GetHint(const string name)
   //    {
   //       int total=this.m_list_hints.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          CVisualHint *obj=this.GetHintAt(i);
   //          if(obj!=NULL && obj.Name()==name)
   //             return obj;
   //       }
   //       return NULL;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Adds the specified tooltip object to the list |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::AddHintToList(CVisualHint *obj)
   //    {
   //    // --- If an empty pointer is passed, we report this and return false
   //       if(obj==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
   //          return false;
   //       }
   //    // --- Remember the list sorting method
   //       int sort_mode=this.m_list_hints.SortMode();
   //    // --- Set the list to sort by identifier
   //       this.m_list_hints.Sort(ELEMENT_SORT_BY_ID);
   //    // --- If such element is not in the list,
   //       if(this.m_list_hints.Search(obj)==NULL)
   //       {
   //          // --- return the list to its original sorting and return the result of adding it to the list
   //          this.m_list_hints.Sort(sort_mode);
   //          return(this.m_list_hints.Add(obj)>-1);
   //       }
   //    // --- Return the list to its original sorting
   //       this.m_list_hints.Sort(sort_mode);
   //    // --- An element with the same identifier is already in the list - return false
   //       return false;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Creates a new tooltip |
   //    //+------------------------------------------------------------------+
   //    CVisualHint *CElementBase::CreateNewHint(const ENUM_HINT_TYPE type,const string object_name,const string user_name,const int id, const int x,const int y,const int w,const int h)
   //    {
   //    // --- Create a new tooltip object
   //       CVisualHint *obj=new CVisualHint(object_name,this.m_chart_id,this.m_wnd,x,y,w,h);
   //       if(obj==NULL)
   //       {
   //          ::PrintFormat("%s: Error: Failed to create Hint object",__FUNCTION__);
   //          return NULL;
   //       }
   //    // --- Set the identifier, name and type of tooltip
   //       obj.SetID(id);
   //       obj.SetName(user_name);
   //       obj.SetHintType(type);
         
   //    // --- Return a pointer to the created object
   //       return obj;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Creates and adds a new tooltip object to the list|
   //    //+------------------------------------------------------------------+
   //    CVisualHint *CElementBase::CreateAndAddNewHint(const ENUM_HINT_TYPE type,const string user_name,const int w,const int h)
   //    {
   //    // --- Create a name for the graphic object
   //       int obj_total=this.m_list_hints.Total();
   //       string obj_name=this.NameFG()+"_HNT"+(string)obj_total;
         
   //    // --- Calculate the coordinates of the object below and to the right of the lower right corner of the element
   //       int x=this.Right()+1;
   //       int y=this.Bottom()+1;
         
   //    // --- Create a new tooltip object
   //       CVisualHint *obj=this.CreateNewHint(type,obj_name,user_name,obj_total,x,y,w,h);
         
   //    // --- If a new object is not created, return NULL
   //       if(obj==NULL)
   //          return NULL;

   //    // --- Set image limits, container and z-order
   //       obj.SetImageBound(0,0,this.Width(),this.Height());
   //       obj.SetContainerObj(&this);
   //       obj.ObjectSetZOrder(this.ObjectZOrder()+1);

   //    // --- If the created element is not added to the list, we report this, delete the created element and return NULL
   //       if(!this.AddHintToList(obj))
   //       {
   //          ::PrintFormat("%s: Error. Failed to add Hint object with ID %d to list",__FUNCTION__,obj.ID());
   //          delete obj;
   //          return NULL;
   //       }
         
   //    // --- Return a pointer to the created and attached object
   //       return obj;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Adds an existing tooltip object to the list |
   //    //+------------------------------------------------------------------+
   //    CVisualHint *CElementBase::AddHint(CVisualHint *obj,const int dx,const int dy)
   //    {
   //    // --- If an object is passed that does not have a hint type, we return NULL
   //       if(obj.Type()!=ELEMENT_TYPE_HINT)
   //       {
   //          ::PrintFormat("%s: Error. Only an object with the Hint type can be used here. The element type \"%s\" was passed",__FUNCTION__,ElementDescription((ENUM_ELEMENT_TYPE)obj.Type()));
   //          return NULL;
   //       }
   //    // --- Remember the object identifier and set a new one
   //       int id=obj.ID();
   //       obj.SetID(this.m_list_hints.Total());
         
   //    // --- Add an object to the list; if it fails, we report this, set the initial identifier and return NULL
   //       if(!this.AddHintToList(obj))
   //       {
   //          ::PrintFormat("%s: Error. Failed to add Hint object to list",__FUNCTION__);
   //          obj.SetID(id);
   //          return NULL;
   //       }
   //    // --- Set new coordinates, container and z-order of the object
   //       int x=this.X()+dx;
   //       int y=this.Y()+dy;
   //       obj.Move(x,y);
   //       obj.SetContainerObj(&this);
   //       obj.ObjectSetZOrder(this.ObjectZOrder()+1);
         
   //    // --- Return a pointer to the attached object
   //       return obj;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Adds arrow tooltip objects to the list |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::AddHintsArrowed(void)
   //    {
   //    // --- Arrays of names and types of hints
   //       string array[4]={DEF_HINT_NAME_HORZ,DEF_HINT_NAME_VERT,DEF_HINT_NAME_NWSE,DEF_HINT_NAME_NESW};
         
   //       ENUM_HINT_TYPE type[4]={HINT_TYPE_ARROW_HORZ,HINT_TYPE_ARROW_VERT,HINT_TYPE_ARROW_NWSE,HINT_TYPE_ARROW_NESW};
         
   //    // --- In a loop we create four tooltips with arrows
   //       bool res=true;
   //       for(int i=0;i<(int)array.Size();i++)
   //          res &=(this.CreateAndAddNewHint(type[i],array[i],0,0)!=NULL);
            
   //    // --- If there were errors during creation, return false
   //       if(!res)
   //          return false;
            
   //    // --- In a loop through an array of names of hint objects
   //       for(int i=0;i<(int)array.Size();i++)
   //       {
   //          // --- we get the next object by name,
   //          CVisualHint *obj=this.GetHint(array[i]);
   //          if(obj==NULL)
   //             continue;
   //          // --- hide the object and draw the appearance (arrows according to the type of object)
   //          obj.Hide(false);
   //          obj.Draw(false);
   //       }
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Removes arrow tooltip objects from the list |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::DeleteHintsArrowed(void)
   //    {
   //    // --- In a loop through a list of hint objects
   //       bool res=true;
   //       for(int i=this.m_list_hints.Total()-1;i>=0;i--)
   //       {
   //          // --- we get another object and, if it is not a tooltip, we delete it
   //          CVisualHint *obj=this.m_list_hints.GetNodeAtIndex(i);
   //          if(obj!=NULL && obj.HintType()!=HINT_TYPE_TOOLTIP)
   //             res &=this.m_list_hints.DeleteCurrent();
   //       }
   //    // --- Return the result of removing tooltips with arrows
   //       return res;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Creates and adds a new tooltip object to the list|
   //    //+------------------------------------------------------------------+
   //    CVisualHint *CElementBase::InsertNewTooltip(const ENUM_HINT_TYPE type,const string user_name,const int w,const int h)
   //    {
   //    // --- If the tooltip type is not a tooltip, we report this and return NULL
   //       if(type!=HINT_TYPE_TOOLTIP)
   //       {
   //          ::PrintFormat("%s: Error. Only a tooltip can be added to an element",__FUNCTION__);
   //          return NULL;
   //       }
   //    // --- Create and add a new hint object to the list;
   //    // --- Return a pointer to the created and attached object
   //       return this.CreateAndAddNewHint(type,user_name,w,h);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Adds a previously created tooltip object to the list|
   //    //+------------------------------------------------------------------+
   //    CVisualHint *CElementBase::InsertTooltip(CVisualHint *obj,const int dx,const int dy)
   //    {
   //       // --- If an empty or invalid pointer to an object is passed, return NULL
   //          if(::CheckPointer(obj)==POINTER_INVALID)
   //          {
   //             ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
   //             return NULL;
   //          }
   //       // --- If the tooltip type is not tooltype, we report this and return NULL
   //          if(obj.HintType()!=HINT_TYPE_TOOLTIP)
   //          {
   //             ::PrintFormat("%s: Error. Only a tooltip can be added to an element",__FUNCTION__);
   //             return NULL;
   //          }
   //       // --- Add the specified hint object to the list;
   //       // --- Return a pointer to the created and attached object
   //          return this.AddHint(obj,dx,dy);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Displays the specified tooltip |
   //    // | at the specified coordinates |
   //    //+------------------------------------------------------------------+
   //    void CElementBase::ShowHintArrowed(const ENUM_HINT_TYPE type,const int x,const int y)
   //    {
   //          CVisualHint *hint=NULL; // Pointer to the object being searched for
   //       // --- In a loop through a list of tooltip objects
   //          for(int i=0;i<this.m_list_hints.Total();i++)
   //          {
   //             // --- get a pointer to the next object
   //             CVisualHint *obj=this.GetHintAt(i);
   //             if(obj==NULL)
   //                continue;
   //             // --- If this is the type of hint you are looking for, remember the pointer,
   //             if(obj.HintType()==type)
   //                hint=obj;
   //             // --- otherwise - hide the object
   //             else
   //                obj.Hide(false);
   //          }
   //       // --- If the desired object is found and it is hidden
   //          if(hint!=NULL && hint.IsHidden())
   //          {
   //             // --- place the object at the specified coordinates,
   //             // --- draw the appearance and bring the object to the foreground, making it visible
   //             hint.Move(x,y);
   //             hint.Draw(false);
   //             hint.BringToTop(true);
   //          }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Hide all tooltips |
   //    //+------------------------------------------------------------------+
   //    void CElementBase::HideHintsAll(const bool chart_redraw)
   //       {
   //       // --- In a loop through a list of hint objects
   //          for(int i=0;i<this.m_list_hints.Total();i++)
   //          {
   //             // --- get another object and hide it
   //             CVisualHint *obj=this.GetHintAt(i);
   //             if(obj!=NULL)
   //                obj.Hide(false);
   //          }
   //       // --- If indicated, redraw the graph
   //          if(chart_redraw)
   //             ::ChartRedraw(this.m_chart_id);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Displays resizing cursor |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y)
   //       {
   //             CVisualHint *hint=NULL;          // Pointer to tooltip
   //             int hint_shift_x=0;              // Tooltip X offset
   //             int hint_shift_y=0;              // Tooltip Y Offset
               
   //          // --- Depending on the location of the cursor on the borders of the element
   //          // --- indicate the offset of the tooltip relative to the cursor coordinates,
   //          // --- display the required hint on the chart and get a pointer to this object
   //             switch(edge)
   //             {
   //                // --- Cursor on the right or left border - horizontal double arrow
   //                case CURSOR_REGION_RIGHT         :
   //                case CURSOR_REGION_LEFT          :
   //                   hint_shift_x=1;
   //                   hint_shift_y=18;
   //                   this.ShowHintArrowed(HINT_TYPE_ARROW_HORZ,x+hint_shift_x,y+hint_shift_y);
   //                   hint=this.GetHint(DEF_HINT_NAME_HORZ);
   //                break;
               
   //                // --- Cursor on the top or bottom border - vertical double arrow
   //                case CURSOR_REGION_TOP           :
   //                case CURSOR_REGION_BOTTOM        :
   //                   hint_shift_x=12;
   //                   hint_shift_y=4;
   //                   this.ShowHintArrowed(HINT_TYPE_ARROW_VERT,x+hint_shift_x,y+hint_shift_y);
   //                   hint=this.GetHint(DEF_HINT_NAME_VERT);
   //                break;
               
   //                // --- Cursor in the upper left or lower right corner - diagonal double arrow from top left to bottom right
   //                case CURSOR_REGION_LEFT_TOP      :
   //                case CURSOR_REGION_RIGHT_BOTTOM  :
   //                   hint_shift_x=10;
   //                   hint_shift_y=2;
   //                   this.ShowHintArrowed(HINT_TYPE_ARROW_NWSE,x+hint_shift_x,y+hint_shift_y);
   //                   hint=this.GetHint(DEF_HINT_NAME_NWSE);
   //                break;
               
   //                // --- Cursor in the lower left or upper right corner - diagonal double arrow from bottom left to top right
   //                case CURSOR_REGION_LEFT_BOTTOM   :
   //                case CURSOR_REGION_RIGHT_TOP     :
   //                   hint_shift_x=5;
   //                   hint_shift_y=12;
   //                   this.ShowHintArrowed(HINT_TYPE_ARROW_NESW,x+hint_shift_x,y+hint_shift_y);
   //                   hint=this.GetHint(DEF_HINT_NAME_NESW);
   //                break;
                  
   //                // --- By default we do nothing
   //                default: break;
   //             }

   //          // --- Return the result of adjusting the position of the tooltip relative to the cursor
   //             return(hint!=NULL ? hint.Move(x+hint_shift_x,y+hint_shift_y) : false);
   //       }
   //    //+------------------------------------------------------------------+
   //    //| CElementBase::Resizing Handler |
   //    //+------------------------------------------------------------------+
   //    void CElementBase::OnResizeZoneEvent(const int id,const long lparam,const double dparam,const string sparam)
   //       {
   //             int x=(int)lparam;               // X coordinate of cursor
   //             int y=(int)dparam;               // Cursor Y coordinate
   //             int shift_x=0;                   // Tooltip X offset
   //             int shift_y=0;                   // Tooltip Y Offset
               
   //          // --- Get the cursor position relative to the element's boundaries and the interaction mode
   //             ENUM_CURSOR_REGION edge=(this.ResizeRegion()==CURSOR_REGION_NONE ? this.CheckResizeZone(x,y) : this.ResizeRegion());
   //             ENUM_RESIZE_ZONE_ACTION action=(ENUM_RESIZE_ZONE_ACTION)id;
               
   //          // --- If the cursor is outside the resizing boundaries or just hovered over the interaction zone
   //             if(action==RESIZE_ZONE_ACTION_NONE || (action==RESIZE_ZONE_ACTION_HOVER && edge==CURSOR_REGION_NONE))
   //             {
   //                // --- disable resizing mode and interaction region,
   //                // --- hide all hints
   //                this.SetResizeMode(false);
   //                this.SetResizeRegion(CURSOR_REGION_NONE);
   //                this.HideHintsAll(true);
   //             }

   //          // --- Cursor on one of the resizing boundaries
   //             if(action==RESIZE_ZONE_ACTION_HOVER)
   //             {
   //                // --- Display a tooltip with an arrow for the interaction region
   //                if(this.ShowCursorHint(edge,x,y))
   //                   ::ChartRedraw(this.m_chart_id);
   //             }
               
   //          // ---Start resizing
   //             if(action==RESIZE_ZONE_ACTION_BEGIN)
   //             {
   //                // --- enable resizing mode and interaction region,
   //                // --- display the corresponding cursor tooltip
   //                this.SetResizeMode(true);
   //                this.SetResizeRegion(edge);
   //                this.ShowCursorHint(edge,x,y);
   //             }
               
   //          // ---Drag an object's border to resize an element
   //             if(action==RESIZE_ZONE_ACTION_DRAG)
   //             {
   //                // --- Call the handler for dragging the boundaries of the object to change its size,
   //                // --- display the corresponding cursor tooltip
   //                this.ResizeActionDragHandler(x,y);
   //                this.ShowCursorHint(edge,x,y);
   //             }
   //       }
   //    //+------------------------------------------------------------------+
   //    //| CElementBase::Element edges and corners drag handler |
   //    //+------------------------------------------------------------------+
   //    void CElementBase::ResizeActionDragHandler(const int x, const int y)
   //       {
   //          // --- Resizing beyond the right border
   //             if(this.ResizeRegion()==CURSOR_REGION_RIGHT)
   //                this.ResizeZoneRightHandler(x,y);
   //          // --- Resizing beyond the bottom border
   //             if(this.ResizeRegion()==CURSOR_REGION_BOTTOM)
   //                this.ResizeZoneBottomHandler(x,y);
   //          // --- Resizing beyond the left border
   //             if(this.ResizeRegion()==CURSOR_REGION_LEFT)
   //                this.ResizeZoneLeftHandler(x,y);
   //          // --- Resizing beyond the top border
   //             if(this.ResizeRegion()==CURSOR_REGION_TOP)
   //                this.ResizeZoneTopHandler(x,y);
   //          // --- Resizing by the lower right corner
   //             if(this.ResizeRegion()==CURSOR_REGION_RIGHT_BOTTOM)
   //                this.ResizeZoneRightBottomHandler(x,y);
   //          // --- Resizing by the upper right corner
   //             if(this.ResizeRegion()==CURSOR_REGION_RIGHT_TOP)
   //                this.ResizeZoneRightTopHandler(x,y);
   //          // --- Resizing by the lower left corner
   //             if(this.ResizeRegion()==CURSOR_REGION_LEFT_BOTTOM)
   //                this.ResizeZoneLeftBottomHandler(x,y);
   //          // --- Resizing by the upper left corner
   //             if(this.ResizeRegion()==CURSOR_REGION_LEFT_TOP)
   //                this.ResizeZoneLeftTopHandler(x,y);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Right resize handler |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::ResizeZoneRightHandler(const int x,const int y)
   //    {
   //       // --- Calculate and set the new width of the element
   //          int width=::fmax(x-this.X()+1,DEF_PANEL_MIN_W);
   //          if(!this.ResizeW(width))
   //             return false;
   //       // --- Get a pointer to a hint
   //          CVisualHint *hint=this.GetHint(DEF_HINT_NAME_HORZ);
   //          if(hint==NULL)
   //             return false;
   //       // --- Shift the tooltip by the specified amounts relative to the cursor
   //          int shift_x=1;
   //          int shift_y=18;
   //          return hint.Move(x+shift_x,y+shift_y);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Handler for resizing beyond the bottom edge |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::ResizeZoneBottomHandler(const int x,const int y)
   //       {
   //          // --- Calculate and set the new height of the element
   //             int height=::fmax(y-this.Y(),DEF_PANEL_MIN_H);
   //             if(!this.ResizeH(height))
   //                return false;
   //          // --- Get a pointer to a hint
   //             CVisualHint *hint=this.GetHint(DEF_HINT_NAME_VERT);
   //             if(hint==NULL)
   //                return false;
   //          // --- Shift the tooltip by the specified amounts relative to the cursor
   //             int shift_x=12;
   //             int shift_y=4;
   //             return hint.Move(x+shift_x,y+shift_y);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Resizing beyond the left edge |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::ResizeZoneLeftHandler(const int x,const int y)
   //       {
   //          // --- Calculate the new X coordinate and width of the element
   //             int new_x=::fmin(x,this.Right()-DEF_PANEL_MIN_W+1);
   //             int width=this.Right()-new_x+1;
   //          // --- Set new X coordinate and element width
   //             if(!this.MoveXYWidthResize(new_x,this.Y(),width,this.Height()))
   //                return false;
   //          // --- Get a pointer to a hint
   //             CVisualHint *hint=this.GetHint(DEF_HINT_NAME_HORZ);
   //             if(hint==NULL)
   //                return false;
   //          // --- Shift the tooltip by the specified amounts relative to the cursor
   //             int shift_x=1;
   //             int shift_y=18;
   //             return hint.Move(x+shift_x,y+shift_y);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Resizing beyond the top edge |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::ResizeZoneTopHandler(const int x,const int y)
   //       {
   //          // --- Calculate the new Y coordinate and height of the element
   //             int new_y=::fmin(y,this.Bottom()-DEF_PANEL_MIN_H+1);
   //             int height=this.Bottom()-new_y+1;
   //          // --- Set new Y coordinate and element height
   //             if(!this.MoveXYWidthResize(this.X(),new_y,this.Width(),height))
   //                return false;
   //          // --- Get a pointer to a hint
   //             CVisualHint *hint=this.GetHint(DEF_HINT_NAME_VERT);
   //             if(hint==NULL)
   //                return false;
   //          // --- Shift the tooltip by the specified amounts relative to the cursor
   //             int shift_x=12;
   //             int shift_y=4;
   //             return hint.Move(x+shift_x,y+shift_y);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Resize for lower right corner |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::ResizeZoneRightBottomHandler(const int x,const int y)
   //       {
   //          // --- Calculate and set the new width and height of the element
   //             int width =::fmax(x-this.X()+1, DEF_PANEL_MIN_W);
   //             int height=::fmax(y-this.Y()+1, DEF_PANEL_MIN_H);
   //             if(!this.Resize(width,height))
   //                return false;
   //          // --- Get a pointer to a hint
   //             CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NWSE);
   //             if(hint==NULL)
   //                return false;
   //          // --- Shift the tooltip by the specified amounts relative to the cursor
   //             int shift_x=10;
   //             int shift_y=2;
   //             return hint.Move(x+shift_x,y+shift_y);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Resizing for the upper right corner |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::ResizeZoneRightTopHandler(const int x,const int y)
   //       {
   //          // --- Calculate and set new Y coordinates, width and height of the element
   //             int new_y=::fmin(y, this.Bottom()-DEF_PANEL_MIN_H+1);
   //             int width =::fmax(x-this.X()+1, DEF_PANEL_MIN_W);
   //             int height=this.Bottom()-new_y+1;
   //             if(!this.MoveXYWidthResize(this.X(),new_y,width,height))
   //                return false;
   //          // --- Get a pointer to a hint
   //             CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NESW);
   //             if(hint==NULL)
   //                return false;
   //          // --- Shift the tooltip by the specified amounts relative to the cursor
   //             int shift_x=5;
   //             int shift_y=12;
   //             return hint.Move(x+shift_x,y+shift_y);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Resize to bottom left corner |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::ResizeZoneLeftBottomHandler(const int x,const int y)
   //       {
   //          // --- Calculate and set new X coordinates, width and height of the element
   //             int new_x=::fmin(x, this.Right()-DEF_PANEL_MIN_W+1);
   //             int width =this.Right()-new_x+1;
   //             int height=::fmax(y-this.Y()+1, DEF_PANEL_MIN_H);
   //             if(!this.MoveXYWidthResize(new_x,this.Y(),width,height))
   //                return false;
   //          // --- Get a pointer to a hint
   //             CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NESW);
   //             if(hint==NULL)
   //                return false;
   //          // --- Shift the tooltip by the specified amounts relative to the cursor
   //             int shift_x=5;
   //             int shift_y=12;
   //             return hint.Move(x+shift_x,y+shift_y);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Resize by upper left corner |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::ResizeZoneLeftTopHandler(const int x,const int y)
   //       {
   //          // --- Calculate and set new X and Y coordinates, width and height of the element
   //             int new_x=::fmin(x,this.Right()-DEF_PANEL_MIN_W+1);
   //             int new_y=::fmin(y,this.Bottom()-DEF_PANEL_MIN_H+1);
   //             int width =this.Right() -new_x+1;
   //             int height=this.Bottom()-new_y+1;
   //             if(!this.MoveXYWidthResize(new_x, new_y,width,height))
   //                return false;
   //          // --- Get a pointer to a hint
   //             CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NWSE);
   //             if(hint==NULL)
   //                return false;
   //          // --- Shift the tooltip by the specified amounts relative to the cursor
   //             int shift_x=10;
   //             int shift_y=2;
   //             return hint.Move(x+shift_x,y+shift_y);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Saving to file |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::Save(const int file_handle)
   //       {
   //          // --- Save the data of the parent object
   //             if(!CCanvasBase::Save(file_handle))
   //                return false;
            
   //          // --- Save the list of hints
   //             if(!this.m_list_hints.Save(file_handle))
   //                return false;
   //          // --- Save the image object
   //             if(!this.m_painter.Save(file_handle))
   //                return false;
   //          // --- Save the group
   //             if(::FileWriteInteger(file_handle,this.m_group,INT_VALUE)!=INT_VALUE)
   //                return false;
   //          // --- Store the visibility flag in the container
   //             if(::FileWriteInteger(file_handle,this.m_visible_in_container,INT_VALUE)!=INT_VALUE)
   //                return false;
               
   //          // --- Everything is successful
   //             return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CElementBase::Loading from file |
   //    //+------------------------------------------------------------------+
   //    bool CElementBase::Load(const int file_handle)
   //       {
   //          // --- Loading the data of the parent object
   //             if(!CCanvasBase::Load(file_handle))
   //                return false;
                  
   //          // --- Loading a list of tips
   //             if(!this.m_list_hints.Load(file_handle))
   //                return false;      
   //          // --- Loading the image object
   //             if(!this.m_painter.Load(file_handle))
   //                return false;
   //          // --- Loading the group
   //             this.m_group=::FileReadInteger(file_handle,INT_VALUE);
   //          // --- Load the visibility flag in the container
   //             this.m_visible_in_container=::FileReadInteger(file_handle,INT_VALUE);
               
   //          // --- Everything is successful
   //             return true;
   //       }
   // #endif // CELEMENTBASE_IMPLEMENTATION
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_ELEMENTBASE_MQH


#ifndef MOVE_TO_LABEL_MQH
#define MOVE_TO_LABEL_MQH
      // //+------------------------------------------------------------------+
   // // | Text Label Class |
   // //+------------------------------------------------------------------+
   // class CLabel : public CElementBase
   //    {
   //       protected:
   //          ushort            m_text[];                                 // Text
   //          ushort            m_text_prev[];                            // Past text
   //          int               m_text_x;                                 // X coordinate of the text (offset relative to the left edge of the object)
   //          int               m_text_y;                                 // Y coordinate of the text (offset relative to the top border of the object)

   //       // --- (1) Sets, (2) returns past text
   //          void              SetTextPrev(const string text)            { ::StringToShortArray(text,this.m_text_prev);  }
   //          string            TextPrev(void)                      const { return ::ShortArrayToString(this.m_text_prev);}
               
   //       // --- Erases text
   //          void              ClearText(void);

   //       public:
   //       // --- (1) Sets, (2) returns text
   //          void              SetText(const string text)                { ::StringToShortArray(text,this.m_text);       }
   //          string            Text(void)                          const { return ::ShortArrayToString(this.m_text);     }
            
   //       // --- Returns the (1) X, (2) Y coordinate of the text
   //          int               TextX(void)                         const { return this.m_text_x;                         }
   //          int               TextY(void)                         const { return this.m_text_y;                         }

   //       // --- Sets the (1) X, (2) Y coordinate of the text
   //          void              SetTextShiftH(const int x)                { this.ClearText(); this.m_text_x=x;            }
   //          void              SetTextShiftV(const int y)                { this.ClearText(); this.m_text_y=y;            }
            
   //       // --- Outputs text
   //          virtual void      DrawText(const int dx, const int dy, const string text, const bool chart_redraw);
            
   //       // ---Draws the appearance
   //          virtual void      Draw(const bool chart_redraw);

   //       // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //          virtual int       Compare(const CObject *node,const int mode=0) const;
   //          virtual bool      Save(const int file_handle);
   //          virtual bool      Load(const int file_handle);
   //          virtual int       Type(void)                          const { return(ELEMENT_TYPE_LABEL);                   }

   //       // --- Initialize (1) class object, (2) default object colors
   //          void              Init(const string text);
   //          virtual void      InitColors(void){}
            
   //       // --- Constructors/destructor
   //                            CLabel(void);
   //                            CLabel(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                            ~CLabel(void) {}
   //    };
   // #ifndef CLABEL_IMPLEMENTATION
   // #define CLABEL_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CLabel::Default constructor. Builds a label in the main window |
   //    // | current chart in coordinates 0,0 with default sizes |
   //    //+------------------------------------------------------------------+
   //    CLabel::CLabel(void) : CElementBase("Label","Label",::ChartID(),0,0,0,DEF_LABEL_W,DEF_LABEL_H), m_text_x(0), m_text_y(0)
   //    {
   //    // ---Initialization
   //       this.Init("Label");
   //    }
   //    //+-------------------------------------------------------------------+
   //    // | CLabel::The constructor is parametric. Builds a label in the specified window|
   //    // | of the specified graphic with the specified text, coordinates and dimensions |
   //    //+-------------------------------------------------------------------+
   //    CLabel::CLabel(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CElementBase(object_name,text,chart_id,wnd,x,y,w,h), m_text_x(0), m_text_y(0)
   //    {
   //    // ---Initialization
   //       this.Init(text);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CLabel::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CLabel::Init(const string text)
   //    {
   //    // --- Set the current and previous text
   //       this.SetText(text);
   //       this.SetTextPrev("");
   //    // --- Background is transparent, foreground is not
   //       this.SetAlphaBG(0);
   //       this.SetAlphaFG(255);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CLabel::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CLabel::Compare(const CObject *node,const int mode=0) const
   //    {
   //       if(node==NULL)
   //          return -1;
   //       const CLabel *obj=node;
   //       switch(mode)
   //       {
   //          case ELEMENT_SORT_BY_NAME     :  return(this.Name()         >obj.Name()          ? 1 : this.Name()          <obj.Name()          ? -1 : 0);
   //          case ELEMENT_SORT_BY_TEXT     :  return(this.Text()         >obj.Text()          ? 1 : this.Text()          <obj.Text()          ? -1 : 0);
   //          case ELEMENT_SORT_BY_X        :  return(this.X()            >obj.X()             ? 1 : this.X()             <obj.X()             ? -1 : 0);
   //          case ELEMENT_SORT_BY_Y        :  return(this.Y()            >obj.Y()             ? 1 : this.Y()             <obj.Y()             ? -1 : 0);
   //          case ELEMENT_SORT_BY_WIDTH    :  return(this.Width()        >obj.Width()         ? 1 : this.Width()         <obj.Width()         ? -1 : 0);
   //          case ELEMENT_SORT_BY_HEIGHT   :  return(this.Height()       >obj.Height()        ? 1 : this.Height()        <obj.Height()        ? -1 : 0);
   //          case ELEMENT_SORT_BY_COLOR_BG :  return(this.BackColor()    >obj.BackColor()     ? 1 : this.BackColor()     <obj.BackColor()     ? -1 : 0);
   //          case ELEMENT_SORT_BY_COLOR_FG :  return(this.ForeColor()    >obj.ForeColor()     ? 1 : this.ForeColor()     <obj.ForeColor()     ? -1 : 0);
   //          case ELEMENT_SORT_BY_ALPHA_BG :  return(this.AlphaBG()      >obj.AlphaBG()       ? 1 : this.AlphaBG()       <obj.AlphaBG()       ? -1 : 0);
   //          case ELEMENT_SORT_BY_ALPHA_FG :  return(this.AlphaFG()      >obj.AlphaFG()       ? 1 : this.AlphaFG()       <obj.AlphaFG()       ? -1 : 0);
   //          case ELEMENT_SORT_BY_STATE    :  return(this.State()        >obj.State()         ? 1 : this.State()         <obj.State()         ? -1 : 0);
   //          case ELEMENT_SORT_BY_ZORDER   :  return(this.ObjectZOrder() >obj.ObjectZOrder()  ? 1 : this.ObjectZOrder()  <obj.ObjectZOrder()  ? -1 : 0);
   //          default                       :  return(this.ID()           >obj.ID()            ? 1 : this.ID()            <obj.ID()            ? -1 : 0);
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CLabel::Erases text |
   //    //+------------------------------------------------------------------+
   //    void CLabel::ClearText(void)
   //    {
   //          int w=0, h=0;
   //          string text=this.TextPrev();
   //       // --- Getting the dimensions of the previous text
   //          if(text!="")
   //             this.m_foreground.TextSize(text,w,h);
   //       // --- If the dimensions are obtained, draw a transparent rectangle in place of the text, erasing the text
   //          if(w>0 && h>0)
   //             this.m_foreground.FillRectangle(this.AdjX(this.m_text_x),this.AdjY(this.m_text_y),this.AdjX(this.m_text_x+w),this.AdjY(this.m_text_y+h),clrNULL);
   //       // --- Otherwise, we completely clear the entire foreground
   //          else
   //             this.m_foreground.Erase(clrNULL);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CLabel::Outputs text |
   //    //+------------------------------------------------------------------+
   //    void CLabel::DrawText(const int dx,const int dy,const string text,const bool chart_redraw)
   //    {
   //       // --- Clear the previous text and install a new one
   //          this.ClearText();
   //          this.SetText(text);
   //       // --- Output the set text
   //          this.m_foreground.TextOut(this.AdjX(dx),this.AdjY(dy),this.Text(),::ColorToARGB(this.ForeColor(),this.AlphaFG()));
            
   //       // --- If the text extends beyond the right border of the object
   //          if(this.Width()-dx<this.m_foreground.TextWidth(text))
   //          {
   //             // --- Getting the dimensions of the text "ellipsis"
   //             int w=0,h=0;
   //             this.m_foreground.TextSize("... ",w,h);
   //             if(w>0 && h>0)
   //             {
   //                // --- Erase the text at the right border of the object according to the text size "ellipsis" and replace the end of the label text with an ellipsis
   //                this.m_foreground.FillRectangle(this.AdjX(this.Width()-w),this.AdjY(this.m_text_y),this.AdjX(this.Width()),this.AdjY(this.m_text_y+h),clrNULL);
   //                this.m_foreground.TextOut(this.AdjX(this.Width()-w),this.AdjY(dy),"...",::ColorToARGB(this.ForeColor(),this.AlphaFG()));
   //             }
   //          }
   //       // --- Update the foreground canvas and remember the new text coordinates
   //          this.m_foreground.Update(chart_redraw);
   //          this.m_text_x=dx;
   //          this.m_text_y=dy;
   //       // --- Remember the drawn text as the previous one
   //          this.SetTextPrev(text);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CLabel::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CLabel::Draw(const bool chart_redraw)
   //    {
   //       this.DrawText(this.m_text_x,this.m_text_y,this.Text(),chart_redraw);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CLabel::Save to file |
   //    //+------------------------------------------------------------------+
   //    bool CLabel::Save(const int file_handle)
   //    {
   //       // --- Save the data of the parent object
   //          if(!CElementBase::Save(file_handle))
   //             return false;
         
   //       // --- Save the text
   //          if(::FileWriteArray(file_handle,this.m_text)!=sizeof(this.m_text))
   //             return false;
   //       // --- Save the previous text
   //          if(::FileWriteArray(file_handle,this.m_text_prev)!=sizeof(this.m_text_prev))
   //             return false;
   //       // --- Save the X coordinate of the text
   //          if(::FileWriteInteger(file_handle,this.m_text_x,INT_VALUE)!=INT_VALUE)
   //             return false;
   //       // --- Save the Y coordinate of the text
   //          if(::FileWriteInteger(file_handle,this.m_text_y,INT_VALUE)!=INT_VALUE)
   //             return false;
            
   //       // --- Everything is successful
   //          return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    //| CLabel::Loading from file |
   //    //+------------------------------------------------------------------+
   //    bool CLabel::Load(const int file_handle)
   //    {
   //       // --- Loading the data of the parent object
   //          if(!CElementBase::Load(file_handle))
   //             return false;
               
   //       // --- Loading text
   //          if(::FileReadArray(file_handle,this.m_text)!=sizeof(this.m_text))
   //             return false;
   //       // --- Loading the previous text
   //          if(::FileReadArray(file_handle,this.m_text_prev)!=sizeof(this.m_text_prev))
   //             return false;
   //       // --- Load the X coordinate of the text
   //          this.m_text_x=::FileReadInteger(file_handle,INT_VALUE);
   //       // --- Load the Y coordinate of the text
   //          this.m_text_y=::FileReadInteger(file_handle,INT_VALUE);
            
   //       // --- Everything is successful
   //       return true;
   //    }
   // #endif // CLABEL_IMPLEMENTATION
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_LABEL_MQH

#ifndef MOVE_TO_BUTTON_MQH
#define MOVE_TO_BUTTON_MQH
   // //+------------------------------------------------------------------+
   // //| Simple button class |
   // //+------------------------------------------------------------------+
   // class CButton : public CLabel
   //    {
   //       public:
   //       // ---Draws the appearance
   //          virtual void      Draw(const bool chart_redraw);

   //       // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //          virtual int       Compare(const CObject *node,const int mode=0) const;
   //          virtual bool      Save(const int file_handle)               { return CLabel::Save(file_handle); }
   //          virtual bool      Load(const int file_handle)               { return CLabel::Load(file_handle); }
   //          virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON);      }
            
   //       // --- Initialize (1) class object, (2) default object colors
   //          void              Init(const string text);
   //          virtual void      InitColors(void){}
            
   //       // --- Timer event handler
   //          virtual void      TimerEventHandler(void);
            
   //       // --- Constructors/destructor
   //                            CButton(void);
   //                            CButton(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                            ~CButton (void) {}
   //    };
   // #ifndef CBUTTON_IMPLEMENTATION
   // #define CBUTTON_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CButton::Default constructor. Builds a button in the main window |
   //    // | current chart in coordinates 0,0 with default sizes |
   //    //+------------------------------------------------------------------+
   //    CButton::CButton(void) : CLabel("Button","Button",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
   //    {
   //    // ---Initialization
   //       this.Init("");
   //    }
   //    //+---------------------------------------------------------------------+
   //    // | CButton::The constructor is parametric. Builds a button in the specified window|
   //    // | of the specified graphic with the specified text, coordinates and dimensions |
   //    //+---------------------------------------------------------------------+
   //    CButton::CButton(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CLabel(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //    // ---Initialization
   //       this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButton::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CButton::Init(const string text)
   //    {
   //    // --- Set the default state
   //       this.SetState(ELEMENT_STATE_DEF);
   //    // ---Background and foreground - opaque
   //       this.SetAlpha(255);
   //    // --- Offset text from left edge of button by default
   //       this.m_text_x=2;
   //    // --- Auto-repeat is disabled
   //       this.m_autorepeat_flag=false;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButton::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CButton::Compare(const CObject *node,const int mode=0) const
   //    {
   //       return CLabel::Compare(node,mode);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButton::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CButton::Draw(const bool chart_redraw)
   //    {
   //    // --- Fill the button with the background color, draw a frame and update the background canvas
   //       this.Fill(this.BackColor(),false);
   //       this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //       this.m_background.Update(false);
   //    // --- Display button text
   //       CLabel::Draw(false);
            
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Timer event handler |
   //    //+------------------------------------------------------------------+
   //    void CButton::TimerEventHandler(void)
   //    {
   //       if(this.m_autorepeat_flag)
   //          this.m_autorepeat.Process();
   //    }
   // #endif // CBUTTON_IMPLEMENTATION
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_BUTTON_MQH

#ifndef MOVE_TO_BUTTONTRIGGERED_MQH
#define MOVE_TO_BUTTONTRIGGERED_MQH
      // //+------------------------------------------------------------------+
   // // | Two-way button class |
   // //+------------------------------------------------------------------+
   // class CButtonTriggered : public CButton
   //    {
   //       public:
   //       // ---Draws the appearance
   //          virtual void      Draw(const bool chart_redraw);

   //       // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //          virtual int       Compare(const CObject *node,const int mode=0) const;
   //          virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
   //          virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
   //          virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_TRIGGERED);  }
         
   //       // --- Event handler for mouse button clicks (Press)
   //          virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);

   //       // --- Initialize (1) class object, (2) default object colors
   //          void              Init(const string text);
   //          virtual void      InitColors(void);
            
   //       // --- Constructors/destructor
   //                            CButtonTriggered(void);
   //                            CButtonTriggered(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                            ~CButtonTriggered (void) {}
   //    };
   // #ifndef CBUTTONTRIGGERED_IMPLEMENTATION
   // #define CBUTTONTRIGGERED_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CButtonTriggered::Default constructor.                      |
   //    // | Builds a button in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CButtonTriggered::CButtonTriggered(void) : CButton("Button","Button",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
   //    {
   //    // ---Initialization
   //       this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonTriggered::Parametric constructor.                   |
   //    // | Builds a button in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CButtonTriggered::CButtonTriggered(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CButton(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //    // ---Initialization
   //       this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonTriggered::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CButtonTriggered::Init(const string text)
   //    {
   //    // --- Initialize default colors
   //       this.InitColors();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonTriggered::Initializing default object colors |
   //    //+------------------------------------------------------------------+
   //    void CButtonTriggered::InitColors(void)
   //    {
   //    // --- Initialize the background colors for normal and activated states and make it the current background color
   //       this.InitBackColors(clrWhiteSmoke);
   //       this.InitBackColorsAct(clrLightBlue);
   //       this.BackColorToDefault();
         
   //    // --- Initialize the foreground colors for normal and activated states and make it the current text color
   //       this.InitForeColors(clrBlack);
   //       this.InitForeColorsAct(clrBlack);
   //       this.ForeColorToDefault();
         
   //    // --- Initialize the border colors for the normal and activated states and make it the current border color
   //       this.InitBorderColors(clrDarkGray);
   //       this.InitBorderColorsAct(clrGreen);
   //       this.BorderColorToDefault();
         
   //    // --- Initialize the border color and foreground color for the blocked element
   //       this.InitBorderColorBlocked(clrLightGray);
   //       this.InitForeColorBlocked(clrSilver);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonTriggered::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CButtonTriggered::Compare(const CObject *node,const int mode=0) const
   //    {
   //       return CButton::Compare(node,mode);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonTriggered::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CButtonTriggered::Draw(const bool chart_redraw)
   //    {
   //       // --- Fill the button with the background color, draw a frame and update the background canvas
   //          this.Fill(this.BackColor(),false);
   //          this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //          this.m_background.Update(false);
   //       // --- Display button text
   //          CLabel::Draw(false);
               
   //       // --- If indicated, update the schedule
   //          if(chart_redraw)
   //             ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonTriggered::Event handler for mouse button clicks (Press)|
   //    //+------------------------------------------------------------------+
   //    void CButtonTriggered::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //       // --- Set the button state opposite to the one already set
   //          ENUM_ELEMENT_STATE state=(this.State()==ELEMENT_STATE_DEF ? ELEMENT_STATE_ACT : ELEMENT_STATE_DEF);
   //          this.SetState(state);
            
   //       // --- Call the handler of the parent object indicating the identifier in lparam and the state in dparam
   //          CCanvasBase::OnPressEvent(id,this.m_id,this.m_state,sparam);
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CBUTTONTRIGGERED_IMPLEMENTATION
   // //+------------------------------------------------------------------+
#endif // MOVE_TO_BUTTONTRIGGERED_MQH

#ifndef MOVE_TO_BUTTONARROWUP_MQH
#define MOVE_TO_BUTTONARROWUP_MQH
      // //+------------------------------------------------------------------+
   // //| Up arrow button class |
   // //+------------------------------------------------------------------+
   // class CButtonArrowUp : public CButton
   // {
   //    public:
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);

   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0) const;
   //       virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
   //       virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_ARROW_UP);}
         
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(const string text);
   //       virtual void      InitColors(void){}
         
   //    // --- Constructors/destructor
   //                         CButtonArrowUp(void);
   //                         CButtonArrowUp(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CButtonArrowUp (void) {}
   //    };
   // #ifndef CBUTTONARROWUP_IMPLEMENTATION
   // #define CBUTTONARROWUP_IMPLEMENTATION
   //       //+------------------------------------------------------------------+
   //    // | CButtonArrowUp::Default constructor.                        |
   //    // | Builds a button in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CButtonArrowUp::CButtonArrowUp(void) : CButton("Arrow Up Button","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
   //    {
   //       // ---Initialization
   //       this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowUp::Parametric constructor.                     |
   //    // | Builds a button in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CButtonArrowUp::CButtonArrowUp(const string object_name, const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CButton(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //       // ---Initialization
   //       this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    //| CButtonArrowUp::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CButtonArrowUp::Init(const string text)
   //    {
   //       // --- Initialize default colors
   //          this.InitColors();
   //       // --- Set the offset and dimensions of the image area
   //          this.SetImageBound(1,1,this.Height()-2,this.Height()-2);

   //       // --- Initialize auto-repeat counters
   //          this.m_autorepeat_flag=true;

   //       // --- Initialize the properties of the event auto-repeat control object
   //          this.m_autorepeat.SetChartID(this.m_chart_id);
   //          this.m_autorepeat.SetID(0);
   //          this.m_autorepeat.SetName("ButtUpAutorepeatControl");
   //          this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
   //          this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
   //          this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
   //    }
   //    //+------------------------------------------------------------------+
   //    //| CButtonArrowUp::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CButtonArrowUp::Compare(const CObject *node,const int mode=0) const
   //    {
   //       return CButton::Compare(node,mode);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowUp::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CButtonArrowUp::Draw(const bool chart_redraw)
   //    {
   //       // --- Fill the button with the background color, draw a frame and update the background canvas
   //          this.Fill(this.BackColor(),false);
   //          this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //          this.m_background.Update(false);
   //       // --- Display button text
   //          CLabel::Draw(false);
   //       // --- Clear the drawing area
   //          this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //       // --- Set the arrow color for the normal and locked states of the button and draw an up arrow
   //          color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
   //          this.m_painter.ArrowUp(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
               
   //       // --- If indicated, update the schedule
   //          if(chart_redraw)
   //             ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CBUTTONARROWUP_IMPLEMENTATION
#endif // MOVE_TO_BUTTONARROWUP_MQH

#ifndef MOVE_TO_BUTTONARROWDOWN_MQH
#define MOVE_TO_BUTTONARROWDOWN_MQH
      // //+------------------------------------------------------------------+
   // // | Down arrow button class |
   // //+------------------------------------------------------------------+
   // class CButtonArrowDown : public CButton
   //    {
   //       public:
   //       // ---Draws the appearance
   //          virtual void      Draw(const bool chart_redraw);

   //       // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //          virtual int       Compare(const CObject *node,const int mode=0) const;
   //          virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
   //          virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
   //          virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_ARROW_DOWN); }
            
   //       // --- Initialize (1) class object, (2) default object colors
   //          void              Init(const string text);
   //          virtual void      InitColors(void){}
            
   //       // --- Constructors/destructor
   //                            CButtonArrowDown(void);
   //                            CButtonArrowDown(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                         ~CButtonArrowDown (void) {}
   //    };
   //    //+------------------------------------------------------------------+
   // #ifndef CBUTTONARROWDOWN_IMPLEMENTATION
   // #define CBUTTONARROWDOWN_IMPLEMENTATION
   //       //+------------------------------------------------------------------+
   //    // | CButtonArrowDown::Default constructor.                      |
   //    // | Builds a button in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CButtonArrowDown::CButtonArrowDown(void) : CButton("Arrow Up Button","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
   //    {
   //       // ---Initialization
   //          this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowDown::Parametric constructor.                   |
   //    // | Builds a button in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CButtonArrowDown::CButtonArrowDown(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CButton(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //       // ---Initialization
   //          this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowDown::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CButtonArrowDown::Init(const string text)
   //    {
   //       // --- Initialize default colors
   //          this.InitColors();
   //       // --- Set the offset and dimensions of the image area
   //          this.SetImageBound(1,1,this.Height()-2,this.Height()-2);

   //       // --- Initialize auto-repeat counters
   //          this.m_autorepeat_flag=true;

   //       // --- Initialize the properties of the event auto-repeat control object
   //          this.m_autorepeat.SetChartID(this.m_chart_id);
   //          this.m_autorepeat.SetID(0);
   //          this.m_autorepeat.SetName("ButtDownAutorepeatControl");
   //          this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
   //          this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
   //          this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowDown::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CButtonArrowDown::Compare(const CObject *node,const int mode=0) const
   //    {
   //       return CButton::Compare(node,mode);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowDown::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CButtonArrowDown::Draw(const bool chart_redraw)
   //    {
   //    // --- Fill the button with the background color, draw a frame and update the background canvas
   //       this.Fill(this.BackColor(),false);
   //       this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //       this.m_background.Update(false);
   //    // --- Display button text
   //       CLabel::Draw(false);
   //    // --- Clear the drawing area
   //       this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //    // --- Set the arrow color for the normal and locked states of the button and draw a down arrow
   //       color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
   //       this.m_painter.ArrowDown(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
            
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CBUTTONARROWDOWN_IMPLEMENTATION
#endif // MOVE_TO_BUTTONARROWDOWN_MQH

#ifndef MOVE_TO_BUTTONARROWLEFT_MQH
#define MOVE_TO_BUTTONARROWLEFT_MQH
      // //+------------------------------------------------------------------+
   // // | Left arrow button class |
   // //+------------------------------------------------------------------+
   // class CButtonArrowLeft : public CButton
   // {
   //    public:
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);

   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0) const;
   //       virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
   //       virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_ARROW_DOWN); }
         
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(const string text);
   //       virtual void      InitColors(void){}
         
   //    // --- Constructors/destructor
   //                         CButtonArrowLeft(void);
   //                         CButtonArrowLeft(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CButtonArrowLeft (void) {}
   // };
   //    //+------------------------------------------------------------------+
   // #ifndef CBUTTONARROWLEFT_IMPLEMENTATION
   // #define CBUTTONARROWLEFT_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowLeft::Default constructor.                      |
   //    // | Builds a button in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CButtonArrowLeft::CButtonArrowLeft(void) : CButton("Arrow Up Button","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
   //       {
   //          // ---Initialization
   //             this.Init("");
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowLeft::Parametric constructor.                   |
   //    // | Builds a button in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CButtonArrowLeft::CButtonArrowLeft(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CButton(object_name,text,chart_id,wnd,x,y,w,h)
   //       {
   //       // ---Initialization
   //          this.Init("");
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowLeft::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CButtonArrowLeft::Init(const string text)
   //       {
   //       // --- Initialize default colors
   //          this.InitColors();
   //       // --- Set the offset and dimensions of the image area
   //          this.SetImageBound(1,1,this.Height()-2,this.Height()-2);

   //       // --- Initialize auto-repeat counters
   //          this.m_autorepeat_flag=true;

   //       // --- Initialize the properties of the event auto-repeat control object
   //          this.m_autorepeat.SetChartID(this.m_chart_id);
   //          this.m_autorepeat.SetID(0);
   //          this.m_autorepeat.SetName("ButtLeftAutorepeatControl");
   //          this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
   //          this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
   //          this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowLeft::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CButtonArrowLeft::Compare(const CObject *node,const int mode=0) const
   //       {
   //          return CButton::Compare(node,mode);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowLeft::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CButtonArrowLeft::Draw(const bool chart_redraw)
   //       {
   //       // --- Fill the button with the background color, draw a frame and update the background canvas
   //          this.Fill(this.BackColor(),false);
   //          this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //          this.m_background.Update(false);
   //       // --- Display button text
   //          CLabel::Draw(false);
   //       // --- Clear the drawing area
   //          this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //       // --- Set the arrow color for the normal and locked states of the button and draw a left arrow
   //          color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
   //          this.m_painter.ArrowLeft(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
               
   //       // --- If indicated, update the schedule
   //          if(chart_redraw)
   //             ::ChartRedraw(this.m_chart_id);
   //       }
   //    //+------------------------------------------------------------------+
   // #endif // CBUTTONARROWLEFT_IMPLEMENTATION
#endif // MOVE_TO_BUTTONARROWLEFT_MQH

#ifndef MOVE_TO_BUTTONARROWRIGHT_MQH
#define MOVE_TO_BUTTONARROWRIGHT_MQH
      // //+------------------------------------------------------------------+
   // // | Right arrow button class |
   // //+------------------------------------------------------------------+
   // class CButtonArrowRight : public CButton
   // {
   //    public:
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);

   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0) const;
   //       virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
   //       virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_ARROW_DOWN); }
         
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(const string text);
   //       virtual void      InitColors(void){}
         
   //    // --- Constructors/destructor
   //                         CButtonArrowRight(void);
   //                         CButtonArrowRight(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CButtonArrowRight (void) {}
   // };
   //    //+------------------------------------------------------------------+
   // #ifndef CBUTTONARROWRIGHT_IMPLEMENTATION
   // #define CBUTTONARROWRIGHT_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    //| CButtonArrowRight::Default constructor.                     |
   //    //| Builds a button in the main window of the current chart |
   //    //| at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CButtonArrowRight::CButtonArrowRight(void) : CButton("Arrow Up Button","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
   //    {
   //       // ---Initialization
   //          this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowRight::Parametric constructor.                  |
   //    // | Builds a button in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CButtonArrowRight::CButtonArrowRight(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CButton(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //    // ---Initialization
   //       this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowRight::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CButtonArrowRight::Init(const string text)
   //    {
   //    // --- Initialize default colors
   //       this.InitColors();
   //    // --- Set the offset and dimensions of the image area
   //       this.SetImageBound(1,1,this.Height()-2,this.Height()-2);

   //    // --- Initialize auto-repeat counters
   //       this.m_autorepeat_flag=true;

   //    // --- Initialize the properties of the event auto-repeat control object
   //       this.m_autorepeat.SetChartID(this.m_chart_id);
   //       this.m_autorepeat.SetID(0);
   //       this.m_autorepeat.SetName("ButtRightAutorepeatControl");
   //       this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
   //       this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
   //       this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowRight::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CButtonArrowRight::Compare(const CObject *node,const int mode=0) const
   //    {
   //       return CButton::Compare(node,mode);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CButtonArrowRight::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CButtonArrowRight::Draw(const bool chart_redraw)
   //    {
   //    // --- Fill the button with the background color, draw a frame and update the background canvas
   //       this.Fill(this.BackColor(),false);
   //       this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //       this.m_background.Update(false);
   //    // --- Display button text
   //       CLabel::Draw(false);
   //    // --- Clear the drawing area
   //       this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //    // --- Set the arrow color for the normal and locked states of the button and draw an arrow to the right
   //       color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
   //       this.m_painter.ArrowRight(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
            
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CBUTTONARROWRIGHT_IMPLEMENTATION
#endif // MOVE_TO_BUTTONARROWRIGHT_MQH

#ifndef MOVE_TO_VISUALHINT_MQH
#define MOVE_TO_VISUALHINT_MQH
      // //+------------------------------------------------------------------+
   // //| Tooltip class |
   // //+------------------------------------------------------------------+
   // class CVisualHint : public CButton
   // {
   //    protected:
   //       ENUM_HINT_TYPE    m_hint_type;                              // Tooltip type

   //    // --- Draws (1) tooltip, (2) horizontal, (3) vertical arrow,
   //    // --- arrows (4) top-left --- bottom-right, (5) bottom-left --- top-right,
   //    // --- displacement arrows along (6) horizontal, (7) vertical
   //       void              DrawTooltip(void);
   //       void              DrawArrHorz(void);
   //       void              DrawArrVert(void);
   //       void              DrawArrNWSE(void);
   //       void              DrawArrNESW(void);
   //       void              DrawArrShiftHorz(void);
   //       void              DrawArrShiftVert(void);
         
   //    // --- Initialize colors for tooltip type (1) Tooltip, (2) arrows
   //       void              InitColorsTooltip(void);
   //       void              InitColorsArrowed(void);
         
   //    public:
   //    // --- (1) Sets, (2) returns the tooltip type
   //       void              SetHintType(const ENUM_HINT_TYPE type);
   //       ENUM_HINT_TYPE    HintType(void)                      const { return this.m_hint_type;             }

   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);

   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0) const;
   //       virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
   //       virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_HINT);           }
         
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(const string text);
   //       virtual void      InitColors(void);
         
   //    // --- Constructors/destructor
   //                         CVisualHint(void);
   //                         CVisualHint(const string object_name, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CVisualHint (void) {}
   // };
   // #ifndef CVISUALHINT_IMPLEMENTATION
   // #define CVISUALHINT_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Default constructor.                     |
   //    // | Plots an element in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CVisualHint::CVisualHint(void) : CButton("HintObject","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
   //       {
   //       // ---Initialization
   //          this.Init("");
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::The constructor is parametric.                        |
   //    // | Plots an element in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CVisualHint::CVisualHint(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CButton(object_name,"",chart_id,wnd,x,y,w,h)
   //       {
   //       // ---Initialization
   //          this.Init("");
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::Init(const string text)
   //       {
   //       // --- Initialize default colors
   //          this.InitColors();
   //       // --- Set the offset and dimensions of the image area
   //          this.SetImageBound(0,0,this.Width(),this.Height());

   //       // --- Object is not clipped to container boundaries
   //          this.m_trim_flag=false;
            
   //       // --- Initialize auto-repeat counters
   //          this.m_autorepeat_flag=true;

   //       // --- Initialize the properties of the event auto-repeat control object
   //          this.m_autorepeat.SetChartID(this.m_chart_id);
   //          this.m_autorepeat.SetID(0);
   //          this.m_autorepeat.SetName("VisualHintAutorepeatControl");
   //          this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
   //          this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
   //          this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Initializing colors for the Tooltip hint type |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::InitColorsTooltip(void)
   //       {
   //       // ---Background and foreground opaque
   //          this.SetAlpha(255);
            
   //       // --- Initialize the background colors for normal and activated states and make it the current background color
   //          this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //          this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //          this.BackColorToDefault();
            
   //       // --- Initialize the foreground colors for normal and activated states and make it the current text color
   //          this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   //          this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   //          this.ForeColorToDefault();
            
   //       // --- Initialize the border colors for the normal and activated states and make it the current border color
   //          this.InitBorderColors(clrLightGray,clrLightGray,clrLightGray,clrLightGray);
   //          this.InitBorderColorsAct(clrLightGray,clrLightGray,clrLightGray,clrLightGray);
   //          this.BorderColorToDefault();
            
   //       // --- Initialize the border color and foreground color for the locked element
   //          this.InitBorderColorBlocked(clrNULL);
   //          this.InitForeColorBlocked(clrNULL);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Initializing colors for the Arrowed hint type |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::InitColorsArrowed(void)
   //       {
   //       // --- Background is transparent, foreground is opaque
   //          this.SetAlphaBG(0);
   //          this.SetAlphaFG(255);
            
   //       // --- Initialize the background colors for normal and activated states and make it the current background color
   //          this.InitBackColors(clrNULL,clrNULL,clrNULL,clrNULL);
   //          this.InitBackColorsAct(clrNULL,clrNULL,clrNULL,clrNULL);
   //          this.BackColorToDefault();
            
   //       // --- Initialize the foreground colors for normal and activated states and make it the current text color
   //          this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   //          this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   //          this.ForeColorToDefault();
            
   //       // --- Initialize the border colors for the normal and activated states and make it the current border color
   //          this.InitBorderColors(clrNULL,clrNULL,clrNULL,clrNULL);
   //          this.InitBorderColorsAct(clrNULL,clrNULL,clrNULL,clrNULL);
   //          this.BorderColorToDefault();
            
   //       // --- Initialize the border color and foreground color for the blocked element
   //          this.InitBorderColorBlocked(clrNULL);
   //          this.InitForeColorBlocked(clrNULL);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Initializing default object colors |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::InitColors(void)
   //       {
   //          if(this.m_hint_type==HINT_TYPE_TOOLTIP)
   //             this.InitColorsTooltip();
   //          else
   //             this.InitColorsArrowed();
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CVisualHint::Compare(const CObject *node,const int mode=0) const
   //       {
   //          return CButton::Compare(node,mode);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Sets the hint type |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::SetHintType(const ENUM_HINT_TYPE type)
   //       {
   //       // --- If the passed type matches the set one, we leave
   //          if(this.m_hint_type==type)
   //             return;
   //       // --- Installing a new tooltip type
   //          this.m_hint_type=type;
   //       // --- Depending on the type of tooltip, set the size of the object
   //          switch(this.m_hint_type)
   //          {
   //             case HINT_TYPE_ARROW_HORZ        :  this.Resize(17,7);   break;
   //             case HINT_TYPE_ARROW_VERT        :  this.Resize(7,17);   break;
   //             case HINT_TYPE_ARROW_NESW        :
   //             case HINT_TYPE_ARROW_NWSE        :  this.Resize(13,13);  break;
   //             case HINT_TYPE_ARROW_SHIFT_HORZ  :
   //             case HINT_TYPE_ARROW_SHIFT_VERT  :  this.Resize(18,18);  break;
   //             default                          :  break;
   //          }
   //       // --- Set the offset and dimensions of the image area,
   //       // --- initialize the colors based on the tooltip type
   //          this.SetImageBound(0,0,this.Width(),this.Height());
   //          this.InitColors();
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Draws the appearance |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::Draw(const bool chart_redraw)
   //       {
   //       // --- Depending on the type of tooltip, call the corresponding drawing method
   //          switch(this.m_hint_type)
   //          {
   //             case HINT_TYPE_ARROW_HORZ        :  this.DrawArrHorz();        break;
   //             case HINT_TYPE_ARROW_VERT        :  this.DrawArrVert();        break;
   //             case HINT_TYPE_ARROW_NESW        :  this.DrawArrNESW();        break;
   //             case HINT_TYPE_ARROW_NWSE        :  this.DrawArrNWSE();        break;
   //             case HINT_TYPE_ARROW_SHIFT_HORZ  :  this.DrawArrShiftHorz();   break;
   //             case HINT_TYPE_ARROW_SHIFT_VERT  :  this.DrawArrShiftVert();   break;
   //             default                          :  this.DrawTooltip();        break;
   //          }

   //       // --- If indicated, update the schedule
   //          if(chart_redraw)
   //             ::ChartRedraw(this.m_chart_id);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Draws a tooltip |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::DrawTooltip(void)
   //       {
   //       // --- Fill the object with the background color, draw a frame and update the background canvas
   //          this.Fill(this.BackColor(),false);
   //          this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //          this.m_background.Update(false);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Draws a horizontal arrow |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::DrawArrHorz(void)
   //       {
   //       // --- Clear the drawing area
   //          this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //       // --- Draw a double horizontal arrow
   //          this.m_painter.ArrowHorz(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Draws a vertical arrow |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::DrawArrVert(void)
   //       {
   //       // --- Clear the drawing area
   //          this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //       // --- Draw a double vertical arrow
   //          this.m_painter.ArrowVert(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Draws arrows top-left --- bottom-right |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::DrawArrNWSE(void)
   //       {
   //       // --- Clear the drawing area
   //          this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //       // --- Draw a double diagonal arrow from top to left --- down to right
   //          this.m_painter.ArrowNWSE(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Draws arrows bottom-left --- top-right |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::DrawArrNESW(void)
   //       {
   //       // --- Clear the drawing area
   //          this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //       // --- Draw a double diagonal arrow from bottom to left --- top to right
   //          this.m_painter.ArrowNESW(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Draws horizontal offset arrows |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::DrawArrShiftHorz(void)
   //       {
   //       // --- Clear the drawing area
   //          this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //       // --- Draw horizontal displacement arrows
   //          this.m_painter.ArrowShiftHorz(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CVisualHint::Draws vertical offset arrows |
   //    //+------------------------------------------------------------------+
   //    void CVisualHint::DrawArrShiftVert(void)
   //       {
   //       // --- Clear the drawing area
   //          this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //       // --- Draw horizontal displacement arrows
   //          this.m_painter.ArrowShiftVert(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
   //       }
   //    //+------------------------------------------------------------------+
   // #endif // CVISUALHINT_IMPLEMENTATION
#endif // MOVE_TO_VISUALHINT_MQH

#ifndef MOVE_TO_CHECKBOX_MQH
#define MOVE_TO_CHECKBOX_MQH
   // //+------------------------------------------------------------------+
   // // | Checkbox Control Class |
   // //+------------------------------------------------------------------+
   // class CCheckBox : public CButtonTriggered
   // {
   //    public:
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);

   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0) const;
   //       virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
   //       virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_CHECKBOX);       }
      
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(const string text);
   //       virtual void      InitColors(void);
         
   //    // --- Constructors/destructor
   //                         CCheckBox(void);
   //                         CCheckBox(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                         ~CCheckBox (void) {}
   // };
   // //+------------------------------------------------------------------+
   // #ifndef CCHECKBOX_IMPLEMENTATION
   // #define CCHECKBOX_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CCheckBox::Default constructor.                             |
   //    // | Plots an element in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CCheckBox::CCheckBox(void) : CButtonTriggered("CheckBox","CheckBox",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
   //    {
   //       // ---Initialization
   //          this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCheckBox::Parametric constructor.                          |
   //    // | Plots an element in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CCheckBox::CCheckBox(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CButtonTriggered(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //       // ---Initialization
   //          this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCheckBox::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CCheckBox::Init(const string text)
   //    {
   //       // --- Set default colors, transparency for background and foreground,
   //       // --- and coordinates and boundaries of the button icon drawing area
   //          this.InitColors();
   //          this.SetAlphaBG(0);
   //          this.SetAlphaFG(255);
   //          this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCheckBox::Initializing default object colors |
   //    //+------------------------------------------------------------------+
   //    void CCheckBox::InitColors(void)
   //    {
   //    // --- Initialize the background colors for normal and activated states and make it the current background color
   //       this.InitBackColors(clrNULL);
   //       this.InitBackColorsAct(clrNULL);
   //       this.BackColorToDefault();
         
   //    // --- Initialize the foreground colors for normal and activated states and make it the current text color
   //       this.InitForeColors(clrBlack);
   //       this.InitForeColorsAct(clrBlack);
   //       this.InitForeColorFocused(clrNavy);
   //       this.InitForeColorActFocused(clrNavy);
   //       this.ForeColorToDefault();
         
   //    // --- Initialize the border colors for the normal and activated states and make it the current border color
   //       this.InitBorderColors(clrNULL);
   //       this.InitBorderColorsAct(clrNULL);
   //       this.BorderColorToDefault();

   //    // --- Initialize the border color and foreground color for the locked element
   //       this.InitBorderColorBlocked(clrNULL);
   //       this.InitForeColorBlocked(clrSilver);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCheckBox::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CCheckBox::Compare(const CObject *node,const int mode=0) const
   //    {
   //       return CButtonTriggered::Compare(node,mode);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCheckBox::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CCheckBox::Draw(const bool chart_redraw)
   //    {
   //       // --- Fill the button with the background color, draw a frame and update the background canvas
   //          this.Fill(this.BackColor(),false);
   //          this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //          this.m_background.Update(false);
   //       // --- Display button text
   //          CLabel::Draw(false);
            
   //       // --- Clear the drawing area
   //          this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //       // --- Draw a marked icon for the active state of the button,
   //          if(this.m_state)
   //             this.m_painter.CheckedBox(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
   //       // --- and unchecked - for inactive
   //          else
   //             this.m_painter.UncheckedBox(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
               
   //       // --- If indicated, update the schedule
   //          if(chart_redraw)
   //             ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CCHECKBOX_IMPLEMENTATION
#endif // MOVE_TO_CHECKBOX_MQH

#ifndef MOVE_TO_RADIOBUTTON_MQH
#define MOVE_TO_RADIOBUTTON_MQH
      // //+------------------------------------------------------------------+
   // //| Radio Button Control Class |
   // //+------------------------------------------------------------------+
   // class CRadioButton : public CCheckBox
   // {
   //    public:
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);

   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0) const;
   //       virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
   //       virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_RADIOBUTTON);    }
      
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(const string text);
   //       virtual void      InitColors(void){}
         
   //    // --- Event handler for mouse button clicks (Press)
   //       virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);

   //    // --- Constructors/destructor
   //                         CRadioButton(void);
   //                         CRadioButton(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                         ~CRadioButton (void) {}
   // };
   // //+------------------------------------------------------------------+
   // #ifndef CRADIOBUTTON_IMPLEMENTATION
   // #define CRADIOBUTTON_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CRadioButton::Default constructor.                          |
   //    // | Plots an element in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CRadioButton::CRadioButton(void) : CCheckBox("RadioButton","",::ChartID(),0,0,0,DEF_BUTTON_H,DEF_BUTTON_H)
   //       {
   //       // ---Initialization
   //          this.Init("");
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CRadioButton::Parametric constructor.                       |
   //    // | Plots an element in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CRadioButton::CRadioButton(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CCheckBox(object_name,text,chart_id,wnd,x,y,w,h)
   //       {
   //       // ---Initialization
   //          this.Init("");
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CRadioButton::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CRadioButton::Init(const string text)
   //       {
   //          return;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CRadioButton::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CRadioButton::Compare(const CObject *node,const int mode=0) const
   //       {
   //          return CCheckBox::Compare(node,mode);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CRadioButton::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CRadioButton::Draw(const bool chart_redraw)
   //       {
   //       // --- Fill the button with the background color, draw a frame and update the background canvas
   //          this.Fill(this.BackColor(),false);
   //          this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //          this.m_background.Update(false);
   //       // --- Display button text
   //          CLabel::Draw(false);
            
   //       // --- Clear the drawing area
   //          this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //       // --- Draw a marked icon for the active state of the button,
   //          if(this.m_state)
   //             this.m_painter.CheckedRadioButton(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
   //       // --- and unchecked - for inactive
   //          else
   //             this.m_painter.UncheckedRadioButton(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
               
   //       // --- If indicated, update the schedule
   //          if(chart_redraw)
   //             ::ChartRedraw(this.m_chart_id);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CRadioButton::Event handler for mouse button clicks (Press) |
   //    //+------------------------------------------------------------------+
   //    void CRadioButton::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
   //       {
   //       // --- If the button is already marked, we leave
   //          if(this.m_state)
            
   //             return;
   //       // --- Set the button state opposite to the one already set
   //          ENUM_ELEMENT_STATE state=(this.State()==ELEMENT_STATE_DEF ? ELEMENT_STATE_ACT : ELEMENT_STATE_DEF);
   //          this.SetState(state);         
   //       // --- Call the handler of the parent object indicating the identifier in lparam and the state in dparam
   //          CCanvasBase::OnPressEvent(id,this.m_id,this.m_state,sparam);
   //       }
   //    //+------------------------------------------------------------------+
   // #endif // CRADIOBUTTON_IMPLEMENTATION
#endif // MOVE_TO_RADIOBUTTON_MQH

#ifndef MOVE_TO_PANEL_MQH
#define MOVE_TO_PANEL_MQH
      // //+------------------------------------------------------------------+
   // //| Panel class |
   // //+------------------------------------------------------------------+
   // class CPanel : public CLabel
   // {
   //    private:
   //       CElementBase      m_temp_elm;                // Temporary object for searching elements
   //       CBound            m_temp_bound;              // Temporary object for searching areas
   //    protected:
   //       CListElm          m_list_elm;                // List of attached items
   //       CListElm          m_list_bounds;             // List of areas
   //    // --- Adds a new element to the list
   //       bool              AddNewElement(CElementBase *element);

   //    public:
   //    // --- Returns a pointer to a list of (1) attached items, (2) areas
   //       CListElm         *GetListAttachedElements(void)             { return &this.m_list_elm;                         }
   //       CListElm         *GetListBounds(void)                       { return &this.m_list_bounds;                      }
         
   //    // --- Returns the attached element by (1) index in the list, (2) identifier, (3) assigned object name
   //       CElementBase     *GetAttachedElementAt(const uint index)    { return this.m_list_elm.GetNodeAtIndex(index);    }
   //       CElementBase     *GetAttachedElementByID(const int id);
   //       CElementBase     *GetAttachedElementByName(const string name);
         
   //    // --- Returns the number of (1) areas, (2) attached elements,
   //       int               BoundsTotal(void)                   const { return this.m_list_bounds.Total();               }
   //       int               AttachedElementsTotal(void)         const { return this.m_list_elm.Total();                  }

   //    // --- Returns the area by (1) index in the list, (2) identifier, (3) assigned area name
   //       CBound           *GetBoundAt(const uint index)              { return this.m_list_bounds.GetNodeAtIndex(index); }
   //       CBound           *GetBoundByID(const int id);
   //       CBound           *GetBoundByName(const string name);
         
   //    // --- Creates and adds (1) a new, (2) a previously created element to the list
   //       virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
   //       virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);
   //    // --- Removes the specified element
   //       bool              DeleteElement(const int index)            { return this.m_list_elm.Delete(index);            }

   //    // --- (1) Creates and adds a new area to the list, (2) deletes the specified area
   //       CBound           *InsertNewBound(const string name,const int dx,const int dy,const int w,const int h);
   //       bool              DeleteBound(const int index)              { return this.m_list_bounds.Delete(index);         }
         
   //    // --- (1) Assigns an object to the specified area, (2) unassigns an object from the specified area
   //       bool              AssignObjectToBound(const int bound, CBaseObj *object);
   //       bool              UnassignObjectFromBound(const int bound);

   //    // --- Changes the size of an object
   //       virtual bool      ResizeW(const int w);
   //       virtual bool      ResizeH(const int h);
   //       virtual bool      Resize(const int w,const int h);
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);
         
   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0) const;
   //       virtual bool      Save(const int file_handle);
   //       virtual bool      Load(const int file_handle);
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_PANEL);                      }
      
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(void);
   //       virtual void      InitColors(void);
         
   //    // --- Sets the object to new XY coordinates
   //       virtual bool      Move(const int x,const int y);
   //    // --- Offsets the object along the XY axes by the specified offset
   //       virtual bool      Shift(const int dx,const int dy);
   //    // --- Sets both the coordinates and dimensions of an element
   //       virtual bool      MoveXYWidthResize(const int x,const int y,const int w,const int h);
         
   //    // --- (1) Hides (2) displays the object on all chart periods,
   //    // --- (3) brings the object to the front, (4) locks, (5) unlocks the element,
   //       virtual void      Hide(const bool chart_redraw);
   //       virtual void      Show(const bool chart_redraw);
   //       virtual void      BringToTop(const bool chart_redraw);
   //       virtual void      Block(const bool chart_redraw);
   //       virtual void      Unblock(const bool chart_redraw);
         
   //    // --- Logs a description of the object
   //       virtual void      Print(void);
         
   //    // --- Prints a list of (1) attached objects, (2) areas
   //       void              PrintAttached(const uint tab=3);
   //       void              PrintBounds(void);

   //    // --- Event handler
   //       virtual void      OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam);
         
   //    // --- Timer event handler
   //       virtual void      TimerEventHandler(void);
         
   //    // --- Constructors/destructor
   //                         CPanel(void);
   //                         CPanel(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CPanel (void) { this.m_list_elm.Clear(); this.m_list_bounds.Clear(); }
   // };
   // #ifndef CPANEL_IMPLEMENTATION
   // #define CPANEL_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Default constructor.                                |
   //    // | Plots an element in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CPanel::CPanel(void) : CLabel("Panel","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Parametric constructor.                             |
   //    // | Plots an element in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CPanel::CPanel(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CLabel(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CPanel::Init(void)
   //    {
   //    // --- Initialize default colors
   //       this.InitColors();
   //    // --- Background is transparent, foreground is not
   //       this.SetAlphaBG(0);
   //       this.SetAlphaFG(255);
   //    // --- Set the offset and dimensions of the image area
   //       this.SetImageBound(0,0,this.Width(),this.Height());
   //    // --- Frame width
   //       this.SetBorderWidth(2);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Initializing default object colors |
   //    //+------------------------------------------------------------------+
   //    void CPanel::InitColors(void)
   //    {
   //    // --- Initialize the background colors for normal and activated states and make it the current background color
   //       this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //       this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //       this.BackColorToDefault();
         
   //    // --- Initialize the foreground colors for normal and activated states and make it the current text color
   //       this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.ForeColorToDefault();
         
   //    // --- Initialize the border colors for the normal and activated states and make it the current border color
   //       this.InitBorderColors(clrNULL,clrNULL,clrNULL,clrNULL);
   //       this.InitBorderColorsAct(clrNULL,clrNULL,clrNULL,clrNULL);
   //       this.BorderColorToDefault();
         
   //    // --- Initialize the border color and foreground color for the blocked element
   //       this.InitBorderColorBlocked(clrNULL);
   //       this.InitForeColorBlocked(clrSilver);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Comparing two objects |
   //    //+------------------------------------------------------------------+
   //    int CPanel::Compare(const CObject *node,const int mode=0) const
   //    {
   //       return CLabel::Compare(node,mode);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Changes the width of an object |
   //    //+------------------------------------------------------------------+
   //    bool CPanel::ResizeW(const int w)
   //    {
   //       if(!this.ObjectResizeW(w))
   //          return false;
   //       this.BoundResizeW(w);
   //       this.SetImageSize(w,this.Height());
   //       if(!this.ObjectTrim())
   //       {
   //          this.Update(false);
   //          this.Draw(false);
   //       }
   //    // --- We get a pointer to the base element and, if it exists, its type - container,
   //    // --- check the ratio of the dimensions of the current element relative to the dimensions of the container
   //    // --- to display scrollbars in the container if necessary
   //       if(this.GetContainer()!=NULL && this.GetContainer().Type()==ELEMENT_TYPE_CONTAINER)
   //       {
   //          CContainer *base=this.GetContainer();
   //          base.CheckElementSizes(&this);
   //       }
            
   //    // --- In a loop through attached elements, we cut off each element along the boundaries of the container
   //       int total=this.m_list_elm.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             elm.ObjectTrim();
   //       }
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Changes the height of an object |
   //    //+------------------------------------------------------------------+
   //    bool CPanel::ResizeH(const int h)
   //    {
   //       if(!this.ObjectResizeH(h))
   //          return false;
   //       this.BoundResizeH(h);
   //       this.SetImageSize(this.Width(),h);
   //       if(!this.ObjectTrim())
   //       {
   //          this.Update(false);
   //          this.Draw(false);
   //       }
   //    // --- We get a pointer to the base element and, if it exists, its type - container,
   //    // --- check the ratio of the dimensions of the current element relative to the dimensions of the container
   //    // --- to display scrollbars in the container if necessary
   //       if(this.GetContainer()!=NULL && this.GetContainer().Type()==ELEMENT_TYPE_CONTAINER)
   //       {
   //          CContainer *base=this.GetContainer();
   //          base.CheckElementSizes(&this);
   //       }
            
   //    // --- In a loop through attached elements, we cut off each element along the boundaries of the container
   //       int total=this.m_list_elm.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             elm.ObjectTrim();
   //       }
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Resizes an object |
   //    //+------------------------------------------------------------------+
   //    bool CPanel::Resize(const int w,const int h)
   //    {
   //       if(!this.ObjectResize(w,h))
   //          return false;
   //       this.BoundResize(w,h);
   //       this.SetImageSize(w,h);
   //       if(!this.ObjectTrim())
   //       {
   //          this.Update(false);
   //          this.Draw(false);
   //       }
   //    // --- We get a pointer to the base element and, if it exists, its type - container,
   //    // --- check the ratio of the dimensions of the current element relative to the dimensions of the container
   //    // --- to display scrollbars in the container if necessary
   //       CContainer *base=this.GetContainer();
   //       if(base!=NULL && base.Type()==ELEMENT_TYPE_CONTAINER)
   //          base.CheckElementSizes(&this);
            
   //    // --- In a loop through attached elements, we cut off each element along the boundaries of the container
   //       int total=this.m_list_elm.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             elm.ObjectTrim();
   //       }
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CPanel::Draw(const bool chart_redraw)
   //    {
   //    // --- Fill the object with the background color
   //       this.Fill(this.BackColor(),false);
         
   //    // --- Clear the drawing area
   //       this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //    // --- Set the color for the dark and light lines and draw the panel frame
   //       color clr_dark =(this.BackColor()==clrNULL ? this.BackColor() : this.GetBackColorControl().NewColor(this.BackColor(),-20,-20,-20));
   //       color clr_light=(this.BackColor()==clrNULL ? this.BackColor() : this.GetBackColorControl().NewColor(this.BackColor(),  6,  6,  6));
   //       if(this.BorderWidthBottom()+this.BorderWidthLeft()+this.BorderWidthRight()+this.BorderWidthTop()!=0)
   //          this.m_painter.FrameGroupElements(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),
   //                                           this.m_painter.Width(),this.m_painter.Height(),this.Text(),
   //                                           this.ForeColor(),clr_dark,clr_light,this.AlphaFG(),true);
         
   //    // --- Updating the background canvas without redrawing the graph
   //       this.m_background.Update(false);
         
   //    // --- Drawing list elements
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL && elm.Type()!=ELEMENT_TYPE_SCROLLBAR_H && elm.Type()!=ELEMENT_TYPE_SCROLLBAR_V)
   //             elm.Draw(false);
   //       }
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Adds a new element to the list |
   //    //+------------------------------------------------------------------+
   //    bool CPanel::AddNewElement(CElementBase *element)
   //    {
   //    // --- If an empty pointer is passed, we report this and return false
   //       if(element==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
   //          return false;
   //       }
   //    // --- Remember the list sorting method
   //       int sort_mode=this.m_list_elm.SortMode();
   //    // --- Set the list to sort by identifier
   //       this.m_list_elm.Sort(ELEMENT_SORT_BY_ID);
   //    // --- If such element is not in the list,
   //       if(this.m_list_elm.Search(element)==NULL)
   //       {
   //          // --- return the list to its original sorting and return the result of adding it to the list
   //          this.m_list_elm.Sort(sort_mode);
   //          return(this.m_list_elm.Add(element)>-1);
   //       }
   //    // --- Return the list to its original sorting
   //       this.m_list_elm.Sort(sort_mode);
   //    // --- An element with the same identifier is already in the list - return false
   //       return false;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Creates and adds a new element to the list |
   //    //+------------------------------------------------------------------+
   //    CElementBase *CPanel::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
   //    {
   //    // --- Create a name for the graphic object
   //       int elm_total=this.m_list_elm.Total();
   //       string obj_name=this.NameFG()+"_"+ElementShortName(type)+(string)elm_total;
   //    // --- Calculate coordinates
   //       int x=this.X()+dx;
   //       int y=this.Y()+dy;
   //    // --- Depending on the type of object, we create a new object
   //       CElementBase *element=NULL;
   //       switch(type)
   //       {
   //          case ELEMENT_TYPE_LABEL                      :  element = new CLabel(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);             break;   // Text label
   //          case ELEMENT_TYPE_BUTTON                     :  element = new CButton(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);            break;   // Simple button
   //          case ELEMENT_TYPE_BUTTON_TRIGGERED           :  element = new CButtonTriggered(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Two-position button
   //          case ELEMENT_TYPE_BUTTON_ARROW_UP            :  element = new CButtonArrowUp(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);     break;   // Up arrow button
   //          case ELEMENT_TYPE_BUTTON_ARROW_DOWN          :  element = new CButtonArrowDown(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Down arrow button
   //          case ELEMENT_TYPE_BUTTON_ARROW_LEFT          :  element = new CButtonArrowLeft(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Left Arrow Button
   //          case ELEMENT_TYPE_BUTTON_ARROW_RIGHT         :  element = new CButtonArrowRight(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);  break;   // Right arrow button
   //          case ELEMENT_TYPE_CHECKBOX                   :  element = new CCheckBox(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);          break;   // CheckBox control
   //          case ELEMENT_TYPE_RADIOBUTTON                :  element = new CRadioButton(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);       break;   // RadioButton control
   //          case ELEMENT_TYPE_SCROLLBAR_THUMB_H          :  element = new CScrollBarThumbH(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Scrollbar horizontal ScrollBar
   //          case ELEMENT_TYPE_SCROLLBAR_THUMB_V          :  element = new CScrollBarThumbV(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Vertical ScrollBar
   //          case ELEMENT_TYPE_SCROLLBAR_H                :  element = new CScrollBarH(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);        break;   // Horizontal ScrollBar control
   //          case ELEMENT_TYPE_SCROLLBAR_V                :  element = new CScrollBarV(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);        break;   // Vertical ScrollBar control
   //          case ELEMENT_TYPE_TABLE_ROW_VIEW             :  element = new CTableRowView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);      break;   // Table row visual object
   //          case ELEMENT_TYPE_TABLE_CAPTION_VIEW         :  element = new CCaptionView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);       break;   // Basic header object (View)
   //          case ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW  :  element = new CColumnCaptionView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h); break;   // Table column header visual representation object
   //          case ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW     :  element = new CRowCaptionView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);    break;   // Table row header visual representation object
   //          case ELEMENT_TYPE_TABLE_HEADER_VIEW          :  element = new CTableHeaderView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Table header visual object
   //          case ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW     :  element = new CTableRowsHeaderView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);break;  // Object for visual representation of table row headers
   //          case ELEMENT_TYPE_TABLE_VIEW                 :  element = new CTableView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);         break;   // Table visual object
   //          case ELEMENT_TYPE_PANEL                      :  element = new CPanel(obj_name,"",this.m_chart_id,this.m_wnd,x,y,w,h);               break;   // Panel control
   //          case ELEMENT_TYPE_GROUPBOX                   :  element = new CGroupBox(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);          break;   // GroupBox control
   //          case ELEMENT_TYPE_CONTAINER                  :  element = new CContainer(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);         break;   // Container control
   //          default                                      :  element = NULL;
   //       }

   //    // --- If a new element is not created, we report this and return NULL
   //       if(element==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to create graphic element %s",__FUNCTION__,ElementDescription(type));
   //          return NULL;
   //       }
   //    // --- Set the identifier, name, container and z-order of the element
   //       element.SetID(elm_total);
   //       element.SetName(user_name);
   //       element.SetContainerObj(&this);
   //       element.ObjectSetZOrder(this.ObjectZOrder()+1);
         
   //    // --- If the created element is not added to the list, we report this, delete the created element and return NULL
   //       if(!this.AddNewElement(element))
   //       {
   //          ::PrintFormat("%s: Error. Failed to add %s element with ID %d to list",__FUNCTION__,ElementDescription(type),element.ID());
   //          delete element;
   //          return NULL;
   //       }
   //    // --- We get the parent element to which the children are attached
   //       CElementBase *elm=this.GetContainer();
   //    // --- If the parent element is of type "Container", then it has scrollbars
   //       if(elm!=NULL && elm.Type()==ELEMENT_TYPE_CONTAINER)
   //       {
   //          // --- Convert CElementBase to CContainer
   //          CContainer *container_obj=elm;
   //          // --- If the horizontal scroll bar is visible,
   //          if(container_obj.ScrollBarHorzIsVisible())
   //          {
   //             // --- get a pointer to the horizontal scrollbar and move it to the front
   //             CScrollBarH *sbh=container_obj.GetScrollBarH();
   //             if(sbh!=NULL)
   //                sbh.BringToTop(false);
   //          }
   //          // --- If the vertical scroll bar is visible,
   //          if(container_obj.ScrollBarVertIsVisible())
   //          {
   //             // --- get the pointer to the vertical scrollbar and move it to the front
   //             CScrollBarV *sbv=container_obj.GetScrollBarV();
   //             if(sbv!=NULL)
   //                sbv.BringToTop(false);
   //          }
   //       }
   //    // --- Return a pointer to the created and attached element
   //       return element;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Adds the specified element to the list |
   //    //+------------------------------------------------------------------+
   //    CElementBase *CPanel::InsertElement(CElementBase *element,const int dx,const int dy)
   //    {
   //    // --- If an empty or invalid pointer to an element is passed, return NULL
   //       if(::CheckPointer(element)==POINTER_INVALID)
   //       {
   //          ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
   //          return NULL;
   //       }
   //    // --- If a base element is passed, return NULL
   //       if(element.Type()==ELEMENT_TYPE_BASE)
   //       {
   //          ::PrintFormat("%s: Error. The base element cannot be used",__FUNCTION__);
   //          return NULL;
   //       }
   //    // --- Remember the element identifier and set a new one
   //       int id=element.ID();
   //       element.SetID(this.m_list_elm.Total());
         
   //    // --- Add an element to the list; if it fails, we report this, set the initial identifier and return NULL
   //       if(!this.AddNewElement(element))
   //       {
   //          ::PrintFormat("%s: Error. Failed to add element %s to list",__FUNCTION__,ElementDescription((ENUM_ELEMENT_TYPE)element.Type()));
   //          element.SetID(id);
   //          return NULL;
   //       }
   //    // --- Set new coordinates, container and z-order of the element
   //       int x=this.X()+dx;
   //       int y=this.Y()+dy;
   //       element.Move(x,y);
   //       element.SetContainerObj(&this);
   //       element.ObjectSetZOrder(this.ObjectZOrder()+1);
         
   //    // --- Return a pointer to the attached element
   //       return element;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Returns an element by ID |
   //    //+------------------------------------------------------------------+
   //    CElementBase *CPanel::GetAttachedElementByID(const int id)
   //    {
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL && elm.ID()==id)
   //             return elm;
   //       }
   //       return NULL;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Returns an element by the assigned object name |
   //    //+------------------------------------------------------------------+
   //    CElementBase *CPanel::GetAttachedElementByName(const string name)
   //    {
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL && elm.Name()==name)
   //             return elm;
   //       }
   //       return NULL;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Creates and adds a new area to the list |
   //    //+------------------------------------------------------------------+
   //    CBound *CPanel::InsertNewBound(const string name,const int dx,const int dy,const int w,const int h)
   //    {
   //    // --- Check if there is an area with the specified name in the list and, if so, report it and return NULL
   //       this.m_temp_bound.SetName(name);
   //    // --- Remember the list sorting method
   //       int sort_mode=this.m_list_bounds.SortMode();
   //    // --- Set the list to sort by name
   //       this.m_list_bounds.Sort(ELEMENT_SORT_BY_NAME);
   //       if(this.m_list_bounds.Search(&this.m_temp_bound)!=NULL)
   //       {
   //          // --- We return the initial sorting to the list, inform that such an object already exists and return NULL
   //          this.m_list_bounds.Sort(sort_mode);
   //          ::PrintFormat("%s: Error. An area named \"%s\" is already in the list",__FUNCTION__,name);
   //          return NULL;
   //       }
   //    // --- Return the list to its original sorting
   //       this.m_list_bounds.Sort(sort_mode);
   //    // --- Create a new area object; if it fails, we report it and return NULL
   //       CBound *bound=new CBound(dx,dy,w,h);
   //       if(bound==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to create CBound object",__FUNCTION__);
   //          return NULL;
   //       }
   //    // --- Set the area name and identifier, and return a pointer to the object
   //       bound.SetName(name);
   //       bound.SetID(this.m_list_bounds.Total());
   //    // --- If a new object could not be added to the list, we report this, delete the object and return NULL
   //       if(this.m_list_bounds.Add(bound)==-1)
   //       {
   //          ::PrintFormat("%s: Error. Failed to add CBound object to list",__FUNCTION__);
   //          delete bound;
   //          return NULL;
   //       }
   //       return bound;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Returns area by ID |
   //    //+------------------------------------------------------------------+
   //    CBound *CPanel::GetBoundByID(const int id)
   //    {
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          CBound *bound=this.GetBoundAt(i);
   //          if(bound!=NULL && bound.ID()==id)
   //             return bound;
   //       }
   //       return NULL;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Returns the area by assigned area name |
   //    //+------------------------------------------------------------------+
   //    CBound *CPanel::GetBoundByName(const string name)
   //    {
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          CBound *bound=this.GetBoundAt(i);
   //          if(bound!=NULL && bound.Name()==name)
   //             return bound;
   //       }
   //       return NULL;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Assigns an object to the specified area |
   //    //+------------------------------------------------------------------+
   //    bool CPanel::AssignObjectToBound(const int bound,CBaseObj *object)
   //    {
   //       CBound *bound_obj=this.GetBoundAt(bound);
   //       if(bound_obj==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get Bound at index %d",__FUNCTION__,bound);
   //          return false;
   //       }
   //       bound_obj.AssignObject(object);
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Unassigns an object from the specified area |
   //    //+------------------------------------------------------------------+
   //    bool CPanel::UnassignObjectFromBound(const int bound)
   //    {
   //       CBound *bound_obj=this.GetBoundAt(bound);
   //       if(bound_obj==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get Bound at index %d",__FUNCTION__,bound);
   //          return false;
   //       }
   //       bound_obj.UnassignObject();
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Logs a description of an object |
   //    //+------------------------------------------------------------------+
   //    void CPanel::Print(void)
   //    {
   //       CBaseObj::Print();
   //       this.PrintAttached();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Prints a list of attached objects |
   //    //+------------------------------------------------------------------+
   //    void CPanel::PrintAttached(const uint tab=3)
   //    {
   //    // --- In a loop through all bound elements
   //       int total=this.m_list_elm.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- get another element
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm==NULL)
   //             continue;
   //          // --- Get the element type and, if it is a scroll bar, skip it
   //          ENUM_ELEMENT_TYPE type=(ENUM_ELEMENT_TYPE)elm.Type();
   //          if(type==ELEMENT_TYPE_SCROLLBAR_H || type==ELEMENT_TYPE_SCROLLBAR_V)
   //             continue;
   //          // --- Print out the description of the element in the magazine
   //          ::PrintFormat("%*s[%d]: %s",tab,"",i,elm.Description());
   //          // --- If the element is a container, print its list of attached elements to the log
   //          if(type==ELEMENT_TYPE_PANEL || type==ELEMENT_TYPE_GROUPBOX || type==ELEMENT_TYPE_CONTAINER)
   //          {
   //             CPanel *obj=elm;
   //             obj.PrintAttached(tab*2);
   //          }
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Prints a list of areas |
   //    //+------------------------------------------------------------------+
   //    void CPanel::PrintBounds(void)
   //    {
   //    // --- In a loop through a list of element areas
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- get the next area and print its description into the journal
   //          CBound *obj=this.GetBoundAt(i);
   //          if(obj==NULL)
   //             continue;
   //          ::PrintFormat("  [%d]: %s",i,obj.Description());
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Sets an object to new X and Y coordinates |
   //    //+------------------------------------------------------------------+
   //    bool CPanel::Move(const int x,const int y)
   //    {
   //       // --- Calculate the distance by which the element will move
   //       int delta_x=x-this.X();
   //       int delta_y=y-this.Y();

   //       // --- Move the element to the specified coordinates
   //       bool res=this.ObjectMove(x,y);
   //       if(!res)
   //          return false;
   //       this.BoundMove(x,y);
   //       this.ObjectTrim();
         
   //    // --- Move all anchored elements to the calculated distance
   //       int total=this.m_list_elm.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- Move the anchored element taking into account the offset of the parent element
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             res &=elm.Move(elm.X()+delta_x,elm.Y()+delta_y);
   //       }
   //    // --- Return the result of moving all bound elements
   //       return res;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Shifts an object along the X and Y axes by the specified offset |
   //    //+------------------------------------------------------------------+
   //    bool CPanel::Shift(const int dx,const int dy)
   //    {
   //    // --- Shift the element by the specified distance
   //       bool res=this.ObjectShift(dx,dy);
   //       if(!res)
   //          return false;
   //       this.BoundShift(dx,dy);
   //       this.ObjectTrim();
         
   //    // --- Move all anchored elements
   //       int total=this.m_list_elm.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             res &=elm.Shift(dx,dy);
   //       }
   //    // --- Return the result of the offset of all anchored elements
   //       return res;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Sets both the coordinates and dimensions of an element |
   //    //+------------------------------------------------------------------+
   //    bool CPanel::MoveXYWidthResize(const int x,const int y,const int w,const int h)
   //    {
   //       // --- Calculate the distance by which the element will move
   //       int delta_x=x-this.X();
   //       int delta_y=y-this.Y();

   //       // --- Move the element to the specified coordinates with resizing
   //       if(!CCanvasBase::MoveXYWidthResize(x,y,w,h))
   //          return false;
   //       this.BoundMove(x,y);
   //       this.BoundResize(w,h);
   //       this.SetImageBound(0,0,this.Width(),this.Height());
   //       if(!this.ObjectTrim())
   //       {
   //          this.Update(false);
   //          this.Draw(false);
   //       }
         
   //    // --- Move all anchored elements to the calculated distance
   //       bool res=true;
   //       int total=this.m_list_elm.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- Move the anchored element taking into account the offset of the parent element
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             res &=elm.Move(elm.X()+delta_x,elm.Y()+delta_y);
   //       }
   //    // --- Return the result of moving all bound elements
   //       return res;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Hides the object on all chart periods |
   //    //+------------------------------------------------------------------+
   //    void CPanel::Hide(const bool chart_redraw)
   //    {
   //    // --- If the object is already hidden, we leave
   //       if(this.m_hidden)
   //          return;
            
   //    // --- Hide the panel
   //       CCanvasBase::Hide(false);
   //    // --- Hiding attached objects
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             elm.Hide(false);
   //       }
   //    // --- If indicated, redraw the graph
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Displays an object on all chart periods |
   //    //+------------------------------------------------------------------+
   //    void CPanel::Show(const bool chart_redraw)
   //    {
   //    // --- If the object is already visible, or should not be displayed in the container, leave
   //       if(!this.m_hidden || !this.m_visible_in_container)
   //          return;
            
   //    // --- Display the panel
   //       CCanvasBase::Show(false);
   //    // --- Display attached objects
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //          {
   //             if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_H || elm.Type()==ELEMENT_TYPE_SCROLLBAR_V)
   //                continue;
   //             elm.Show(false);
   //          }
   //       }
   //    // --- If indicated, redraw the graph
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Brings the object to the front |
   //    //+------------------------------------------------------------------+
   //    void CPanel::BringToTop(const bool chart_redraw)
   //    {
   //    // --- Move the panel to the front
   //       CCanvasBase::BringToTop(false);
   //    // --- Place attached objects in the foreground
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //          {
   //             if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_H || elm.Type()==ELEMENT_TYPE_SCROLLBAR_V)
   //                continue;
   //             elm.ObjectTrim();
   //             elm.BringToTop(false);
   //          }
   //       }
   //    // --- If indicated, redraw the graph
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Blocks element |
   //    //+------------------------------------------------------------------+
   //    void CPanel::Block(const bool chart_redraw)
   //    {
   //    // --- If the element is already blocked, we leave
   //       if(this.m_blocked)
   //          return;
            
   //    // --- Lock the panel
   //       CCanvasBase::Block(false);
   //    // --- Blocking attached objects
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             elm.Block(false);
   //       }
   //    // --- If indicated, redraw the graph
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Unlocks element |
   //    //+------------------------------------------------------------------+
   //    void CPanel::Unblock(const bool chart_redraw)
   //    {
   //    // --- If the element is already unlocked, we leave
   //       if(!this.m_blocked)
   //          return;
            
   //    // --- Unlock the panel
   //       CCanvasBase::Unblock(false);
   //    // --- Unlock attached objects
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             elm.Unblock(false);
   //       }
   //    // --- If indicated, redraw the graph
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Saving to file |
   //    //+------------------------------------------------------------------+
   //    bool CPanel::Save(const int file_handle)
   //    {
   //    // --- Save the data of the parent object
   //       if(!CElementBase::Save(file_handle))
   //          return false;
      
   //    // --- Save the list of attached elements
   //       if(!this.m_list_elm.Save(file_handle))
   //          return false;
   //    // --- Save the list of areas
   //       if(!this.m_list_bounds.Save(file_handle))
   //          return false;
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Loading from file |
   //    //+------------------------------------------------------------------+
   //    bool CPanel::Load(const int file_handle)
   //    {
   //    // --- Loading the data of the parent object
   //       if(!CElementBase::Load(file_handle))
   //          return false;
            
   //    // --- Loading the list of attached elements
   //       if(!this.m_list_elm.Load(file_handle))
   //          return false;
   //    // --- Loading a list of areas
   //       if(!this.m_list_bounds.Load(file_handle))
   //          return false;
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Event Handler |
   //    //+------------------------------------------------------------------+
   //    void CPanel::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
   //    {
   //    // --- Call the event handler of the parent class
   //       CCanvasBase::OnChartEvent(id,lparam,dparam,sparam);
   //    // --- In a loop through all bound elements
   //       int total=this.m_list_elm.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- get the next element and call its event handler
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             elm.OnChartEvent(id,lparam,dparam,sparam);
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CPanel::Timer event handler |
   //    //+------------------------------------------------------------------+
   //    void CPanel::TimerEventHandler(void)
   //    {
   //    // --- In a loop through all bound elements
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          // --- get the next element and call its timer event handler
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             elm.TimerEventHandler();
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CPANEL_IMPLEMENTATION
#endif // MOVE_TO_PANEL_MQH

#ifndef MOVE_TO_GROUPBOX_MQH
#define MOVE_TO_GROUPBOX_MQH
      // //+------------------------------------------------------------------+
   // // | Object Group Class |
   // //+------------------------------------------------------------------+
   // class CGroupBox : public CPanel
   // {
   //    public:
   //    // ---Object type
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_GROUPBOX); }
      
   //    // --- Initializing a class object
   //       void              Init(void);
         
   //    // --- Sets a group of elements
   //       virtual void      SetGroup(const int group);
         
   //    // --- Creates and adds (1) a new, (2) a previously created element to the list
   //       virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
   //       virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);

   //    // --- Constructors/destructor
   //                         CGroupBox(void);
   //                         CGroupBox(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CGroupBox(void) {}
   // };
   // #ifndef CGROUPBOX_IMPLEMENTATION
   // #define CGROUPBOX_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CGroupBox::Default constructor.                             |
   //    // | Plots an element in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CGroupBox::CGroupBox(void) : CPanel("GroupBox","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CGroupBox::Parametric constructor.                          |
   //    // | Plots an element in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CGroupBox::CGroupBox(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CPanel(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CGroupBox::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CGroupBox::Init(void)
   //    {
   //    // ---Initialization using parent class
   //       CPanel::Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CGroupBox::Sets a group of elements |
   //    //+------------------------------------------------------------------+
   //    void CGroupBox::SetGroup(const int group)
   //    {
   //    // --- Set the group to this element using the parent class method
   //       CElementBase::SetGroup(group);
   //    // --- In a loop through a list of bound elements
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          // --- get the next element and assign a group to it
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             elm.SetGroup(group);
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CGroupBox::Creates and adds a new element to the list |
   //    //+------------------------------------------------------------------+
   //    CElementBase *CGroupBox::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
   //    {
   //    // --- Create and add a new element to the list of elements
   //       CElementBase *element=CPanel::InsertNewElement(type,text,user_name,dx,dy,w,h);
   //       if(element==NULL)
   //          return NULL;
   //    // --- Set the created element to a group equal to the group of this object
   //       element.SetGroup(this.Group());
   //       return element;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CGroupBox::Adds the specified element to the list |
   //    //+------------------------------------------------------------------+
   //    CElementBase *CGroupBox::InsertElement(CElementBase *element,const int dx,const int dy)
   //    {
   //    // --- Add a new element to the list of elements
   //       if(CPanel::InsertElement(element,dx,dy)==NULL)
   //          return NULL;
   //    // --- Set the added element to a group equal to the group of this object
   //       element.SetGroup(this.Group());
   //       return element;
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CGROUPBOX_IMPLEMENTATION
#endif // MOVE_TO_GROUPBOX_MQH

#ifndef MOVE_TO_SCROLLBARTHUMBH_MQH
#define MOVE_TO_SCROLLBARTHUMBH_MQH
      // //+------------------------------------------------------------------+
   // //| Horizontal Scroll Slider Class |
   // //+------------------------------------------------------------------+
   // class CScrollBarThumbH : public CButton
   // {
   //    protected:
   //       bool              m_chart_redraw;                           // Graph update flag
   //    public:
   //    // --- (1) Sets, (2) returns the graph update flag
   //       void              SetChartRedrawFlag(const bool flag)       { this.m_chart_redraw=flag;               }
   //       bool              ChartRedrawFlag(void)               const { return this.m_chart_redraw;             }
         
   //    // --- Virtual methods (1) save to file, (2) load from file, (3) object type
   //       virtual bool      Save(const int file_handle);
   //       virtual bool      Load(const int file_handle);
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_THUMB_H); }
         
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(const string text);
         
   //    // --- Event handlers for (1) cursor movement, (2) wheel scrolling
   //       virtual void      OnMoveEvent(const int id, const long lparam, const double dparam, const string sparam);
   //       virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);
         
   //    // --- Constructors/destructor
   //                         CScrollBarThumbH(void);
   //                         CScrollBarThumbH(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CScrollBarThumbH (void) {}
   // };
   // #ifndef CSCROLLBARTHUMBH_IMPLEMENTATION
   // #define CSCROLLBARTHUMBH_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbH::Default constructor.                      |
   //    // | Plots an element in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CScrollBarThumbH::CScrollBarThumbH(void) : CButton("SBThumb","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_SCROLLBAR_TH)
   //    {
   //    // ---Initialization
   //       this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbH::The constructor is parametric.                   |
   //    // | Plots an element in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CScrollBarThumbH::CScrollBarThumbH(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CButton(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //    // ---Initialization
   //       this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbH::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarThumbH::Init(const string text)
   //    {
   //    // ---Initializing the parent class
   //       CButton::Init("");
   //    // --- Set the relocatability and schedule update flags
   //       this.SetMovable(true);
   //       this.SetChartRedrawFlag(false);
   //    // --- Element is not clipped to container boundaries
   //       this.m_trim_flag=false;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbH::Cursor move handler |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarThumbH::OnMoveEvent(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //    // --- Base object cursor movement handler
   //       CCanvasBase::OnMoveEvent(id,lparam,dparam,sparam);
   //    // --- Get a pointer to the base object (horizontal scrollbar control)
   //       CCanvasBase *base_obj=this.GetContainer();
   //    // --- If the movability flag is not set for the slider, or the pointer to the base object is not received, we leave
   //       if(!this.IsMovable() || base_obj==NULL)
   //          return;
         
   //    // --- Get the width of the base object and calculate the boundaries of the space for the slider
   //       int base_w=base_obj.Width();
   //       int base_left=base_obj.X()+base_obj.Height();
   //       int base_right=base_obj.Right()-base_obj.Height()+1;
         
   //    // --- From the coordinates of the cursor and the size of the slider, we calculate the restrictions for movement
   //       int x=(int)lparam-this.m_cursor_delta_x;
   //       if(x<base_left)
   //          x=base_left;
   //       if(x+this.Width()>base_right)
   //          x=base_right-this.Width();
   //    // --- Move the slider to the calculated X coordinate
   //       if(!this.MoveX(x))
   //          return;
            
   //    // --- Calculate the position of the slider
   //       int thumb_pos=this.X()-base_left;
         
   //    // --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   //       ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_MOVE, thumb_pos, dparam, this.NameFG());
   //    // --- Redraw the graph
   //       if(this.m_chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbH::Wheel scroll handler |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarThumbH::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //    // --- Get a pointer to the base object (horizontal scroll bar control)
   //       CCanvasBase *base_obj=this.GetContainer();
         
   //    // --- Get the name of the main object in the hierarchy by value in sparam
   //       string array_names[];
   //       string name_main=(GetElementNames(sparam,"_",array_names)>0 ? array_names[0] : "");
         
   //    // --- If the main object in the hierarchy is not ours, we leave
   //       if(::StringFind(this.NameFG(),name_main)!=0)
   //          return;
            
   //    // --- If the movability flag is not set for the slider, or the pointer to the base object is not received, we leave
   //       if(!this.IsMovable() || base_obj==NULL)
   //          return;
         
   //    // --- Get the width of the base object and calculate the boundaries of the space for the slider
   //       int base_w=base_obj.Width();
   //       int base_left=base_obj.X()+base_obj.Height();
   //       int base_right=base_obj.Right()-base_obj.Height()+1;
         
   //    // --- Set the direction of displacement depending on the direction of rotation of the mouse wheel
   //       int dx=(dparam<0 ? 2 : dparam>0 ? -2 : 0);
   //       if(dx==0)
   //          dx=(int)lparam;

   //    // --- If, when shifted, the slider goes beyond the left edge of its area, set it to the left edge
   //       if(dx<0 && this.X()+dx<=base_left)
   //          this.MoveX(base_left);
   //    // --- otherwise, if, when shifted, the slider goes beyond the right edge of its area, position it along the right edge
   //       else if(dx>0 && this.Right()+dx>=base_right)
   //          this.MoveX(base_right-this.Width());
   //    // --- Otherwise, if the slider is within its area, move it by the offset amount
   //       else
   //       {
   //          this.ShiftX(dx);
   //       }

   //    // --- Calculate the position of the slider
   //       int thumb_pos=this.X()-base_left;
         
   //    // --- Getting the cursor coordinates
   //       int x=CCommonManager::GetInstance().CursorX();
   //       int y=CCommonManager::GetInstance().CursorY();
         
   //    // --- If the cursor hits the slider, change the color to “In Focus”,
   //       if(this.Contains(x,y))
   //          this.OnFocusEvent(id,lparam,dparam,sparam);
   //    // --- otherwise - return the color to "Default"
   //       else
   //          this.OnReleaseEvent(id,lparam,dparam,sparam);
            
   //    // --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   //       ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_WHEEL, thumb_pos, dparam, this.NameFG());
   //    // --- Redraw the graph
   //       if(this.m_chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbH::Saving to file |
   //    //+------------------------------------------------------------------+
   //    bool CScrollBarThumbH::Save(const int file_handle)
   //    {
   //    // --- Save the data of the parent object
   //       if(!CButton::Save(file_handle))
   //          return false;
      
   //    // --- Save the graph update flag
   //       if(::FileWriteInteger(file_handle,this.m_chart_redraw,INT_VALUE)!=INT_VALUE)
   //          return false;
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbH::Loading from file |
   //    //+------------------------------------------------------------------+
   //    bool CScrollBarThumbH::Load(const int file_handle)
   //    {
   //    // --- Loading the data of the parent object
   //       if(!CButton::Load(file_handle))
   //          return false;
            
   //    // --- Loading the graph update flag
   //       this.m_chart_redraw=::FileReadInteger(file_handle,INT_VALUE);
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CSCROLLBARTHUMBH_IMPLEMENTATION
#endif // MOVE_TO_SCROLLBARTHUMBH_MQH

#ifndef MOVE_TO_SCROLLBARTHUMBV_MQH
#define MOVE_TO_SCROLLBARTHUMBV_MQH
      // //+------------------------------------------------------------------+
   // //| Vertical Scroll Slider Class |
   // //+------------------------------------------------------------------+
   // class CScrollBarThumbV : public CButton
   // {
   //    protected:
   //       bool              m_chart_redraw;                           // Graph update flag
   //    public:
   //    // --- (1) Sets, (2) returns the graph update flag
   //       void              SetChartRedrawFlag(const bool flag)       { this.m_chart_redraw=flag;               }
   //       bool              ChartRedrawFlag(void)               const { return this.m_chart_redraw;             }
         
   //    // --- Virtual methods (1) save to file, (2) load from file, (3) object type
   //       virtual bool      Save(const int file_handle);
   //       virtual bool      Load(const int file_handle);
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_THUMB_V); }
         
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(const string text);
         
   //    // --- Event handlers for (1) cursor movement, (2) wheel scrolling
   //       virtual void      OnMoveEvent(const int id, const long lparam, const double dparam, const string sparam);
   //       virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);
         
   //    // --- Constructors/destructor
   //                         CScrollBarThumbV(void);
   //                         CScrollBarThumbV(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CScrollBarThumbV (void) {}
   // };
   // #ifndef CSCROLLBARTHUMBV_IMPLEMENTATION
   // #define CSCROLLBARTHUMBV_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbV::Default constructor.                      |
   //    // | Plots an element in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CScrollBarThumbV::CScrollBarThumbV(void) : CButton("SBThumb","",::ChartID(),0,0,0,DEF_SCROLLBAR_TH,DEF_PANEL_W)
   //    {
   //    // ---Initialization
   //       this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbV::Parametric constructor.                   |
   //    // | Plots an element in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CScrollBarThumbV::CScrollBarThumbV(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CButton(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //    // ---Initialization
   //       this.Init("");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbV::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarThumbV::Init(const string text)
   //    {
   //    // ---Initializing the parent class
   //       CButton::Init("");
   //    // --- Set the relocatability and schedule update flags
   //       this.SetMovable(true);
   //       this.SetChartRedrawFlag(false);
   //    // --- Element is not clipped to container boundaries
   //       this.m_trim_flag=false;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbV::Cursor move handler |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarThumbV::OnMoveEvent(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //    // --- Base object cursor movement handler
   //       CCanvasBase::OnMoveEvent(id,lparam,dparam,sparam);
   //    // --- Get a pointer to the base object (vertical scroll bar control)
   //       CCanvasBase *base_obj=this.GetContainer();
   //    // --- If the movability flag is not set for the slider, or the pointer to the base object is not received, we leave
   //       if(!this.IsMovable() || base_obj==NULL)
   //          return;
         
   //    // --- Get the height of the base object and calculate the boundaries of the space for the slider
   //       int base_h=base_obj.Height();
   //       int base_top=base_obj.Y()+base_obj.Width();
   //       int base_bottom=base_obj.Bottom()-base_obj.Width()+1;
         
   //    // --- From the coordinates of the cursor and the size of the slider, we calculate the restrictions for movement
   //       int y=(int)dparam-this.m_cursor_delta_y;
   //       if(y<base_top)
   //          y=base_top;
   //       if(y+this.Height()>base_bottom)
   //          y=base_bottom-this.Height();
   //    // --- Move the slider to the calculated Y coordinate
   //       if(!this.MoveY(y))
   //          return;
         
   //    // --- Calculate the position of the slider
   //       int thumb_pos=this.Y()-base_top;
         
   //    // --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   //       ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_MOVE, thumb_pos, dparam, this.NameFG());
   //    // --- Redraw the graph
   //       if(this.m_chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbV::Wheel scroll handler |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarThumbV::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //    // --- Get a pointer to the base object (vertical scroll bar control)
   //       CCanvasBase *base_obj=this.GetContainer();
         
   //    // --- Get the name of the main object in the hierarchy by value in sparam
   //       string array_names[];
   //       string name_main=(GetElementNames(sparam,"_",array_names)>0 ? array_names[0] : "");
         
   //    // --- If the main object in the hierarchy is not ours, we leave
   //       if(::StringFind(this.NameFG(),name_main)!=0)
   //          return;
            
   //    // --- If the movability flag is not set for the slider, or the pointer to the base object is not received, we leave
   //       if(!this.IsMovable() || base_obj==NULL)
   //          return;
         
   //    // --- Get the height of the base object and calculate the boundaries of the space for the slider
   //       int base_h=base_obj.Height();
   //       int base_top=base_obj.Y()+base_obj.Width();
   //       int base_bottom=base_obj.Bottom()-base_obj.Width()+1;
         
   //    // --- Set the direction of displacement depending on the direction of rotation of the mouse wheel
   //       int dy=(dparam<0 ? 2 : dparam>0 ? -2 : 0);
   //       if(dy==0)
   //          dy=(int)lparam;

   //    // --- If, when shifted, the slider goes beyond the top edge of its area, set it to the top edge
   //       if(dy<0 && this.Y()+dy<=base_top)
   //          this.MoveY(base_top);
   //    // --- otherwise, if, when shifted, the slider goes beyond the bottom edge of its area, position it along the bottom edge
   //       else if(dy>0 && this.Bottom()+dy>=base_bottom)
   //          this.MoveY(base_bottom-this.Height());
   //    // --- Otherwise, if the slider is within its area, move it by the offset amount
   //       else
   //       {
   //          this.ShiftY(dy);
   //       }

   //    // --- Calculate the position of the slider
   //       int thumb_pos=this.Y()-base_top;
         
   //    // --- Getting the cursor coordinates
   //       int x=CCommonManager::GetInstance().CursorX();
   //       int y=CCommonManager::GetInstance().CursorY();
         
   //    // --- If the cursor hits the slider, change the color to “In Focus”,
   //       if(this.Contains(x,y))
   //          this.OnFocusEvent(id,lparam,dparam,sparam);
   //    // --- otherwise - return the color to "Default"
   //       else
   //          this.OnReleaseEvent(id,lparam,dparam,sparam);
            
   //    // --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   //       ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_WHEEL, thumb_pos, dparam, this.NameFG());
   //    // --- Redraw the graph
   //       if(this.m_chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbV::Saving to file |
   //    //+------------------------------------------------------------------+
   //    bool CScrollBarThumbV::Save(const int file_handle)
   //    {
   //    // --- Save the data of the parent object
   //       if(!CButton::Save(file_handle))
   //          return false;
      
   //    // --- Save the graph update flag
   //       if(::FileWriteInteger(file_handle,this.m_chart_redraw,INT_VALUE)!=INT_VALUE)
   //          return false;
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarThumbV::Loading from file |
   //    //+------------------------------------------------------------------+
   //    bool CScrollBarThumbV::Load(const int file_handle)
   //    {
   //    // --- Loading the data of the parent object
   //       if(!CButton::Load(file_handle))
   //          return false;
            
   //    // --- Loading the graph update flag
   //       this.m_chart_redraw=::FileReadInteger(file_handle,INT_VALUE);
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CSCROLLBARTHUMBV_IMPLEMENTATION
#endif // MOVE_TO_SCROLLBARTHUMBV_MQH

#ifndef MOVE_TO_SCROLLBARH_MQH
#define MOVE_TO_SCROLLBARH_MQH
      // //+------------------------------------------------------------------+
   // // | Horizontal Scrollbar Class |
   // //+------------------------------------------------------------------+
   // class CScrollBarH : public CPanel
   // {
   //    protected:
   //       CButtonArrowLeft *m_butt_left;                              // Left Arrow Button
   //       CButtonArrowRight*m_butt_right;                             // Right arrow button
   //       CScrollBarThumbH *m_thumb;                                  // Scrollbar slider

   //    public:
   //    // --- Returns a pointer to (1) left, (2) right button, (3) slider
   //       CButtonArrowLeft *GetButtonLeft(void)                       { return this.m_butt_left;                                              }
   //       CButtonArrowRight*GetButtonRight(void)                      { return this.m_butt_right;                                             }
   //       CScrollBarThumbH *GetThumb(void)                            { return this.m_thumb;                                                  }

   //    // --- (1) Sets, (2) returns the graph update flag
   //       void              SetChartRedrawFlag(const bool flag)       { if(this.m_thumb!=NULL) this.m_thumb.SetChartRedrawFlag(flag);         }
   //       bool              ChartRedrawFlag(void)               const { return(this.m_thumb!=NULL ? this.m_thumb.ChartRedrawFlag() : false);  }

   //    // --- Returns (1) the length (2) the start of the track, (3) the position of the slider
   //       int               TrackLength(void)    const;
   //       int               TrackBegin(void)     const;
   //       int               ThumbPosition(void)  const;
         
   //    // --- Sets the position of the slider
   //       bool              SetThumbPosition(const int pos)     const { return(this.m_thumb!=NULL ? this.m_thumb.MoveX(pos) : false);         }
   //    // --- Changes the size of the slider
   //       bool              SetThumbSize(const uint size)       const { return(this.m_thumb!=NULL ? this.m_thumb.ResizeW(size) : false);      }

   //    // --- Changes the width of an object
   //       virtual bool      ResizeW(const int size);
         
   //    // --- Sets the visibility flag in the container
   //       virtual void      SetVisibleInContainer(const bool flag);
         
   //    // --- Sets the clipping flag to the container's borders
   //       virtual void      SetTrimmered(const bool flag);

   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);
         
   //    // ---Object type
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_H);                                     }
         
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(void);
   //       virtual void      InitColors(void);
         
   //    // --- Wheel scroll handler
   //       virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);

   //    // --- Constructors/destructor
   //                         CScrollBarH(void);
   //                         CScrollBarH(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CScrollBarH(void) {}
   // };
   // #ifndef CSCROLLBARH_IMPLEMENTATION
   // #define CSCROLLBARH_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::Default constructor.                           |
   //    // | Plots an element in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CScrollBarH::CScrollBarH(void) : CPanel("ScrollBarH","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H),m_butt_left(NULL),m_butt_right(NULL),m_thumb(NULL)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::The constructor is parametric.                        |
   //    // | Plots an element in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CScrollBarH::CScrollBarH(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CPanel(object_name,text,chart_id,wnd,x,y,w,h),m_butt_left(NULL),m_butt_right(NULL),m_thumb(NULL)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarH::Init(void)
   //    {
   //    // ---Initializing the parent class
   //       CPanel::Init();
   //    // --- Background - opaque
   //       this.SetAlphaBG(255);
   //    // --- Frame width and text
   //       this.SetBorderWidth(0);
   //       this.SetText("");
         
   //    // ---Creating scroll buttons
   //       int w=this.Height();
   //       int h=this.Height();
   //       this.m_butt_left = this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_LEFT, "","ButtL",0,0,w,h);
   //       this.m_butt_right= this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_RIGHT,"","ButtR",this.Width()-w,0,w,h);
   //       if(this.m_butt_left==NULL || this.m_butt_right==NULL)
   //       {
   //          ::PrintFormat("%s: Init failed",__FUNCTION__);
   //          return;
   //       }
   //    // --- Customize the colors and appearance of the left arrow button
   //       this.m_butt_left.SetImageBound(1,1,w-2,h-4);
   //       this.m_butt_left.InitBackColors(this.m_butt_left.BackColorFocused());
   //       this.m_butt_left.ColorsToDefault();
   //       this.m_butt_left.InitBorderColors(this.BorderColor(),this.m_butt_left.BackColorFocused(),this.m_butt_left.BackColorPressed(),this.m_butt_left.BackColorBlocked());
   //       this.m_butt_left.ColorsToDefault();
         
   //    // --- Customize the colors and appearance of the right arrow button
   //       this.m_butt_right.SetImageBound(1,1,w-2,h-4);
   //       this.m_butt_right.InitBackColors(this.m_butt_right.BackColorFocused());
   //       this.m_butt_right.ColorsToDefault();
   //       this.m_butt_right.InitBorderColors(this.BorderColor(),this.m_butt_right.BackColorFocused(),this.m_butt_right.BackColorPressed(),this.m_butt_right.BackColorBlocked());
   //       this.m_butt_right.ColorsToDefault();
         
   //    // --- Create a slider
   //       int tsz=this.Width()-w*2;
   //       this.m_thumb=this.InsertNewElement(ELEMENT_TYPE_SCROLLBAR_THUMB_H,"","ThumbH",w,1,tsz-w*4,h-2);
   //       if(this.m_thumb==NULL)
   //       {
   //          ::PrintFormat("%s: Init failed",__FUNCTION__);
   //          return;
   //       }
   //    // --- Customize the colors of the slider and set the movability flag for it
   //       this.m_thumb.InitBackColors(this.m_thumb.BackColorFocused());
   //       this.m_thumb.ColorsToDefault();
   //       this.m_thumb.InitBorderColors(this.m_thumb.BackColor(),this.m_thumb.BackColorFocused(),this.m_thumb.BackColorPressed(),this.m_thumb.BackColorBlocked());
   //       this.m_thumb.ColorsToDefault();
   //       this.m_thumb.SetMovable(true);
   //    // --- We prohibit independent redrawing of the graph
   //       this.m_thumb.SetChartRedrawFlag(false);
         
   //    // --- Initially not displayed in the container and is not cut off along its borders
   //       this.SetVisibleInContainer(false);
   //       this.SetTrimmered(false);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::Initializing default object colors |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarH::InitColors(void)
   //    {
   //    // --- Initialize the background colors for normal and activated states and make it the current background color
   //       this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //       this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //       this.BackColorToDefault();
         
   //    // --- Initialize the foreground colors for normal and activated states and make it the current text color
   //       this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.ForeColorToDefault();
         
   //    // --- Initialize the border colors for the normal and activated states and make it the current border color
   //       this.InitBorderColors(clrLightGray,clrLightGray,clrLightGray,clrSilver);
   //       this.InitBorderColorsAct(clrLightGray,clrLightGray,clrLightGray,clrSilver);
   //       this.BorderColorToDefault();
         
   //    // --- Initialize the border color and foreground color for the locked element
   //       this.InitBorderColorBlocked(clrSilver);
   //       this.InitForeColorBlocked(clrSilver);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::Sets the visibility flag in the container |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarH::SetVisibleInContainer(const bool flag)
   //    {
   //       this.m_visible_in_container=flag;
   //       if(this.m_butt_left!=NULL)
   //          this.m_butt_left.SetVisibleInContainer(flag);
   //       if(this.m_butt_right!=NULL)
   //          this.m_butt_right.SetVisibleInContainer(flag);
   //       if(this.m_thumb!=NULL)
   //          this.m_thumb.SetVisibleInContainer(flag);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::Sets the container's clipping flag |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarH::SetTrimmered(const bool flag)
   //    {
   //       this.m_trim_flag=flag;
   //       if(this.m_butt_left!=NULL)
   //          this.m_butt_left.SetTrimmered(flag);
   //       if(this.m_butt_right!=NULL)
   //          this.m_butt_right.SetTrimmered(flag);
   //       if(this.m_thumb!=NULL)
   //          this.m_thumb.SetTrimmered(flag);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarH::Draw(const bool chart_redraw)
   //    {
   //    // --- Fill the button with the background color, draw a frame and update the background canvas
   //       this.Fill(this.BackColor(),false);
   //       this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //       this.m_background.Update(false);
   //    // --- Updating the background canvas without redrawing the graph
   //       this.m_background.Update(false);
         
   //    // --- Drawing list elements without redrawing the graph
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             elm.Draw(false);
   //       }
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::Returns track length |
   //    //+------------------------------------------------------------------+
   //    int CScrollBarH::TrackLength(void) const
   //    {
   //       if(this.m_butt_left==NULL || this.m_butt_right==NULL)
   //          return 0;
   //       return(this.m_butt_right.X()-this.m_butt_left.Right());
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::Returns the start of the track |
   //    //+------------------------------------------------------------------+
   //    int CScrollBarH::TrackBegin(void) const
   //    {
   //       return(this.m_butt_left!=NULL ? this.m_butt_left.Width() : 0);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::Returns the position of the slider |
   //    //+------------------------------------------------------------------+
   //    int CScrollBarH::ThumbPosition(void) const
   //    {
   //       int pos=(this.m_thumb!=NULL ? this.m_thumb.X()-this.TrackBegin()-this.X() : 0);
   //       return(pos<0 ? 0 : pos);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::Changes the width of an object |
   //    //+------------------------------------------------------------------+
   //    bool CScrollBarH::ResizeW(const int size)
   //    {
   //    // --- Getting pointers to the left and right buttons
   //       if(this.m_butt_left==NULL || this.m_butt_right==NULL)
   //          return false;
   //    // --- Changing the width of the object
   //       if(!CCanvasBase::ResizeW(size))
   //          return false;
   //    // --- Move the buttons to a new location relative to the left and right borders of the element that has changed size
   //       if(!this.m_butt_left.MoveX(this.X()))
   //          return false;
   //       return(this.m_butt_right.MoveX(this.Right()-this.m_butt_right.Width()+1));
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarH::Wheel scroll handler |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarH::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //    // --- Call the scroll handler for the slider
   //       if(this.m_thumb!=NULL)
   //          this.m_thumb.OnWheelEvent(id,this.ThumbPosition(),dparam,this.NameFG());
            
   //    // --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   //       ::EventChartCustom(this.m_chart_id,CHARTEVENT_MOUSE_WHEEL,this.ThumbPosition(),dparam,this.NameFG());
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CSCROLLBARH_IMPLEMENTATION
#endif // MOVE_TO_SCROLLBARH_MQH

#ifndef MOVE_TO_SCROLLBARV_MQH
#define MOVE_TO_SCROLLBARV_MQH
      // //+------------------------------------------------------------------+
   // // | Vertical scrollbar class |
   // //+------------------------------------------------------------------+
   // class CScrollBarV : public CPanel
   // {
   //    protected:
   //       CButtonArrowUp   *m_butt_up;                                // Up arrow button
   //       CButtonArrowDown *m_butt_down;                              // Down arrow button
   //       CScrollBarThumbV *m_thumb;                                  // Scrollbar slider

   //    public:
   //    // --- Returns a pointer to (1) left, (2) right button, (3) slider
   //       CButtonArrowUp   *GetButtonUp(void)                         { return this.m_butt_up;      }
   //       CButtonArrowDown *GetButtonDown(void)                       { return this.m_butt_down;    }
   //       CScrollBarThumbV *GetThumb(void)                            { return this.m_thumb;        }

   //    // --- (1) Sets, (2) returns the graph update flag
   //       void              SetChartRedrawFlag(const bool flag)       { if(this.m_thumb!=NULL) this.m_thumb.SetChartRedrawFlag(flag);         }
   //       bool              ChartRedrawFlag(void)               const { return(this.m_thumb!=NULL ? this.m_thumb.ChartRedrawFlag() : false);  }

   //    // --- Returns (1) the length (2) the start of the track, (3) the position of the slider
   //       int               TrackLength(void)    const;
   //       int               TrackBegin(void)     const;
   //       int               ThumbPosition(void)  const;
         
   //    // --- Sets the position of the slider
   //       bool              SetThumbPosition(const int pos)     const { return(this.m_thumb!=NULL ? this.m_thumb.MoveY(pos) : false);         }
   //    // --- Changes the size of the slider
   //       bool              SetThumbSize(const uint size)       const { return(this.m_thumb!=NULL ? this.m_thumb.ResizeH(size) : false);      }
         
   //    // --- Changes the height of an object
   //       virtual bool      ResizeH(const int size);
         
   //    // --- Sets the visibility flag in the container
   //       virtual void      SetVisibleInContainer(const bool flag);
         
   //    // --- Sets the clipping flag to the container's borders
   //       virtual void      SetTrimmered(const bool flag);

   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);
         
   //    // ---Object type
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_V);                                     }
         
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(void);
   //       virtual void      InitColors(void);
         
   //    // --- Wheel scroll handler
   //       virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);
         
   //    // --- Constructors/destructor
   //                         CScrollBarV(void);
   //                         CScrollBarV(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CScrollBarV(void) {}
   // };
   // #ifndef CSCROLLBARV_IMPLEMENTATION
   // #define CSCROLLBARV_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Default constructor.                           |
   //    // | Plots an element in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CScrollBarV::CScrollBarV(void) : CPanel("ScrollBarV","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H),m_butt_up(NULL),m_butt_down(NULL),m_thumb(NULL)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Parametric constructor.                        |
   //    // | Plots an element in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CScrollBarV::CScrollBarV(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CPanel(object_name,text,chart_id,wnd,x,y,w,h),m_butt_up(NULL),m_butt_down(NULL),m_thumb(NULL)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarV::Init(void)
   //    {
   //    // ---Initializing the parent class
   //       CPanel::Init();
   //    // --- Background - opaque
   //       this.SetAlphaBG(255);
   //    // --- Frame width and text
   //       this.SetBorderWidth(0);
   //       this.SetText("");
         
   //    // ---Creating scroll buttons
   //       int w=this.Width();
   //       int h=this.Width();
   //       this.m_butt_up = this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_UP, "","ButtU",0,0,w,h);
   //       this.m_butt_down= this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_DOWN,"","ButtD",0,this.Height()-w,w,h);
   //       if(this.m_butt_up==NULL || this.m_butt_down==NULL)
   //       {
   //          ::PrintFormat("%s: Init failed",__FUNCTION__);
   //          return;
   //       }
   //    // --- Customize the colors and appearance of the up arrow button
   //       this.m_butt_up.SetImageBound(1,0,w-4,h-2);
   //       this.m_butt_up.InitBackColors(this.m_butt_up.BackColorFocused());
   //       this.m_butt_up.ColorsToDefault();
   //       this.m_butt_up.InitBorderColors(this.BorderColor(),this.m_butt_up.BackColorFocused(),this.m_butt_up.BackColorPressed(),this.m_butt_up.BackColorBlocked());
   //       this.m_butt_up.ColorsToDefault();
         
   //    // --- Customize the colors and appearance of the down arrow button
   //       this.m_butt_down.SetImageBound(1,0,w-4,h-2);
   //       this.m_butt_down.InitBackColors(this.m_butt_down.BackColorFocused());
   //       this.m_butt_down.ColorsToDefault();
   //       this.m_butt_down.InitBorderColors(this.BorderColor(),this.m_butt_down.BackColorFocused(),this.m_butt_down.BackColorPressed(),this.m_butt_down.BackColorBlocked());
         
   //    // --- Create a slider
   //       int tsz=this.Height()-w*2;
   //       this.m_thumb=this.InsertNewElement(ELEMENT_TYPE_SCROLLBAR_THUMB_V,"","ThumbV",1,w,w-2,tsz/2);
   //       if(this.m_thumb==NULL)
   //       {
   //          ::PrintFormat("%s: Init failed",__FUNCTION__);
   //          return;
   //       }
   //    // --- Customize the colors of the slider and set the movability flag for it
   //       this.m_thumb.InitBackColors(this.m_thumb.BackColorFocused());
   //       this.m_thumb.ColorsToDefault();
   //       this.m_thumb.InitBorderColors(this.m_thumb.BackColor(),this.m_thumb.BackColorFocused(),this.m_thumb.BackColorPressed(),this.m_thumb.BackColorBlocked());
   //       this.m_thumb.ColorsToDefault();
   //       this.m_thumb.SetMovable(true);
   //    // --- we prohibit independent redrawing of the graph
   //       this.m_thumb.SetChartRedrawFlag(false);
         
   //    // --- Initially not displayed in the container and is not cut off along its borders
   //       this.SetVisibleInContainer(false);
   //       this.SetTrimmered(false);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Initializing default object colors |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarV::InitColors(void)
   //    {
   //    // --- Initialize the background colors for normal and activated states and make it the current background color
   //       this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //       this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //       this.BackColorToDefault();
         
   //    // --- Initialize the foreground colors for normal and activated states and make it the current text color
   //       this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.ForeColorToDefault();
         
   //    // --- Initialize the border colors for the normal and activated states and make it the current border color
   //       this.InitBorderColors(clrLightGray,clrLightGray,clrLightGray,clrSilver);
   //       this.InitBorderColorsAct(clrLightGray,clrLightGray,clrLightGray,clrSilver);
   //       this.BorderColorToDefault();
         
   //    // --- Initialize the border color and foreground color for the locked element
   //       this.InitBorderColorBlocked(clrSilver);
   //       this.InitForeColorBlocked(clrSilver);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Sets the visibility flag in the container |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarV::SetVisibleInContainer(const bool flag)
   //    {
   //       this.m_visible_in_container=flag;
   //       if(this.m_butt_up!=NULL)
   //          this.m_butt_up.SetVisibleInContainer(flag);
   //       if(this.m_butt_down!=NULL)
   //          this.m_butt_down.SetVisibleInContainer(flag);
   //       if(this.m_thumb!=NULL)
   //          this.m_thumb.SetVisibleInContainer(flag);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Set the container's clipping flag |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarV::SetTrimmered(const bool flag)
   //    {
   //       this.m_trim_flag=flag;
   //       if(this.m_butt_up!=NULL)
   //          this.m_butt_up.SetTrimmered(flag);
   //       if(this.m_butt_down!=NULL)
   //          this.m_butt_down.SetTrimmered(flag);
   //       if(this.m_thumb!=NULL)
   //          this.m_thumb.SetTrimmered(flag);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarV::Draw(const bool chart_redraw)
   //    {
   //    // --- Fill the button with the background color, draw a frame and update the background canvas
   //       this.Fill(this.BackColor(),false);
   //       this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //       this.m_background.Update(false);
   //    // --- Updating the background canvas without redrawing the graph
   //       this.m_background.Update(false);
         
   //    // --- Drawing list elements without redrawing the graph
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //             elm.Draw(false);
   //       }
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Returns track length |
   //    //+------------------------------------------------------------------+
   //    int CScrollBarV::TrackLength(void) const
   //    {
   //       if(this.m_butt_up==NULL || this.m_butt_down==NULL)
   //          return 0;
   //       return(this.m_butt_down.Y()-this.m_butt_up.Bottom());
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Returns the start of the slider |
   //    //+------------------------------------------------------------------+
   //    int CScrollBarV::TrackBegin(void) const
   //    {
   //       return(this.m_butt_up!=NULL ? this.m_butt_up.Height() : 0);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Returns the position of the slider |
   //    //+------------------------------------------------------------------+
   //    int CScrollBarV::ThumbPosition(void) const
   //    {
   //       int pos=(this.m_thumb!=NULL ? this.m_thumb.Y()-this.TrackBegin()-this.Y() : 0);
   //       return(pos<0 ? 0 : pos);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Changes the height of an object |
   //    //+------------------------------------------------------------------+
   //    bool CScrollBarV::ResizeH(const int size)
   //    {
   //    // --- Getting pointers to the top and bottom buttons
   //       if(this.m_butt_up==NULL || this.m_butt_down==NULL)
   //          return false;
   //    // --- Changing the height of the object
   //       if(!CCanvasBase::ResizeH(size))
   //          return false;
   //    // --- Move the buttons to a new location relative to the top and bottom borders of the element that changed the size
   //       if(!this.m_butt_up.MoveY(this.Y()))
   //          return false;
   //       return(this.m_butt_down.MoveY(this.Bottom()-this.m_butt_down.Height()+1));
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CScrollBarV::Wheel scroll handler |
   //    //+------------------------------------------------------------------+
   //    void CScrollBarV::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //    // --- Call the scroll handler for the slider
   //       if(this.m_thumb!=NULL)
   //          this.m_thumb.OnWheelEvent(id,this.ThumbPosition(),dparam,this.NameFG());
            
   //    // --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   //       ::EventChartCustom(this.m_chart_id,CHARTEVENT_MOUSE_WHEEL,this.ThumbPosition(),dparam,this.NameFG());
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CSCROLLBARV_IMPLEMENTATION
#endif // MOVE_TO_SCROLLBARV_MQH

#ifndef MOVE_TO_SCROLLBARV_MQH
#define MOVE_TO_SCROLLBARV_MQH
     // //+------------------------------------------------------------------+
   // // | Class Container |
   // //+------------------------------------------------------------------+
   // class CContainer : public CPanel
   // {
   //    private:
   //       bool              m_visible_scrollbar_h;                    // Horizontal scrollbar visibility flag
   //       bool              m_visible_scrollbar_v;                    // Vertical scrollbar visibility flag
   //       int               m_init_border_size_top;                   // Initial frame size at top
   //       int               m_init_border_size_bottom;                // Initial frame size below
   //       int               m_init_border_size_left;                  // Initial frame size on the left
   //       int               m_init_border_size_right;                 // Initial frame size on the right
         
   //    // --- Returns the type of the element that sent the event
   //       ENUM_ELEMENT_TYPE GetEventElementType(const string name);
         
   //    protected:
   //       CScrollBarH      *m_scrollbar_h;                            // Pointer to horizontal scroll bar
   //       CScrollBarV      *m_scrollbar_v;                            // Pointer to vertical scroll bar
      
   //    // --- Handler for dragging edges and corners of an element
   //       virtual void      ResizeActionDragHandler(const int x, const int y);
         
   //    public:
   //    // --- Checks the dimensions of an element to display scrollbars
   //       void              CheckElementSizes(CElementBase *element);
   //    protected:
   //    // --- Calculates and returns the size of (1) the slider, (2) full, (3) the working size of the horizontal scrollbar track
   //       int               ThumbSizeHorz(void);
   //       int               TrackLengthHorz(void)               const { return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.TrackLength() : 0);       }
   //       int               TrackEffectiveLengthHorz(void)            { return(this.TrackLengthHorz()-this.ThumbSizeHorz());                           }
   //    // --- Calculates and returns the size of the (1) slider, (2) full, (3) working size of the vertical scrollbar track
   //       int               ThumbSizeVert(void);
   //       int               TrackLengthVert(void)               const { return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.TrackLength() : 0);       }
   //       int               TrackEffectiveLengthVert(void)            { return(this.TrackLengthVert()-this.ThumbSizeVert());                           }
   //    // --- Size of visible content area (1) horizontally, (2) vertically
   //       int               ContentVisibleHorz(void)            const { return int(this.Width()-this.BorderWidthLeft()-this.BorderWidthRight());       }
   //       int               ContentVisibleVert(void)            const { return int(this.Height()-this.BorderWidthTop()-this.BorderWidthBottom());      }
         
   //    // --- Full content size in (1) horizontal, (2) vertical
   //       int               ContentSizeHorz(void);
   //       int               ContentSizeVert(void);
         
   //    // --- Position of content along (1) horizontal, (2) vertical
   //       int               ContentPositionHorz(void);
   //       int               ContentPositionVert(void);
   //    // --- Calculates and returns the amount of content offset (1) horizontally, (2) vertically depending on the position of the slider
   //       int               CalculateContentOffsetHorz(const uint thumb_position);
   //       int               CalculateContentOffsetVert(const uint thumb_position);
   //    // --- Calculates and returns the amount of slider displacement along (1) horizontal, (2) vertical depending on the position of the content
   //       int               CalculateThumbOffsetHorz(const uint content_position);
   //       int               CalculateThumbOffsetVert(const uint content_position);
         
   //    // --- Shifts content (1) horizontally, (2) vertically by the specified amount
   //       bool              ContentShiftHorz(const int value);
   //       bool              ContentShiftVert(const int value);
         
   //    public:
   //    // --- Returning pointers to scrollbars, buttons and scrollbar sliders
   //       CScrollBarH      *GetScrollBarH(void)                       { return this.m_scrollbar_h;                                                     }
   //       CScrollBarV      *GetScrollBarV(void)                       { return this.m_scrollbar_v;                                                     }
   //       CButtonArrowUp   *GetScrollBarButtonUp(void)                { return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.GetButtonUp()   : NULL);  }
   //       CButtonArrowDown *GetScrollBarButtonDown(void)              { return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.GetButtonDown() : NULL);  }
   //       CButtonArrowLeft *GetScrollBarButtonLeft(void)              { return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.GetButtonLeft() : NULL);  }
   //       CButtonArrowRight*GetScrollBarButtonRight(void)             { return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.GetButtonRight(): NULL);  }
   //       CScrollBarThumbH *GetScrollBarThumbH(void)                  { return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.GetThumb()      : NULL);  }
   //       CScrollBarThumbV *GetScrollBarThumbV(void)                  { return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.GetThumb()      : NULL);  }
         
   //    // --- Returns the visibility flag of (1) horizontal, (2) vertical scrollbar
   //       bool              ScrollBarHorzIsVisible(void)        const { return this.m_visible_scrollbar_h;                                             }
   //       bool              ScrollBarVertIsVisible(void)        const { return this.m_visible_scrollbar_v;                                             }

   //    // --- Returns the attached element (the contents of the container)
   //       CElementBase     *GetAttachedElement(void)                  { return this.GetAttachedElementAt(2);                                           }

   //    // --- Creates and adds (1) a new, (2) a previously created element to the list
   //       virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
   //       virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);
         
   //    // --- (1) Displays the object on all chart periods, (2) places the object in the foreground
   //       virtual void      Show(const bool chart_redraw);
   //       virtual void      BringToTop(const bool chart_redraw);
         
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);

   //    // ---Object type
   //       virtual int       Type(void)                          const { return(ELEMENT_TYPE_CONTAINER);                                                }
         
   //    // --- Element custom event handlers for hover, click, and wheel scroll in an object area
   //       virtual void      MouseMoveHandler(const int id, const long lparam, const double dparam, const string sparam);
   //       virtual void      MousePressHandler(const int id, const long lparam, const double dparam, const string sparam);
   //       virtual void      MouseWheelHandler(const int id, const long lparam, const double dparam, const string sparam);
         
   //    // --- Initializing a class object
   //       void              Init(void);
         
   //    // --- Constructors/destructor
   //                         CContainer(void);
   //                         CContainer(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CContainer (void) {}
   // };
   // #ifndef CCONTAINER_IMPLEMENTATION
   // #define CCONTAINER_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Default constructor.                            |
   //    // | Plots an element in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CContainer::CContainer(void) : CPanel("Container","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H), m_visible_scrollbar_h(false), m_visible_scrollbar_v(false)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Parametric constructor.                         |
   //    // | Plots an element in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CContainer::CContainer(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CPanel(object_name,text,chart_id,wnd,x,y,w,h), m_visible_scrollbar_h(false), m_visible_scrollbar_v(false)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CContainer::Init(void)
   //    {
   //    // --- Initializing the parent object
   //       CPanel::Init();
   //    // --- Frame width
   //       this.SetBorderWidth(0);
   //    // --- Remember the set width of the frame on each side
   //       this.m_init_border_size_top   = (int)this.BorderWidthTop();
   //       this.m_init_border_size_bottom= (int)this.BorderWidthBottom();
   //       this.m_init_border_size_left  = (int)this.BorderWidthLeft();
   //       this.m_init_border_size_right = (int)this.BorderWidthRight();
         
   //    // --- Create a horizontal scrollbar
   //       this.m_scrollbar_h=dynamic_cast<CScrollBarH *>(CPanel::InsertNewElement(ELEMENT_TYPE_SCROLLBAR_H,"","ScrollBarH",0,this.Height()-DEF_SCROLLBAR_TH-1,this.Width()-1,DEF_SCROLLBAR_TH));
   //       if(m_scrollbar_h!=NULL)
   //       {
   //          // --- Hide the element and set a ban on independent redrawing of the graph
   //          this.m_scrollbar_h.Hide(false);
   //          this.m_scrollbar_h.SetChartRedrawFlag(false);
   //       }
   //    // --- Create a vertical scrollbar
   //       this.m_scrollbar_v=dynamic_cast<CScrollBarV *>(CPanel::InsertNewElement(ELEMENT_TYPE_SCROLLBAR_V,"","ScrollBarV",this.Width()-DEF_SCROLLBAR_TH-1,0,DEF_SCROLLBAR_TH,this.Height()-1));
   //       if(m_scrollbar_v!=NULL)
   //       {
   //          // --- Hide the element and set a ban on independent redrawing of the graph
   //          this.m_scrollbar_v.Hide(false);
   //          this.m_scrollbar_v.SetChartRedrawFlag(false);
   //       }
   //    // --- Allow content scrolling
   //       this.m_scroll_flag=true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Displays an object on all chart periods |
   //    //+------------------------------------------------------------------+
   //    void CContainer::Show(const bool chart_redraw)
   //    {
   //    // --- If the object is already visible, or should not be displayed in the container, leave
   //       if(!this.m_hidden || !this.m_visible_in_container)
   //          return;
            
   //    // --- Display the panel
   //       CCanvasBase::Show(false);
   //    // --- Display attached objects
   //       for(int i=0;i<this.m_list_elm.Total();i++)
   //       {
   //          CElementBase *elm=this.GetAttachedElementAt(i);
   //          if(elm!=NULL)
   //          {
   //             if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_H && !this.m_visible_scrollbar_h)
   //                continue;
   //             if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_V && !this.m_visible_scrollbar_v)
   //                continue;
   //             elm.Show(false);
   //          }
   //       }
   //    // --- If indicated, redraw the graph
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Puts the object in front |
   //    //+------------------------------------------------------------------+
   //    void CContainer::BringToTop(const bool chart_redraw)
   //       {
   //       // --- Move the panel to the front
   //          CCanvasBase::BringToTop(false);
   //       // --- Place attached objects in the foreground
   //          for(int i=0;i<this.m_list_elm.Total();i++)
   //          {
   //             CElementBase *elm=this.GetAttachedElementAt(i);
   //             if(elm!=NULL)
   //             {
   //                if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_H && !this.m_visible_scrollbar_h)
   //                {
   //                   elm.Hide(false);
   //                   continue;
   //                }
   //                if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_V && !this.m_visible_scrollbar_v)
   //                {
   //                   elm.Hide(false);
   //                   continue;
   //                }
   //                elm.BringToTop(false);
   //             }
   //          }
   //       // --- If indicated, redraw the graph
   //          if(chart_redraw)
   //             ::ChartRedraw(this.m_chart_id);
   //       }
   //       //+------------------------------------------------------------------+
   //       // | CContainer::Draws appearance |
   //       //+------------------------------------------------------------------+
   //       void CContainer::Draw(const bool chart_redraw)
   //       {
   //       // --- Drawing the appearance
   //          CPanel::Draw(false);

   //       // --- If scrolling is enabled
   //          if(this.m_scroll_flag)
   //          {
   //             // --- If both scrollbars are visible
   //             if(this.m_visible_scrollbar_h && this.m_visible_scrollbar_v)
   //             {
   //                // --- Get a pointer to the horizontal scrollbar and take its background color
   //                CScrollBarH *scroll_bar=this.GetScrollBarH();
   //                color clr=(scroll_bar!=NULL ? scroll_bar.BackColor() : clrWhiteSmoke);
                  
   //                // --- Set the coordinates at which the filled rectangle will be drawn
   //                int x1=this.Width()-DEF_SCROLLBAR_TH-1;
   //                int y1=this.Height()-DEF_SCROLLBAR_TH-1;
   //                int x2=this.Width()-3;
   //                int y2=this.Height()-3;
                  
   //                // --- Draw a rectangle with the background color of the scrollbar in the lower right corner
   //                this.m_foreground.FillRectangle(x1,y1,x2,y2,::ColorToARGB(clr));
   //                this.m_foreground.Update(false);
   //             }
   //          }

   //       // --- If indicated, update the schedule
   //          if(chart_redraw)
   //             ::ChartRedraw(this.m_chart_id);
   //       }
   //       //+------------------------------------------------------------------+
   //       // | CContainer::Creates and adds a new element to the list |
   //       //+------------------------------------------------------------------+
   //       CElementBase *CContainer::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
   //       {
   //       // --- We check that there are no more than three objects in the list - two scroll bars and the one being added
   //          if(this.m_list_elm.Total()>2)
   //          {
   //             ::PrintFormat("%s: Error. You can only add one element to a container\nTo add multiple elements, use the panel",__FUNCTION__);
   //             return NULL;
   //          }
   //       // --- Create and add a new element using the parent class method
   //       // --- The element is placed at coordinates 0,0 regardless of those specified in the parameters
   //          CElementBase *elm=CPanel::InsertNewElement(type,text,user_name,dx,dy,w,h);
   //       // --- Checking the dimensions of the element to display scroll bars
   //          this.CheckElementSizes(elm);
   //       // --- Return a pointer to the element
   //          return elm;
   //       }
   //       //+------------------------------------------------------------------+
   //       // | CContainer::Adds the specified element to the list |
   //       //+------------------------------------------------------------------+
   //       CElementBase *CContainer::InsertElement(CElementBase *element,const int dx,const int dy)
   //       {
   //       // --- We check that there are no more than three objects in the list - two scroll bars and the one being added
   //          if(this.m_list_elm.Total()>2)
   //          {
   //             ::PrintFormat("%s: Error. You can only add one element to a container\nTo add multiple elements, use the panel",__FUNCTION__);
   //             return NULL;
   //          }
   //       // --- Add the specified element using the parent class method
   //       // --- The element is placed at coordinates 0,0 regardless of those specified in the parameters
   //          CElementBase *elm=CPanel::InsertElement(element,0,0);
   //       // --- Checking the dimensions of the element to display scroll bars
   //          this.CheckElementSizes(elm);
   //       // --- Return a pointer to the element
   //          return elm;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Checks element dimensions |
   //    // | to display scroll bars |
   //    //+------------------------------------------------------------------+
   //    void CContainer::CheckElementSizes(CElementBase *element)
   //       {
   //       // --- If an empty element is passed, or scrolling is prohibited, or scrollbars are not created, we leave
            
   //          if(element==NULL || !this.m_scroll_flag || this.m_scrollbar_h==NULL || this.m_scrollbar_v==NULL)
   //             return;
               
   //       // --- We get the element type and, if it is a scrollbar, we leave
   //          ENUM_ELEMENT_TYPE type=(ENUM_ELEMENT_TYPE)element.Type();
   //          if(type==ELEMENT_TYPE_SCROLLBAR_H || type==ELEMENT_TYPE_SCROLLBAR_V)
   //             return;
               
   //       // --- Initialize scrollbar display flags
   //          this.m_visible_scrollbar_h=false;
   //          this.m_visible_scrollbar_v=false;
            
   //       // --- If the width of the element is greater than the width of the visible area of ​​the container -
   //       // --- set the horizontal scrollbar display flag
   //       // --- and container display flag
   //          if(element.Width()>this.ContentVisibleHorz())
   //          {
   //             this.m_visible_scrollbar_h=true;
   //             this.m_scrollbar_h.SetVisibleInContainer(true);
   //          }
   //       // --- If the height of the element is greater than the height of the visible area of ​​the container -
   //       // --- set the vertical scrollbar display flag
   //       // --- and container display flag
   //          if(element.Height()>this.ContentVisibleVert())
   //          {
   //             this.m_visible_scrollbar_v=true;
   //             this.m_scrollbar_v.SetVisibleInContainer(true);
   //          }

   //       // ---If both scrollbars should be displayed
   //          if(this.m_visible_scrollbar_h && this.m_visible_scrollbar_v)
   //          {
   //             // --- Adjust the size of both scroll bars to the thickness of the scrollbar and
   //             // --- set the slider sizes to the new track sizes
   //             if(this.m_scrollbar_v.ResizeH(this.Height()-DEF_SCROLLBAR_TH))
   //                this.m_scrollbar_v.SetThumbSize(this.ThumbSizeVert());
   //             if(this.m_scrollbar_h.ResizeW(this.Width() -DEF_SCROLLBAR_TH))
   //                this.m_scrollbar_h.SetThumbSize(this.ThumbSizeHorz());
   //          }
            
   //       // ---If the horizontal scrollbar should be shown
   //          if(this.m_visible_scrollbar_h)
   //          {
   //             // --- Reduce the size of the visible container window from below by the thickness of the scroll bar + 1 pixel
   //             this.SetBorderWidthBottom(this.m_scrollbar_h.Height()+1);
   //             // --- Adjust the size of the slider to the new size of the scroll bar and
   //             // --- move the scrollbar to the foreground, making it visible
   //             this.m_scrollbar_h.SetThumbSize(this.ThumbSizeHorz());
               
   //             int end_track=this.X()+this.m_scrollbar_h.TrackBegin()+this.m_scrollbar_h.TrackLength();
   //             int thumb_right=this.m_scrollbar_h.GetThumb().Right();
   //             if(thumb_right>=end_track)
   //             {
   //                int pos=end_track-this.ThumbSizeHorz();
   //                this.m_scrollbar_h.SetThumbPosition(pos);
   //             }
               
   //             this.m_scrollbar_h.SetVisibleInContainer(true);
   //             this.m_scrollbar_h.MoveY(this.Bottom()-DEF_SCROLLBAR_TH);
   //             this.m_scrollbar_h.BringToTop(false);
   //          }
   //          else
   //          {
   //             // --- Restore the size of the visible container window from below,
   //             // --- hide the horizontal scrollbar, disable its display in the container,
   //             // --- and set the height of the vertical scrollbar to the height of the container
   //             this.SetBorderWidthBottom(this.m_init_border_size_bottom);
   //             this.m_scrollbar_h.Hide(false);
   //             this.m_scrollbar_h.SetVisibleInContainer(false);
   //             if(this.m_scrollbar_v.ResizeH(this.Height()-1))
   //                this.m_scrollbar_v.SetThumbSize(this.ThumbSizeVert());
   //          }
            
   //       // ---If the vertical scrollbar should be shown
   //          if(this.m_visible_scrollbar_v)
   //          {
   //             // --- Reduce the size of the visible container window on the right by the width of the scroll bar + 1 pixel
   //             this.SetBorderWidthRight(this.m_scrollbar_v.Width()+1);
   //             // --- Adjust the size of the slider to the new size of the scroll bar and
   //             // --- move the scrollbar to the foreground, making it visible
   //             this.m_scrollbar_v.SetThumbSize(this.ThumbSizeVert());
               
   //             int end_track=this.Y()+this.m_scrollbar_v.TrackBegin()+this.m_scrollbar_v.TrackLength();
   //             int thumb_bottom=this.m_scrollbar_v.GetThumb().Bottom();
   //             if(thumb_bottom>=end_track)
   //             {
   //                int pos=end_track-this.ThumbSizeVert();
   //                this.m_scrollbar_v.SetThumbPosition(pos);
   //             }
               
   //             this.m_scrollbar_v.SetVisibleInContainer(true);
   //             this.m_scrollbar_v.MoveX(this.Right()-DEF_SCROLLBAR_TH);
   //             this.m_scrollbar_v.BringToTop(false);
   //          }
   //          else
   //          {
   //             // --- Restore the size of the visible container window on the right,
   //             // --- hide the vertical scrollbar, disable its display in the container,
   //             // --- and set the width of the horizontal scrollbar to the width of the container
   //             this.SetBorderWidthRight(this.m_init_border_size_right);
   //             this.m_scrollbar_v.Hide(false);
   //             this.m_scrollbar_v.SetVisibleInContainer(false);
   //             if(this.m_scrollbar_h.ResizeW(this.Width()-1))
   //                this.m_scrollbar_h.SetThumbSize(this.ThumbSizeHorz());
   //          }
   //       // --- If any of the scroll bars are visible, crop the anchored element to the new dimensions of the visible area
   //          if(this.m_visible_scrollbar_h || this.m_visible_scrollbar_v)
   //          {
   //             element.ObjectTrim();
   //          }
   //       }
   //    //+-------------------------------------------------------------------+
   //    // |CContainer::Calculates the size of the horizontal scrollbar slider|
   //    //+-------------------------------------------------------------------+
   //    int CContainer::ThumbSizeHorz(void)
   //       {
   //       CElementBase *elm=this.GetAttachedElement();
   //       if(elm==NULL || elm.Width()==0 || this.TrackLengthHorz()==0)
   //          return 0;
   //       return int(::round(::fmax(((double)this.ContentVisibleHorz() / (double)elm.Width()) * (double)this.TrackLengthHorz(), DEF_THUMB_MIN_SIZE)));
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Calculates the size of the vertical scrollbar slider|
   //    //+------------------------------------------------------------------+
   //    int CContainer::ThumbSizeVert(void)
   //       {
   //       CElementBase *elm=this.GetAttachedElement();
   //       if(elm==NULL || elm.Height()==0 || this.TrackLengthVert()==0)
   //          return 0;
   //       return int(::round(::fmax(((double)this.ContentVisibleVert() / (double)elm.Height()) * (double)this.TrackLengthVert(), DEF_THUMB_MIN_SIZE)));
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Full content horizontal size |
   //    //+------------------------------------------------------------------+
   //    int CContainer::ContentSizeHorz(void)
   //       {
   //       CElementBase *elm=this.GetAttachedElement();
   //       return(elm!=NULL ? elm.Width() : 0);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Full content vertical size |
   //    //+------------------------------------------------------------------+
   //    int CContainer::ContentSizeVert(void)
   //       {
   //          CElementBase *elm=this.GetAttachedElement();
   //          return(elm!=NULL ? elm.Height() : 0);
   //       }
   //    //+--------------------------------------------------------------------+
   //    // |CContainer::Returns the horizontal position of the container's contents|
   //    //+--------------------------------------------------------------------+
   //    int CContainer::ContentPositionHorz(void)
   //       {
   //          CElementBase *elm=this.GetAttachedElement();
   //          return(elm!=NULL ? elm.X()-this.X() : 0);
   //       }
   //       //+------------------------------------------------------------------+
   //       // |CContainer::Returns the vertical position of the container's contents|
   //       //+------------------------------------------------------------------+
   //       int CContainer::ContentPositionVert(void)
   //       {
   //          CElementBase *elm=this.GetAttachedElement();
   //          return(elm!=NULL ? elm.Y()-this.Y() : 0);
   //       }
   //       //+------------------------------------------------------------------+
   //       // | CContainer::Calculates and returns offset value |
   //       // | container contents horizontally by slider position |
   //       //+------------------------------------------------------------------+
   //       int CContainer::CalculateContentOffsetHorz(const uint thumb_position)
   //       {
   //          CElementBase *elm=this.GetAttachedElement();
   //          int effective_track_length=this.TrackEffectiveLengthHorz();
   //          if(elm==NULL || effective_track_length==0)
   //             return 0;
   //          return (int)::round(((double)thumb_position / (double)effective_track_length) * ((double)elm.Width() - (double)this.ContentVisibleHorz()));
   //       }
   //       //+------------------------------------------------------------------+
   //       // | CContainer::Calculates and returns offset value |
   //       // | container contents vertically by slider position |
   //       //+------------------------------------------------------------------+
   //       int CContainer::CalculateContentOffsetVert(const uint thumb_position)
   //       {
   //          CElementBase *elm=this.GetAttachedElement();
   //          int effective_track_length=this.TrackEffectiveLengthVert();
   //          if(elm==NULL || effective_track_length==0)
   //             return 0;
   //          return (int)::round(((double)thumb_position / (double)effective_track_length) * ((double)elm.Height() - (double)this.ContentVisibleVert()));
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Calculates and returns the slider offset value |
   //    // | horizontally depending on the position of the content |
   //    //+------------------------------------------------------------------+
   //    int CContainer::CalculateThumbOffsetHorz(const uint content_position)
   //       {
   //          CElementBase *elm=this.GetAttachedElement();
   //          if(elm==NULL)
   //             return 0;
   //          int value=elm.Width()-this.ContentVisibleHorz();
   //          if(value==0)
   //             return 0;
   //          return (int)::round(((double)content_position / (double)value) * ((double)this.TrackEffectiveLengthHorz() - (double)this.ThumbSizeHorz()));
   //       }
   //       //+------------------------------------------------------------------+
   //       // | CContainer::Calculates and returns the slider offset value |
   //       // | vertically depending on the position of the content |
   //       //+------------------------------------------------------------------+
   //       int CContainer::CalculateThumbOffsetVert(const uint content_position)
   //       {
   //          CElementBase *elm=this.GetAttachedElement();
   //          if(elm==NULL)
   //             return 0;
   //          int value=elm.Height()-this.ContentVisibleVert();
   //          if(value==0)
   //             return 0;
   //          return (int)::round(((double)content_position / (double)value) * ((double)this.TrackEffectiveLengthVert() - (double)this.ThumbSizeVert()));
   //       }
   //    //+-------------------------------------------------------------------+
   //    // |CContainer::Shifts content horizontally by the specified amount|
   //    //+-------------------------------------------------------------------+
   //    bool CContainer::ContentShiftHorz(const int value)
   //       {
   //       // --- Get a pointer to the contents of the container
   //          CElementBase *elm=this.GetAttachedElement();
   //          if(elm==NULL)
   //             return false;
            
   //       // --- Calculate the offset value based on the position of the slider
   //          int content_offset=this.CalculateContentOffsetHorz(value);
            
   //       // --- For the CTableView element we get the table title
   //          bool res=true;
   //          CElementBase     *elm_container=elm.GetContainer();
   //          CTableHeaderView *table_header=NULL;
   //          if(elm_container!=NULL && ::StringFind(elm.Name(),"Table")==0)
   //          {
   //             CElementBase *obj=elm_container.GetContainer();
   //             if(obj!=NULL && obj.Type()==ELEMENT_TYPE_TABLE_VIEW)
   //             {
   //                CTableView *table_view=obj;
   //                table_header=table_view.GetHeader();
   //                // --- Move the title
   //                if(table_header!=NULL)
   //                   res &=table_header.MoveX(this.X()-content_offset);
   //             }
   //          }

   //       // --- Return the result of shifting the content by the calculated amount
   //          res &=elm.MoveX(this.X()-content_offset);
   //          return res;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Shifts the content vertically by the specified value|
   //    //+------------------------------------------------------------------+
   //    bool CContainer::ContentShiftVert(const int value)
   //       {
   //       // --- Get a pointer to the contents of the container
   //          CElementBase *elm=this.GetAttachedElement();
   //          if(elm==NULL)
   //             return false;
            
   //       // --- Calculate the offset value based on the position of the slider
   //          int content_offset=this.CalculateContentOffsetVert(value);
            
   //       // --- For the CTableView element we get the vertical table header
   //          bool res=true;
   //          CElementBase         *elm_container=elm.GetContainer();
   //          CTableRowsHeaderView *table_header=NULL;
   //          if(elm_container!=NULL && ::StringFind(elm.Name(),"Table")==0)
   //          {
   //             CElementBase *obj=elm_container.GetContainer();
   //             if(obj!=NULL && obj.Type()==ELEMENT_TYPE_TABLE_VIEW)
   //             {
   //                CTableView *table_view=obj;
   //                table_header=table_view.GetRowsHeader();
   //                // --- Move the title
   //                if(table_header!=NULL)
   //                   res &=table_header.MoveY(this.Y()-content_offset);
   //             }
   //          }

   //       // --- Return the result of shifting the content by the calculated amount
   //          res &=elm.MoveY(this.Y()-content_offset);
   //          return res;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | Returns the type of the element that sent the event |
   //    //+------------------------------------------------------------------+
   //    ENUM_ELEMENT_TYPE CContainer::GetEventElementType(const string name)
   //       {
   //       // --- Get the names of all elements in the hierarchy (if there is an error, return -1)
   //          string names[]={};
   //          int total = GetElementNames(name,"_",names);
   //          if(total==WRONG_VALUE)
   //             return WRONG_VALUE;
            
   //       // --- Find in the array the name of the container closest to the name of the element with the event
   //          int    cntr_index=-1;      // Index of the container name in the array of names in the element hierarchy
   //          string cntr_name="";       // The name of the container in the array of names in the hierarchy of elements
            
   //       // --- We are looking for the very first occurrence of the substring "CNTR" from the end in the loop
   //          for(int i=total-1;i>=0;i--)
   //          {
   //             if(::StringFind(names[i],"CNTR")==0)
   //             {
   //                cntr_name=names[i];
   //                cntr_index=i;
   //                break;
   //             }
   //          }
   //       // --- If the container name is not found in the array (index is -1) - return -1
   //          if(cntr_index==WRONG_VALUE)
   //             return WRONG_VALUE;
            
   //       // --- If the element name does not contain a substring with the name of the base element, then this is not our event - we leave
   //          string base_name=names[cntr_index];
   //          if(::StringFind(this.NameFG(),base_name)==WRONG_VALUE)
   //             return WRONG_VALUE;

   //       // --- Events that did not come from scrollbars are skipped
   //          string check_name=::StringSubstr(names[cntr_index+1],0,4);
   //          if(check_name!="SCBH" && check_name!="SCBV")
   //             return WRONG_VALUE;
               
   //       // --- Get the name of the element from which the event came and initialize the element type
   //          string elm_name=names[names.Size()-1];
   //          ENUM_ELEMENT_TYPE type=WRONG_VALUE;
            
   //       // --- Check and record the element type
   //       // --- Up arrow button
   //          if(::StringFind(elm_name,"BTARU")==0)
   //             type=ELEMENT_TYPE_BUTTON_ARROW_UP;
   //       // --- Down arrow button
   //          else if(::StringFind(elm_name,"BTARD")==0)
   //             type=ELEMENT_TYPE_BUTTON_ARROW_DOWN;
   //       // ---Left arrow button
   //          else if(::StringFind(elm_name,"BTARL")==0)
   //             type=ELEMENT_TYPE_BUTTON_ARROW_LEFT;
   //       // --- Right arrow button
   //          else if(::StringFind(elm_name,"BTARR")==0)
   //             type=ELEMENT_TYPE_BUTTON_ARROW_RIGHT;
   //       // ---Horizontal scroll bar slider
   //          else if(::StringFind(elm_name,"THMBH")==0)
   //             type=ELEMENT_TYPE_SCROLLBAR_THUMB_H;
   //       // ---Vertical scroll bar slider
   //          else if(::StringFind(elm_name,"THMBV")==0)
   //             type=ELEMENT_TYPE_SCROLLBAR_THUMB_V;
   //       // ---ScrollBarHorizontal control
   //          else if(::StringFind(elm_name,"SCBH")==0)
   //             type=ELEMENT_TYPE_SCROLLBAR_H;
   //       // --- ScrollBarVertical control
   //          else if(::StringFind(elm_name,"SCBV")==0)
   //             type=ELEMENT_TYPE_SCROLLBAR_V;
               
   //       // --- Return the element type
   //          return type;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Element Custom Event Handler |
   //    // | when moving the cursor in the object area |
   //    //+------------------------------------------------------------------+
   //    void CContainer::MouseMoveHandler(const int id,const long lparam,const double dparam,const string sparam)
   //       {
   //          bool res=false;
   //       // --- Get a pointer to the contents of the container
   //          CElementBase *elm=this.GetAttachedElement();
   //       // --- Get the type of element from which the event came
   //          ENUM_ELEMENT_TYPE type=this.GetEventElementType(sparam);
   //       // --- If we couldn’t get the element type or a pointer to the content, leave
   //          if(type==WRONG_VALUE || elm==NULL)
   //             return;
   //       // --- If the horizontal scrollbar slider event - shift the content horizontally
   //          if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_H)
   //             res=this.ContentShiftHorz((int)lparam);

   //       // --- If the vertical scrollbar slider event - shift the content vertically
   //          if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_V)
   //             res=this.ContentShiftVert((int)lparam);
            
   //       // --- If the content is successfully shifted, we update the graph
   //          if(res)
   //             ::ChartRedraw(this.m_chart_id);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Element Custom Event Handler |
   //    // | when clicking in the object area |
   //    //+------------------------------------------------------------------+
   //    void CContainer::MousePressHandler(const int id,const long lparam,const double dparam,const string sparam)
   //       {
   //          bool res=false;
   //       // --- Get a pointer to the contents of the container
   //          CElementBase *elm=this.GetAttachedElement();
   //       // --- Get the type of element from which the event came
   //          ENUM_ELEMENT_TYPE type=this.GetEventElementType(sparam);
   //       // --- If we couldn’t get the element type or a pointer to the content, leave
   //          if(type==WRONG_VALUE || elm==NULL)
   //             return;
            
   //       // --- If the events of the horizontal scrollbar buttons,
   //          if(type==ELEMENT_TYPE_BUTTON_ARROW_LEFT || type==ELEMENT_TYPE_BUTTON_ARROW_RIGHT)
   //          {
   //             // --- Check the pointer to the horizontal scrollbar
   //             if(this.m_scrollbar_h==NULL)
   //                return;
   //             // --- get a pointer to the scrollbar slider
   //             CScrollBarThumbH *obj=this.m_scrollbar_h.GetThumb();
   //             if(obj==NULL)
   //                return;
   //             // --- determine the direction of slider shift based on the type of button pressed
   //             int direction=(type==ELEMENT_TYPE_BUTTON_ARROW_LEFT ? 120 : -120);
   //             // --- call the scroll handler of the slider object to move the slider in the direction
   //             obj.OnWheelEvent(id,0,direction,this.NameFG());
   //             // --- Successfully
   //             res=true;
   //          }
            
   //       // --- If the events of the vertical scrollbar buttons,
   //          if(type==ELEMENT_TYPE_BUTTON_ARROW_UP || type==ELEMENT_TYPE_BUTTON_ARROW_DOWN)
   //          {
   //             // --- Checking the pointer to the vertical scrollbar
   //             if(this.m_scrollbar_v==NULL)
   //                return;
   //             // --- get a pointer to the scrollbar slider
   //             CScrollBarThumbV *obj=this.m_scrollbar_v.GetThumb();
   //             if(obj==NULL)
   //                return;
   //             // --- determine the direction of slider shift based on the type of button pressed
   //             int direction=(type==ELEMENT_TYPE_BUTTON_ARROW_UP ? 120 : -120);
   //             // --- call the scroll handler of the slider object to move the slider in the direction
   //             obj.OnWheelEvent(id,0,direction,this.NameFG());
   //             // --- Successfully
   //             res=true;
   //          }

   //       // --- If the click event is on a horizontal scrollbar (between the slider and scroll buttons),
   //          if(type==ELEMENT_TYPE_SCROLLBAR_H)
   //          {
   //             // --- Check the pointer to the horizontal scrollbar
   //             if(this.m_scrollbar_h==NULL)
   //                return;
   //             // --- get a pointer to the scrollbar slider
   //             CScrollBarThumbH *thumb=this.m_scrollbar_h.GetThumb();
   //             if(thumb==NULL)
   //                return;
   //             // --- Slider offset direction
   //             int direction=(lparam>=thumb.Right() ? 1 : lparam<=thumb.X() ? -1 : 0);

   //             // --- Check the divisor for a zero value
   //             if(this.ContentSizeHorz()-this.ContentVisibleHorz()==0)
   //                return;     
               
   //             // --- Calculate the slider offset proportional to the content offset by one screen
   //             int thumb_shift=(int)::round(direction * ((double)this.ContentVisibleHorz() / double(this.ContentSizeHorz()-this.ContentVisibleHorz())) * (double)this.TrackEffectiveLengthHorz());
   //             // --- call the scroll handler of the slider object to move the slider in the direction of the offset
   //             thumb.OnWheelEvent(id,thumb_shift,0,this.NameFG());
   //             // --- Record the result of shifting the contents of the container
   //             res=this.ContentShiftHorz(thumb_shift);
   //          }
            
   //       // --- If the click event is on a vertical scrollbar (between the slider and scroll buttons),
   //          if(type==ELEMENT_TYPE_SCROLLBAR_V)
   //          {
   //             // --- Checking the pointer to the vertical scrollbar
   //             if(this.m_scrollbar_v==NULL)
   //                return;
   //             // --- get a pointer to the scrollbar slider
   //             CScrollBarThumbV *thumb=this.m_scrollbar_v.GetThumb();
   //             if(thumb==NULL)
   //                return;
   //             // --- Slider offset direction
   //             int cursor=int(dparam-this.m_wnd_y);
   //             int direction=(cursor>=thumb.Bottom() ? 1 : cursor<=thumb.Y() ? -1 : 0);

   //             // --- Check the divisor for a zero value
   //             if(this.ContentSizeVert()-this.ContentVisibleVert()==0)
   //                return;     
               
   //             // --- Calculate the slider offset proportional to the content offset by one screen
   //             int thumb_shift=(int)::round(direction * ((double)this.ContentVisibleVert() / double(this.ContentSizeVert()-this.ContentVisibleVert())) * (double)this.TrackEffectiveLengthVert());
   //             // --- call the scroll handler of the slider object to move the slider in the direction of the offset
   //             thumb.OnWheelEvent(id,thumb_shift,0,this.NameFG());
   //             // --- Record the result of shifting the contents of the container
   //             res=this.ContentShiftVert(thumb_shift);
   //          }
            
   //       // --- If everything is successful, update the schedule
   //          if(res)
   //             ::ChartRedraw(this.m_chart_id);
   //       }
   //       //+------------------------------------------------------------------+
   //       // | CContainer::Element Custom Event Handler |
   //       // | when scrolling the wheel in the scrollbar slider area |
   //       //+------------------------------------------------------------------+
   //       void CContainer::MouseWheelHandler(const int id,const long lparam,const double dparam,const string sparam)
   //       {
   //          bool res=false;
   //       // --- Get a pointer to the contents of the container
   //          CElementBase *elm=this.GetAttachedElement();
   //       // --- Get the type of element from which the event came
   //          ENUM_ELEMENT_TYPE type=this.GetEventElementType(sparam);
   //       // --- If we were unable to obtain a pointer to the contents or the type of the element, we leave
   //          if(type==WRONG_VALUE || elm==NULL)
   //             return;
            
   //       // --- If the horizontal scrollbar slider event - shift the content horizontally
   //          if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_H)
   //             res=this.ContentShiftHorz((int)lparam);

   //       // --- If the vertical scrollbar slider event - shift the content vertically
   //          if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_V)
   //             res=this.ContentShiftVert((int)lparam);
            
   //       // --- If the content is successfully shifted, we update the graph
   //          if(res)
   //             ::ChartRedraw(this.m_chart_id);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CContainer::Element edges and corners drag handler |
   //    //+------------------------------------------------------------------+
   //    void CContainer::ResizeActionDragHandler(const int x, const int y)
   //       {
   //       // --- Checking the validity of the scroll bars
   //          if(this.m_scrollbar_h==NULL || this.m_scrollbar_v==NULL)
   //             return;
            
   //       // ---Depending on the region of interaction with the cursor
   //          switch(this.ResizeRegion())
   //          {
   //             // --- Resizing beyond the right border
   //             case CURSOR_REGION_RIGHT :
   //                // --- If the new width is successfully set
   //                if(this.ResizeZoneRightHandler(x,y))
   //                {
   //                   // --- check the size of the contents of the container for displaying scrollbars,
   //                   // --- shift the content to the new position of the horizontal scrollbar slider
   //                   this.CheckElementSizes(this.GetAttachedElement());
   //                   this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
   //                }
   //             break;
               
   //             // --- Resizing beyond the bottom border
   //             case CURSOR_REGION_BOTTOM :
   //                // --- If the new height is successfully set
   //                if(this.ResizeZoneBottomHandler(x,y))
   //                {
   //                   // --- check the size of the contents of the container for displaying scrollbars,
   //                   // --- shift the content to the new position of the vertical scrollbar slider
   //                   this.CheckElementSizes(this.GetAttachedElement());
   //                   this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
   //                }
   //             break;
               
   //             // --- Resizing beyond the left border
   //             case CURSOR_REGION_LEFT :
   //                // --- If the new X coordinate and width are successfully set
   //                if(this.ResizeZoneLeftHandler(x,y))
   //                {
   //                   // --- check the size of the contents of the container for displaying scrollbars,
   //                   // --- shift the content to the new position of the horizontal scrollbar slider
   //                   this.CheckElementSizes(this.GetAttachedElement());
   //                   this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
   //                }
   //             break;
               
   //             // --- Resizing beyond the top border
   //             case CURSOR_REGION_TOP :
   //                // --- If the new Y coordinate and height are successfully set
   //                if(this.ResizeZoneTopHandler(x,y))
   //                {
   //                   // --- check the size of the contents of the container for displaying scrollbars,
   //                   // --- shift the content to the new position of the vertical scrollbar slider
   //                   this.CheckElementSizes(this.GetAttachedElement());
   //                   this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
   //                }
   //             break;
               
   //             // --- Resizing by the lower right corner
   //             case CURSOR_REGION_RIGHT_BOTTOM :
   //                // --- If the new width and height are successfully set
   //                if(this.ResizeZoneRightBottomHandler(x,y))
   //                {
   //                   // --- check the size of the contents of the container for displaying scrollbars,
   //                   // --- shift the content to new positions of the scrollbar sliders
   //                   this.CheckElementSizes(this.GetAttachedElement());
   //                   this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
   //                   this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
   //                }
   //             break;
               
   //             // --- Resizing by the upper right corner
   //             case CURSOR_REGION_RIGHT_TOP :
   //                // ---If the new Y coordinate, width and height are successfully set
   //                if(this.ResizeZoneRightTopHandler(x,y))
   //                {
   //                   // --- check the size of the contents of the container for displaying scrollbars,
   //                   // --- shift the content to new positions of the scrollbar sliders
   //                   this.CheckElementSizes(this.GetAttachedElement());
   //                   this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
   //                   this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
   //                }
   //             break;
               
   //             // --- Resizing by the lower left corner
   //             case CURSOR_REGION_LEFT_BOTTOM :
   //                // ---If the new X coordinate, width and height are successfully set
   //                if(this.ResizeZoneLeftBottomHandler(x,y))
   //                {
   //                   // --- check the size of the contents of the container for displaying scrollbars,
   //                   // --- shift the content to new positions of the scrollbar sliders
   //                   this.CheckElementSizes(this.GetAttachedElement());
   //                   this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
   //                   this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
   //                }
   //             break;
               
   //             // --- Resizing by the upper left corner
   //             case CURSOR_REGION_LEFT_TOP :
   //                // --- If the new X and Y coordinates, width and height are set successfully
   //                if(this.ResizeZoneLeftTopHandler(x,y)) {}
   //                {
   //                   // --- check the size of the contents of the container for displaying scrollbars,
   //                   // --- shift the content to new positions of the scrollbar sliders
   //                   this.CheckElementSizes(this.GetAttachedElement());
   //                   this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
   //                   this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
   //                }
   //             break;
               
   //             // --- By default - leave
   //             default: return;
   //          }
   //          ::ChartRedraw(this.m_chart_id);
   //       }
   //    //+------------------------------------------------------------------+
   // #endif // CCONTAINER_IMPLEMENTATION
#endif // MOVE_TO_SCROLLBARV_MQH

#ifndef MOVE_TO_TABLECELLVIEW_MQH
#define MOVE_TO_TABLECELLVIEW_MQH
     // //+------------------------------------------------------------------+
   // // | Table cell visual representation class |
   // //+------------------------------------------------------------------+
   // class CTableCellView : public CBoundedObj
   // {
   //       protected:
   //          CTableCell       *m_table_cell_model;                       // Pointer to cell model
   //          CImagePainter    *m_painter;                                // Pointer to the drawing object
   //          CTableRowView    *m_element_base;                           // Pointer to base element (table row)
   //          CCanvas          *m_background;                             // Pointer to canvas background
   //          CCanvas          *m_foreground;                             // Pointer to foreground canvas
   //          int               m_index;                                  // Index in a list of cells
   //          ENUM_ANCHOR_POINT m_text_anchor;                            // Text anchor point (alignment in cell)
   //          int               m_text_x;                                 // X coordinate of the text (offset relative to the left edge of the object area)
   //          int               m_text_y;                                 // Y coordinate of the text (offset relative to the top border of the object area)
   //          ushort            m_text[];                                 // Text
   //          color             m_fore_color;                             // Foreground color
   //          color             m_back_color;                             // Background color
            
   //       // --- Returns the offsets of the initial drawing coordinates on the canvas relative to the canvas and the coordinates of the base element
   //          int               CanvasOffsetX(void)     const { return(this.m_element_base.ObjectX()-this.m_element_base.X());  }
   //          int               CanvasOffsetY(void)     const { return(this.m_element_base.ObjectY()-this.m_element_base.Y());  }
            
   //       // --- Returns the adjusted coordinate of a point on the canvas, taking into account the offset of the canvas relative to the base element
   //          int               AdjX(const int x)                            const { return(x-this.CanvasOffsetX());            }
   //          int               AdjY(const int y)                            const { return(y-this.CanvasOffsetY());            }

   //       // --- Returns the X and Y coordinates of the text depending on the anchor point
   //          bool              GetTextCoordsByAnchor(int &x, int &y, int &dir_x, int dir_y);

   //       // --- Returns a pointer to the table row pane container
   //          CContainer       *GetRowsPanelContainer(void);
            
   //       public:
   //       // --- Returns a pointer to the designated (1) background, (2) foreground canvas
   //          CCanvas          *GetBackground(void)                                { return this.m_background;                  }
   //          CCanvas          *GetForeground(void)                                { return this.m_foreground;                  }

   //       // --- Getting the bounds of the parent container object
   //          int               ContainerLimitLeft(void)   const { return(this.m_element_base==NULL ? this.X()      :  this.m_element_base.LimitLeft());   }
   //          int               ContainerLimitRight(void)  const { return(this.m_element_base==NULL ? this.Right()  :  this.m_element_base.LimitRight());  }
   //          int               ContainerLimitTop(void)    const { return(this.m_element_base==NULL ? this.Y()      :  this.m_element_base.LimitTop());    }
   //          int               ContainerLimitBottom(void) const { return(this.m_element_base==NULL ? this.Bottom() :  this.m_element_base.LimitBottom()); }

   //       // --- Returns a flag that an object is located outside of its container
   //          virtual bool      IsOutOfContainer(void);

   //       // --- (1) Sets, (2) returns the cell text
   //          void              SetText(const string text)                         { ::StringToShortArray(text,this.m_text);    }
   //          string            Text(void)                                   const { return ::ShortArrayToString(this.m_text);  }

   //       // --- (1) Sets, (2) returns the cell text color
   //          void              SetForeColor(const color clr)                      { this.m_fore_color=clr;                     }
   //          color             ForeColor(void)                              const { return this.m_fore_color;                  }

   //       // --- (1) Sets, (2) returns the background color of the cell
   //          void              SetBackColor(const color clr)                      { this.m_back_color=clr;                     }
   //          color             BackColor(void)                              const { return this.m_back_color;                  }

   //       // --- Sets the ID
   //          virtual void      SetID(const int id)                                { this.m_id=id;                              }
   //       // --- (1) Sets, (2) returns the cell index
   //          void              SetIndex(const int index)                          { this.m_index=index;                        }
   //          int               Index(void)                                  const { return this.m_index;                       }

   //       // --- (1) Sets, (2) returns the X offset of the text
   //          void              SetTextShiftX(const int shift)                     { this.m_text_x=shift;                       }
   //          int               TextShiftX(void)                             const { return this.m_text_x;                      }
            
   //       // --- (1) Sets, (2) returns the Y-axis offset of the text
   //          void              SetTextShiftY(const int shift)                     { this.m_text_y=shift;                       }
   //          int               TextShiftY(void)                             const { return this.m_text_y;                      }
            
   //       // --- (1) Sets, (2) returns the text anchor point
   //          void              SetTextAnchor(const ENUM_ANCHOR_POINT anchor,const bool cell_redraw,const bool chart_redraw);
   //          int               TextAnchor(void)                             const { return this.m_text_anchor;                 }
            
   //       // --- Sets the text anchor and offset point
   //          void              SetTextPosition(const ENUM_ANCHOR_POINT anchor,const int shift_x,const int shift_y,const bool cell_redraw,const bool chart_redraw);

   //       // --- Assigns a base element (table row)
   //          void              RowAssign(CTableRowView *base_element);
            
   //       // --- (1) Assigns, (2) returns the cell model
   //          bool              TableCellModelAssign(CTableCell *cell_model,int dx,int dy,int w,int h);
   //          CTableCell       *GetTableCellModel(void)                            { return this.m_table_cell_model;            }

   //       // --- Prints the assigned cell model in the journal
   //          void              TableCellModelPrint(void);
            
   //       // --- (1) Fills the object with the background color, (2) Updates the object to reflect the changes, (3) Draws the appearance
   //          virtual void      Clear(const bool chart_redraw);
   //          virtual void      Update(const bool chart_redraw);
   //          virtual void      Draw(const bool chart_redraw);
            
   //       // --- Outputs text
   //          virtual void      DrawText(const int dx, const int dy, const string text, const bool chart_redraw);
            
   //       // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //          virtual int       Compare(const CObject *node,const int mode=0)const { return CBaseObj::Compare(node,mode);       }
   //          virtual bool      Save(const int file_handle);
   //          virtual bool      Load(const int file_handle);
   //          virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_CELL_VIEW);      }
            
   //       // --- Initializing a class object
   //          void              Init(const string text);
            
   //       // --- Returns a description of the object
   //          virtual string    Description(void);
            
   //       // --- Constructors/destructor
   //                            CTableCellView(void);
   //                            CTableCellView(const int id, const string user_name, const string text, const int x, const int y, const int w, const int h);
   //                         ~CTableCellView (void){}
   //    };
   // #ifndef CTABLECELLVIEW_IMPLEMENTATION
   // #define CTABLECELLVIEW_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Default constructor. Builds an object in the main|
   //    // | window of the current chart in coordinates 0,0 with default sizes |
   //    //+------------------------------------------------------------------+
   //    CTableCellView::CTableCellView(void) : CBoundedObj("TableCell",-1,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H), m_index(-1),m_text_anchor(ANCHOR_LEFT)
   //       {
   //       // ---Initialization
   //          this.Init("");
   //          this.SetID(-1);
   //          this.SetIndex(-1);
   //          this.SetName("TableCellView");
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Parametric constructor. Builds an object |
   //    // | in the specified window of the specified chart with the specified text, |
   //    // | coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CTableCellView::CTableCellView(const int id, const string user_name, const string text, const int x, const int y, const int w, const int h) :
   //       CBoundedObj(user_name,id,x,y,w,h), m_index(-1),m_text_anchor(ANCHOR_LEFT)
   //       {
   //       // ---Initialization
   //          this.Init(text);
   //          this.SetID(id);
   //          this.SetIndex(-1);
   //          this.SetName(user_name);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CTableCellView::Init(const string text)
   //       {
   //       // --- The class does not manage canvases
   //          this.m_canvas_owner=false;
   //       // --- Cell text
   //          this.SetText(text);
   //       // --- Default text offsets
   //          this.m_text_x=2;
   //          this.m_text_y=0;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Returns object description |
   //    //+------------------------------------------------------------------+
   //    string CTableCellView::Description(void)
   //       {
   //          string nm=this.Name();
   //          string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   //          return ::StringFormat("%s%s ID %d, X %d, Y %d, W %d, H %d, Value: \"%s\"",
   //                               ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,
   //                               this.ID(),this.X(),this.Y(),this.Width(),this.Height(),this.Text());
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Assigns row, background and foreground canvases |
   //    //+------------------------------------------------------------------+
   //    void CTableCellView::RowAssign(CTableRowView *base_element)
   //       {
   //          if(base_element==NULL)
   //          {
   //             ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
   //             return;
   //          }
   //          this.m_element_base=base_element;
   //          this.m_background=this.m_element_base.GetBackground();
   //          this.m_foreground=this.m_element_base.GetForeground();
   //          this.m_painter=this.m_element_base.Painter();
   //          this.m_fore_color=this.m_element_base.ForeColor();
   //          this.m_back_color=this.m_element_base.BackColor();
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Assigns a cell model |
   //    //+------------------------------------------------------------------+
   //    bool CTableCellView::TableCellModelAssign(CTableCell *cell_model,int dx,int dy,int w,int h)
   //       {
   //       // --- If an invalid cell model object is passed, we report this and return false
   //          if(cell_model==NULL)
   //          {
   //             ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
   //             return false;
   //          }
   //       // --- If the base element (table row) is not assigned, we report this and return false
   //          if(this.m_element_base==NULL)
   //          {
   //             ::PrintFormat("%s: Error. Base element not assigned. Please use RowAssign() method first",__FUNCTION__);
   //             return false;
   //          }
   //       // --- Save the cell model
   //          this.m_table_cell_model=cell_model;
   //       // --- Set the coordinates and dimensions of the visual representation of the cell
   //          this.BoundSetXY(dx,dy);
   //          this.BoundResize(w,h);
   //       // --- Set the dimensions of the drawing area of ​​the visual representation of the cell
   //          this.m_painter.SetBound(dx,dy,w,h);
   //       // --- Everything is successful
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Returns the X and Y coordinates of the text |
   //    // | depending on the anchor point |
   //    //+------------------------------------------------------------------+
   //    bool CTableCellView::GetTextCoordsByAnchor(int &x,int &y, int &dir_x,int dir_y)
   //       {
   //       // --- Get the dimensions of the text in the cell
   //          int text_w=0, text_h=0;
   //          this.m_foreground.TextSize(this.Text(),text_w,text_h);
   //          if(text_w==0 || text_h==0)
   //             return false;
   //       // --- Depending on the text anchor point in the cell
   //       // --- calculate its initial coordinates (upper left corner)
   //          switch(this.m_text_anchor)
   //          {
   //             // --- Anchor point left center
   //             case ANCHOR_LEFT :
   //             x=0;
   //             y=(this.Height()-text_h)/2;
   //             dir_x=1;
   //             dir_y=1;
   //             break;
   //             // --- Anchor point in the lower left corner
   //             case ANCHOR_LEFT_LOWER :
   //             x=0;
   //             y=this.Height()-text_h;
   //             dir_x= 1;
   //             dir_y=-1;
   //             break;
   //             // --- Anchor point bottom center
   //             case ANCHOR_LOWER :
   //             x=(this.Width()-text_w)/2;
   //             y=this.Height()-text_h;
   //             dir_x= 1;
   //             dir_y=-1;
   //             break;
   //             // --- Anchor point in the lower right corner
   //             case ANCHOR_RIGHT_LOWER :
   //             x=this.Width()-text_w;
   //             y=this.Height()-text_h;
   //             dir_x=-1;
   //             dir_y=-1;
   //             break;
   //             // --- Anchor point right center
   //             case ANCHOR_RIGHT :
   //             x=this.Width()-text_w;
   //             y=(this.Height()-text_h)/2;
   //             dir_x=-1;
   //             dir_y= 1;
   //             break;
   //             // --- Anchor point in the upper right corner
   //             case ANCHOR_RIGHT_UPPER :
   //             x=this.Width()-text_w;
   //             y=0;
   //             dir_x=-1;
   //             dir_y= 1;
   //             break;
   //             // --- Anchor point top center
   //             case ANCHOR_UPPER :
   //             x=(this.Width()-text_w)/2;
   //             y=0;
   //             dir_x=1;
   //             dir_y=1;
   //             break;
   //             // --- The anchor point is strictly in the center of the object
   //             case ANCHOR_CENTER :
   //             x=(this.Width()-text_w)/2;
   //             y=(this.Height()-text_h)/2;
   //             dir_x=1;
   //             dir_y=1;
   //             break;
   //             // --- Anchor point in the upper left corner
   //             //---ANCHOR_LEFT_UPPER
   //             default:
   //             x=0;
   //             y=0;
   //             dir_x=1;
   //             dir_y=1;
   //             break;
   //          }
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Sets text anchor point |
   //    //+------------------------------------------------------------------+
   //    void CTableCellView::SetTextAnchor(const ENUM_ANCHOR_POINT anchor,const bool cell_redraw,const bool chart_redraw)
   //       {
   //          if(this.m_text_anchor==anchor)
   //             return;
   //          this.m_text_anchor=anchor;
   //          if(cell_redraw)
   //             this.Draw(chart_redraw);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Sets text anchor and offset |
   //    //+------------------------------------------------------------------+
   //    void CTableCellView::SetTextPosition(const ENUM_ANCHOR_POINT anchor,const int shift_x,const int shift_y,const bool cell_redraw,const bool chart_redraw)
   //       {
   //          this.SetTextShiftX(shift_x);
   //          this.SetTextShiftY(shift_y);
   //          this.SetTextAnchor(anchor,cell_redraw,chart_redraw);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Fills an object with color |
   //    //+------------------------------------------------------------------+
   //    void CTableCellView::Clear(const bool chart_redraw)
   //       {
   //       // --- Set the correct coordinates of the cell corners
   //          int x1=this.AdjX(this.m_bound.X());
   //          int y1=this.AdjY(this.m_bound.Y());
   //          int x2=this.AdjX(this.m_bound.Right());
   //          int y2=this.AdjY(this.m_bound.Bottom());
   //       // --- Erase the background and foreground inside the rectangular area of ​​the cell location
   //          if(this.m_background!=NULL)
   //             this.m_background.FillRectangle(x1,y1,x2,y2-1,::ColorToARGB(this.m_element_base.BackColor(),this.m_element_base.AlphaBG()));
   //          if(this.m_foreground!=NULL)
   //             this.m_foreground.FillRectangle(x1,y1,x2,y2-1,clrNULL);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Updates an object to reflect changes |
   //    //+------------------------------------------------------------------+
   //    void CTableCellView::Update(const bool chart_redraw)
   //       {
   //          if(this.m_background!=NULL)
   //             this.m_background.Update(false);
   //          if(this.m_foreground!=NULL)
   //             this.m_foreground.Update(chart_redraw);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Returns a pointer |
   //    // | to the table row panel container |
   //    //+------------------------------------------------------------------+
   //    CContainer *CTableCellView::GetRowsPanelContainer(void)
   //       {
   //       // --- Checking the string
   //          if(this.m_element_base==NULL)
   //             return NULL;
   //       // --- We get a panel for placing lines
   //          CPanel *rows_area=this.m_element_base.GetContainer();
   //          if(rows_area==NULL)
   //             return NULL;
   //       // --- Return the panel container with rows
   //          return rows_area.GetContainer();
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Returns the flag that the object |
   //    // | located outside of its container |
   //    //+------------------------------------------------------------------+
   //    bool CTableCellView::IsOutOfContainer(void)
   //       {
   //       // --- Checking the string
   //          if(this.m_element_base==NULL)
   //             return false;

   //       // --- We get a panel container with rows
   //          CContainer *container=this.GetRowsPanelContainer();
   //          if(container==NULL)
   //             return false;
         
   //       // --- We get the cell boundaries on all sides
   //          int cell_l=this.m_element_base.X()+this.X();
   //          int cell_r=this.m_element_base.X()+this.Right();
   //          int cell_t=this.m_element_base.Y()+this.Y();
   //          int cell_b=this.m_element_base.Y()+this.Bottom();
            
   //       // --- Return the result of checking that the object completely extends beyond the container
   //          return(cell_r <= container.X() || cell_l >= container.Right() || cell_b <= container.Y() || cell_t >= container.Bottom());
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CTableCellView::Draw(const bool chart_redraw)
   //       {
   //       // --- If the cell is outside the table row container - leave
   //          if(this.IsOutOfContainer())
   //             return;
               
   //       // --- Get text coordinates and offset direction depending on the anchor point
   //          int text_x=0, text_y=0;
   //          int dir_horz=0, dir_vert=0;
   //          if(!this.GetTextCoordsByAnchor(text_x,text_y,dir_horz,dir_vert))
   //             return;
   //       // --- Correcting text coordinates
   //          int x=this.AdjX(this.X()+text_x);
   //          int y=this.AdjY(this.Y()+text_y);
            
   //       // --- Set the coordinates of the dividing line
   //          int x1=this.AdjX(this.X());
   //          int y1=this.AdjY(this.Y());
   //          int x2=this.AdjX(this.X());
   //          int y2=this.AdjY(this.Bottom());

   //       // --- Displaying text on the foreground canvas taking into account the displacement direction without updating the graph
   //          this.DrawText(x+this.m_text_x*dir_horz,y+this.m_text_y*dir_vert,this.Text(),false);
            
   //       // --- Set the coordinates of the rectangular fill
   //          x1=this.AdjX(this.X());
   //          y1=this.AdjY(this.Y());
   //          x2=this.AdjX(this.Right());
   //          y2=this.AdjY(this.Bottom()-1);
   //          this.m_background.FillRectangle(x1,y1,x2,y2,::ColorToARGB(this.BackColor(),this.m_element_base.AlphaBG()));

   //       // --- If this is not the cell on the far right, draw a vertical dividing stripe near the cell on the right
   //          if(this.m_element_base!=NULL && this.Index()<this.m_element_base.CellsTotal()-1)
   //          {
   //             int line_x=this.AdjX(this.Right());
   //             this.m_background.Line(line_x,y1,line_x,y2,::ColorToARGB(this.m_element_base.BorderColor(),this.m_element_base.AlphaBG()));
   //          }
   //       // --- Update the background canvas with the specified graph redraw flag
   //          this.m_background.Update(chart_redraw);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Displays text |
   //    //+------------------------------------------------------------------+
   //    void CTableCellView::DrawText(const int dx,const int dy,const string text,const bool chart_redraw)
   //       {
   //       // --- Checking the base element
   //          if(this.m_element_base==NULL)
   //             return;
               
   //       // --- Clear the cell and set the text
   //          this.Clear(false);
   //          this.SetText(text);
            
   //       // --- Display the set text on the foreground canvas
   //          this.m_foreground.TextOut(dx,dy,this.Text(),::ColorToARGB(this.ForeColor(),this.m_element_base.AlphaFG()));
            
   //       // --- If the text extends beyond the right border of the cell area
   //          if(this.Right()-dx<this.m_foreground.TextWidth(text))
   //          {
   //             // --- Getting the dimensions of the text "ellipsis"
   //             int w=0,h=0;
   //             this.m_foreground.TextSize("... ",w,h);
   //             if(w>0 && h>0)
   //             {
   //                // --- Erase the text at the right border of the object according to the text size "ellipsis" and replace the end of the label text with an ellipsis
   //                this.m_foreground.FillRectangle(this.AdjX(this.Right())-w,this.AdjY(this.Y()),this.AdjX(this.Right()),this.AdjY(this.Y())+h,clrNULL);
   //                this.m_foreground.TextOut(this.AdjX(this.Right())-w,this.AdjY(dy),"...",::ColorToARGB(this.ForeColor(),this.m_element_base.AlphaFG()));
   //             }
   //          }
   //       // --- Update the foreground canvas with the specified graph redraw flag
   //          this.m_foreground.Update(chart_redraw);
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Prints the assigned row model in the log|
   //    //+------------------------------------------------------------------+
   //    void CTableCellView::TableCellModelPrint(void)
   //       {
   //       if(this.m_table_cell_model!=NULL)
   //          this.m_table_cell_model.Print();
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Saving to file |
   //    //+------------------------------------------------------------------+
   //    bool CTableCellView::Save(const int file_handle)
   //       {
   //       // --- Save the data of the parent object
   //          if(!CBaseObj::Save(file_handle))
   //             return false;
         
   //       // --- Save the cell number
   //          if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
   //             return false;
   //       // --- Save the text anchor point
   //          if(::FileWriteInteger(file_handle,this.m_text_anchor,INT_VALUE)!=INT_VALUE)
   //             return false;
   //       // --- Save the X coordinate of the text
   //          if(::FileWriteInteger(file_handle,this.m_text_x,INT_VALUE)!=INT_VALUE)
   //             return false;
   //       // --- Save the Y coordinate of the text
   //          if(::FileWriteInteger(file_handle,this.m_text_y,INT_VALUE)!=INT_VALUE)
   //             return false;
   //       // --- Save the text
   //          if(::FileWriteArray(file_handle,this.m_text)!=sizeof(this.m_text))
   //             return false;
               
   //       // --- Everything is successful
   //          return true;
   //       }
   //    //+------------------------------------------------------------------+
   //    // | CTableCellView::Loading from file |
   //    //+------------------------------------------------------------------+
   //    bool CTableCellView::Load(const int file_handle)
   //       {
   //          // --- Loading the data of the parent object
   //             if(!CBaseObj::Load(file_handle))
   //                return false;
                  
   //          // --- Load the cell number
   //             this.m_index=::FileReadInteger(file_handle,INT_VALUE);
   //          // --- Loading text anchor point
   //             this.m_text_anchor=(ENUM_ANCHOR_POINT)::FileReadInteger(file_handle,INT_VALUE);
   //          // --- Load the X coordinate of the text
   //             this.m_text_x=::FileReadInteger(file_handle,INT_VALUE);
   //          // --- Load the Y coordinate of the text
   //             this.m_text_y=::FileReadInteger(file_handle,INT_VALUE);
   //          // --- Loading text
   //             if(::FileReadArray(file_handle,this.m_text)!=sizeof(this.m_text))
   //                return false;
               
   //          // --- Everything is successful
   //             return true;
   //       }
   //    //+------------------------------------------------------------------+
   // #endif // CTABLECELLVIEW_IMPLEMENTATION
#endif // MOVE_TO_TABLECELLVIEW_MQH

#ifndef MOVE_TO_TABLEROWVIEW_MQH
#define MOVE_TO_TABLEROWVIEW_MQH
   // //+------------------------------------------------------------------+
   // // | Table row visualization class |
   // //+------------------------------------------------------------------+
   // class CTableRowView : public CPanel
   // {
   //    protected:
   //       CTableCellView    m_temp_cell;                                    // Temporary cell object to search
   //       CTableRow        *m_table_row_model;                              // Pointer to a string model
   //       CListElm          m_list_cells;                                   // List of cells
   //       int               m_index;                                        // Index in a list of strings
   //       ENUM_ROWS_HIGHLIGHT_MODE m_highlight_mode;                        // Line highlighting mode
         
   //    // --- Creates and adds a new cell view object to the list
   //       CTableCellView   *InsertNewCellView(const int index,const string text,const int dx,const int dy,const int w,const int h);
   //    // --- Deletes the specified row area and the cell at the corresponding index
   //       bool              BoundCellDelete(const int index);
   //    // --- Returns a visual representation of (1) table, (2) column headers, (3) rows
   //       CTableView       *GetTableView(void);
   //       CTableHeaderView *GetHeaderView(void);
   //       CTableRowsHeaderView *GetRowsHeaderView(void);
         
   //    // --- Sets the specified header (1) column, (2) row as selected
   //       void              SetColumnCaptionSelected(const uint index);
   //       void              SetRowCaptionSelected(const uint index);
   //    // --- Deselects all (1) column, (2) row headers
   //       void              SetAllColumnCaptionsUnselected(const int exclude=-1);
   //       void              SetAllRowCaptionsUnselected(const int exclude=-1);
         
   //    public:
   //    // --- Returns (1) list, (2) number of cells, (3) cell, (4) column header, (5) rows
   //       CListElm         *GetListCells(void)                                 { return &this.m_list_cells;                       }
   //       int               CellsTotal(void)                             const { return this.m_list_cells.Total();                }
   //       CTableCellView   *GetCellView(const uint index)                      { return this.m_list_cells.GetNodeAtIndex(index);  }
   //       CColumnCaptionView *GetColumnCaption(const uint index);
   //       CRowCaptionView  *GetRowCaption(const uint index);
         
   //    // --- Sets the ID
   //       virtual void      SetID(const int id)                                { this.m_id=id;                                    }
   //    // --- (1) Sets, (2) returns the row index
   //       void              SetIndex(const int index)                          { this.m_index=index;                              }
   //       int               Index(void)                                  const { return this.m_index;                             }

   //    // --- (1) Sets, (2) returns the string model
   //       bool              TableRowModelAssign(CTableRow *row_model);
   //       CTableRow        *GetTableRowModel(void)                             { return this.m_table_row_model;                   }
   //    // --- Updates the stack with the updated model
   //       bool              TableRowModelUpdate(CTableRow *row_model);

   //    // --- (1) Sets, (2) returns the line highlighting mode
   //       void              SetHighlightMode(const ENUM_ROWS_HIGHLIGHT_MODE mode) { this.m_highlight_mode=mode;                   }
   //       ENUM_ROWS_HIGHLIGHT_MODE HighlightMode(void)                   const { return this.m_highlight_mode;                    }
         
   //    // --- Recalculates cell areas
   //       bool              RecalculateBounds(CListElm *list_bounds);

   //    // --- Prints the assigned line model in the log
   //       void              TableRowModelPrint(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS);
         
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);
         
   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0)const { return CLabel::Compare(node,mode);               }
   //       virtual bool      Save(const int file_handle);
   //       virtual bool      Load(const int file_handle);
   //       virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_ROW_VIEW);             }
      
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(void);
   //       virtual void      InitColors(void);

   //    // --- Event handlers for (1) cursor hover (Focus), (2) mouse button clicks (Press),
   //       virtual void      OnFocusEvent(const int id, const long lparam, const double dparam, const string sparam);
   //       virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);
         
   //    // --- Constructors/destructor
   //                         CTableRowView(void);
   //                         CTableRowView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CTableRowView (void){ this.m_list_cells.Clear(); }
   // };
   // #ifndef CTABLEROWVIEW_IMPLEMENTATION
   // #define CTABLEROWVIEW_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //    // | CTableRowView::Default constructor. Builds an object in the main |
   //    // | window of the current chart in coordinates 0,0 with default sizes |
   //    //+------------------------------------------------------------------+
   //    CTableRowView::CTableRowView(void) : CPanel("TableRow","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H), m_index(-1), m_highlight_mode(ROWS_HIGHLIGHT_MODE_ROW)
   //    {
   //       // ---Initialization
   //          this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Parametric constructor. Builds an object in |
   //    // | the specified window of the specified chart with the specified text, |
   //    // | coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CTableRowView::CTableRowView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CPanel(object_name,text,chart_id,wnd,x,y,w,h), m_index(-1), m_highlight_mode(ROWS_HIGHLIGHT_MODE_ROW)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CTableRowView::Init(void)
   //    {
   //    // --- Initializing the parent object
   //       CPanel::Init();
   //    // --- Background - opaque
   //       this.SetAlphaBG(255);
   //    // --- Frame width
   //       this.SetBorderWidth(1);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Initializing default object colors |
   //    //+------------------------------------------------------------------+
   //    void CTableRowView::InitColors(void)
   //    {
   //    // --- Initialize the background colors for normal and activated states and make it the current background color
   //       this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //       this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //       this.BackColorToDefault();
         
   //    // --- Initialize the foreground colors for normal and activated states and make it the current text color
   //       this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.ForeColorToDefault();
         
   //    // --- Initialize the border colors for the normal and activated states and make it the current border color
   //       this.InitBorderColors(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
   //       this.InitBorderColorsAct(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
   //       this.BorderColorToDefault();
         
   //    // --- Initialize the border color and foreground color for the locked element
   //       this.InitBorderColorBlocked(clrSilver);
   //       this.InitForeColorBlocked(clrSilver);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Creates and adds to the list |
   //    // | new cell view object |
   //    //+------------------------------------------------------------------+
   //    CTableCellView *CTableRowView::InsertNewCellView(const int index,const string text,const int dx,const int dy,const int w,const int h)
   //    {
   //    // --- Check if there is an object with the specified identifier in the list and, if so, report it and return NULL
   //       this.m_temp_cell.SetIndex(index);
   //    // --- Remember the list sorting method
   //       int sort_mode=this.m_list_cells.SortMode();
   //    // --- Set the list to sort by identifier
   //       this.m_list_cells.Sort(ELEMENT_SORT_BY_ID);
   //       if(this.m_list_cells.Search(&this.m_temp_cell)!=NULL)
   //       {
   //          // --- We return the initial sorting to the list, inform that such an object already exists and return NULL
   //          this.m_list_cells.Sort(sort_mode);
   //          ::PrintFormat("%s: Error. The TableCellView object with index %d is already in the list",__FUNCTION__,index);
   //          return NULL;
   //       }
   //    // --- Return the list to its original sorting
   //       this.m_list_cells.Sort(sort_mode);
   //    // --- Create a cell object name
   //       string name="TableCellView"+(string)this.Index()+"x"+(string)index;
   //    // --- Create a new TableCellView object; if it fails, we report it and return NULL
   //       CTableCellView *cell_view=new CTableCellView(index,name,text,dx,dy,w,h);
   //       if(cell_view==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to create CTableCellView object",__FUNCTION__);
   //          return NULL;
   //       }
   //    // --- If a new object could not be added to the list, we report this, delete the object and return NULL
   //       if(this.m_list_cells.Add(cell_view)==-1)
   //       {
   //          ::PrintFormat("%s: Error. Failed to add CTableCellView object to list",__FUNCTION__);
   //          delete cell_view;
   //          return NULL;
   //       }
   //    // --- Assign a base element (string) and return a pointer to the object
   //       cell_view.RowAssign(&this);
   //       return cell_view;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Sets the row model |
   //    //+------------------------------------------------------------------+
   //    bool CTableRowView::TableRowModelAssign(CTableRow *row_model)
   //    {
   //    // --- If an empty object is passed, we report this and return false
   //       if(row_model==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
   //          return false;
   //       }
   //    // --- If there is not a single cell in the passed row model, we report this and return false
   //       int total=(int)row_model.CellsTotal();
   //       if(total==0)
   //       {
   //          ::PrintFormat("%s: Error. Row model does not contain any cells",__FUNCTION__);
   //          return false;
   //       }
   //    // --- Save a pointer to the passed string model
   //       this.m_table_row_model=row_model;
   //    // --- calculate the cell width based on the width of the row panel
   //       CCanvasBase *base=this.GetContainer();
   //       int w=(base!=NULL ? base.Width() : this.Width());
   //       int cell_w=(int)::fmax(::round((double)w/(double)total),DEF_TABLE_COLUMN_MIN_W);

   //    // --- In a loop by the number of cells in the row model
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- we get the model of the next cell,
   //          CTableCell *cell_model=this.m_table_row_model.GetCell(i);
   //          if(cell_model==NULL)
   //             return false;
   //          // --- calculate the coordinate and create a name for the cell area
   //          int x=cell_w*i;
   //          string name="CellBound"+(string)this.m_table_row_model.Index()+"x"+(string)i;
   //          // --- Create a new cell area
   //          CBound *cell_bound=this.InsertNewBound(name,x,0,cell_w,this.Height());
   //          if(cell_bound==NULL)
   //             return false;
   //          // --- Create a new cell visual representation object
   //          CTableCellView *cell_view=this.InsertNewCellView(i,cell_model.Value(),x,0,cell_w,this.Height());
   //          if(cell_view==NULL)
   //             return false;
   //          // --- We assign the corresponding object of visual representation of the cell to the current area of ​​the cell
   //          cell_bound.AssignObject(cell_view);
   //       }
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Updates the row with the updated model |
   //    //+------------------------------------------------------------------+
   //    bool CTableRowView::TableRowModelUpdate(CTableRow *row_model)
   //    {
   //    // --- If an empty object is passed, we report this and return false
   //       if(row_model==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
   //          return false;
   //       }
   //    // --- If there is not a single cell in the passed row model, we report this and return false
   //       int total_model=(int)row_model.CellsTotal(); // Number of cells in row model
   //       if(total_model==0)
   //       {
   //          ::PrintFormat("%s: Error. Row model does not contain any cells",__FUNCTION__);
   //          return false;
   //       }
   //    // --- Save a pointer to the passed string model
   //       this.m_table_row_model=row_model;

   //    // --- Calculate the cell width based on the width of the row panel
   //       CCanvasBase *base=this.GetContainer();
   //       int w=(base!=NULL ? base.Width() : this.Width());
   //       int cell_w=(int)::fmax(::round((double)w/(double)total_model),DEF_TABLE_COLUMN_MIN_W);
         
   //       CBound *cell_bound=NULL;
   //       int total_bounds=this.m_list_bounds.Total(); // Number of areas
   //       int diff=total_model-total_bounds;           // Difference between number of areas in a row and cells in a row model
         
   //    // --- If there are more cells in the model than areas in the list, we will create the missing areas and cells at the end of the lists
   //       if(diff>0)
   //       {
   //          // --- In a loop based on the number of missing areas
   //          for(int i=total_bounds;i<total_bounds+diff;i++)
   //          {
   //             // --- create and add to the diff list the number of areas of row cells.
   //             // --- We get the model of the next cell,
   //             CTableCell *cell_model=this.m_table_row_model.GetCell(i);
   //             if(cell_model==NULL)
   //                return false;
   //             // --- calculate the coordinate and create a name for the cell area
   //             int x=cell_w*i;
   //             string name="CellBound"+(string)this.m_table_row_model.Index()+"x"+(string)i;
   //             // --- Create a new cell area
   //             CBound *cell_bound=this.InsertNewBound(name,x,0,cell_w,this.Height());
   //             if(cell_bound==NULL)
   //                return false;
                  
   //             // --- Create a new cell visual representation object
   //             CTableCellView *cell_view=this.InsertNewCellView(i,cell_model.Value(),x,0,cell_w,this.Height());
   //             if(cell_view==NULL)
   //                return false;
   //          }
   //       }
      
   //    // --- If there are more areas in the list than there are cells in the model, remove the extra areas at the end of the list
   //       if(diff<0)
   //       {
   //          int  start=total_bounds-1;
   //          int  end=start-diff;
   //          bool res=true;
   //          for(int i=start;i>end;i--)
   //          {
   //             if(!this.BoundCellDelete(i))
   //                return false;
   //          }
   //       }
         
   //    // --- In a loop by the number of cells in the row model
   //       for(int i=0;i<total_model;i++)
   //       {
   //          // --- we get the model of the next cell,
   //          CTableCell *cell_model=this.m_table_row_model.GetCell(i);
   //          if(cell_model==NULL)
   //             return false;
            
   //          // --- calculate the cell coordinate
   //          int x=cell_w*i;
   //          // --- We get the next area of ​​the cell
   //          CBound *cell_bound=this.GetBoundAt(i);
   //          if(cell_bound==NULL)
   //             return false;
            
   //          // --- We get a cell visual representation object from the list
   //          CTableCellView *cell_view=this.m_list_cells.GetNodeAtIndex(i);
   //          if(cell_view==NULL)
   //             return false;
            
   //          // --- Assign the corresponding visual object of the cell and its text to the current area of ​​the cell
   //          cell_bound.AssignObject(cell_view);
   //          cell_view.SetText(cell_model.Value());
   //       }
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Deletes the specified row area |
   //    // | and the cell with the corresponding index |
   //    //+------------------------------------------------------------------+
   //    bool CTableRowView::BoundCellDelete(const int index)
   //    {
   //       if(!this.m_list_cells.Delete(index))
   //          return false;
   //       return this.m_list_bounds.Delete(index);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Draws the appearance |
   //    //+------------------------------------------------------------------+
   //    void CTableRowView::Draw(const bool chart_redraw)
   //    {
   //    // --- If the line is outside the container, we leave
   //       if(this.IsOutOfContainer())
   //          return;

   //    // --- Fill the object with the background color, draw a line line and update the background canvas
   //       this.Fill(this.BackColor(),false);
   //       this.m_background.Line(this.AdjX(0),this.AdjY(this.Height()-1),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
      
   //    // --- Draw row cells
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- Getting the area of ​​the next cell
   //          CBound *cell_bound=this.GetBoundAt(i);
   //          if(cell_bound==NULL)
   //             continue;
            
   //          // --- From the cell area we get the attached cell object
   //          CTableCellView *cell_view=cell_bound.GetAssignedObj();
   //          // --- Draw a visual representation of the cell
   //          if(cell_view!=NULL)
   //             cell_view.Draw(false);
   //       }
   //    // --- Update the background and foreground canvases with the specified graph redraw flag
   //       this.Update(chart_redraw);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Prints the assigned row model in the log |
   //    //+------------------------------------------------------------------+
   //    void CTableRowView::TableRowModelPrint(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS)
   //    {
   //       if(this.m_table_row_model!=NULL)
   //          this.m_table_row_model.Print(detail,as_table,cell_width);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Recalculates cell areas |
   //    //+------------------------------------------------------------------+
   //    bool CTableRowView::RecalculateBounds(CListElm *list_bounds)
   //    {
   //    // --- Checking the list
   //       if(list_bounds==NULL)
   //          return false;

   //    // --- In a loop based on the number of areas in the list
   //       for(int i=0;i<list_bounds.Total();i++)
   //       {
   //          // --- we get the next header area and the corresponding cell area
   //          CBound *capt_bound=list_bounds.GetNodeAtIndex(i);
   //          CBound *cell_bound=this.GetBoundAt(i);
   //          if(capt_bound==NULL || cell_bound==NULL)
   //             return false;

   //          // --- In the cell area we set the coordinate and size of the header area
   //          cell_bound.SetX(capt_bound.X());
   //          cell_bound.ResizeW(capt_bound.Width());
            
   //          // --- From the cell area we get the attached cell object
   //          CTableCellView *cell_view=cell_bound.GetAssignedObj();
   //          if(cell_view==NULL)
   //             return false;

   //          // --- Set the coordinate and size of the cell area to the visual representation object of the cell
   //          cell_view.BoundSetX(cell_bound.X());
   //          cell_view.BoundResizeW(cell_bound.Width());
   //       }
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Returns a visual view of the table |
   //    //+------------------------------------------------------------------+
   //    CTableView *CTableRowView::GetTableView(void)
   //    {
   //       CTableView *obj=NULL;
   //    // --- We get a panel with table rows
   //       CElementBase *base0=this.GetContainer();
   //       if(base0==NULL)
   //          return NULL;
         
   //    // --- Getting the table row panel container
   //       CElementBase *base1=base0.GetContainer();
   //       if(base1==NULL)
   //          return NULL;
         
   //    // --- Get the table visual representation object
   //       CElementBase *base2=base1.GetContainer();
   //       if(base2!=NULL && base2.Type()==ELEMENT_TYPE_TABLE_VIEW)
   //       {
   //          obj=base2;
   //          return obj;
   //       }
   //       return NULL;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Returns the visual view |
   //    // | column headers |
   //    //+------------------------------------------------------------------+
   //    CTableHeaderView *CTableRowView::GetHeaderView(void)
   //    {
   //       CTableView *table=this.GetTableView();
   //       return(table!=NULL ? table.GetHeader() : NULL);
   //    }
   //    //+------------------------------------------------------------------+
   //    // |CTableRowView::Returns a visual representation of the row headers|
   //    //+------------------------------------------------------------------+
   //    CTableRowsHeaderView *CTableRowView::GetRowsHeaderView(void)
   //    {
   //       CTableView *table=this.GetTableView();
   //       return(table!=NULL ? table.GetRowsHeader() : NULL);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Returns the column title |
   //    //+------------------------------------------------------------------+
   //    CColumnCaptionView *CTableRowView::GetColumnCaption(const uint index)
   //    {
   //       CTableHeaderView *header=this.GetHeaderView();
   //       return(header!=NULL ? header.GetColumnCaption(index) : NULL);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Returns the row title |
   //    //+------------------------------------------------------------------+
   //    CRowCaptionView *CTableRowView::GetRowCaption(const uint index)
   //    {
   //       CTableRowsHeaderView *header=this.GetRowsHeaderView();
   //       return(header!=NULL ? header.GetRowCaption(index) : NULL);
   //    }
   //    //+------------------------------------------------------------------+
   //    // |CTableRowView::Sets the specified column header as selected|
   //    //+------------------------------------------------------------------+
   //    void CTableRowView::SetColumnCaptionSelected(const uint index)
   //    {
   //       CColumnCaptionView *capt=this.GetColumnCaption(index);
   //       if(capt==NULL || capt.State()==ELEMENT_STATE_ACT)
   //          return;
   //       capt.SetState(ELEMENT_STATE_ACT);
   //       capt.GetBackground().FillRectangle(0,capt.Height()-2,capt.Width()-1,capt.Height()-1,ColorToARGB(clrCadetBlue));
   //       capt.GetBackground().Update(false);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Sets the specified row header as selected|
   //    //+------------------------------------------------------------------+
   //    void CTableRowView::SetRowCaptionSelected(const uint index)
   //    {
   //       CRowCaptionView *capt=this.GetRowCaption(index);
   //       if(capt==NULL || capt.State()==ELEMENT_STATE_ACT)
   //          return;
   //       capt.SetState(ELEMENT_STATE_ACT);
   //       capt.GetBackground().FillRectangle(capt.Width()-2,2,capt.Width()-1,capt.Height()-0,ColorToARGB(clrCadetBlue));
   //       capt.GetBackground().Update(false);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Deselects all column headers |
   //    //+------------------------------------------------------------------+
   //    void CTableRowView::SetAllColumnCaptionsUnselected(const int exclude=-1)
   //    {
   //       CTableHeaderView *header=this.GetHeaderView();
   //       if(header==NULL)
   //          return;
   //       int total=header.BoundsTotal();
   //       for(int i=0;i<total;i++)
   //       {
   //          CColumnCaptionView *capt=this.GetColumnCaption(i);
   //          if(capt==NULL || (exclude>-1 && i==exclude))
   //             continue;
   //          if(capt.State()!=ELEMENT_STATE_DEF)
   //          {
   //             capt.SetState(ELEMENT_STATE_DEF);
   //             capt.Draw(false);
   //          }
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Deselects all row headers |
   //    //+------------------------------------------------------------------+
   //    void CTableRowView::SetAllRowCaptionsUnselected(const int exclude=-1)
   //    {
   //       CTableRowsHeaderView *header=this.GetRowsHeaderView();
   //       if(header==NULL)
   //          return;
   //       int total=header.BoundsTotal();
   //       for(int i=0;i<total;i++)
   //       {
   //          CRowCaptionView *capt=this.GetRowCaption(i);
   //          if(capt==NULL || (exclude>-1 && capt.ID()==exclude))
   //             continue;
   //          if(capt.State()!=ELEMENT_STATE_DEF)
   //          {
   //             capt.SetState(ELEMENT_STATE_DEF);
   //             capt.Draw(false);
   //          }
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Hover Handler |
   //    //+------------------------------------------------------------------+
   //    void CTableRowView::OnFocusEvent(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //    // --- If the entire string is processed, call the event handler of the parent class
   //       if(this.m_highlight_mode==ROWS_HIGHLIGHT_MODE_ROW)
   //       {
   //          CCanvasBase::OnFocusEvent(id,lparam,dparam,sparam);
   //          return;
   //       }

   //    // --- Getting the cursor coordinates
   //       int x=int(lparam-this.X());
   //       int y=int(dparam-this.m_wnd_y-this.Y());

   //    // --- In a loop through areas of row cells
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- we get another area
   //          CBound *bound=this.GetBoundAt(i);
   //          if(bound==NULL)
   //             continue;

   //          // --- From the current area we get the element assigned to it
   //          CBaseObj *obj=bound.GetAssignedObj();
   //          CTableCellView *cell=NULL;
            
   //          // --- If the resulting element is not a table cell, move on
   //          if(obj==NULL || obj.Type()!=ELEMENT_TYPE_TABLE_CELL_VIEW)
   //             continue;

   //          // --- This is a table cell. We determine its coordinates in the table (row/column)
   //          cell=obj;
   //          int row=this.ID();
   //          int col=obj.ID();
            
   //          // --- Get the corresponding row and column headers
   //          CColumnCaptionView *col_capt=this.GetColumnCaption(col);
   //          CRowCaptionView    *row_capt=this.GetRowCaption(row);
   //          if(col_capt==NULL || row_capt==NULL)
   //             continue;
            
   //          // --- If the cursor is on the cell area
   //          if(bound.Contains(x,y))
   //          {
   //             // --- Set the column and row headers to be selected,
   //             this.SetColumnCaptionSelected(i);
   //             this.SetRowCaptionSelected(this.ID());
   //             // --- remove the selected header flag from all line headers except the current one
   //             this.SetAllRowCaptionsUnselected(this.ID());
   //          }
   //          // --- If the cursor is outside the cell area
   //          else
   //          {
   //             // --- If the title is selected,
   //             if(col_capt.State()!=ELEMENT_STATE_DEF)
   //             {
   //                // --- deselect it and redraw the object as not selected
   //                col_capt.SetState(ELEMENT_STATE_DEF);
   //                col_capt.Draw(false);
   //             }
   //          }
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Object click handler |
   //    //+------------------------------------------------------------------+
   //    void CTableRowView::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //    // --- If the entire string is processed, call the event handler of the parent class
   //       if(this.m_highlight_mode==ROWS_HIGHLIGHT_MODE_ROW)
   //       {
   //          CCanvasBase::OnPressEvent(id,lparam,dparam,sparam);
   //          return;
   //       }

   //    // --- In a loop through all areas of the string
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- we get another area
   //          CBound *bound=this.GetBoundAt(i);
   //          if(bound==NULL)
   //             continue;

   //          // --- Get the cursor coordinates and
   //          int x=int(lparam-this.X());
   //          int y=int(dparam-this.m_wnd_y-this.Y());
   //          // --- check that the cursor is inside the area
   //          if(bound.Contains(x,y))
   //          {
   //             // --- Getting an attached object (cell) from the area
   //             CBaseObj *obj=bound.GetAssignedObj();
   //             if(obj!=NULL)
   //             {
   //                // --- Write down the cell address in the table (row/column)
   //                int row=this.ID();
   //                int col=obj.ID();
                  
   //                // --- Based on the row and column identifiers, we get pointers to the corresponding headers
   //                CRowCaptionView    *row_capt=this.GetRowCaption(row);
   //                CColumnCaptionView *col_capt=this.GetColumnCaption(col);
   //                if(row_capt==NULL || col_capt==NULL)
   //                   return;
                  
   //                // --- Create a text value for a custom event from the string name and header texts
   //                string sprm=obj.Name()+";"+row_capt.Text()+";"+col_capt.Text();
   //                // --- Send a custom object click event with row and column coordinates and text
   //                ::EventChartCustom(this.m_chart_id,CHARTEVENT_OBJECT_CLICK,row,col,sprm);
   //             }
   //          }
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Saving to file |
   //    //+------------------------------------------------------------------+
   //    bool CTableRowView::Save(const int file_handle)
   //    {
   //    // --- Save the data of the parent object
   //       if(!CPanel::Save(file_handle))
   //          return false;

   //    // --- Save the list of cells
   //       if(!this.m_list_cells.Save(file_handle))
   //          return false;
   //    // --- Save the line number
   //       if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
   //          return false;
   //    // --- Save the backlight mode
   //       if(::FileWriteInteger(file_handle,this.m_highlight_mode,INT_VALUE)!=INT_VALUE)
   //          return false;
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowView::Loading from file |
   //    //+------------------------------------------------------------------+
   //    bool CTableRowView::Load(const int file_handle)
   //    {
   //    // --- Loading the data of the parent object
   //       if(!CPanel::Load(file_handle))
   //          return false;
         
   //    // --- Loading a list of cells
   //       if(!this.m_list_cells.Load(file_handle))
   //          return false;
   //    // --- Load the line number
   //       this.m_index=(int)::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Loading backlight mode
   //       this.m_highlight_mode=(ENUM_ROWS_HIGHLIGHT_MODE)::FileReadInteger(file_handle,INT_VALUE);
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CTABLEROWVIEW_IMPLEMENTATION
#endif // MOVE_TO_TABLEROWVIEW_MQH

#ifndef MOVE_TO_CAPTIONVIEW_MQH
#define MOVE_TO_CAPTIONVIEW_MQH
      // //+------------------------------------------------------------------+
   // // | Abstract header visual class |
   // //+------------------------------------------------------------------+
   // class CCaptionView : public CButton
   // {
   //    protected:
   //       CBound           *m_bound_node;                                   // Pointer to title area
   //       int               m_index;                                        // Index in a list of strings
         
   //    public:
   //    // --- Sets the ID
   //       virtual void      SetID(const int id)                                { this.m_id=id;                              }
   //    // --- (1) Sets, (2) returns the row index
   //       void              SetIndex(const int index)                          { this.m_index=index;                        }
   //       int               Index(void)                                  const { return this.m_index;                       }

   //    // --- (1) Assigns, (2) returns the title area to which the object is assigned
   //       void              AssignBoundNode(CBound *bound)                     { this.m_bound_node=bound;                   }
   //       CBound           *GetBoundNode(void)                                 { return this.m_bound_node;                  }

   //    // --- Draws (1) appearance, (2) sort direction arrow
   //       virtual void      Draw(const bool chart_redraw);

   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0)const { return CButton::Compare(node,mode);        }
   //       virtual bool      Save(const int file_handle);
   //       virtual bool      Load(const int file_handle);
   //       virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_CAPTION_VIEW);   }
      
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(const string text);
   //       virtual void      InitColors(void);
         
   //    // --- Returns a description of the object
   //       virtual string    Description(void);
         
   //    // --- Constructors/destructor
   //                         CCaptionView(void);
   //                         CCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h); 
   //                      ~CCaptionView (void){}
   // };
   // #ifndef CCAPTIONVIEW_IMPLEMENTATION
   // #define CCAPTIONVIEW_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CCaptionView::Default constructor. Builds an object |
   //    // | in the main window of the current chart at coordinates 0,0 |
   //    // | with default sizes |
   //    //+------------------------------------------------------------------+
   //    CCaptionView::CCaptionView(void) : CButton("Caption","Caption",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H), m_index(0)
   //    {
   //    // ---Initialization
   //       this.Init("Caption");
   //       this.SetID(0);
   //       this.SetIndex(-1);
   //       this.SetName("Caption");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCaptionView::The constructor is parametric.                       |
   //    // | Plots an object in the specified window of the specified chart with |
   //    // | specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CCaptionView::CCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h) :
   //       CButton(object_name,text,chart_id,wnd,x,y,w,h), m_index(0)
   //    {
   //    // ---Initialization
   //       this.Init(text);
   //       this.SetID(0);
   //       this.SetIndex(-1);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCaptionView::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CCaptionView::Init(const string text)
   //    {
   //    // --- Default text offsets
   //       this.m_text_x=4;
   //       this.m_text_y=2;
   //    // --- Set the colors of different states
   //       this.InitColors();
   //    // --- Can be resized
   //       this.SetResizable(false);
   //       this.SetMovable(false);
   //       this.SetImageBound(this.ObjectWidth()-14,4,8,11);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCaptionView::Initialize default object colors |
   //    //+------------------------------------------------------------------+
   //    void CCaptionView::InitColors(void)
   //    {
   //    // --- Initialize the background colors for normal and activated states and make it the current background color
   //       this.InitBackColors(C'230,230,230',C'159,213,183',this.GetBackColorControl().NewColor(C'159,213,183',-6,-6,-6),clrSilver);
   //       this.InitBackColorsAct(C'230,230,230',C'159,213,183',this.GetBackColorControl().NewColor(C'159,213,183',-6,-6,-6),clrSilver);
   //       this.BackColorToDefault();
         
   //    // --- Initialize the foreground colors for normal and activated states and make it the current text color
   //       this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.ForeColorToDefault();
         
   //    // --- Initialize the border colors for the normal and activated states and make it the current border color
   //       this.InitBorderColors(clrLightGray,clrLightGray,clrLightGray,clrLightGray);
   //       this.InitBorderColorsAct(clrLightGray,clrLightGray,clrLightGray,clrLightGray);
   //       this.BorderColorToDefault();
         
   //    // --- Initialize the border color and foreground color for the locked element
   //       this.InitBorderColorBlocked(clrNULL);
   //       this.InitForeColorBlocked(clrSilver);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCaptionView::Draws the appearance |
   //    //+------------------------------------------------------------------+
   //    void CCaptionView::Draw(const bool chart_redraw)
   //    {
   //    // --- If the object is outside its container, we leave
   //       if(this.IsOutOfContainer())
   //          return;

   //    // --- Fill the object with the background color, draw a light vertical line on the left, and a dark one on the right
   //       this.Fill(this.BackColor(),false);
   //       color clr_dark =this.BorderColor();                                                       // "Dark color"
   //       color clr_light=this.GetBackColorControl().NewColor(this.BorderColor(), 100, 100, 100);   // "Light color"
   //       this.m_background.Line(this.AdjX(0),this.AdjY(0),this.AdjX(0),this.AdjY(this.Height()-1),::ColorToARGB(clr_light,this.AlphaBG()));                          // Line on the left
   //       this.m_background.Line(this.AdjX(this.Width()-1),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(clr_dark,this.AlphaBG())); // Line on the right
   //    // --- updating the background canvas
   //       this.m_background.Update(false);
         
   //    // --- Output title text
   //       CLabel::Draw(false);
            
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCaptionView::Returns the object description |
   //    //+------------------------------------------------------------------+
   //    string CCaptionView::Description(void)
   //    {
   //       string nm=this.Name();
   //       string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   //       return ::StringFormat("%s%s ID %d, X %d, Y %d, W %d, H %d",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.ID(),this.X(),this.Y(),this.Width(),this.Height());
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCaptionView::Save to file |
   //    //+------------------------------------------------------------------+
   //    bool CCaptionView::Save(const int file_handle)
   //    {
   //    // --- Save the data of the parent object
   //       if(!CButton::Save(file_handle))
   //          return false;
      
   //    // --- Save the header number
   //       if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
   //          return false;
            
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CCaptionView::Loading from file |
   //    //+------------------------------------------------------------------+
   //    bool CCaptionView::Load(const int file_handle)
   //    {
   //    // --- Loading the data of the parent object
   //       if(!CButton::Load(file_handle))
   //          return false;
            
   //    // --- Loading the header number
   //       this.m_index=::FileReadInteger(file_handle,INT_VALUE);
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CCAPTIONVIEW_IMPLEMENTATION
#endif // MOVE_TO_CAPTIONVIEW_MQH   

#ifndef MOVE_TO_COLUMNCAPTIONVIEW_MQH
#define MOVE_TO_COLUMNCAPTIONVIEW_MQH
   // //+------------------------------------------------------------------+
   // // | Table column header visual representation class |
   // //+------------------------------------------------------------------+
   // class CColumnCaptionView : public CCaptionView
   // {
   //    protected:
   //       CColumnCaption   *m_column_caption_model;                         // Pointer to column header model
   //       ENUM_TABLE_SORT_MODE m_sort_mode;                                 // Table column sort mode
   //       bool              m_sortable;                                     // Sorting control flag
         
   //    // --- Adds tooltip objects with arrows to the list
   //       virtual bool      AddHintsArrowed(void);
   //    // --- Displays resizing cursor
   //       virtual bool      ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y);
         
   //    public:
   //    // --- (1) Assigns, (2) returns the column header model
   //       bool              ColumnCaptionModelAssign(CColumnCaption *caption_model);
   //       CColumnCaption   *ColumnCaptionModel(void)                           { return this.m_column_caption_model;        }

   //    // --- Prints the assigned column header model in the log
   //       void              ColumnCaptionModelPrint(void);

   //    // --- (1) Sets, (2) returns the sortable flag
   //       void              SetSortableFlag(const bool flag)
   //                         {
   //                            this.m_sortable=flag;
   //                            this.SetSortMode(flag ? TABLE_SORT_MODE_ASC : TABLE_SORT_MODE_NONE);
   //                         }
   //       bool              IsSortabe(void)                              const { return this.m_sortable;                    }

   //    // --- (1) Sets, (2) returns the sort mode
   //       void              SetSortMode(const ENUM_TABLE_SORT_MODE mode)       { this.m_sort_mode=mode;                     }
   //       ENUM_TABLE_SORT_MODE SortMode(void)                            const { return this.m_sort_mode;                   }
         
   //    // --- Sets the opposite direction of sorting
   //       void              SetSortModeReverse(void);
         
   //    // --- Draws (1) appearance, (2) sort direction arrow
   //       virtual void      Draw(const bool chart_redraw);
   //    protected:
   //       void              DrawSortModeArrow(void);
   //    public:  
   //    // --- Right side element resizing handler
   //       virtual bool      ResizeZoneRightHandler(const int x, const int y);
         
   //    // --- Handlers for resizing an element by sides and corners
   //       virtual bool      ResizeZoneLeftHandler(const int x, const int y)       { return false;                           }
   //       virtual bool      ResizeZoneTopHandler(const int x, const int y)        { return false;                           }
   //       virtual bool      ResizeZoneBottomHandler(const int x, const int y)     { return false;                           }
   //       virtual bool      ResizeZoneLeftTopHandler(const int x, const int y)    { return false;                           }
   //       virtual bool      ResizeZoneRightTopHandler(const int x, const int y)   { return false;                           }
   //       virtual bool      ResizeZoneLeftBottomHandler(const int x, const int y) { return false;                           }
   //       virtual bool      ResizeZoneRightBottomHandler(const int x, const int y){ return false;                           }
         
   //    // --- Changes the width of an object
   //       virtual bool      ResizeW(const int w);
         
   //    // --- Event handler for mouse button clicks (Press)
   //       virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);
         
   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0)const { return CButton::Compare(node,mode);        }
   //       virtual bool      Save(const int file_handle);
   //       virtual bool      Load(const int file_handle);
   //       virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW);}
      
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(const string text);
   //       //virtual void      InitColors(void);
         
   //    // --- Returns a description of the object
   //       virtual string    Description(void);
         
   //    // --- Constructors/destructor
   //                         CColumnCaptionView(void);
   //                         CColumnCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h); 
   //                      ~CColumnCaptionView (void){}
   // };
   // #ifndef CCOLUMNCAPTIONVIEW_IMPLEMENTATION
   // #define CCOLUMNCAPTIONVIEW_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Default constructor. Builds an object |
   //    // | in the main window of the current chart at coordinates 0,0 |
   //    // | with default sizes |
   //    //+------------------------------------------------------------------+
   //    CColumnCaptionView::CColumnCaptionView(void) : CCaptionView("ColumnCaption","Caption",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H),m_sort_mode(TABLE_SORT_MODE_NONE),m_sortable(true)
   //    {
   //    // ---Initialization
   //       this.Init("Caption");
   //       this.SetID(0);
   //       this.SetIndex(-1);
   //       this.SetName("ColumnCaption");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::The constructor is parametric.                 |
   //    // | Plots an object in the specified window of the specified chart with |
   //    // | specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CColumnCaptionView::CColumnCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h) :
   //       CCaptionView(object_name,text,chart_id,wnd,x,y,w,h),m_sort_mode(TABLE_SORT_MODE_NONE),m_sortable(true)
   //    {
   //    // ---Initialization
   //       this.Init(text);
   //       this.SetID(0);
   //       this.SetIndex(-1);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CColumnCaptionView::Init(const string text)
   //    {
   //    // --- Initializing the parent object
   //       CCaptionView::Init(text);
   //    // --- Can be resized
   //       this.SetResizable(true);
   //       this.SetMovable(false);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Draws the appearance |
   //    //+------------------------------------------------------------------+
   //    void CColumnCaptionView::Draw(const bool chart_redraw)
   //    {
   //    // --- If the object is outside its container, we leave
   //       if(this.IsOutOfContainer())
   //          return;

   //    // --- Fill the object with the background color, draw a light vertical line on the left, and a dark one on the right
   //       this.Fill(this.BackColor(),false);
   //       color clr_dark =this.BorderColor();                                                       // "Dark color"
   //       color clr_light=this.GetBackColorControl().NewColor(this.BorderColor(), 20, 20, 20);      // "Light color"
   //       this.m_background.Line(this.AdjX(0),this.AdjY(0),this.AdjX(0),this.AdjY(this.Height()-1),::ColorToARGB(clr_light,this.AlphaBG()));                          // Line on the left
   //       this.m_background.Line(this.AdjX(this.Width()-1),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(clr_dark,this.AlphaBG())); // Line on the right

   //    // --- Output title text
   //       CLabel::Draw(false);
            
   //    // --- Draw sorting direction arrows
   //       this.DrawSortModeArrow();

   //    // --- updating the background canvas
   //       this.m_background.Update(false);
         
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Draws a sort direction arrow |
   //    //+------------------------------------------------------------------+
   //    void CColumnCaptionView::DrawSortModeArrow(void)
   //    {
   //    // --- Set the arrow color for the normal and blocked states of the object
   //       color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
   //       switch(this.m_sort_mode)
   //       {
   //          // --- Sort in ascending order
   //          case TABLE_SORT_MODE_ASC   :  
   //             // --- Clear the drawing area and draw a down arrow
   //             this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //             this.m_painter.ArrowDown(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
   //             break;
   //          // --- Sort in descending order
   //          case TABLE_SORT_MODE_DESC  :  
   //             // --- Clear the drawing area and draw an up arrow
   //             this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //             this.m_painter.ArrowUp(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
   //             break;
   //          // --- No sorting
   //          default : 
   //             // --- Clear the drawing area
   //             this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //             break;
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Expands sort direction |
   //    //+------------------------------------------------------------------+
   //    void CColumnCaptionView::SetSortModeReverse(void)
   //    {
   //       switch(this.m_sort_mode)
   //       {
   //          case TABLE_SORT_MODE_ASC   :  this.m_sort_mode=TABLE_SORT_MODE_DESC; break;
   //          case TABLE_SORT_MODE_DESC  :  this.m_sort_mode=TABLE_SORT_MODE_ASC;  break;
   //          default                    :  break;
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Returns the description of the object |
   //    //+------------------------------------------------------------------+
   //    string CColumnCaptionView::Description(void)
   //    {
   //       string nm=this.Name();
   //       string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   //       string sort=(this.SortMode()==TABLE_SORT_MODE_ASC ? "ascending" : this.SortMode()==TABLE_SORT_MODE_DESC ? "descending" : "none");
   //       return ::StringFormat("%s%s ID %d, X %d, Y %d, W %d, H %d, sort %s",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.ID(),this.X(),this.Y(),this.Width(),this.Height(),sort);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Assigns a column header model |
   //    //+------------------------------------------------------------------+
   //    bool CColumnCaptionView::ColumnCaptionModelAssign(CColumnCaption *caption_model)
   //    {
   //    // --- If an invalid column header model object is passed, we report this and return false
   //       if(caption_model==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
   //          return false;
   //       }
   //    // --- Save the column header model
   //       this.m_column_caption_model=caption_model;
   //    // --- Set the dimensions of the drawing area of ​​the visual representation of the column header
   //       this.m_painter.SetBound(0,0,this.Width(),this.Height());
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Prints in journal |
   //    // | assigned column header model |
   //    //+------------------------------------------------------------------+
   //    void CColumnCaptionView::ColumnCaptionModelPrint(void)
   //    {
   //       if(this.m_column_caption_model!=NULL)
   //          this.m_column_caption_model.Print();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Adds to list |
   //    // | tooltip objects with arrows |
   //    //+------------------------------------------------------------------+
   //    bool CColumnCaptionView::AddHintsArrowed(void)
   //    {
   //    // --- Create a horizontal offset arrow tooltip
   //       CVisualHint *hint=this.CreateAndAddNewHint(HINT_TYPE_ARROW_SHIFT_HORZ,DEF_HINT_NAME_SHIFT_HORZ,18,18);
   //       if(hint==NULL)
   //          return false;

   //    // --- Set the size of the tooltip image area
   //       hint.SetImageBound(0,0,hint.Width(),hint.Height());
         
   //    // --- hide the tooltip and draw the appearance
   //       hint.Hide(false);
   //       hint.Draw(false);
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Displays resizing cursor |
   //    //+------------------------------------------------------------------+
   //    bool CColumnCaptionView::ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y)
   //    {
   //       CVisualHint *hint=NULL;          // Pointer to tooltip
   //       int hint_shift_x=0;              // Tooltip X offset
   //       int hint_shift_y=0;              // Tooltip Y Offset
         
   //    // --- Depending on the location of the cursor on the borders of the element
   //    // --- indicate the offset of the tooltip relative to the cursor coordinates,
   //    // --- display the required hint on the chart and get a pointer to this object
   //       if(edge!=CURSOR_REGION_RIGHT)
   //          return false;
         
   //       hint_shift_x=-8;
   //       hint_shift_y=-12;
   //       this.ShowHintArrowed(HINT_TYPE_ARROW_SHIFT_HORZ,x+hint_shift_x,y+hint_shift_y);
   //       hint=this.GetHint(DEF_HINT_NAME_SHIFT_HORZ);

   //    // --- Return the result of adjusting the position of the tooltip relative to the cursor
   //       return(hint!=NULL ? hint.Move(x+hint_shift_x,y+hint_shift_y) : false);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Right resizing handler|
   //    //+------------------------------------------------------------------+
   //    bool CColumnCaptionView::ResizeZoneRightHandler(const int x,const int y)
   //    {
   //    // --- Calculate and set the new width of the element
   //       int width=::fmax(x-this.X()+1,DEF_TABLE_COLUMN_MIN_W);
   //       if(!this.ResizeW(width))
   //          return false;
   //    // --- Get a pointer to a hint
   //       CVisualHint *hint=this.GetHint(DEF_HINT_NAME_SHIFT_HORZ);
   //       if(hint==NULL)
   //          return false;
   //    // --- Shift the tooltip by the specified amounts relative to the cursor
   //       int shift_x=-8;
   //       int shift_y=-12;
         
   //       CTableHeaderView *header=this.m_container;
   //       if(header==NULL)
   //          return false;
         
   //       bool res=header.RecalculateBounds(this.GetBoundNode(),this.Width());
   //       res &=hint.Move(x+shift_x,y+shift_y);
   //       if(res)
   //          ::ChartRedraw(this.m_chart_id);
   //       return res;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Changes the width of an object |
   //    //+------------------------------------------------------------------+
   //    bool CColumnCaptionView::ResizeW(const int w)
   //    {
   //       if(!CCanvasBase::ResizeW(w))
   //          return false;
   //    // --- Clear the drawing area in the previous place
   //       this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
   //    // --- Set up a new drawing area
   //       this.SetImageBound(this.Width()-14,4,8,11);
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Mouse click event handler |
   //    //+------------------------------------------------------------------+
   //    void CColumnCaptionView::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //    // --- If the mouse button is released in the drag area of ​​the right edge of the element, we leave
   //       if(this.ResizeRegion()==CURSOR_REGION_RIGHT)
   //          return;
   //    // --- Change the sorting direction arrow to the opposite one and call the mouse click handler
   //       if(this.m_sortable)
   //          this.SetSortModeReverse();
   //       CCanvasBase::OnPressEvent(id,lparam,dparam,sparam);
   //       ::EventChartCustom(this.m_chart_id,CHARTEVENT_OBJECT_CLICK,this.ID(),-(10000+this.SortMode()),this.NameFG());
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Saving to file |
   //    //+------------------------------------------------------------------+
   //    bool CColumnCaptionView::Save(const int file_handle)
   //    {
   //    // --- Save the data of the parent object
   //       if(!CButton::Save(file_handle))
   //          return false;
      
   //    // --- Save the header number
   //       if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
   //          return false;
   //    // --- Save the sorting direction
   //       if(::FileWriteInteger(file_handle,this.m_sort_mode,INT_VALUE)!=INT_VALUE)
   //          return false;
   //    // --- Save the sorting control flag
   //       if(::FileWriteInteger(file_handle,this.m_sortable,INT_VALUE)!=INT_VALUE)
   //          return false;
            
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CColumnCaptionView::Loading from file |
   //    //+------------------------------------------------------------------+
   //    bool CColumnCaptionView::Load(const int file_handle)
   //    {
   //    // --- Loading the data of the parent object
   //       if(!CButton::Load(file_handle))
   //          return false;
            
   //    // --- Loading the header number
   //       this.m_index=::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Loading the sorting direction
   //       this.m_sort_mode=(ENUM_TABLE_SORT_MODE)::FileReadInteger(file_handle,INT_VALUE);
   //    // --- Load the sorting control flag
   //       this.m_sortable=(bool)::FileReadInteger(file_handle,INT_VALUE);
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CCOLUMNCAPTIONVIEW_IMPLEMENTATION
#endif // MOVE_TO_COLUMNCAPTIONVIEW_MQH

#ifndef MOVE_TO_ROWCAPTIONVIEW_MQH
#define MOVE_TO_ROWCAPTIONVIEW_MQH
         // //+------------------------------------------------------------------+
   // // | Class for visual representation of table row header |
   // //+------------------------------------------------------------------+
   // class CRowCaptionView : public CCaptionView
   // {
   //    protected:
         
   //    public:
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);

   //    public:  
   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0)const { return CButton::Compare(node,mode);        }
   //       virtual bool      Save(const int file_handle);
   //       virtual bool      Load(const int file_handle);
   //       virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW);}
      
   //    // --- Initializing a class object
   //       void              Init(const string text);
         
   //    // --- Returns a description of the object
   //       virtual string    Description(void);
         
   //    // --- Constructors/destructor
   //                         CRowCaptionView(void);
   //                         CRowCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h); 
   //                      ~CRowCaptionView (void){}
   // };
   // #ifndef CROWCAPTIONVIEW_IMPLEMENTATION
   // #define CROWCAPTIONVIEW_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CRowCaptionView::Default constructor. Builds an object |
   //    // | in the main window of the current chart at coordinates 0,0 |
   //    // | with default sizes |
   //    //+------------------------------------------------------------------+
   //    CRowCaptionView::CRowCaptionView(void) : CCaptionView("RowCaption","Caption",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H)
   //    {
   //    // ---Initialization
   //       this.Init("Caption");
   //       this.SetID(0);
   //       this.SetIndex(-1);
   //       this.SetName("RowCaption");
   //       this.SetTextShiftH(8);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CRowCaptionView::Parametric constructor.                    |
   //    // | Plots an object in the specified window of the specified chart with |
   //    // | specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CRowCaptionView::CRowCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h) :
   //       CCaptionView(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //    // ---Initialization
   //       this.Init(text);
   //       this.SetID(0);
   //       this.SetIndex(-1);
   //       this.SetTextShiftH(8);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CRowCaptionView::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CRowCaptionView::Init(const string text)
   //    {
   //    // --- Initializing the parent object
   //       CCaptionView::Init(text);
   //    // --- Dimensions are not changeable
   //       this.SetResizable(false);
   //       this.SetMovable(false);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CRowCaptionView::Draws the appearance |
   //    //+------------------------------------------------------------------+
   //    void CRowCaptionView::Draw(const bool chart_redraw)
   //    {
   //    // --- If the object is outside its container, we leave
   //       if(this.IsOutOfContainer())
   //          return;

   //    // --- Fill the object with the background color, draw a light vertical line on the left, and a dark one on the right
   //       this.Fill(this.BackColor(),false);
   //       this.m_background.Rectangle(this.AdjX(2),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //    // --- updating the background canvas
   //       this.m_background.Update(false);
         
   //    // --- Output title text
   //       CLabel::Draw(false);
            
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CRowCaptionView::Returns the description of the object |
   //    //+------------------------------------------------------------------+
   //    string CRowCaptionView::Description(void)
   //    {
   //       string nm=this.Name();
   //       string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   //       return ::StringFormat("%s%s ID %d, X %d, Y %d, W %d, H %d",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.ID(),this.X(),this.Y(),this.Width(),this.Height());
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CRowCaptionView::Save to file |
   //    //+------------------------------------------------------------------+
   //    bool CRowCaptionView::Save(const int file_handle)
   //    {
   //    // --- Save the data of the parent object
   //       if(!CButton::Save(file_handle))
   //          return false;
      
   //    // --- Save the header number
   //       if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
   //          return false;
            
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CRowCaptionView::Loading from file |
   //    //+------------------------------------------------------------------+
   //    bool CRowCaptionView::Load(const int file_handle)
   //    {
   //    // --- Loading the data of the parent object
   //       if(!CButton::Load(file_handle))
   //          return false;
            
   //    // --- Loading the header number
   //       this.m_index=::FileReadInteger(file_handle,INT_VALUE);
         
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CROWCAPTIONVIEW_IMPLEMENTATION
#endif // MOVE_TO_ROWCAPTIONVIEW_MQH

#ifndef MOVE_TO_TABLEHEADERVIEW_MQH
#define MOVE_TO_TABLEHEADERVIEW_MQH
      // //+------------------------------------------------------------------+
   // // | Table header visual class |
   // //+------------------------------------------------------------------+
   // class CTableHeaderView : public CPanel
   // {
   //    protected:
   //       CColumnCaptionView m_temp_caption;                                // Temporary column header object to search
   //       CTableHeader     *m_table_header_model;                           // Pointer to table header model
   //       bool              m_sortable;                                     // Sorting control flag

   //    // --- Creates and adds a new column header view object to the list
   //       CColumnCaptionView *InsertNewColumnCaptionView(const string text, const int x, const int y, const int w, const int h);
         
   //    public:
   //    // --- (1) Sets, (2) returns the table header model
   //       bool              TableHeaderModelAssign(CTableHeader *header_model);
   //       CTableHeader     *GetTableHeaderModel(void)                          { return this.m_table_header_model;       }

   //    // --- Recalculates header areas
   //       bool              RecalculateBounds(CBound *bound,int new_width);

   //    // --- Prints the assigned table header model in the log
   //       void              TableHeaderModelPrint(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS);
         
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);

   //    // --- (1) Sets, (2) returns the sortable flag
   //       void              SetSortableFlag(const bool flag);
   //       bool              IsSortabe(void)                              const { return this.m_sortable;                 }

   //    // --- Sets the column header sorting flag
   //       void              SetSortedColumnCaption(const uint index);

   //    // --- Gets the column header (1) by index, (2) with sort flag
   //       CColumnCaptionView *GetColumnCaption(const uint index);
   //       CColumnCaptionView *GetSortedColumnCaption(void);
   //    // --- Returns the index of the column header with the sort flag
   //       int               IndexSortedColumnCaption(void);
         
   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0)const { return CPanel::Compare(node,mode);      }
   //       virtual bool      Save(const int file_handle)                        { return CPanel::Save(file_handle);       }
   //       virtual bool      Load(const int file_handle)                        { return CPanel::Load(file_handle);       }
   //       virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_HEADER_VIEW); }
         
   //    // --- Handler for a custom element event when an object area is clicked
   //       virtual void      MousePressHandler(const int id, const long lparam, const double dparam, const string sparam);
      
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(void);
   //       virtual void      InitColors(void);

   //    // --- Constructors/destructor
   //                         CTableHeaderView(void);
   //                         CTableHeaderView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CTableHeaderView (void){}
   // };
   // #ifndef CTABLEHEADERVIEW_IMPLEMENTATION
   // #define CTABLEHEADERVIEW_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Default constructor. Builds an object in |
   //    // | main window of the current chart in coordinates 0,0 |
   //    // | with default sizes |
   //    //+------------------------------------------------------------------+
   //    CTableHeaderView::CTableHeaderView(void) : CPanel("TableHeader","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H),m_sortable(true)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Parametric constructor. Builds an object in |
   //    // | the specified window of the specified chart with the specified text, |
   //    // | coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CTableHeaderView::CTableHeaderView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CPanel(object_name,text,chart_id,wnd,x,y,w,h),m_sortable(true)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CTableHeaderView::Init(void)
   //    {
   //    // --- Initializing the parent object
   //       CPanel::Init();
   //    // --- Background color - opaque
   //       this.SetAlphaBG(255);
   //    // --- Frame width
   //       this.SetBorderWidth(1);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Initializing default object colors |
   //    //+------------------------------------------------------------------+
   //    void CTableHeaderView::InitColors(void)
   //    {
   //    // --- Initialize the background colors for normal and activated states and make it the current background color
   //       this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //       this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   //       this.BackColorToDefault();
         
   //    // --- Initialize the foreground colors for normal and activated states and make it the current text color
   //       this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.ForeColorToDefault();
         
   //    // --- Initialize the border colors for the normal and activated states and make it the current border color
   //       this.InitBorderColors(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
   //       this.InitBorderColorsAct(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
   //       this.BorderColorToDefault();
         
   //    // --- Initialize the border color and foreground color for the locked element
   //       this.InitBorderColorBlocked(clrSilver);
   //       this.InitForeColorBlocked(clrSilver);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Creates and adds to the list |
   //    // | new column header view object |
   //    //+------------------------------------------------------------------+
   //    CColumnCaptionView *CTableHeaderView::InsertNewColumnCaptionView(const string text,const int x,const int y,const int w,const int h)
   //    {
   //    // --- Create an object name and return the result of creating a new column header
   //       string user_name="ColumnCaptionView"+(string)this.m_list_elm.Total();
   //       CColumnCaptionView *caption_view=this.InsertNewElement(ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW,text,user_name,x,y,w,h);
   //       return(caption_view!=NULL ? caption_view : NULL);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Sets the header model |
   //    //+------------------------------------------------------------------+
   //    bool CTableHeaderView::TableHeaderModelAssign(CTableHeader *header_model)
   //    {
   //    // --- If an empty object is passed, we report this and return false
   //       if(header_model==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
   //          return false;
   //       }
   //    // --- If the passed header model does not have a single column header, report this and return false
   //       int total=(int)header_model.ColumnsTotal();
   //       if(total==0)
   //       {
   //          ::PrintFormat("%s: Error. Header model does not contain any columns",__FUNCTION__);
   //          return false;
   //       }
   //    // --- We save a pointer to the passed table header model and calculate the width of each column header
   //       this.m_table_header_model=header_model;
   //       int caption_w=(int)::fmax(::round((double)this.Width()/(double)total),DEF_TABLE_COLUMN_MIN_W);

   //    // --- Loop through the number of column headers in the table header model
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- we get the model of the next column header,
   //          CColumnCaption *caption_model=this.m_table_header_model.GetColumnCaption(i);
   //          if(caption_model==NULL)
   //             return false;
   //          // --- calculate the coordinate and create a name for the column header area
   //          int x=caption_w*i;
   //          string name="CaptionBound"+(string)i;
   //          // --- Create a new column header area
   //          CBound *caption_bound=this.InsertNewBound(name,x,0,caption_w,this.Height());
   //          if(caption_bound==NULL)
   //             return false;
   //          caption_bound.SetID(i);
   //          // --- Create a new object for visual representation of the column header
   //          CColumnCaptionView *caption_view=this.InsertNewColumnCaptionView(caption_model.Value(),x,0,caption_w,this.Height());
   //          if(caption_view==NULL)
   //             return false;
   //          caption_view.SetIndex(i);
            
   //          // --- Assign the corresponding object for visual representation of the column header to the current area of ​​the column header
   //          caption_bound.AssignObject(caption_view);
   //          caption_view.AssignBoundNode(caption_bound);
            
   //          // --- For the very first heading, set the sort flag in ascending order
   //          if(i==0 && caption_view.IsSortabe())
   //             caption_view.SetSortMode(TABLE_SORT_MODE_ASC);
   //       }
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Recalculates header areas |
   //    //+------------------------------------------------------------------+
   //    bool CTableHeaderView::RecalculateBounds(CBound *bound,int new_width)
   //    {
   //    // --- If an empty area object is passed or its width has not changed, return false
   //       if(bound==NULL || bound.Width()==new_width)
   //          return false;
            
   //    // --- Get the index of the area in the list
   //       int index=this.m_list_bounds.IndexOf(bound);
   //       if(index==WRONG_VALUE)
   //          return false;

   //    // --- Calculate the offset and, if it is not there, return false
   //       int delta=new_width-bound.Width();
   //       if(delta==0)
   //          return false;

   //    // --- Change the width of the current area and the object assigned to the area
   //       bound.ResizeW(new_width);
   //       CElementBase *assigned_obj=bound.GetAssignedObj();
   //       if(assigned_obj!=NULL)
   //          assigned_obj.ResizeW(new_width);

   //    // --- Get the next area after the current one
   //       CBound *next_bound=this.m_list_bounds.GetNextNode();
   //    // --- Recalculate X coordinates for all subsequent areas
   //       while(!::IsStopped() && next_bound!=NULL)
   //       {
   //          // --- Shift the area by delta value
   //          int new_x = next_bound.X()+delta;
   //          int prev_width=next_bound.Width();
   //          next_bound.SetX(new_x);
   //          next_bound.Resize(prev_width,next_bound.Height());
            
   //          // --- If there is an assigned object in the area, update its position
   //          CElementBase *assigned_obj=next_bound.GetAssignedObj();
   //          if(assigned_obj!=NULL)
   //          {
   //             assigned_obj.Move(assigned_obj.X()+delta,assigned_obj.Y());

   //             // --- This code block is part of an effort to troubleshoot artifacts when dragging headers
   //             CCanvasBase *base_obj=assigned_obj.GetContainer();
   //             if(base_obj!=NULL)
   //             {
   //                if(assigned_obj.X()>base_obj.ContainerLimitRight())
   //                   assigned_obj.Hide(false);
   //                else
   //                   assigned_obj.Show(false);
   //             }
   //          }
   //          // --- Moving on to the next area
   //          next_bound=this.m_list_bounds.GetNextNode();
   //       }
         
   //    // --- Calculate the new width of the table header based on the width of the column headers
   //       int header_width=0;
   //       for(int i=0;i<this.m_list_bounds.Total();i++)
   //       {
   //          CBound *bound=this.GetBoundAt(i);
   //          if(bound!=NULL)
   //             header_width+=bound.Width();
   //       }

   //    // --- If the calculated width of the table header differs from the current one, change the width
   //       if(header_width!=this.Width())
   //       {
   //          if(!this.ResizeW(header_width))
   //             return false;
   //       }

   //    // --- Get a pointer to the table object (View)
   //       CPanel *obj=this.GetContainer();
   //       if(obj==NULL)
   //          return false;
   //       CTableView *table_view=obj.GetContainer();
   //       if(table_view==NULL)
   //          return false;

   //    // --- From the table object we get a pointer to the panel with table rows
   //       CPanel *table_area=table_view.GetTableArea();
   //       if(table_area==NULL)
   //          return false;
         
   //    // --- Change the size of the table row panel to the overall size of the column headers
   //       if(!table_area.ResizeW(header_width))
   //          return false;
         
   //    // --- Get a list of table rows and loop through all the rows
   //       CListElm *list=table_area.GetListAttachedElements();
   //       int total=list.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- We get the next row of the table
   //          CTableRowView *row=table_area.GetAttachedElementAt(i);
   //          if(row!=NULL)
   //          {
   //             // --- Change the row size to fit the panel size and recalculate the cell areas
   //             row.ResizeW(table_area.Width());
   //             row.RecalculateBounds(&this.m_list_bounds);
   //          }
   //       }
   //    // --- Redraw all table rows
   //       table_area.Draw(false);
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Draws the appearance |
   //    //+------------------------------------------------------------------+
   //    void CTableHeaderView::Draw(const bool chart_redraw)
   //    {
   //    // --- Fill the object with the background color, draw a line line and update the background canvas
   //       this.Fill(this.BackColor(),false);
   //       this.m_background.Line(this.AdjX(0),this.AdjY(this.Height()-1),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //       this.m_background.Update(false);
         
   //    // --- Draw column headers
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- Getting the area of ​​the next column header
   //          CBound *cell_bound=this.GetBoundAt(i);
   //          if(cell_bound==NULL)
   //             continue;
            
   //          // --- From the column header area we get the attached column header object
   //          CColumnCaptionView *caption_view=cell_bound.GetAssignedObj();
   //          // --- Draw a visual representation of the column header
   //          if(caption_view!=NULL)
   //          {
   //             caption_view.Draw(false);
   //          }
   //       }
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Sets the sortable flag |
   //    //+------------------------------------------------------------------+
   //    void CTableHeaderView::SetSortableFlag(const bool flag)
   //    {
   //    // --- Write down the flag value
   //       this.m_sortable=flag;
         
   //    // --- In a loop by the number of column headers
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- get the next column header object and set the sorting flag for it
   //          CColumnCaptionView *caption_view=this.GetColumnCaption(i);
   //          if(caption_view!=NULL)
   //             caption_view.SetSortableFlag(flag);
   //       }
   //    // --- If the table is being sorted, set the zero column sorted in ascending order
   //       if(this.m_sortable)
   //          this.SetSortedColumnCaption(0);

   //    // --- Redraw the title
   //       this.Draw(true);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Sets the column header sort flag|
   //    //+------------------------------------------------------------------+
   //    void CTableHeaderView::SetSortedColumnCaption(const uint index)
   //    {
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- Getting the next column header object
   //          CColumnCaptionView *caption_view=this.GetColumnCaption(i);
   //          if(caption_view==NULL)
   //             continue;
            
   //          // --- If the loop index is equal to the required index, set the sorting flag in ascending order
   //          if(i==index)
   //          {
   //             caption_view.SetSortMode(TABLE_SORT_MODE_ASC);
   //             caption_view.Draw(false);
   //          }
   //          // --- Otherwise, reset the sorting flag
   //          else
   //          {
   //             caption_view.SetSortMode(TABLE_SORT_MODE_NONE);
   //             caption_view.Draw(false);
   //          }
   //       }
   //    // --- Redraw the title
   //       this.Draw(true);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Gets column header by index |
   //    //+------------------------------------------------------------------+
   //    CColumnCaptionView *CTableHeaderView::GetColumnCaption(const uint index)
   //    {
   //    // --- Get the column header area by index
   //       CBound *capt_bound=this.GetBoundAt(index);
   //       if(capt_bound==NULL)
   //          return NULL;
   //    // --- From the column header area, return a pointer to the attached column header object
   //       return capt_bound.GetAssignedObj();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Gets the column header with the sort flag |
   //    //+------------------------------------------------------------------+
   //    CColumnCaptionView *CTableHeaderView::GetSortedColumnCaption(void)
   //    {
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- We get the area of ​​the next column header and
   //          // --- from it we get the attached column header object
   //          CColumnCaptionView *caption_view=this.GetColumnCaption(i);
            
   //          // --- If an object is received and its sorting flag is set, return a pointer to it
   //          if(caption_view!=NULL && caption_view.SortMode()!=TABLE_SORT_MODE_NONE)
   //             return caption_view;
   //       }
   //       return NULL;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Returns the index of the sorted column |
   //    //+------------------------------------------------------------------+
   //    int CTableHeaderView::IndexSortedColumnCaption(void)
   //    {
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- We get the area of ​​the next column header and
   //          // --- from it we get the attached column header object
   //          CColumnCaptionView *caption_view=this.GetColumnCaption(i);
         
   //          // --- If the object is received and its sorting flag is set, return the area index
   //          if(caption_view!=NULL && caption_view.SortMode()!=TABLE_SORT_MODE_NONE)
   //             return i;
   //       }
   //       return WRONG_VALUE;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Prints to log |
   //    // | designated table header model |
   //    //+------------------------------------------------------------------+
   //    void CTableHeaderView::TableHeaderModelPrint(const bool detail,const bool as_table=false,const int cell_width=CELL_WIDTH_IN_CHARS)
   //    {
   //       if(this.m_table_header_model!=NULL)
   //          this.m_table_header_model.Print(detail,as_table,cell_width);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableHeaderView::Element Custom Event Handler |
   //    // | when clicking on an area of ​​an object |
   //    //+------------------------------------------------------------------+
   //    void CTableHeaderView::MousePressHandler(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //    // --- Get the name of the table header object from sparam
   //       int len=::StringLen(this.NameFG());
   //       string header_str=::StringSubstr(sparam,0,len);
   //    // --- If the extracted name does not match the name of this object - not our event, leave
   //       if(header_str!=this.NameFG())
   //          return;
         
   //    // --- Let's find the index of the column header in sparam
   //       string capt_str=::StringSubstr(sparam,len+1);
   //       string index_str=::StringSubstr(capt_str,6,capt_str.Length()-8);
         
   //    // --- First character before "FG" (last digit of search index)
   //       int pos=(int)capt_str.Length()-3;
   //       int end=pos;
         
   //    // --- We are looking for all the numbers on the left up to the first “non-digit”
   //       while(!::IsStopped() && pos>=0 && capt_str.GetChar(pos)>='0' && capt_str.GetChar(pos)<='9')
   //          pos--;

   //    // --- Start of digits of the searched index
   //       int start=pos+1;
   //    // --- If the index numbers are not found, we leave
   //       if(start>end)
   //          return;

   //    // --- Get index from string
   //       index_str=StringSubstr(capt_str,start,end-start+1);

   //    // --- Write the index of the column header
   //       int index=(int)::StringToInteger(index_str);
         
   //    // --- Get the column header by index
   //       CColumnCaptionView *caption=this.GetColumnCaption(index);
   //       if(caption==NULL)
   //          return;
         
   //    // --- If the title does not have a sorting flag, set the sorting flag in ascending order
   //       if(caption.IsSortabe() && caption.SortMode()==TABLE_SORT_MODE_NONE)
   //       {
   //          this.SetSortedColumnCaption(index);
   //       }
   //    // --- Send a custom event to the chart with the title index in lparam, sort mode in dparam and object name in sparam
   //    // --- Since the standard OBJECT_CLICK event sends cursor coordinates to lparam and dparam, we will pass negative values ​​here
   //       ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_OBJECT_CLICK, -(10000+index), -(10000+caption.SortMode()), this.NameFG());
   //       ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CTABLEHEADERVIEW_IMPLEMENTATION
#endif // MOVE_TO_TABLEHEADERVIEW_MQH

#ifndef MOVE_TO_TABLEROWSHEADERVIEW_MQH
#define MOVE_TO_TABLEROWSHEADERVIEW_MQH
         // //+------------------------------------------------------------------+
   // // | Class for visual representation of table row headers |
   // //+------------------------------------------------------------------+
   // class CTableRowsHeaderView : public CPanel
   //    {
   //    protected:
   //       CRowCaptionView   m_temp_caption;                                 // Temporary row header object for search
   //       string            m_table_row_columns[];                          // Array of table row headers

   //    // --- Creates and adds to the list a new row header view object
   //       CRowCaptionView *InsertNewRowCaptionView(const string text, const int x, const int y, const int w, const int h);
         
   //    public:
   //    // --- (1) Sets an array of table row headers
   //       bool              TableRowCaptionsAssign(string &captions_array[]);

   //    // --- Recalculates header areas
   //       bool              RecalculateBounds(CBound *bound,int new_width);

   //    // --- Prints the assigned table header model in the log
   //       void              TableRowHeaderModelPrint(void)                     { ::ArrayPrint(this.m_table_row_columns);       }
         
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);
         
   //    // --- Gets the row header by index
   //       CRowCaptionView  *GetRowCaption(const uint index);
         
   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0)const { return CPanel::Compare(node,mode);            }
   //       virtual bool      Save(const int file_handle)                        { return CPanel::Save(file_handle);             }
   //       virtual bool      Load(const int file_handle)                        { return CPanel::Load(file_handle);             }
   //       virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW);  }
         
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(void);
   //       virtual void      InitColors(void);

   //    // --- Constructors/destructor
   //                         CTableRowsHeaderView(void);
   //                         CTableRowsHeaderView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CTableRowsHeaderView (void){}
   // };
   // #ifndef CTABLEROWSHEADERVIEW_IMPLEMENTATION
   // #define CTABLEROWSHEADERVIEW_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CTableRowsHeaderView::Default constructor. Builds an object in |
   //    // | main window of the current chart in coordinates 0,0 |
   //    // | with default sizes |
   //    //+------------------------------------------------------------------+
   //    CTableRowsHeaderView::CTableRowsHeaderView(void) : CPanel("TableRowHeader","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowsHeaderView::Parametric constructor. Builds an object |
   //    // | in the specified window of the specified chart with the specified text, |
   //    // | coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CTableRowsHeaderView::CTableRowsHeaderView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CPanel(object_name,text,chart_id,wnd,x,y,w,h)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowsHeaderView::Initializing |
   //    //+------------------------------------------------------------------+
   //    void CTableRowsHeaderView::Init(void)
   //    {
   //    // --- Initializing the parent object
   //       CPanel::Init();
   //    // --- Background color - opaque
   //       this.SetAlphaBG(255);
   //    // --- Frame width
   //       this.SetBorderWidth(1);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowsHeaderView::Initializing default object colors |
   //    //+------------------------------------------------------------------+
   //    void CTableRowsHeaderView::InitColors(void)
   //    {
   //    // --- Initialize the background colors for normal and activated states and make it the current background color
   //       this.InitBackColors(C'230,230,230',C'230,230,230',C'230,230,230',clrWhiteSmoke);
   //       this.InitBackColorsAct(C'230,230,230',C'230,230,230',C'230,230,230',clrWhiteSmoke);
   //       this.BackColorToDefault();
         
   //    // --- Initialize the foreground colors for normal and activated states and make it the current text color
   //       this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   //       this.ForeColorToDefault();
         
   //    // --- Initialize the border colors for the normal and activated states and make it the current border color
   //       this.InitBorderColors(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
   //       this.InitBorderColorsAct(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
   //       this.BorderColorToDefault();
         
   //    // --- Initialize the border color and foreground color for the locked element
   //       this.InitBorderColorBlocked(clrSilver);
   //       this.InitForeColorBlocked(clrSilver);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowsHeaderView::Creates and adds to the list |
   //    // | new row header view object |
   //    //+------------------------------------------------------------------+
   //    CRowCaptionView *CTableRowsHeaderView::InsertNewRowCaptionView(const string text,const int x,const int y,const int w,const int h)
   //    {
   //    // --- Create an object name and return the result of creating a new column header
   //       string user_name="RowCaptionView"+(string)this.m_list_elm.Total();
   //       CRowCaptionView *caption_view=this.InsertNewElement(ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW,text,user_name,x,y,w,h);
   //       return(caption_view!=NULL ? caption_view : NULL);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowsHeaderView::Sets the vertical header |
   //    //+------------------------------------------------------------------+
   //    bool CTableRowsHeaderView::TableRowCaptionsAssign(string &captions_array[])
   //    {
   //    // --- Get a pointer to the table object (View)
   //       CPanel *obj=this.GetContainer();
   //       if(obj==NULL)
   //          return false;
   //       CTableView *table_view=obj.GetContainer();
   //       if(table_view==NULL)
   //          return false;
            
   //    // --- From the table object we get a pointer to the panel with table rows
   //       CPanel *table_area=table_view.GetTableArea();
   //       if(table_area==NULL)
   //          return false;
         
   //    // --- Get a list of table rows
   //       CListElm *list=table_area.GetListAttachedElements();
   //       int total_rows=list.Total();

   //    // --- Save the passed array of table row headers
   //       ::ArrayCopy(this.m_table_row_columns,captions_array);
   //       int total_captions=(int)this.m_table_row_columns.Size();
   //    //---
   //       int total=::fmax(total_rows,total_captions);
   //    // --- We go through the loop through the number of created headers
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- we get the next line
   //          CTableRowView *row=table_area.GetAttachedElementAt(i);
   //          if(row==NULL)
   //             continue;
            
   //          // --- calculate the coordinate and create a name for the row header area
   //          int y=row.Height()*i;
   //          string name="CaptionBound"+(string)i;
   //          // --- Create a new row header area
   //          CBound *caption_bound=this.InsertNewBound(name,0,y,this.Width(),row.Height());
   //          if(caption_bound==NULL)
   //             return false;
   //          caption_bound.SetID(row.ID());
   //          // --- Define the text for the row header
   //          // --- If the headers array is smaller than the rows in the table, then the headers will first have the values ​​from the array, and then the row numbers
   //          // --- If the header array has no size, then all lines will be headed by serial numbers
   //          string text=(this.m_table_row_columns.Size()>0 ? (i<(int)this.m_table_row_columns.Size() ? this.m_table_row_columns[i] : string(i+1)) : string(i+1));
   //          // --- Create a new object for visual representation of the row header
   //          CRowCaptionView *caption_view=this.InsertNewRowCaptionView(text,0,y,this.Width(),row.Height());
   //          if(caption_view==NULL)
   //             return false;
   //          caption_view.SetIndex(i);
            
   //          // --- We assign the corresponding object for visual representation of the row header to the current area of ​​the row header
   //          caption_bound.AssignObject(caption_view);
   //          caption_view.AssignBoundNode(caption_bound);
   //       }
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowsHeaderView::Recalculates header areas |
   //    //+------------------------------------------------------------------+
   //    bool CTableRowsHeaderView::RecalculateBounds(CBound *bound,int new_width)
   //    {
   //    // --- If an empty area object is passed or its width has not changed, return false
   //       if(bound==NULL || bound.Width()==new_width)
   //          return false;
            
   //    // --- Get the index of the area in the list
   //       int index=this.m_list_bounds.IndexOf(bound);
   //       if(index==WRONG_VALUE)
   //          return false;

   //    // --- Calculate the offset and, if it is not there, return false
   //       int delta=new_width-bound.Width();
   //       if(delta==0)
   //          return false;

   //    // --- Change the width of the current area and the object assigned to the area
   //       bound.ResizeW(new_width);
   //       CElementBase *assigned_obj=bound.GetAssignedObj();
   //       if(assigned_obj!=NULL)
   //          assigned_obj.ResizeW(new_width);

   //    // --- Get the next area after the current one
   //       CBound *next_bound=this.m_list_bounds.GetNextNode();
   //    // --- Recalculate X coordinates for all subsequent areas
   //       while(!::IsStopped() && next_bound!=NULL)
   //       {
   //          // --- Shift the area by delta value
   //          int new_x = next_bound.X()+delta;
   //          int prev_width=next_bound.Width();
   //          next_bound.SetX(new_x);
   //          next_bound.Resize(prev_width,next_bound.Height());
            
   //          // --- If there is an assigned object in the area, update its position
   //          CElementBase *assigned_obj=next_bound.GetAssignedObj();
   //          if(assigned_obj!=NULL)
   //          {
   //             assigned_obj.Move(assigned_obj.X()+delta,assigned_obj.Y());
               
   //             // --- This code block is part of an effort to troubleshoot artifacts when dragging headers
   //             CCanvasBase *base_obj=assigned_obj.GetContainer();
   //             if(base_obj!=NULL)
   //             {
   //                if(assigned_obj.X()>base_obj.ContainerLimitRight())
   //                   assigned_obj.Hide(false);
   //                else
   //                   assigned_obj.Show(false);
   //             }
   //          }
   //          // --- Moving on to the next area
   //          next_bound=this.m_list_bounds.GetNextNode();
   //       }
         
   //    // --- Calculate the new width of the table header based on the width of the column headers
   //       int header_width=0;
   //       for(int i=0;i<this.m_list_bounds.Total();i++)
   //       {
   //          CBound *bound=this.GetBoundAt(i);
   //          if(bound!=NULL)
   //             header_width+=bound.Width();
   //       }

   //    // --- If the calculated width of the table header differs from the current one, change the width
   //       if(header_width!=this.Width())
   //       {
   //          if(!this.ResizeW(header_width))
   //             return false;
   //       }

   //    // --- Get a pointer to the table object (View)
   //       CPanel *obj=this.GetContainer();
   //       if(obj==NULL)
   //          return false;
   //       CTableView *table_view=obj.GetContainer();
   //       if(table_view==NULL)
   //          return false;

   //    // --- From the table object we get a pointer to the panel with table rows
   //       CPanel *table_area=table_view.GetTableArea();
   //       if(table_area==NULL)
   //          return false;
         
   //    // --- Change the size of the table row panel to the overall size of the column headers
   //       if(!table_area.ResizeW(header_width))
   //          return false;
         
   //    // --- Get a list of table rows and loop through all the rows
   //       CListElm *list=table_area.GetListAttachedElements();
   //       int total=list.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- We get the next row of the table
   //          CTableRowView *row=table_area.GetAttachedElementAt(i);
   //          if(row!=NULL)
   //          {
   //             // --- Change the row size to fit the panel size and recalculate the cell areas
   //             row.ResizeW(table_area.Width());
   //             row.RecalculateBounds(&this.m_list_bounds);
   //          }
   //       }
   //    // --- Redraw all table rows
   //       table_area.Draw(false);
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowsHeaderView::Gets row header by index |
   //    //+------------------------------------------------------------------+
   //    CRowCaptionView *CTableRowsHeaderView::GetRowCaption(const uint index)
   //    {
   //    // --- Get the row header area by index
   //       CBound *capt_bound=this.GetBoundAt(index);
   //       if(capt_bound==NULL)
   //          return NULL;
   //    // --- From the row header area, return a pointer to the attached row header object
   //       return capt_bound.GetAssignedObj();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableRowsHeaderView::Draws the appearance |
   //    //+------------------------------------------------------------------+
   //    void CTableRowsHeaderView::Draw(const bool chart_redraw)
   //    {
   //    // --- Fill the object with the background color, draw a line line and update the background canvas
   //       this.Fill(this.BackColor(),false);
   //       this.m_background.Line(this.AdjX(0),this.AdjY(this.Height()-1),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   //       this.m_background.Update(false);
         
   //    // --- Drawing line headers
   //       int total=this.m_list_bounds.Total();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- Get the row header object by loop index
   //          CRowCaptionView *caption_view=this.GetRowCaption(i);
   //          // --- Draw a visual representation of the row header
   //          if(caption_view!=NULL)
   //          {
   //             caption_view.Draw(false);
   //          }
   //       }
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CTABLEROWSHEADERVIEW_IMPLEMENTATION
#endif // MOVE_TO_TABLEROWSHEADERVIEW_MQH

#ifndef MOVE_TO_TABLEVIEW_MQH
#define MOVE_TO_TABLEVIEW_MQH
      // //+------------------------------------------------------------------+
   // // | Table visual class |
   // //+------------------------------------------------------------------+
   // class CTableView : public CPanel
   // {
   //    private:
   //       int               m_rows_header_panel_w;        // Width when creating table row header panel
         
   //    protected:
   //    // --- Retrieved table data
   //       CTable           *m_table_obj;                  // Pointer to a table object (includes table and header models)
   //       CTableModel      *m_table_model;                // Pointer to the table model (obtained from CTable)
   //       CTableHeader     *m_header_model;               // Pointer to the table header model (obtained from CTable)
         
   //    // --- View component data
   //       CPanel           *m_header_panel;               // Panel for placing table header
   //       CTableHeaderView *m_header_view;                // Pointer to table header (View)
   //       CPanel           *m_rows_header_panel;          // Panel for placing table row headers
   //       CTableRowsHeaderView *m_rows_header_view;       // Pointer to table row headers (View)
   //       CPanel           *m_table_area;                 // Panel for placing table rows
   //       CContainer       *m_table_area_container;       // Container for placing a panel with table rows
   //       bool              m_sortable;                   // Sortable table flag
         
   //    // --- (1) Sets, (2) returns the table model
   //       bool              TableModelAssign(CTableModel *table_model);
   //       CTableModel      *GetTableModel(void)                                { return this.m_table_model;           }
         
   //    // --- (1) Sets, (2) returns the table header model
   //       bool              HeaderModelAssign(CTableHeader *header_model);
   //       CTableHeader     *GetHeaderModel(void)                               { return this.m_header_model;          }
         
   //    // --- (1) Sets the required size of the row header panel, (2) returns the width of the table row header
   //       void              SetRowsHeaderPanelSize(const int width)            { this.m_rows_header_panel_w=width;    }
   //       int               RowsHeaderWidth(void) const
   //                         {
   //                            return(this.m_rows_header_view!=NULL ? this.m_rows_header_view.Width() : 0);
   //                         }

   //    // --- Creates a (1) table object, (2-3) header object from the model, (4) updates the modified table
   //       bool              CreateTable(void);
   //       bool              CreateHeader(void);
   //    public:
   //       bool              CreateRowsHeader(string &captions_array[]);
   //       bool              UpdateTable(void);
         
   //    // --- (1) Sets, (2) returns a table object
   //       bool              TableObjectAssign(CTable *table_obj);
   //       CTable           *GetTableObj(void)                                  { return this.m_table_obj;             }

   //    // --- Returns (1-2) title, (3) table area, (4) table area container
   //       CTableHeaderView *GetHeader(void)                                    { return this.m_header_view;           }
   //       CTableRowsHeaderView *GetRowsHeader(void)                            { return this.m_rows_header_view;      }
   //       CPanel           *GetTableArea(void)                                 { return this.m_table_area;            }
   //       CContainer       *GetTableAreaContainer(void)                        { return this.m_table_area_container;  }

   //    // --- Prints the assigned model of (1) table, (2) header, (3) table object in the log
   //       void              TableModelPrint(const bool detail);
   //       void              HeaderModelPrint(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS);
   //       void              TablePrint(const int column_width=CELL_WIDTH_IN_CHARS);
         
   //    // --- Gets the column header (1) by index, (2) with sort flag
   //       CColumnCaptionView *GetColumnCaption(const uint index)
   //                         { return(this.GetHeader()!=NULL ? this.GetHeader().GetColumnCaption(index) : NULL);     }
   //       CColumnCaptionView *GetSortedColumnCaption(void)
   //                         { return(this.GetHeader()!=NULL ? this.GetHeader().GetSortedColumnCaption(): NULL);     }

   //    // --- Returns a visual object representing the specified (1) row, (2) cell
   //       CTableRowView    *GetRowView(const uint index)
   //                         { return(this.GetTableArea()!=NULL ? this.GetTableArea().GetAttachedElementAt(index) : NULL); }
   //       CTableCellView   *GetCellView(const uint row,const uint col)
   //                         { return(this.GetRowView(row)!=NULL ? this.GetRowView(row).GetCellView(col) : NULL);    }
                           
   //    // --- Returns the number of table rows
   //       int               RowsTotal(void)
   //                         { return(this.GetTableArea()!=NULL ? this.GetTableArea().AttachedElementsTotal() : 0);  }
                           
   //    // --- Returns the number of cells in the specified table row
   //       int               CellsInRow(const uint row)
   //                         { return(this.GetRowView(row)!=NULL ? this.GetRowView(row).CellsTotal() : 0);           }

   //    // --- Sets the row highlighting method
   //       void              SetRowsHighlightMode(const ENUM_ROWS_HIGHLIGHT_MODE mode);
         
   //    // --- (1) Sets, (2) returns the flag of the table being sorted
   //       void              SetSortable(const bool flag);
   //       bool              IsSortable(void)                             const { return this.m_sortable;              }
         
   //    // ---Draws the appearance
   //       virtual void      Draw(const bool chart_redraw);
         
   //    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   //       virtual int       Compare(const CObject *node,const int mode=0)const { return CPanel::Compare(node,mode);   }
   //       virtual bool      Save(const int file_handle);
   //       virtual bool      Load(const int file_handle);
   //       virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_VIEW);     }
         
   //    // --- Handler for a custom element event when an object area is clicked
   //       virtual void      MousePressHandler(const int id, const long lparam, const double dparam, const string sparam);
         
   //    // --- Sorts the table by column value and direction
   //       bool              Sort(const uint column,const ENUM_TABLE_SORT_MODE sort_mode);
      
   //    // --- Initialize (1) class object, (2) default object colors
   //       void              Init(void);

   //    // --- Constructors/destructor
   //                         CTableView(void);
   //                         CTableView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CTableView (void){}
   // };
   // #ifndef CTABLEVIEW_IMPLEMENTATION
   // #define CTABLEVIEW_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Default constructor.                            |
   //    // | Plots an element in the main window of the current chart |
   //    // | at coordinates 0,0 with default dimensions |
   //    //+------------------------------------------------------------------+
   //    CTableView::CTableView(void) : CPanel("TableView","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H),
   //       m_table_model(NULL),m_header_model(NULL),m_table_obj(NULL),m_header_view(NULL),m_rows_header_view(NULL),
   //       m_table_area(NULL),m_table_area_container(NULL),m_rows_header_panel_w(0),m_sortable(true)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Parametric constructor.                         |
   //    // | Plots an element in the specified window of the specified chart |
   //    // | with specified text, coordinates and dimensions |
   //    //+------------------------------------------------------------------+
   //    CTableView::CTableView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CPanel(object_name,text,chart_id,wnd,x,y,w,h),m_table_model(NULL),m_header_model(NULL),m_rows_header_view(NULL),m_table_obj(NULL),m_header_view(NULL),
   //       m_table_area(NULL),m_table_area_container(NULL),m_rows_header_panel_w(0),m_sortable(true)
   //    {
   //    // ---Initialization
   //       this.Init();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Initialization |
   //    //+------------------------------------------------------------------+
   //    void CTableView::Init(void)
   //    {
   //    // --- Initializing the parent object
   //       CPanel::Init();
   //    // --- Frame width, opacity
   //       this.SetBorderWidth(1);
   //       this.SetAlphaBG(255);
   //       this.SetAlphaFG(255);
   //    // --- Initialize the background colors of the panel and make it the current background color
   //       this.InitBackColors(C'230,230,230',C'230,230,230',C'230,230,230',clrSilver);
   //       this.BackColorToDefault();
   //    // --- Initialize the panel border colors and make it the current border color
   //       this.InitBorderColors(C'180,180,180',C'180,180,180',C'180,180,180',clrSilver);
   //       this.BorderColorToDefault();
         
   //    // --- X coordinate offset for table header and rows (vertical row header width)
   //       int dx=(int)::StringToInteger(this.Text());

   //       this.m_rows_header_panel_w=dx;
   //       this.SetText("");
   //       if(dx>DEF_TABLE_ROWS_HEADER_W)
   //          dx+=12;
         
   //    // --- Coordinates and dimensions of the table header panel (table header is horizontal)
   //       int x=1+dx;
   //       int y=1;
   //       int w=this.Width()-2-dx;
   //       int h=DEF_TABLE_HEADER_H;
   //    // --- Create a panel for the table header
   //       this.m_header_panel=this.InsertNewElement(ELEMENT_TYPE_PANEL,"","TableHeaderPanel",x,y,w,h);
   //       if(this.m_header_panel==NULL)
   //          return;
   //    // --- Initialize the background colors of the panel and make it the current background color
   //       this.m_header_panel.InitBackColors(C'230,230,230',C'230,230,230',C'230,230,230',clrSilver);
   //       this.m_header_panel.BackColorToDefault();
   //       this.m_header_panel.SetBorderWidth(0);
   //       this.m_header_panel.SetAlphaBG(255);
   //    // --- Create a table header
   //       this.m_header_view=this.m_header_panel.InsertNewElement(ELEMENT_TYPE_TABLE_HEADER_VIEW,"","TableHeader",0,0,this.m_header_panel.Width(),this.m_header_panel.Height());
   //       if(this.m_header_view==NULL)
   //          return;
   //       this.m_header_view.SetBorderWidth(0);
         
   //    // --- Coordinates and dimensions of the panel for the table row header (the table header is vertical)
   //       x=1;
   //       y=DEF_TABLE_HEADER_H;
   //       w=(dx>0 ? dx : 1);
   //       h=this.Height()-2-DEF_TABLE_HEADER_H;
   //    // ---Creating a panel
   //       this.m_rows_header_panel=this.InsertNewElement(ELEMENT_TYPE_PANEL,"","TableRowsHeaderPanel",x,y,w,h);
   //       if(this.m_rows_header_panel==NULL)
   //          return;
   //    // --- Initialize the background colors of the panel and make it the current background color
   //       this.m_rows_header_panel.InitBackColors(C'230,230,230',C'230,230,230',C'230,230,230',clrSilver);
   //       this.m_rows_header_panel.BackColorToDefault();
   //       this.m_rows_header_panel.SetBorderWidth(0);
   //       this.m_rows_header_panel.SetAlphaBG(255);
   //    // --- Create table row headers
   //       this.m_rows_header_view=this.m_rows_header_panel.InsertNewElement(ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW,"","TableRowsHeader",0,0,this.m_rows_header_panel.Width(),this.m_rows_header_panel.Height());
   //       if(this.m_rows_header_view==NULL)
   //          return;
   //       this.m_rows_header_view.SetBorderWidth(0);
   //       this.m_rows_header_view.SetAlphaBG(0);
   //       if(this.m_rows_header_panel_w==0)
   //          this.m_rows_header_view.Hide(false);
         
   //    // --- Coordinates and dimensions of the container in which the table row panel will be located
   //       x=1+dx;
   //       y=1+DEF_TABLE_HEADER_H;
   //       w=this.Width()-2-dx;
   //       h=this.Height()-2-DEF_TABLE_HEADER_H;
   //    // --- Create a container
   //       this.m_table_area_container=this.InsertNewElement(ELEMENT_TYPE_CONTAINER,"","TableAreaContainer",x,y,w,h);
   //       if(this.m_table_area_container==NULL)
   //          return;
   //       this.m_table_area_container.SetBorderWidth(0);
   //       this.m_table_area_container.SetScrollable(true);
         
   //    // --- Attach a panel to the container for storing table rows
   //       this.m_table_area=this.m_table_area_container.InsertNewElement(ELEMENT_TYPE_PANEL,"","TableAreaPanel",0,0,this.m_table_area_container.Width()-0,this.m_table_area_container.Height()-0);
   //       if(m_table_area==NULL)
   //          return;
   //       this.m_table_area.SetBorderWidth(0);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Sets the table model |
   //    //+------------------------------------------------------------------+
   //    bool CTableView::TableModelAssign(CTableModel *table_model)
   //    {
   //       if(table_model==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
   //          return false;
   //       }
   //       this.m_table_model=table_model;
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Sets the table header model |
   //    //+------------------------------------------------------------------+
   //    bool CTableView::HeaderModelAssign(CTableHeader *header_model)
   //    {
   //       if(header_model==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
   //          return false;
   //       }
   //       this.m_header_model=header_model;
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Sets a table object |
   //    //+------------------------------------------------------------------+
   //    bool CTableView::TableObjectAssign(CTable *table_obj)
   //    {
   //    // --- If an empty table object is passed, we report this and return false
   //       if(table_obj==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
   //          return false;
   //       }
   //    // --- Save the pointer to a variable
   //       this.m_table_obj=table_obj;
   //    // --- Write down the result of assigning the table model and header model
   //       bool res=this.TableModelAssign(this.m_table_obj.GetTableModel());
   //       res &=this.HeaderModelAssign(this.m_table_obj.GetTableHeader());
         
   //    // --- If it was not possible to assign any model, return false
   //       if(!res)
   //          return false;
         
   //    // --- We record the result of creating a table header from the model and a table from the model
   //       res=this.CreateHeader();
   //       res&=this.CreateTable();
         
   //    // --- Return the result
   //       return res;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Creates a title object from the model |
   //    //+------------------------------------------------------------------+
   //    bool CTableView::CreateHeader(void)
   //    {
   //       if(this.m_header_view==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Table header object not created",__FUNCTION__);
   //          return false;
   //       }
   //       return this.m_header_view.TableHeaderModelAssign(this.m_header_model);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Creates a row header object |
   //    //+------------------------------------------------------------------+
   //    bool CTableView::CreateRowsHeader(string &captions_array[])
   //    {
   //       if(this.m_rows_header_view==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Table rows header object not created",__FUNCTION__);
   //          return false;
   //       }
   //       return this.m_rows_header_view.TableRowCaptionsAssign(captions_array);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Creates a table object from a model |
   //    //+------------------------------------------------------------------+
   //    bool CTableView::CreateTable(void)
   //    {
   //       if(this.m_table_area==NULL)
   //          return false;

   //    // --- In a loop, we create and attach RowsTotal rows from TableRowView elements to the Panel element (m_table_area)
   //       int total=(int)this.m_table_model.RowsTotal();
   //       int y=1;                   // Vertical offset
   //       int table_height=0;        // Calculated panel height
   //       CTableRowView *row=NULL;
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- Create and attach a table row object to the panel
   //          row=this.m_table_area.InsertNewElement(ELEMENT_TYPE_TABLE_ROW_VIEW,"","TableRow"+(string)i,0,y+(row!=NULL ? row.Height()*i : 0),this.m_table_area.Width()-1,DEF_TABLE_ROW_H);
   //          if(row==NULL)
   //             return false;
            
   //          // --- Set the row identifier
   //          row.SetID(i);
   //          row.SetIndex(i);
   //          // --- Depending on the line number (even/odd), we set its background color
   //          if(row.ID()%2==0)
   //             row.InitBackColorDefault(clrWhite);
   //          else
   //             row.InitBackColorDefault(C'242,242,242');
   //          row.BackColorToDefault();
   //          row.InitBackColorFocused(row.GetBackColorControl().NewColor(row.BackColor(),-4,-4,-4));
            
   //          // --- Getting the row model from the table object
   //          CTableRow *row_model=this.m_table_model.GetRow(i);
   //          if(row_model==NULL)
   //             return false;
   //          // --- Assign the resulting row model to the created table row object
   //          row.TableRowModelAssign(row_model);
   //          // --- Calculate the new value of the panel height
   //          table_height+=row.Height();
   //       }
   //    // --- Return the result of resizing the panel to the value calculated in the loop
   //       return this.m_table_area.ResizeH(table_height+y);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Updates a modified table |
   //    //+------------------------------------------------------------------+
   //    bool CTableView::UpdateTable(void)
   //    {
   //       if(this.m_table_area==NULL)
   //          return false;
         
   //       int total_model=(int)this.m_table_model.RowsTotal();        // Number of rows in the model
   //       int total_view =this.m_table_area.AttachedElementsTotal();  // Number of rows in visual representation
   //       int diff=total_model-total_view;                            // Difference in number of rows of two components
   //       int y=1;                                                    // Vertical offset
   //       int table_height=0;                                         // Calculated panel height
   //       CTableRowView *row=NULL;                                    // Pointer to a string rendering object
         
   //    // --- If there are more rows in the model than in the visual representation, we will create the missing rows in the visual representation at the end of the list
   //       if(diff>0)
   //       {
   //          // --- We get the last row of the visual representation of the table (based on its coordinates, the added rows will be placed)
   //          row=this.m_table_area.GetAttachedElementAt(total_view-1);
   //          // --- In a loop based on the number of missing lines
   //          for(int i=total_view;i<total_view+diff;i++)
   //          {
   //             // --- create and attach to the diff panel the number of objects for visual representation of a table row
   //             row=this.m_table_area.InsertNewElement(ELEMENT_TYPE_TABLE_ROW_VIEW,"","TableRow"+(string)i,0,y+(row!=NULL ? row.Height()*i : 0),this.m_table_area.Width()-1,DEF_TABLE_ROW_H);
   //             if(row==NULL)
   //                return false;
   //          }
   //       }
      
   //    // --- If there are more lines in the visual representation than in the model, delete the extra lines in the visual representation at the end of the list
   //       if(diff<0)
   //       {
   //          CListElm *list=this.m_table_area.GetListAttachedElements();
   //          if(list==NULL)
   //             return false;
            
   //          int  start=total_view-1;
   //          int  end=start-diff;
   //          bool res=true;
   //          for(int i=start;i>end;i--)
   //             res &=list.Delete(i);
   //          if(!res)
   //             return false;
   //       }
         
   //    // --- Looping through a list of table model rows
   //       for(int i=0;i<total_model;i++)
   //       {
   //          // --- we get from the list of the row panel the next object of visual representation of a table row
   //          row=this.m_table_area.GetAttachedElementAt(i);
   //          if(row==NULL)
   //             return false;
   //          // --- Let's check the object type
   //          if(row.Type()!=ELEMENT_TYPE_TABLE_ROW_VIEW)
   //             continue;
               
   //          // --- Set the row identifier
   //          row.SetID(i);
   //          row.SetIndex(i);
   //          // --- Depending on the line number (even/odd), we set its background color
   //          if(row.ID()%2==0)
   //             row.InitBackColorDefault(clrWhite);
   //          else
   //             row.InitBackColorDefault(C'242,242,242');
   //          row.BackColorToDefault();
   //          row.InitBackColorFocused(row.GetBackColorControl().NewColor(row.BackColor(),-4,-4,-4));
            
   //          // --- Getting the row model from the table object
   //          CTableRow *row_model=this.m_table_model.GetRow(i);
   //          if(row_model==NULL)
   //             return false;

   //          // --- Update the cells of the table row object according to the row model
   //          row.TableRowModelUpdate(row_model);
   //          // --- Calculate the new value of the panel height
   //          table_height+=row.Height();
   //       }
   //    // --- Return the result of resizing the panel to the value calculated in the loop
   //       return this.m_table_area.ResizeH(table_height+y);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Draws appearance |
   //    //+------------------------------------------------------------------+
   //    void CTableView::Draw(const bool chart_redraw)
   //    {
   //    // --- Draw the base
   //       CPanel::Draw(false);
   //    // --- Draw the table title and rows
   //       if(this.m_header_view!=NULL)
   //          this.m_header_view.Draw(false);
   //       if(this.m_table_area_container!=NULL)
   //          this.m_table_area_container.Draw(false);
            
   //    // --- Set the offset and dimensions of the image area
   //       int x=this.m_rows_header_panel.Width()-16;
   //       int y=this.m_header_panel.Height()-16;
   //       int w=11;
   //       int h=w;
   //    // --- Clear the area and draw a corner
   //       m_painter.Clear(x,y,w,h,false);
   //       m_painter.TriangleRB(x,y,w,h,BorderColor(),AlphaFG(),true);
            
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Sets the row highlighting method |
   //    //+------------------------------------------------------------------+
   //    void CTableView::SetRowsHighlightMode(const ENUM_ROWS_HIGHLIGHT_MODE highlight_mode)
   //    {
   //       int total=this.RowsTotal();
   //       for(int i=0;i<total;i++)
   //       {
   //          CTableRowView *row=this.GetRowView(i);
   //          if(row!=NULL)
   //             row.SetHighlightMode(highlight_mode);
   //       }
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Sets the sortable table flag |
   //    //+------------------------------------------------------------------+
   //    void CTableView::SetSortable(const bool flag)
   //    {
   //       this.m_sortable=flag;
   //       CTableHeaderView *header=this.GetHeader();
   //       if(header!=NULL)
   //          header.SetSortableFlag(flag);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Prints the assigned table model in the log |
   //    //+------------------------------------------------------------------+
   //    void CTableView::TableModelPrint(const bool detail)
   //    {
   //       if(this.m_table_model!=NULL)
   //          this.m_table_model.Print(detail);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Prints the assigned title model in the log |
   //    //+------------------------------------------------------------------+
   //    void CTableView::HeaderModelPrint(const bool detail,const bool as_table=false,const int column_width=CELL_WIDTH_IN_CHARS)
   //    {
   //       if(this.m_header_model!=NULL)
   //          this.m_header_model.Print(detail,as_table,column_width);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Prints the assigned table object in the log |
   //    //+------------------------------------------------------------------+
   //    void CTableView::TablePrint(const int column_width=CELL_WIDTH_IN_CHARS)
   //    {
   //       if(this.m_table_obj!=NULL)
   //          this.m_table_obj.Print(column_width);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Element Custom Event Handler |
   //    // | when clicking on an area of ​​an object |
   //    //+------------------------------------------------------------------+
   //    void CTableView::MousePressHandler(const int id,const long lparam,const double dparam,const string sparam)
   //    {
   //       if(id==CHARTEVENT_OBJECT_CLICK && lparam>=0 && dparam>=0)
   //          return;
            
   //    // --- Get the name of the table header object from sparam
   //       int len=::StringLen(this.NameFG());
   //       string header_str=::StringSubstr(sparam,0,len);
   //    // --- If the extracted name does not match the name of this object - not our event, leave
   //       if(header_str!=this.NameFG())
   //          return;
         
   //    // --- Write the index of the column header
   //    // --- Since the standard OBJECT_CLICK event transfers cursor coordinates to lparam and dparam,
   //    // --- then for this handler a negative value of the index of the header on which the event occurred is passed
   //       int index=(int)::fabs(lparam+10000);
         
   //    // --- Get the column header by index
   //       CColumnCaptionView *caption=this.GetColumnCaption(index);
   //       if(caption==NULL)
   //          return;
         
   //    // --- Sort the list of rows by the sort value in the column header and update the table
   //       if(this.Sort(index,caption.SortMode()) && this.UpdateTable())
   //          this.Draw(true);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | CTableView::Sorts table by column value and direction |
   //    //+------------------------------------------------------------------+
   //    bool CTableView::Sort(const uint column,const ENUM_TABLE_SORT_MODE sort_mode)
   //    {
   //    // --- If the table model is not assigned, report this and return false
   //       if(this.m_table_model==NULL)
   //       {
   //          ::PrintFormat("%s: Error. The table model is not assigned. Please use the TableObjectAssign() method first",__FUNCTION__);
   //          return false;
   //       }

   //    // --- If the table does not have a header or there is no sorting, return false
   //       if(this.m_header_model==NULL || !this.m_sortable || sort_mode==TABLE_SORT_MODE_NONE)
   //          return false;
         
   //    // --- Set the sort direction flag and sort the table model by the specified column and direction
   //       bool descending=(sort_mode==TABLE_SORT_MODE_DESC);
   //       this.m_table_model.SortByColumn(column,descending);
   //    // --- Successfully
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CTABLEVIEW_IMPLEMENTATION   
#endif // MOVE_TO_TABLEVIEW_MQH

#ifndef MOVE_TO_TABLECONTROL_MQH
#define MOVE_TO_TABLECONTROL_MQH
      // //+------------------------------------------------------------------+
   // // | Table management class |
   // //+------------------------------------------------------------------+
   // class CTableControl : public CPanel
   // {
   //    private:
   //    // --- Returns the maximum value of an integer array
   //       bool              ArrayMaximumValue(int &array[],int &value);
   //    // --- Returns the maximum text width in the row header array
   //       int               GetMaximumRowCaptionTextSize(string &array_row_captions[]);
         
   //    protected:
   //       CListObj          m_list_table_model;
   //    // --- Adds a (1) model (CTable), (2) visual representation (CTableView) table object to the list
   //       bool              TableModelAdd(CTable *table_model,const int table_id,const string source);
   //       CTableView       *TableViewAdd(CTable *table_model,string &row_names[],const string source);
   //    // --- Updates the specified column of the specified table
   //       bool              ColumnUpdate(const string source, CTable *table_model, const uint table, const uint col, const bool cells_redraw);
         
   //    public:
   //    // --- Returns (1) model, (2) table view object, (3) object type
   //       CTable           *GetTableModel(const uint index)              { return this.m_list_table_model.GetNodeAtIndex(index);  }
   //       CTableView       *GetTableView(const uint index)               { return this.GetAttachedElementAt(index);               }
         
   //    // --- Creating a table based on the transferred data
   //    template<typename T>
   //       CTableView       *TableCreate(T &row_data[][],const string &column_names[],const int table_id=WRONG_VALUE);
   //       CTableView       *TableCreate(const uint num_rows, const uint num_columns,const int table_id=WRONG_VALUE);
   //       CTableView       *TableCreate(const matrix &row_data,const string &column_names[],const int table_id=WRONG_VALUE);
   //       CTableView       *TableCreate(CList &row_data,const string &column_names[],const int table_id=WRONG_VALUE);
   //    template<typename T>
   //       CTableView       *TableCreate(T &row_data[][],const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE);
   //       CTableView       *TableCreate(const uint num_rows, const uint num_columns,string &row_names[],const int table_id=WRONG_VALUE);
   //       CTableView       *TableCreate(const matrix &row_data,const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE);
   //       CTableView       *TableCreate(CList &row_data,const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE);
         
   //    // --- Returns (1) the string value of the specified cell (Model), the specified (2) row, (3) table cell (View)
   //       string            CellValueAt(const uint table, const uint row, const uint col);
   //       CTableRowView    *GetRowView(const uint table, const uint index);
   //       CTableCellView   *GetCellView(const uint table, const uint row, const uint col);
         
   //    // --- Sets (1) value, (2) precision, (3) time display flags, (4) color name display flag in the specified cell (Model + View)
   //    template<typename T>
   //       void              CellSetValue(const uint table, const uint row, const uint col, const T value, const bool chart_redraw);
   //       void              CellSetDigits(const uint table, const uint row, const uint col, const int digits, const bool chart_redraw);
   //       void              CellSetTimeFlags(const uint table, const uint row, const uint col, const uint flags, const bool chart_redraw);
   //       void              CellSetColorNamesFlag(const uint table, const uint row, const uint col, const bool flag, const bool chart_redraw);

   //    // --- Sets the color of (1) foreground, (2) background to the specified cell (View)
   //       void              CellSetForeColor(const uint table, const uint row, const uint col, const color clr, const bool chart_redraw);
   //       void              CellSetBackColor(const uint table, const uint row, const uint col, const color clr, const bool chart_redraw);
         
   //    // --- (1) Sets, (2) returns the text anchor point in the specified cell (View)
   //       void              CellSetTextAnchor(const uint table, const uint row, const uint col, const ENUM_ANCHOR_POINT anchor,const bool cell_redraw,const bool chart_redraw);
   //       ENUM_ANCHOR_POINT CellTextAnchor(const uint table, const uint row, const uint col);
         
   //    // --- Sets (1) precision, (2) time display flags, (3) color name display flag, (4) text anchor point, (5) data type in the specified column (View)
   //       void              ColumnSetDigits(const uint table, const uint col, const int digits, const bool cells_redraw, const bool chart_redraw);
   //       void              ColumnSetTimeFlags(const uint table, const uint col, const uint flags, const bool cells_redraw, const bool chart_redraw);
   //       void              ColumnSetColorNamesFlag(const uint table, const uint col, const bool flag, const bool cells_redraw, const bool chart_redraw);
   //       void              ColumnSetTextAnchor(const uint table, const uint col, const ENUM_ANCHOR_POINT anchor, const bool cells_redraw, const bool chart_redraw);
   //       void              ColumnSetDatatype(const uint table, const uint col, const ENUM_DATATYPE type, const bool cells_redraw, const bool chart_redraw);

   //    // --- Returns the number of (1) rows, (2) cells per row in the specified table
   //       uint              RowsTotal(const uint table);
   //       uint              CellsInRow(const uint table,const uint row);

   //    // --- Sets (1) the row highlighting mode, (2) the ability to sort the specified table
   //       void              SetRowsHighlightMode(const uint table,const ENUM_ROWS_HIGHLIGHT_MODE highlight_mode);
   //       void              SetSortable(const uint table,const bool flag);
         
   //    // ---Object type
   //       virtual int       Type(void)                             const { return(ELEMENT_TYPE_TABLE_CONTROL_VIEW);               }

   //    // --- Constructors/destructor
   //                         CTableControl(void) { this.m_list_table_model.Clear(); }
   //                         CTableControl(const string object_name, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
   //                      ~CTableControl(void) {}
   // };
   // #ifndef CTABLECONTROL_IMPLEMENTATION
   // #define CTABLECONTROL_IMPLEMENTATION
   //    //+------------------------------------------------------------------+
   //    // | Constructor |
   //    //+------------------------------------------------------------------+
   //    CTableControl::CTableControl(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   //       CPanel(object_name,"",chart_id,wnd,x,y,w,h)
   //    {
   //       this.m_list_table_model.Clear();
   //       this.SetName("Table Control");
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Returns the maximum value of an integer array |
   //    //+------------------------------------------------------------------+
   //    bool CTableControl::ArrayMaximumValue(int &array[],int &value)
   //    {
   //       ::ResetLastError();
   //       int index=::ArrayMaximum(array);
   //       if(index<0)
   //       {
   //          ::PrintFormat("%s: ArrayMaximum() failed. Error %d",__FUNCTION__,::GetLastError());
   //          return false;
   //       }
   //       value=array[index];
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Returns the maximum width of the text in the row header array |
   //    //+------------------------------------------------------------------+
   //    int CTableControl::GetMaximumRowCaptionTextSize(string &row_captions[])
   //    {
   //       int total=(int)row_captions.Size();
   //       if(total==0)
   //          return 0;

   //       int array[]={};
   //       ::ArrayResize(array,total);
   //       for(int i=0;i<total;i++)
   //       {
   //          string text=row_captions[i];
   //          text.TrimLeft();
   //          text.TrimRight();
   //          array[i]=this.m_foreground.TextWidth(text);
   //       }
   //       int value=0;
   //       return(this.ArrayMaximumValue(array,value) ? value : 0);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Adds a table model object (CTable) to the list |
   //    //+------------------------------------------------------------------+
   //    bool CTableControl::TableModelAdd(CTable *table_model,const int table_id,const string source)
   //    {
   //    // --- Checking the table model object
   //       if(table_model==NULL)
   //       {
   //          ::PrintFormat("%s::%s: Error. Failed to create Table Model object",source,__FUNCTION__);
   //          return false;
   //       }
   //    // --- We set an identifier in the table model - either by the size of the list or a given one
   //       table_model.SetID(table_id<0 ? this.m_list_table_model.Total() : table_id);
   //    // --- If a table model with a set identifier is in the list, we report this, delete the object and return false
   //       this.m_list_table_model.Sort(0);
   //       if(this.m_list_table_model.Search(table_model)!=NULL)
   //       {
   //          ::PrintFormat("%s::%s: Error: Table Model object with ID %d already exists in the list",source,__FUNCTION__,table_id);
   //          delete table_model;
   //          return false;
   //       }
   //    // --- If the table model is not added to the list, we report this, delete the object and return false
   //       if(this.m_list_table_model.Add(table_model)<0)
   //       {
   //          ::PrintFormat("%s::%s: Error. Failed to add Table Model object to list",source,__FUNCTION__);
   //          delete table_model;
   //          return false;
   //       }
   //    // --- Everything is successful
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Creates a new object and adds it to the list |
   //    // | visual table view (CTableView) |
   //    //+------------------------------------------------------------------+
   //    CTableView *CTableControl::TableViewAdd(CTable *table_model,string &row_names[],const string source)
   //    {
   //    // --- Checking the table model object
   //       if(table_model==NULL)
   //       {
   //          ::PrintFormat("%s::%s: Error. An invalid Table Model object was passed",source,__FUNCTION__);
   //          return NULL;
   //       }
   //    // --- Get the maximum width of the row header text
   //       int w=this.GetMaximumRowCaptionTextSize(row_names);
   //       if(w>0 && w<DEF_TABLE_ROWS_HEADER_W)
   //          w=DEF_TABLE_ROWS_HEADER_W;
            
   //    // --- Create a new element - a visual representation of the table, attached to the panel
   //       CTableView *table_view=this.InsertNewElement(ELEMENT_TYPE_TABLE_VIEW,(string)w,"TableView"+(string)table_model.ID(),1,1,this.Width()-2,this.Height()-2);
   //       if(table_view==NULL)
   //       {
   //          ::PrintFormat("%s::%s: Error. Failed to create Table View object",source,__FUNCTION__);
   //          return NULL;
   //       }
   //    // --- Assign the table object (Model) and its identifier to the graphic element “Table” (View)
   //       table_view.TableObjectAssign(table_model);
   //       table_view.CreateRowsHeader(row_names);
   //       table_view.SetID(table_model.ID());
   //       return table_view;
   //    }
   //    //+-------------------------------------------------------------------+
   //    // | Creates a table specifying a table array and a header array. |
   //    // | Determines the number and names of columns according to column_names|
   //    // | The number of rows is determined by the size of the data array row_data, |
   //    // | which is also used to fill out the table |
   //    //+-------------------------------------------------------------------+
   //    template<typename T>
   //    CTableView *CTableControl::TableCreate(T &row_data[][],const string &column_names[],const int table_id=WRONG_VALUE)
   //    {
   //    // --- Create a table object using the specified parameters
   //       CTable *table_model=new CTable(row_data,column_names);
   //    // --- If there are errors when creating or adding a table to the list, return NULL
   //       if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
   //          return NULL;
         
   //    // --- Create and return a table with an empty array of row headers
   //       string array[]={};
   //       return this.TableViewAdd(table_model,array,__FUNCTION__);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Creates a table defining the number of columns and rows.       |
   //    // | The columns will have Excel names "A", "B", "C", etc.      |
   //    //+------------------------------------------------------------------+
   //    CTableView *CTableControl::TableCreate(const uint num_rows,const uint num_columns,const int table_id=WRONG_VALUE)
   //    {
   //       CTable *table_model=new CTable(num_rows,num_columns);
   //    // --- If there are errors when creating or adding a table to the list, return NULL
   //       if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
   //          return NULL;
         
   //    // --- Create and return a table with an empty array of row headers
   //       string array[]={};
   //       return this.TableViewAdd(table_model,array,__FUNCTION__);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Creates a table with columns initialized according to column_names |
   //    // | The number of rows is determined by the row_data parameter, with type matrix |
   //    //+------------------------------------------------------------------+
   //    CTableView *CTableControl::TableCreate(const matrix &row_data,const string &column_names[],const int table_id=WRONG_VALUE)
   //    {
   //       CTable *table_model=new CTable(row_data,column_names);
   //    // --- If there are errors when creating or adding a table to the list, return NULL
   //       if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
   //          return NULL;
         
   //    // --- Create and return a table with an empty array of row headers
   //       string array[]={};
   //       return this.TableViewAdd(table_model,array,__FUNCTION__);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Creates a table specifying a table array based on |
   //    // | row_data list containing objects with structure field data.  |
   //    // | Determines the number and names of columns according to the quantity |
   //    // | column names in the column_names array |
   //    //+------------------------------------------------------------------+
   //    CTableView *CTableControl::TableCreate(CList &row_data,const string &column_names[],const int table_id=WRONG_VALUE)
   //    {
   //       CTableByParam *table_model=new CTableByParam(row_data,column_names);
   //    // --- If there are errors when creating or adding a table to the list, return NULL
   //       if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
   //          return NULL;
         
   //    // --- Create and return a table with an empty array of row headers
   //       string array[]={};
   //       return this.TableViewAdd(table_model,array,__FUNCTION__);
   //    }
   //    //+-------------------------------------------------------------------+
   //    // | Creates a table specifying a table array and a header array. |
   //    // | Determines the number and names of columns according to column_names|
   //    // | The number of rows is determined by the size of the data array row_data, |
   //    // | which is also used to fill out the table |
   //    //+-------------------------------------------------------------------+
   //    template<typename T>
   //    CTableView *CTableControl::TableCreate(T &row_data[][],const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE)
   //    {
   //    // --- Create a table object using the specified parameters
   //       CTable *table_model=new CTable(row_data,column_names);
   //    // --- If there are errors when creating or adding a table to the list, return NULL
   //       if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
   //          return NULL;

   //    // --- Create and return the table
   //       return this.TableViewAdd(table_model,row_names,__FUNCTION__);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Creates a table defining the number of columns and rows.       |
   //    // | The columns will have Excel names "A", "B", "C", etc.      |
   //    //+------------------------------------------------------------------+
   //    CTableView *CTableControl::TableCreate(const uint num_rows,const uint num_columns,string &row_names[],const int table_id=WRONG_VALUE)
   //    {
   //       CTable *table_model=new CTable(num_rows,num_columns);
   //    // --- If there are errors when creating or adding a table to the list, return NULL
   //       if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
   //          return NULL;
         
   //    // --- Create and return the table
   //       return this.TableViewAdd(table_model,row_names,__FUNCTION__);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Creates a table with columns initialized according to column_names |
   //    // | The number of rows is determined by the row_data parameter, with type matrix |
   //    //+------------------------------------------------------------------+
   //    CTableView *CTableControl::TableCreate(const matrix &row_data,const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE)
   //    {
   //       CTable *table_model=new CTable(row_data,column_names);
   //    // --- If there are errors when creating or adding a table to the list, return NULL
   //       if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
   //          return NULL;
         
   //    // --- Create and return the table
   //       return this.TableViewAdd(table_model,row_names,__FUNCTION__);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Creates a table specifying a table array based on |
   //    // | row_data list containing objects with structure field data.  |
   //    // | Determines the number and names of columns according to the quantity |
   //    // | column names in the column_names array |
   //    //+------------------------------------------------------------------+
   //    CTableView *CTableControl::TableCreate(CList &row_data,const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE)
   //    {
   //       CTableByParam *table_model=new CTableByParam(row_data,column_names);
   //    // --- If there are errors when creating or adding a table to the list, return NULL
   //       if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
   //          return NULL;
         
   //    // --- Create and return the table
   //       return this.TableViewAdd(table_model,row_names,__FUNCTION__);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the value to the specified cell (Model + View) |
   //    //+------------------------------------------------------------------+
   //    template<typename T>
   //    void CTableControl::CellSetValue(const uint table,const uint row,const uint col,const T value,const bool chart_redraw)
   //    {
   //    // --- Getting the table model
   //       CTable *table_model=this.GetTableModel(table);
   //       if(table_model==NULL)
   //          return;
         
   //    // --- From the table model we get the cell model
   //       CTableCell *cell_model=table_model.GetCell(row,col);
   //       if(cell_model==NULL)
   //          return;
            
   //    // --- Get the visual representation object of the cell
   //       CTableCellView *cell_view=this.GetCellView(table,row,col);
   //       if(cell_view==NULL)
   //          return;
            
   //    // --- Compare the value set in the cell with the value passed
   //       bool equal=false;
   //       ENUM_DATATYPE datatype=cell_model.Datatype();
   //       switch(datatype)
   //       {
   //          case TYPE_LONG    :  
   //          case TYPE_DATETIME:  
   //          case TYPE_COLOR   :  equal=(cell_model.ValueL()==value);                                           break;
   //          case TYPE_DOUBLE  :  equal=(::NormalizeDouble(cell_model.ValueD()-value,cell_model.Digits())==0);  break;
   //          //---TYPE_STRING
   //          default           :  equal=(::StringCompare(cell_model.ValueS(),(string)value)==0);                break;
   //       }
   //    // --- If the values ​​are equal, we leave
   //       if(equal)
   //          return;
            
   //    // --- We set a new value in the cell model;
   //    // --- enter the value from the cell model into the visual representation object of the cell
   //    // --- Redraw the cell with the graph update flag
   //       table_model.CellSetValue(row,col,value);
   //       cell_view.SetText(cell_model.Value());
   //       cell_view.Draw(chart_redraw);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the precision to the specified cell (Model + View) |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::CellSetDigits(const uint table,const uint row,const uint col,const int digits,const bool chart_redraw)
   //    {
   //    // --- Getting the table model
   //       CTable *table_model=this.GetTableModel(table);
   //       if(table_model==NULL)
   //          return;
         
   //    // --- From the table model we get the cell model
   //       CTableCell *cell_model=table_model.GetCell(row,col);
   //       if(cell_model==NULL || cell_model.Digits()==digits)
   //          return;
            
   //    // --- Get the visual representation object of the cell
   //       CTableCellView *cell_view=this.GetCellView(table,row,col);
   //       if(cell_view==NULL)
   //          return;
         
   //    // --- We set a new precision value in the cell model;
   //    // --- enter the value from the cell model into the visual representation object of the cell
   //    // --- Redraw the cell with the graph update flag
   //       table_model.CellSetDigits(row,col,digits);
   //       cell_view.SetText(cell_model.Value());
   //       cell_view.Draw(chart_redraw);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets time display flags |
   //    // | to the specified cell (Model + View) |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::CellSetTimeFlags(const uint table,const uint row,const uint col,const uint flags,const bool chart_redraw)
   //    {
   //    // --- Getting the table model
   //       CTable *table_model=this.GetTableModel(table);
   //       if(table_model==NULL)
   //          return;
         
   //    // --- From the table model we get the cell model
   //       CTableCell *cell_model=table_model.GetCell(row,col);
   //       if(cell_model==NULL || cell_model.DatetimeFlags()==flags)
   //          return;
            
   //    // --- Get the visual representation object of the cell
   //       CTableCellView *cell_view=this.GetCellView(table,row,col);
   //       if(cell_view==NULL)
   //          return;
         
   //    // --- We set a new value for the time display flags in the cell model;
   //    // --- enter the value from the cell model into the visual representation object of the cell
   //    // --- Redraw the cell with the graph update flag
   //       table_model.CellSetTimeFlags(row,col,flags);
   //       cell_view.SetText(cell_model.Value());
   //       cell_view.Draw(chart_redraw);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the color name display flag |
   //    // | to the specified cell (Model + View) |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::CellSetColorNamesFlag(const uint table,const uint row,const uint col,const bool flag,const bool chart_redraw)
   //    {
   //    // --- Getting the table model
   //       CTable *table_model=this.GetTableModel(table);
   //       if(table_model==NULL)
   //          return;
         
   //    // --- From the table model we get the cell model
   //       CTableCell *cell_model=table_model.GetCell(row,col);
   //       if(cell_model==NULL || cell_model.ColorNameFlag()==flag)
   //          return;
            
   //    // --- Get the visual representation object of the cell
   //       CTableCellView *cell_view=this.GetCellView(table,row,col);
   //       if(cell_view==NULL)
   //          return;
         
   //    // --- Set a new value for the flag for displaying color names in the cell model;
   //    // --- enter the value from the cell model into the visual representation object of the cell
   //    // --- Redraw the cell with the graph update flag
   //       table_model.CellSetColorNamesFlag(row,col,flag);
   //       cell_view.SetText(cell_model.Value());
   //       cell_view.Draw(chart_redraw);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the foreground color to the specified cell (View) |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::CellSetForeColor(const uint table,const uint row,const uint col,const color clr,const bool chart_redraw)
   //    {
   //    // --- Get the visual representation object of the cell
   //       CTableCellView *cell_view=this.GetCellView(table,row,col);
   //       if(cell_view==NULL)
   //          return;
         
   //    // --- Set the cell text color to the cell visual representation object
   //    // --- Redraw the cell with the graph update flag
   //       cell_view.SetForeColor(clr);
   //       cell_view.Draw(chart_redraw);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the background color to the specified cell (View) |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::CellSetBackColor(const uint table,const uint row,const uint col,const color clr,const bool chart_redraw)
   //    {
   //    // --- Get the visual representation object of the cell
   //       CTableCellView *cell_view=this.GetCellView(table,row,col);
   //       if(cell_view==NULL)
   //          return;
         
   //    // --- Set the cell background color to the cell visual representation object
   //    // --- Redraw the cell with the graph update flag
   //       cell_view.SetBackColor(clr);
   //       cell_view.Draw(chart_redraw);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the text anchor point to the specified cell (View) |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::CellSetTextAnchor(const uint table,const uint row,const uint col,const ENUM_ANCHOR_POINT anchor,const bool cell_redraw,const bool chart_redraw)
   //    {
   //    // --- Get the visual representation object of the cell
   //       CTableCellView *cell_view=this.GetCellView(table,row,col);
   //       if(cell_view==NULL)
   //          return;
         
   //    // --- Set the text anchor point to the visual representation object of the cell
   //    // --- Redraw the cell with the graph update flag
   //       cell_view.SetTextAnchor(anchor,cell_redraw,chart_redraw);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Returns the text anchor point in the specified cell (View) |
   //    //+------------------------------------------------------------------+
   //    ENUM_ANCHOR_POINT CTableControl::CellTextAnchor(const uint table,const uint row,const uint col)
   //    {
   //    // --- Get the visual representation object of the cell
   //       CTableCellView *cell_view=this.GetCellView(table,row,col);
   //       if(cell_view==NULL)
   //          return ANCHOR_LEFT_UPPER;
         
   //    // --- Return the text anchor point
   //       return((ENUM_ANCHOR_POINT)cell_view.TextAnchor());
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Updates the specified column of the specified table |
   //    //+------------------------------------------------------------------+
   //    bool CTableControl::ColumnUpdate(const string source,CTable *table_model,const uint table,const uint col,const bool cells_redraw)
   //    {
   //    // --- Checking the table model
   //       if(::CheckPointer(table_model)==POINTER_INVALID)
   //       {
   //          ::PrintFormat("%s::%s: Error. Invalid table model pointer passed",source,__FUNCTION__);
   //          return false;
   //       }
   //    // --- Getting a visual representation of the table
   //       CTableView *table_view=this.GetTableView(table);
   //       if(table_view==NULL)
   //       {
   //          ::PrintFormat("%s::%s: Error. Failed to get CTableView object",source,__FUNCTION__);
   //          return false;
   //       }
         
   //    // --- In a loop through the rows of the visual representation of the table
   //       int total=table_view.RowsTotal();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- we obtain from the next row of the table a visual representation of the cell in the specified column
   //          CTableCellView *cell_view=this.GetCellView(table,i,col);
   //          if(cell_view==NULL)
   //          {
   //             ::PrintFormat("%s::%s: Error. Failed to get CTableCellView object (row %d, col %u)",source,__FUNCTION__,i,col);
   //             return false;
   //          }
   //          // --- Get the model of the corresponding cell from the row model
   //          CTableCell *cell_model=table_model.GetCell(i,col);
   //          if(cell_model==NULL)
   //          {
   //             ::PrintFormat("%s::%s: Error. Failed to get CTableCell object (row %d, col %u)",source,__FUNCTION__,i,col);
   //             return false;
   //          }
            
   //          // --- We write the value from the cell model to the visual representation object of the cell
   //          cell_view.SetText(cell_model.Value());
   //          // --- If specified, redraw the visual representation of the cell
   //          if(cells_redraw)
   //             cell_view.Draw(false);
   //       }
   //       return true;
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the precision in the specified column (Model + View) |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::ColumnSetDigits(const uint table,const uint col,const int digits,const bool cells_redraw,const bool chart_redraw)
   //    {
   //    // --- Getting the table model
   //       CTable *table_model=this.GetTableModel(table);
   //       if(table_model==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__);
   //          return;
   //       }
   //    // --- Set Digits for the specified column in the table model
   //       table_model.ColumnSetDigits(col,digits);

   //    // --- Update the column data display and, if specified, redraw the graph
   //       if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Устанавливает флаги отображения времени                          |
   //    // | in the specified column (Model + View) |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::ColumnSetTimeFlags(const uint table,const uint col,const uint flags,const bool cells_redraw,const bool chart_redraw)
   //    {
   //    // --- Getting the table model
   //       CTable *table_model=this.GetTableModel(table);
   //       if(table_model==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__);
   //          return;
   //       }
   //    // --- Set the time display flags for the specified column in the table model
   //       table_model.ColumnSetTimeFlags(col,flags);

   //    // --- Update the column data display and, if specified, redraw the graph
   //       if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the color name display flag |
   //    // | in the specified column (Model + View) |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::ColumnSetColorNamesFlag(const uint table,const uint col,const bool flag,const bool cells_redraw,const bool chart_redraw)
   //    {
   //    // --- Getting the table model
   //       CTable *table_model=this.GetTableModel(table);
   //       if(table_model==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__);
   //          return;
   //       }
   //    // --- Set the time display flags for the specified column in the table model
   //       table_model.ColumnSetColorNamesFlag(col,flag);

   //    // --- Update the column data display and, if specified, redraw the graph
   //       if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the data type in the specified column ( (Model + View)) |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::ColumnSetDatatype(const uint table,const uint col,const ENUM_DATATYPE type,const bool cells_redraw,const bool chart_redraw)
   //    {
   //    // --- Getting the table model
   //       CTable *table_model=this.GetTableModel(table);
   //       if(table_model==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__); 
   //          return;
   //       }
   //    // --- Set the data type for the specified column in the table model
   //       table_model.ColumnSetDatatype(col,type);

   //    // --- Update the column data display and, if specified, redraw the graph
   //       if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the text anchor point in the specified column (View) |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::ColumnSetTextAnchor(const uint table,const uint col,const ENUM_ANCHOR_POINT anchor,const bool cells_redraw,const bool chart_redraw)
   //    {
   //    // --- Getting a visual representation of the table
   //       CTableView *table_view=this.GetTableView(table);
   //       if(table_view==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
   //          return;
   //       }
   //    // --- In a loop through all rows of the table
   //       int total=table_view.RowsTotal();
   //       for(int i=0;i<total;i++)
   //       {
   //          // --- we get the next object of visual representation of the cell
   //          // --- and insert a new anchor point into the object
   //          CTableCellView *cell_view=this.GetCellView(table,i,col);
   //          if(cell_view!=NULL && cell_view.TextAnchor()!=anchor)
   //             cell_view.SetTextAnchor(anchor,cells_redraw,false);
   //       }
   //    // --- If indicated, update the schedule
   //       if(chart_redraw)
   //          ::ChartRedraw(this.m_chart_id);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Returns the string value of the specified cell (Model) |
   //    //+------------------------------------------------------------------+
   //    string CTableControl::CellValueAt(const uint table,const uint row,const uint col)
   //    {
   //       CTable *table_model=this.GetTableModel(table);
   //       return(table_model!=NULL ? table_model.CellValueAt(row,col) : ::StringFormat("%s: Error. Failed to get table model",__FUNCTION__));
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Returns the specified table row (View) |
   //    //+------------------------------------------------------------------+
   //    CTableRowView *CTableControl::GetRowView(const uint table,const uint index)
   //    {
   //       CTableView *table_view=this.GetTableView(table);
   //       if(table_view==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
   //          return NULL;
   //       }
   //       return table_view.GetRowView(index);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Returns the specified table cell (View) |
   //    //+------------------------------------------------------------------+
   //    CTableCellView *CTableControl::GetCellView(const uint table,const uint row,const uint col)
   //    {
   //       CTableView *table_view=this.GetTableView(table);
   //       if(table_view==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
   //          return NULL;
   //       }
   //       return table_view.GetCellView(row,col);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Returns the number of rows in the specified table |
   //    //+------------------------------------------------------------------+
   //    uint CTableControl::RowsTotal(const uint table)
   //    {
   //       CTableView *table_view=this.GetTableView(table);
   //       if(table_view==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
   //          return NULL;
   //       }
   //       return table_view.RowsTotal();
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Returns the number of cells per row in the specified table |
   //    //+------------------------------------------------------------------+
   //    uint CTableControl::CellsInRow(const uint table,const uint row)
   //    {
   //       CTableRowView *row_view=this.GetRowView(table,row);
   //       return(row_view!=NULL ? row_view.CellsTotal() : 0);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the highlighting mode for the rows of the specified table |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::SetRowsHighlightMode(const uint table,const ENUM_ROWS_HIGHLIGHT_MODE highlight_mode)
   //    {
   //       CTableView *table_view=this.GetTableView(table);
   //       if(table_view==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
   //          return;
   //       }
   //       table_view.SetRowsHighlightMode(highlight_mode);
   //    }
   //    //+------------------------------------------------------------------+
   //    // | Sets the ability to sort the specified table |
   //    //+------------------------------------------------------------------+
   //    void CTableControl::SetSortable(const uint table,const bool flag)
   //    {
   //       CTableView *table_view=this.GetTableView(table);
   //       if(table_view==NULL)
   //       {
   //          ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
   //          return;
   //       }
   //       table_view.SetSortable(flag);
   //    }
   //    //+------------------------------------------------------------------+
   // #endif // CTABLECONTROL_IMPLEMENTATION
#endif // MOVE_TO_TABLECONTROL_MQH

