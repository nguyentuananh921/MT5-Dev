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
#include "Base.mqh"

//+------------------------------------------------------------------+
// | Macro substitutions |
//+------------------------------------------------------------------+
#define  DEF_LABEL_W                50          // Default text label width
#define  DEF_LABEL_H                16          // Default text label height
#define  DEF_BUTTON_W               60          // Default button width
#define  DEF_BUTTON_H               16          // Default button height
#define  DEF_PANEL_W                80          // Default panel width
#define  DEF_PANEL_H                80          // Default panel height
#define  DEF_SCROLLBAR_TH           13          // Default scrollbar thickness
#define  DEF_THUMB_MIN_SIZE         8           // Minimum scroll bar thickness
#define  DEF_AUTOREPEAT_DELAY       500         // Delay before auto-repeat starts
#define  DEF_AUTOREPEAT_INTERVAL    100         // Auto repeat frequency

//+------------------------------------------------------------------+
// | Transfers |
//+------------------------------------------------------------------+
enum ENUM_ELEMENT_SORT_BY                       // Comparable properties
  {
   ELEMENT_SORT_BY_ID   =  BASE_SORT_BY_ID,     // Comparison by element ID
   ELEMENT_SORT_BY_NAME =  BASE_SORT_BY_NAME,   // Comparison by element name
   ELEMENT_SORT_BY_X    =  BASE_SORT_BY_X,      // Comparison by element's X coordinate
   ELEMENT_SORT_BY_Y    =  BASE_SORT_BY_Y,      // Comparison by element's Y coordinate
   ELEMENT_SORT_BY_WIDTH=  BASE_SORT_BY_WIDTH,  // Comparison by element width
   ELEMENT_SORT_BY_HEIGHT= BASE_SORT_BY_HEIGHT, // Comparison by element height
   ELEMENT_SORT_BY_ZORDER= BASE_SORT_BY_ZORDER, // Comparison by Z-order of an element
   ELEMENT_SORT_BY_TEXT,                        // Comparison by element text
   ELEMENT_SORT_BY_COLOR_BG,                    // Comparison by element background color
   ELEMENT_SORT_BY_ALPHA_BG,                    // Comparison of element background transparency
   ELEMENT_SORT_BY_COLOR_FG,                    // Comparison by element's foreground color
   ELEMENT_SORT_BY_ALPHA_FG,                    // Comparison by foreground element transparency
   ELEMENT_SORT_BY_STATE,                       // Comparison by item condition
   ELEMENT_SORT_BY_GROUP,                       // Comparison by element group
  };
//+------------------------------------------------------------------+ 
// | Functions |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// | Classes |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Linked List Object Class |
//+------------------------------------------------------------------+
class CListObj : public CList
  {
protected:
   ENUM_ELEMENT_TYPE m_element_type;   // The type of the object being created in CreateElement()
public:
// --- Setting element type
   void              SetElementType(const ENUM_ELEMENT_TYPE type) { this.m_element_type=type;   }
   
// --- Virtual method (1) loading a list from a file, (2) creating a list element
   virtual bool      Load(const int file_handle);
   virtual CObject  *CreateElement(void);
  };
//+------------------------------------------------------------------+
// | Loading a list from a file |
//+------------------------------------------------------------------+
bool CListObj::Load(const int file_handle)
  {
// --- Variables
   CObject *node;
   bool     result=true;
// --- Checking the handle
   if(file_handle==INVALID_HANDLE)
      return(false);
// --- Loading and checking the list start marker - 0xFFFFFFFFFFFFFFFF
   if(::FileReadLong(file_handle)!=MARKER_START_DATA)
      return(false);
// --- Loading and checking list type
   if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
      return(false);
// --- Read list size (number of objects)
   uint num=::FileReadInteger(file_handle,INT_VALUE);
   
// --- We sequentially re-create the list elements by calling the Load() method of node objects
   this.Clear();
   for(uint i=0; i<num; i++)
     {
      // --- Read and check the object data start marker - 0xFFFFFFFFFFFFFFFF
      if(::FileReadLong(file_handle)!=MARKER_START_DATA)
         return false;
      // --- Read the object type
      this.m_element_type=(ENUM_ELEMENT_TYPE)::FileReadInteger(file_handle,INT_VALUE);
      node=this.CreateElement();
      if(node==NULL)
         return false;
      this.Add(node);
      // --- Now the file pointer is offset relative to the beginning of the object marker by 12 bytes (8 - marker, 4 - type)
      // --- Let's place a pointer to the beginning of the object's data and load the object's properties from the file using the Load() method of the node element.
      if(!::FileSeek(file_handle,-12,SEEK_CUR))
         return false;
      result &=node.Load(file_handle);
     }
// --- Result
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
      case ELEMENT_TYPE_BASE              :  return new CBaseObj();           // Basic object of graphic elements
      case ELEMENT_TYPE_COLOR             :  return new CColor();             // Color object
      case ELEMENT_TYPE_COLORS_ELEMENT    :  return new CColorElement();      // Graphics Element Colors Object
      case ELEMENT_TYPE_RECTANGLE_AREA    :  return new CBound();             // Rectangular element area
      case ELEMENT_TYPE_IMAGE_PAINTER     :  return new CImagePainter();      // Object for drawing images
      case ELEMENT_TYPE_CANVAS_BASE       :  return new CCanvasBase();        // Basic graphic element canvas object
      case ELEMENT_TYPE_ELEMENT_BASE      :  return new CElementBase();       // Basic object of graphic elements
      case ELEMENT_TYPE_LABEL             :  return new CLabel();             // Text label
      case ELEMENT_TYPE_BUTTON            :  return new CButton();            // Simple button
      case ELEMENT_TYPE_BUTTON_TRIGGERED  :  return new CButtonTriggered();   // Two-position button
      case ELEMENT_TYPE_BUTTON_ARROW_UP   :  return new CButtonArrowUp();     // Up arrow button
      case ELEMENT_TYPE_BUTTON_ARROW_DOWN :  return new CButtonArrowDown();   // Down arrow button
      case ELEMENT_TYPE_BUTTON_ARROW_LEFT :  return new CButtonArrowLeft();   // Left Arrow Button
      case ELEMENT_TYPE_BUTTON_ARROW_RIGHT:  return new CButtonArrowRight();  // Right arrow button
      case ELEMENT_TYPE_CHECKBOX          :  return new CCheckBox();          // CheckBox control
      case ELEMENT_TYPE_RADIOBUTTON       :  return new CRadioButton();       // RadioButton control
      case ELEMENT_TYPE_PANEL             :  return new CPanel();             // Panel control
      case ELEMENT_TYPE_GROUPBOX          :  return new CGroupBox();          // GroupBox control
      case ELEMENT_TYPE_CONTAINER         :  return new CContainer();         // GroupBox control
      default                             :  return NULL;
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Picture Drawing Class |
//+------------------------------------------------------------------+
class CImagePainter : public CBaseObj
  {
protected:
   CCanvas          *m_canvas;                                 // Pointer to the canvas where we draw
   CBound            m_bound;                                  // Image coordinates and boundaries
   uchar             m_alpha;                                  // Transparency
   
// --- Checks the validity of the canvas and the correct dimensions
   bool              CheckBound(void);

public:
// --- (1) Assigns canvas to draw, (2) sets, (3) returns transparency
   void              CanvasAssign(CCanvas *canvas)             { this.m_canvas=canvas;                }
   void              SetAlpha(const uchar value)               { this.m_alpha=value;                  }
   uchar             Alpha(void)                         const { return this.m_alpha;                 }
   
// --- (1) Sets coordinates, (2) resizes area
   void              SetXY(const int x,const int y)            { this.m_bound.SetXY(x,y);             }
   void              SetSize(const int w,const int h)          { this.m_bound.Resize(w,h);            }
// --- Sets the coordinates and dimensions of the area
   void              SetBound(const int x,const int y,const int w,const int h)
                       {
                        this.SetXY(x,y);
                        this.SetSize(w,h);
                       }

// --- Returns the borders and dimensions of the picture
   int               X(void)                             const { return this.m_bound.X();             }
   int               Y(void)                             const { return this.m_bound.Y();             }
   int               Right(void)                         const { return this.m_bound.Right();         }
   int               Bottom(void)                        const { return this.m_bound.Bottom();        }
   int               Width(void)                         const { return this.m_bound.Width();         }
   int               Height(void)                        const { return this.m_bound.Height();        }
   
// --- Clears the area
   bool              Clear(const int x,const int y,const int w,const int h,const bool update=true);
// --- Draws a filled arrow (1) up, (2) down, (3) left, (4) right
   bool              ArrowUp(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool              ArrowDown(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool              ArrowLeft(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool              ArrowRight(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   
// --- Draws a (1) checked, (2) unchecked CheckBox
   bool              CheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool              UncheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   
// --- Draws a (1) checked, (2) unchecked RadioButton
   bool              CheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool              UncheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);

// --- Draws a frame for a group of elements
   bool              FrameGroupElements(const int x,const int y,const int w,const int h,const string text,
                                        const color clr_text,const color clr_dark,const color clr_light,
                                        const uchar alpha,const bool update=true);
   
// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_IMAGE_PAINTER);  }
   
// --- Constructors/destructor
                     CImagePainter(void) : m_canvas(NULL)               { this.SetBound(1,1,DEF_BUTTON_H-2,DEF_BUTTON_H-2); this.SetName("Image Painter");  }
                     CImagePainter(CCanvas *canvas) : m_canvas(canvas)  { this.SetBound(1,1,DEF_BUTTON_H-2,DEF_BUTTON_H-2); this.SetName("Image Painter");  }
                     CImagePainter(CCanvas *canvas,const int id,const string name) : m_canvas(canvas)
                       {
                        this.m_id=id;
                        this.SetName(name);
                        this.SetBound(1,1,DEF_BUTTON_H-2,DEF_BUTTON_H-2);
                       }
                     CImagePainter(CCanvas *canvas,const int id,const int dx,const int dy,const int w,const int h,const string name) : m_canvas(canvas)
                       {
                        this.m_id=id;
                        this.SetName(name);
                        this.SetBound(dx,dy,w,h);
                       }
                    ~CImagePainter(void) {}
  };
//+------------------------------------------------------------------+
// | CImagePainter::Comparing two objects |
//+------------------------------------------------------------------+
int CImagePainter::Compare(const CObject *node,const int mode=0) const
  {
   if(node==NULL)
      return -1;
   const CImagePainter *obj=node;
   switch(mode)
     {
      case ELEMENT_SORT_BY_NAME     :  return(this.Name()   >obj.Name()    ? 1 : this.Name()    <obj.Name()    ? -1 : 0);
      case ELEMENT_SORT_BY_ALPHA_FG :
      case ELEMENT_SORT_BY_ALPHA_BG :  return(this.Alpha()  >obj.Alpha()   ? 1 : this.Alpha()   <obj.Alpha()   ? -1 : 0);
      case ELEMENT_SORT_BY_X        :  return(this.X()      >obj.X()       ? 1 : this.X()       <obj.X()       ? -1 : 0);
      case ELEMENT_SORT_BY_Y        :  return(this.Y()      >obj.Y()       ? 1 : this.Y()       <obj.Y()       ? -1 : 0);
      case ELEMENT_SORT_BY_WIDTH    :  return(this.Width()  >obj.Width()   ? 1 : this.Width()   <obj.Width()   ? -1 : 0);
      case ELEMENT_SORT_BY_HEIGHT   :  return(this.Height() >obj.Height()  ? 1 : this.Height()  <obj.Height()  ? -1 : 0);
      default                       :  return(this.ID()     >obj.ID()      ? 1 : this.ID()      <obj.ID()      ? -1 : 0);
     }
  }
//+------------------------------------------------------------------+
// |CImagePainter::Checks the validity of the canvas and the correct dimensions|
//+------------------------------------------------------------------+
bool CImagePainter::CheckBound(void)
  {
   if(this.m_canvas==NULL)
     {
      ::PrintFormat("%s: Error. First you need to assign the canvas using the CanvasAssign() method",__FUNCTION__);
      return false;
     }
   if(this.Width()==0 || this.Height()==0)
     {
      ::PrintFormat("%s: Error. First you need to set the area size using the SetSize() or SetBound() methods",__FUNCTION__);
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
// | CImagePainter::Clears an area |
//+------------------------------------------------------------------+
bool CImagePainter::Clear(const int x,const int y,const int w,const int h,const bool update=true)
  {
// --- If the image area is not valid, return false
   if(!this.CheckBound())
      return false;
// --- Clear the entire image area with a transparent color
   this.m_canvas.FillRectangle(x,y,x+w-1,y+h-1,clrNULL);
// --- If indicated, update the canvas
   if(update)
      this.m_canvas.Update(false);
// --- Everything is successful
   return true;   
  }
//+------------------------------------------------------------------+
// | CImagePainter::Draws a filled up arrow |
//+------------------------------------------------------------------+
bool CImagePainter::ArrowUp(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
// --- If the image area is not valid, return false
   if(!this.CheckBound())
      return false;

// --- Calculate the coordinates of the arrow corners inside the image area
   int hw=(int)::floor(w/2);  // Half width
   if(hw==0)
      hw=1;

   int x1 = x + 1;            // X. Base (left point)
   int y1 = y + h - 4;        // Y. Left base point
   int x2 = x1 + hw;          // X. Apex (central top point)
   int y2 = y + 3;            // Y. Apex (highest point)
   int x3 = x1 + w - 1;       // X. Base (right point)
   int y3 = y1;               // Y. Base (right point)

// --- Draw a triangle
   this.m_canvas.FillTriangle(x1, y1, x2, y2, x3, y3, ::ColorToARGB(clr, alpha));
   if(update)
      this.m_canvas.Update(false);
   return true;   
  }
//+------------------------------------------------------------------+
// | CImagePainter::Draws a filled down arrow |
//+------------------------------------------------------------------+
bool CImagePainter::ArrowDown(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
// --- If the image area is not valid, return false
   if(!this.CheckBound())
      return false;

// --- Calculate the coordinates of the arrow corners inside the image area
   int hw=(int)::floor(w/2);  // Half width
   if(hw==0)
      hw=1;

   int x1=x+1;                // X. Base (left point)
   int y1=y+4;                // Y. Left base point
   int x2=x1+hw;              // X. Apex (central lowest point)
   int y2=y+h-3;              // Y. Apex (lowest point)
   int x3=x1+w-1;             // X. Base (right point)
   int y3=y1;                 // Y. Base (right point)

// --- Draw a triangle
   this.m_canvas.FillTriangle(x1, y1, x2, y2, x3, y3, ::ColorToARGB(clr, alpha));
   if(update)
      this.m_canvas.Update(false);
   return true;   
  }
//+------------------------------------------------------------------+
// | CImagePainter::Draws a filled left arrow |
//+------------------------------------------------------------------+
bool CImagePainter::ArrowLeft(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
// --- If the image area is not valid, return false
   if(!this.CheckBound())
      return false;

// --- Calculate the coordinates of the arrow corners inside the image area
   int hh=(int)::floor(h/2);  // Half height
   if(hh==0)
      hh=1;

   int x1=x+w-4;              // X. Base (right side)
   int y1=y+1;                // Y. Upper corner of base
   int x2=x+3;                // X. Vertex (left center point)
   int y2=y1+hh;              // Y. Center point (vertex)
   int x3=x1;                 // X. Bottom corner of base
   int y3=y1+h-1;             // Y. Bottom corner of base

// --- Draw a triangle
   this.m_canvas.FillTriangle(x1, y1, x2, y2, x3, y3, ::ColorToARGB(clr, alpha));

   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
// | CImagePainter::Draws a filled right arrow |
//+------------------------------------------------------------------+
bool CImagePainter::ArrowRight(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
// --- If the image area is not valid, return false
   if(!this.CheckBound())
      return false;

// --- Calculate the coordinates of the arrow corners inside the image area
   int hh=(int)::floor(h/2);  // Half height
   if(hh==0)
      hh=1;

   int x1=x+4;                // X. Triangle base (left side)
   int y1=y+1;                // Y. Upper corner of base
   int x2=x+w-3;              // X. Vertex (right center point)
   int y2=y1+hh;              // Y. Center point (vertex)
   int x3=x1;                 // X. Bottom corner of base
   int y3=y1+h-1;             // Y. Bottom corner of base

// --- Draw a triangle
   this.m_canvas.FillTriangle(x1, y1, x2, y2, x3, y3, ::ColorToARGB(clr, alpha));
   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
// | CImagePainter::Draws a checked CheckBox |
//+------------------------------------------------------------------+
bool CImagePainter::CheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
// --- If the image area is not valid, return false
   if(!this.CheckBound())
      return false;

// --- Rectangle coordinates
   int x1=x+1;                // Upper left corner, X
   int y1=y+1;                // Upper left corner, Y
   int x2=x+w-2;              // Bottom right corner, X
   int y2=y+h-2;              // Bottom right corner, Y

// --- Draw a rectangle
   this.m_canvas.Rectangle(x1, y1, x2, y2, ::ColorToARGB(clr, alpha));
   
// --- Coordinates of the "tick"
   int arrx[3], arry[3];
   
   arrx[0]=x1+(x2-x1)/4;      // X. Left point
   arrx[1]=x1+w/3;            // X. Center point
   arrx[2]=x2-(x2-x1)/4;      // X. Right point
   
   arry[0]=y1+1+(y2-y1)/2;    // Y. Left point
   arry[1]=y2-(y2-y1)/3;      // Y. Center point
   arry[2]=y1+(y2-y1)/3;      // Y. Right point
   
// --- Draw a “tick” with a line of double thickness
   this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr, alpha));
   arrx[0]++;
   arrx[1]++;
   arrx[2]++;
   this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr, alpha));
   
   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
// | CImagePainter::Draws an unchecked CheckBox |
//+------------------------------------------------------------------+
bool CImagePainter::UncheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
// --- If the image area is not valid, return false
   if(!this.CheckBound())
      return false;

// --- Rectangle coordinates
   int x1=x+1;                // Upper left corner, X
   int y1=y+1;                // Upper left corner, Y
   int x2=x+w-2;              // Bottom right corner, X
   int y2=y+h-2;              // Bottom right corner, Y

// --- Draw a rectangle
   this.m_canvas.Rectangle(x1, y1, x2, y2, ::ColorToARGB(clr, alpha));
   
   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
// | CImagePainter::Draws the marked RadioButton |
//+------------------------------------------------------------------+
bool CImagePainter::CheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
// --- If the image area is not valid, return false
   if(!this.CheckBound())
      return false;

// --- Coordinates and radius of the circle
   int x1=x+1;                // Upper left corner of the circle area, X
   int y1=y+1;                // Upper left corner of circle area, Y
   int x2=x+w-2;              // Lower right corner of circle area, X
   int y2=y+h-2;              // Bottom right corner of circle area, Y
   
// --- Coordinates and radius of the circle
   int d=::fmin(x2-x1,y2-y1); // Diameter on the smaller side (width or height)
   int r=d/2;                 // Radius
   if(r<2)
      r=2;
   int cx=x1+r;               // X coordinate of center
   int cy=y1+r;               // Center Y coordinate

// --- Draw a circle
   this.m_canvas.CircleWu(cx, cy, r, ::ColorToARGB(clr, alpha));
   
// --- "Mark" radius
   r/=2;
   if(r<1)
      r=1;
// --- Draw a mark
   this.m_canvas.FillCircle(cx, cy, r, ::ColorToARGB(clr, alpha));
   
   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
// | CImagePainter::Draws an unchecked RadioButton |
//+------------------------------------------------------------------+
bool CImagePainter::UncheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
// --- If the image area is not valid, return false
   if(!this.CheckBound())
      return false;

// --- Coordinates and radius of the circle
   int x1=x+1;                // Upper left corner of the circle area, X
   int y1=y+1;                // Upper left corner of circle area, Y
   int x2=x+w-2;              // Lower right corner of circle area, X
   int y2=y+h-2;              // Bottom right corner of circle area, Y
   
// --- Coordinates and radius of the circle
   int d=::fmin(x2-x1,y2-y1); // Diameter on the smaller side (width or height)
   int r=d/2;                 // Radius
   int cx=x1+r;               // X coordinate of center
   int cy=y1+r;               // Center Y coordinate

// --- Draw a circle
   this.m_canvas.CircleWu(cx, cy, r, ::ColorToARGB(clr, alpha));
   
   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
// | Draws a frame for a group of elements |
//+------------------------------------------------------------------+
bool CImagePainter::FrameGroupElements(const int x,const int y,const int w,const int h,const string text,
                                       const color clr_text,const color clr_dark,const color clr_light,
                                       const uchar alpha,const bool update=true)
  {
// --- If the image area is not valid, return false
   if(!this.CheckBound())
      return false;

// --- Y coordinate adjustment
   int tw=0, th=0;
   if(text!="" && text!=NULL)
      this.m_canvas.TextSize(text,tw,th);
   int shift_v=int(th!=0 ? ::ceil(th/2) : 0);

// --- Frame coordinates and dimensions
   int x1=x;                  // Top left corner of frame area, X
   int y1=y+shift_v;          // Top left corner of frame area, Y
   int x2=x+w-1;              // Bottom right corner of frame area, X
   int y2=y+h-1;              // Bottom right corner of frame area, Y
   
// --- Draw the left-upper part of the frame
   int arrx[3], arry[3];
   arrx[0]=arrx[1]=x1;
   arrx[2]=x2-1;
   arry[0]=y2;
   arry[1]=arry[2]=y1;
   this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr_dark, alpha));
   arrx[0]++;
   arrx[1]++;
   arry[1]++;
   arry[2]++;
   this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr_light, alpha));
// --- Draw the bottom-right part of the frame
   arrx[0]=arrx[1]=x2-1;
   arrx[2]=x1+1;
   arry[0]=y1;
   arry[1]=arry[2]=y2-1;
   this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr_dark, alpha));
   arrx[0]++;
   arrx[1]++;
   arry[1]++;
   arry[2]++;
   this.m_canvas.Polyline(arrx, arry, ::ColorToARGB(clr_light, alpha));
   
   if(tw>0)
      this.m_canvas.FillRectangle(x+5,y,x+7+tw,y+th,clrNULL);
   this.m_canvas.TextOut(x+6,y-1,text,::ColorToARGB(clr_text, alpha));
   
   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
// | CImagePainter::Saving to file |
//+------------------------------------------------------------------+
bool CImagePainter::Save(const int file_handle)
  {
// --- Save the data of the parent object
   if(!CBaseObj::Save(file_handle))
      return false;
  
// --- Maintaining transparency
   if(::FileWriteInteger(file_handle,this.m_alpha,INT_VALUE)!=INT_VALUE)
      return false;
// --- Save area data
   if(!this.m_bound.Save(file_handle))
      return false;
      
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | CImagePainter::Loading from file |
//+------------------------------------------------------------------+
bool CImagePainter::Load(const int file_handle)
  {
// --- Loading the data of the parent object
   if(!CBaseObj::Load(file_handle))
      return false;
      
// --- Loading transparency
   this.m_alpha=(uchar)::FileReadInteger(file_handle,INT_VALUE);
// --- Loading area data
   if(!this.m_bound.Load(file_handle))
      return false;
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Graphic element base class |
//+------------------------------------------------------------------+
class CElementBase : public CCanvasBase
  {
protected:
   CImagePainter     m_painter;                                // Drawing class
   int               m_group;                                  // Group of elements
public:
// --- Returns a pointer to the drawing class
   CImagePainter    *Painter(void)                             { return &this.m_painter;           }
   
// --- (1) Sets coordinates, (2) resizes image area
   void              SetImageXY(const int x,const int y)       { this.m_painter.SetXY(x,y);        }
   void              SetImageSize(const int w,const int h)     { this.m_painter.SetSize(w,h);      }
// --- Sets the coordinates and dimensions of the image area
   void              SetImageBound(const int x,const int y,const int w,const int h)
                       {
                        this.SetImageXY(x,y);
                        this.SetImageSize(w,h);
                       }
// --- Returns the coordinates of the (1) X, (2) Y, (3) width, (4) height, (5) right, (6) bottom border of the image area
   int               ImageX(void)                        const { return this.m_painter.X();        }
   int               ImageY(void)                        const { return this.m_painter.Y();        }
   int               ImageWidth(void)                    const { return this.m_painter.Width();    }
   int               ImageHeight(void)                   const { return this.m_painter.Height();   }
   int               ImageRight(void)                    const { return this.m_painter.Right();    }
   int               ImageBottom(void)                   const { return this.m_painter.Bottom();   }

// --- (1) Sets, (2) returns a group of elements
   virtual void      SetGroup(const int group)                 { this.m_group=group;               }
   int               Group(void)                         const { return this.m_group;              }
   
// --- Returns a description of the object
   virtual string    Description(void);
   
// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_ELEMENT_BASE);}

// --- Constructors/destructor
                     CElementBase(void) {}
                     CElementBase(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CElementBase(void) {}
  };
//+----------------------------------------------------------------------+
// | CElementBase::Parametric constructor. Builds an element at the specified|
// | window of the specified graph with the specified text, coordinates and dimensions |
//+----------------------------------------------------------------------+
CElementBase::CElementBase(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CCanvasBase(object_name,chart_id,wnd,x,y,w,h),m_group(-1)
  {
// --- Assign the foreground canvas to the drawing object and
// --- reset the coordinates and dimensions, which makes it inactive
   this.m_painter.CanvasAssign(this.GetForeground());
   this.m_painter.SetXY(0,0);
   this.m_painter.SetSize(0,0);
  }
//+------------------------------------------------------------------+
// | CElementBase::Comparing two objects |
//+------------------------------------------------------------------+
int CElementBase::Compare(const CObject *node,const int mode=0) const
  {
   if(node==NULL)
      return -1;
   const CElementBase *obj=node;
   switch(mode)
     {
      case ELEMENT_SORT_BY_NAME     :  return(this.Name()         >obj.Name()          ? 1 : this.Name()          <obj.Name()          ? -1 : 0);
      case ELEMENT_SORT_BY_X        :  return(this.X()            >obj.X()             ? 1 : this.X()             <obj.X()             ? -1 : 0);
      case ELEMENT_SORT_BY_Y        :  return(this.Y()            >obj.Y()             ? 1 : this.Y()             <obj.Y()             ? -1 : 0);
      case ELEMENT_SORT_BY_WIDTH    :  return(this.Width()        >obj.Width()         ? 1 : this.Width()         <obj.Width()         ? -1 : 0);
      case ELEMENT_SORT_BY_HEIGHT   :  return(this.Height()       >obj.Height()        ? 1 : this.Height()        <obj.Height()        ? -1 : 0);
      case ELEMENT_SORT_BY_COLOR_BG :  return(this.BackColor()    >obj.BackColor()     ? 1 : this.BackColor()     <obj.BackColor()     ? -1 : 0);
      case ELEMENT_SORT_BY_COLOR_FG :  return(this.ForeColor()    >obj.ForeColor()     ? 1 : this.ForeColor()     <obj.ForeColor()     ? -1 : 0);
      case ELEMENT_SORT_BY_ALPHA_BG :  return(this.AlphaBG()      >obj.AlphaBG()       ? 1 : this.AlphaBG()       <obj.AlphaBG()       ? -1 : 0);
      case ELEMENT_SORT_BY_ALPHA_FG :  return(this.AlphaFG()      >obj.AlphaFG()       ? 1 : this.AlphaFG()       <obj.AlphaFG()       ? -1 : 0);
      case ELEMENT_SORT_BY_STATE    :  return(this.State()        >obj.State()         ? 1 : this.State()         <obj.State()         ? -1 : 0);
      case ELEMENT_SORT_BY_GROUP    :  return(this.Group()        >obj.Group()         ? 1 : this.Group()         <obj.Group()         ? -1 : 0);
      case ELEMENT_SORT_BY_ZORDER   :  return(this.ObjectZOrder() >obj.ObjectZOrder()  ? 1 : this.ObjectZOrder()  <obj.ObjectZOrder()  ? -1 : 0);
      default                       :  return(this.ID()           >obj.ID()            ? 1 : this.ID()            <obj.ID()            ? -1 : 0);
     }
  }
//+------------------------------------------------------------------+
// | CElementBase::Returns the object description |
//+------------------------------------------------------------------+
string CElementBase::Description(void)
  {
   string nm=this.Name();
   string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   string area=::StringFormat("x %d, y %d, w %d, h %d",this.X(),this.Y(),this.Width(),this.Height());
   return ::StringFormat("%s%s (%s, %s): ID %d, Group %d, %s",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.NameBG(),this.NameFG(),this.ID(),this.Group(),area);
  }
//+------------------------------------------------------------------+
// | CElementBase::Saving to file |
//+------------------------------------------------------------------+
bool CElementBase::Save(const int file_handle)
  {
// --- Save the data of the parent object
   if(!CCanvasBase::Save(file_handle))
      return false;
  
// --- Save the image object
   if(!this.m_painter.Save(file_handle))
      return false;
// --- Save the group
   if(::FileWriteInteger(file_handle,this.m_group,INT_VALUE)!=INT_VALUE)
      return false;
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | CElementBase::Loading from file |
//+------------------------------------------------------------------+
bool CElementBase::Load(const int file_handle)
  {
// --- Loading the data of the parent object
   if(!CCanvasBase::Load(file_handle))
      return false;
      
// --- Loading the image object
   if(!this.m_painter.Load(file_handle))
      return false;
// --- Loading the group
   this.m_group=::FileReadInteger(file_handle,INT_VALUE);
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Text Label Class |
//+------------------------------------------------------------------+
class CLabel : public CElementBase
  {
protected:
   ushort            m_text[];                                 // Text
   ushort            m_text_prev[];                            // Past text
   int               m_text_x;                                 // X coordinate of the text (offset relative to the left edge of the object)
   int               m_text_y;                                 // Y coordinate of the text (offset relative to the top border of the object)
   
// --- (1) Sets, (2) returns past text
   void              SetTextPrev(const string text)            { ::StringToShortArray(text,this.m_text_prev);  }
   string            TextPrev(void)                      const { return ::ShortArrayToString(this.m_text_prev);}
      
// --- Erases text
   void              ClearText(void);

public:
// --- (1) Sets, (2) returns text
   void              SetText(const string text)                { ::StringToShortArray(text,this.m_text);       }
   string            Text(void)                          const { return ::ShortArrayToString(this.m_text);     }
   
// --- Returns the (1) X, (2) Y coordinate of the text
   int               TextX(void)                         const { return this.m_text_x;                         }
   int               TextY(void)                         const { return this.m_text_y;                         }

// --- Sets the (1) X, (2) Y coordinate of the text
   void              SetTextShiftH(const int x)                { this.ClearText(); this.m_text_x=x;            }
   void              SetTextShiftV(const int y)                { this.ClearText(); this.m_text_y=y;            }
   
// --- Outputs text
   void              DrawText(const int dx, const int dy, const string text, const bool chart_redraw);
   
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_LABEL);                   }

// --- Initialize (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void){}
   
// --- Constructors/destructor
                     CLabel(void);
                     CLabel(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CLabel(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CLabel(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CLabel(void) {}
  };
//+------------------------------------------------------------------+
// | CLabel::Default constructor. Builds a label in the main window |
// | current chart in coordinates 0,0 with default sizes |
//+------------------------------------------------------------------+
CLabel::CLabel(void) : CElementBase("Label","Label",::ChartID(),0,0,0,DEF_LABEL_W,DEF_LABEL_H), m_text_x(0), m_text_y(0)
  {
// ---Initialization
   this.Init("Label");
  }
//+------------------------------------------------------------------+
// | CLabel::The constructor is parametric. Builds a label in the main window |
// | current chart with the specified text, coordinates and sizes |
//+------------------------------------------------------------------+
CLabel::CLabel(const string object_name, const string text,const int x,const int y,const int w,const int h) :
   CElementBase(object_name,text,::ChartID(),0,x,y,w,h), m_text_x(0), m_text_y(0)
  {
// ---Initialization
   this.Init(text);
  }
//+-------------------------------------------------------------------+
// | CLabel::The constructor is parametric. Builds a label in the specified window|
// | current chart with the specified text, coordinates and sizes |
//+-------------------------------------------------------------------+
CLabel::CLabel(const string object_name, const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CElementBase(object_name,text,::ChartID(),wnd,x,y,w,h), m_text_x(0), m_text_y(0)
  {
// ---Initialization
   this.Init(text);
  }
//+-------------------------------------------------------------------+
// | CLabel::The constructor is parametric. Builds a label in the specified window|
// | specified graphics with specified text, coordinates and dimensions |
//+-------------------------------------------------------------------+
CLabel::CLabel(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CElementBase(object_name,text,chart_id,wnd,x,y,w,h), m_text_x(0), m_text_y(0)
  {
// ---Initialization
   this.Init(text);
  }
//+------------------------------------------------------------------+
// | CLabel::Initialization |
//+------------------------------------------------------------------+
void CLabel::Init(const string text)
  {
// --- Set the current and previous text
   this.SetText(text);
   this.SetTextPrev("");
// --- Background is transparent, foreground is not
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
  }
//+------------------------------------------------------------------+
// | CLabel::Comparing two objects |
//+------------------------------------------------------------------+
int CLabel::Compare(const CObject *node,const int mode=0) const
  {
   if(node==NULL)
      return -1;
   const CLabel *obj=node;
   switch(mode)
     {
      case ELEMENT_SORT_BY_NAME     :  return(this.Name()         >obj.Name()          ? 1 : this.Name()          <obj.Name()          ? -1 : 0);
      case ELEMENT_SORT_BY_TEXT     :  return(this.Text()         >obj.Text()          ? 1 : this.Text()          <obj.Text()          ? -1 : 0);
      case ELEMENT_SORT_BY_X        :  return(this.X()            >obj.X()             ? 1 : this.X()             <obj.X()             ? -1 : 0);
      case ELEMENT_SORT_BY_Y        :  return(this.Y()            >obj.Y()             ? 1 : this.Y()             <obj.Y()             ? -1 : 0);
      case ELEMENT_SORT_BY_WIDTH    :  return(this.Width()        >obj.Width()         ? 1 : this.Width()         <obj.Width()         ? -1 : 0);
      case ELEMENT_SORT_BY_HEIGHT   :  return(this.Height()       >obj.Height()        ? 1 : this.Height()        <obj.Height()        ? -1 : 0);
      case ELEMENT_SORT_BY_COLOR_BG :  return(this.BackColor()    >obj.BackColor()     ? 1 : this.BackColor()     <obj.BackColor()     ? -1 : 0);
      case ELEMENT_SORT_BY_COLOR_FG :  return(this.ForeColor()    >obj.ForeColor()     ? 1 : this.ForeColor()     <obj.ForeColor()     ? -1 : 0);
      case ELEMENT_SORT_BY_ALPHA_BG :  return(this.AlphaBG()      >obj.AlphaBG()       ? 1 : this.AlphaBG()       <obj.AlphaBG()       ? -1 : 0);
      case ELEMENT_SORT_BY_ALPHA_FG :  return(this.AlphaFG()      >obj.AlphaFG()       ? 1 : this.AlphaFG()       <obj.AlphaFG()       ? -1 : 0);
      case ELEMENT_SORT_BY_STATE    :  return(this.State()        >obj.State()         ? 1 : this.State()         <obj.State()         ? -1 : 0);
      case ELEMENT_SORT_BY_ZORDER   :  return(this.ObjectZOrder() >obj.ObjectZOrder()  ? 1 : this.ObjectZOrder()  <obj.ObjectZOrder()  ? -1 : 0);
      default                       :  return(this.ID()           >obj.ID()            ? 1 : this.ID()            <obj.ID()            ? -1 : 0);
     }
  }
//+------------------------------------------------------------------+
// | CLabel::Erases text |
//+------------------------------------------------------------------+
void CLabel::ClearText(void)
  {
   int w=0, h=0;
   string text=this.TextPrev();
// --- Getting the dimensions of the previous text
   if(text!="")
      this.m_foreground.TextSize(text,w,h);
// --- If the dimensions are obtained, draw a transparent rectangle in place of the text, erasing the text
   if(w>0 && h>0)
      this.m_foreground.FillRectangle(this.AdjX(this.m_text_x),this.AdjY(this.m_text_y),this.AdjX(this.m_text_x+w),this.AdjY(this.m_text_y+h),clrNULL);
// --- Otherwise, we completely clear the entire foreground
   else
      this.m_foreground.Erase(clrNULL);
  }
//+------------------------------------------------------------------+
// | CLabel::Outputs text |
//+------------------------------------------------------------------+
void CLabel::DrawText(const int dx,const int dy,const string text,const bool chart_redraw)
  {
// --- Clear the previous text and install a new one
   this.ClearText();
   this.SetText(text);
// --- Output the set text
   this.m_foreground.TextOut(this.AdjX(dx),this.AdjY(dy),this.Text(),::ColorToARGB(this.ForeColor(),this.AlphaFG()));
   
// --- If the text extends beyond the right border of the object
   if(this.Width()-dx<this.m_foreground.TextWidth(text))
     {
      // --- Getting the dimensions of the text "ellipsis"
      int w=0,h=0;
      this.m_foreground.TextSize("... ",w,h);
      if(w>0 && h>0)
        {
         // --- Erase the text at the right border of the object according to the text size "ellipsis" and replace the end of the label text with an ellipsis
         this.m_foreground.FillRectangle(this.AdjX(this.Width()-w),this.AdjY(this.m_text_y),this.AdjX(this.Width()),this.AdjY(this.m_text_y+h),clrNULL);
         this.m_foreground.TextOut(this.AdjX(this.Width()-w),this.AdjY(dy),"...",::ColorToARGB(this.ForeColor(),this.AlphaFG()));
        }
     }
// --- Update the foreground canvas and remember the new text coordinates
   this.m_foreground.Update(chart_redraw);
   this.m_text_x=dx;
   this.m_text_y=dy;
// --- Remember the drawn text as the previous one
   this.SetTextPrev(text);
  }
//+------------------------------------------------------------------+
// | CLabel::Draws appearance |
//+------------------------------------------------------------------+
void CLabel::Draw(const bool chart_redraw)
  {
   this.DrawText(this.m_text_x,this.m_text_y,this.Text(),chart_redraw);
  }
//+------------------------------------------------------------------+
// | CLabel::Save to file |
//+------------------------------------------------------------------+
bool CLabel::Save(const int file_handle)
  {
// --- Save the data of the parent object
   if(!CElementBase::Save(file_handle))
      return false;
  
// --- Save the text
   if(::FileWriteArray(file_handle,this.m_text)!=sizeof(this.m_text))
      return false;
// --- Save the previous text
   if(::FileWriteArray(file_handle,this.m_text_prev)!=sizeof(this.m_text_prev))
      return false;
// --- Save the X coordinate of the text
   if(::FileWriteInteger(file_handle,this.m_text_x,INT_VALUE)!=INT_VALUE)
      return false;
// --- Save the Y coordinate of the text
   if(::FileWriteInteger(file_handle,this.m_text_y,INT_VALUE)!=INT_VALUE)
      return false;
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | CLabel::Loading from file |
//+------------------------------------------------------------------+
bool CLabel::Load(const int file_handle)
  {
// --- Loading the data of the parent object
   if(!CElementBase::Load(file_handle))
      return false;
      
// --- Loading text
   if(::FileReadArray(file_handle,this.m_text)!=sizeof(this.m_text))
      return false;
// --- Loading the previous text
   if(::FileReadArray(file_handle,this.m_text_prev)!=sizeof(this.m_text_prev))
      return false;
// --- Load the X coordinate of the text
   this.m_text_x=::FileReadInteger(file_handle,INT_VALUE);
// --- Load the Y coordinate of the text
   this.m_text_y=::FileReadInteger(file_handle,INT_VALUE);
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Simple button class |
//+------------------------------------------------------------------+
class CButton : public CLabel
  {
public:
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CLabel::Save(file_handle); }
   virtual bool      Load(const int file_handle)               { return CLabel::Load(file_handle); }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON);      }
   
// --- Initialize (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void){}
   
// --- Timer event handler
   virtual void      TimerEventHandler(void);
   
// --- Constructors/destructor
                     CButton(void);
                     CButton(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CButton(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CButton(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButton (void) {}
  };
//+------------------------------------------------------------------+
// | CButton::Default constructor. Builds a button in the main window |
// | current chart in coordinates 0,0 with default sizes |
//+------------------------------------------------------------------+
CButton::CButton(void) : CLabel("Button","Button",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
// ---Initialization
   this.Init("");
  }
//+-------------------------------------------------------------------+
// | CButton::The constructor is parametric. Builds a button in the main window|
// | current chart with the specified text, coordinates and sizes |
//+-------------------------------------------------------------------+
CButton::CButton(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CLabel(object_name,text,::ChartID(),0,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+---------------------------------------------------------------------+
// | CButton::The constructor is parametric. Builds a button in the specified window|
// | current chart with the specified text, coordinates and sizes |
//+---------------------------------------------------------------------+
CButton::CButton(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CLabel(object_name,text,::ChartID(),wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+---------------------------------------------------------------------+
// | CButton::The constructor is parametric. Builds a button in the specified window|
// | specified graphics with specified text, coordinates and dimensions |
//+---------------------------------------------------------------------+
CButton::CButton(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CLabel(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButton::Initialization |
//+------------------------------------------------------------------+
void CButton::Init(const string text)
  {
// --- Set the default state
   this.SetState(ELEMENT_STATE_DEF);
// ---Background and foreground - opaque
   this.SetAlpha(255);
// --- Offset text from left edge of button by default
   this.m_text_x=2;
// --- Auto-repeat is disabled
   this.m_autorepeat_flag=false;
  }
//+------------------------------------------------------------------+
// | CButton::Comparing two objects |
//+------------------------------------------------------------------+
int CButton::Compare(const CObject *node,const int mode=0) const
  {
   return CLabel::Compare(node,mode);
  }
//+------------------------------------------------------------------+
// | CButton::Draws appearance |
//+------------------------------------------------------------------+
void CButton::Draw(const bool chart_redraw)
  {
// --- Fill the button with the background color, draw a frame and update the background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
// --- Display button text
   CLabel::Draw(false);
      
// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | Timer event handler |
//+------------------------------------------------------------------+
void CButton::TimerEventHandler(void)
  {
   if(this.m_autorepeat_flag)
      this.m_autorepeat.Process();
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Two-way button class |
//+------------------------------------------------------------------+
class CButtonTriggered : public CButton
  {
public:
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
   virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_TRIGGERED);  }
  
// --- Event handler for mouse button clicks (Press)
   virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);

// --- Initialize (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void);
   
// --- Constructors/destructor
                     CButtonTriggered(void);
                     CButtonTriggered(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CButtonTriggered(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CButtonTriggered(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButtonTriggered (void) {}
  };
//+------------------------------------------------------------------+
// | CButtonTriggered::Default constructor.                      |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CButtonTriggered::CButtonTriggered(void) : CButton("Button","Button",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Parametric constructor.                   |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonTriggered::CButtonTriggered(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,::ChartID(),0,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Parametric constructor.                   |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonTriggered::CButtonTriggered(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,::ChartID(),wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Parametric constructor.                   |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonTriggered::CButtonTriggered(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Initializing |
//+------------------------------------------------------------------+
void CButtonTriggered::Init(const string text)
  {
// --- Initialize default colors
   this.InitColors();
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Initializing default object colors |
//+------------------------------------------------------------------+
void CButtonTriggered::InitColors(void)
  {
// --- Initialize the background colors for normal and activated states and make it the current background color
   this.InitBackColors(clrWhiteSmoke);
   this.InitBackColorsAct(clrLightBlue);
   this.BackColorToDefault();
   
// --- Initialize the foreground colors for normal and activated states and make it the current text color
   this.InitForeColors(clrBlack);
   this.InitForeColorsAct(clrBlack);
   this.ForeColorToDefault();
   
// --- Initialize the border colors for the normal and activated states and make it the current border color
   this.InitBorderColors(clrDarkGray);
   this.InitBorderColorsAct(clrGreen);
   this.BorderColorToDefault();
   
// --- Initialize the border color and foreground color for the blocked element
   this.InitBorderColorBlocked(clrLightGray);
   this.InitForeColorBlocked(clrSilver);
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Comparing two objects |
//+------------------------------------------------------------------+
int CButtonTriggered::Compare(const CObject *node,const int mode=0) const
  {
   return CButton::Compare(node,mode);
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Draws appearance |
//+------------------------------------------------------------------+
void CButtonTriggered::Draw(const bool chart_redraw)
  {
// --- Fill the button with the background color, draw a frame and update the background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
// --- Display button text
   CLabel::Draw(false);
      
// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Event handler for mouse button clicks (Press)|
//+------------------------------------------------------------------+
void CButtonTriggered::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
// --- Set the button state opposite to the one already set
   ENUM_ELEMENT_STATE state=(this.State()==ELEMENT_STATE_DEF ? ELEMENT_STATE_ACT : ELEMENT_STATE_DEF);
   this.SetState(state);
   
// --- Call the handler of the parent object indicating the identifier in lparam and the state in dparam
   CCanvasBase::OnPressEvent(id,this.m_id,this.m_state,sparam);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Up arrow button class |
//+------------------------------------------------------------------+
class CButtonArrowUp : public CButton
  {
public:
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
   virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_ARROW_UP);}
   
// --- Initialize (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void){}
   
// --- Constructors/destructor
                     CButtonArrowUp(void);
                     CButtonArrowUp(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CButtonArrowUp(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CButtonArrowUp(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButtonArrowUp (void) {}
  };
//+------------------------------------------------------------------+
// | CButtonArrowUp::Default constructor.                        |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CButtonArrowUp::CButtonArrowUp(void) : CButton("Arrow Up Button","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowUp::Parametric constructor.                     |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowUp::CButtonArrowUp(const string object_name, const string text,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,::ChartID(),0,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowUp::Parametric constructor.                     |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowUp::CButtonArrowUp(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,::ChartID(),wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowUp::Parametric constructor.                     |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowUp::CButtonArrowUp(const string object_name, const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowUp::Initialization |
//+------------------------------------------------------------------+
void CButtonArrowUp::Init(const string text)
  {
// --- Initialize default colors
   this.InitColors();
// --- Set the offset and dimensions of the image area
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);

// --- Initialize auto-repeat counters
   this.m_autorepeat_flag=true;

// --- Initialize the properties of the event auto-repeat control object
   this.m_autorepeat.SetChartID(this.m_chart_id);
   this.m_autorepeat.SetID(0);
   this.m_autorepeat.SetName("ButtUpAutorepeatControl");
   this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
   this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
   this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
  }
//+------------------------------------------------------------------+
// | CButtonArrowUp::Comparing two objects |
//+------------------------------------------------------------------+
int CButtonArrowUp::Compare(const CObject *node,const int mode=0) const
  {
   return CButton::Compare(node,mode);
  }
//+------------------------------------------------------------------+
// | CButtonArrowUp::Draws appearance |
//+------------------------------------------------------------------+
void CButtonArrowUp::Draw(const bool chart_redraw)
  {
// --- Fill the button with the background color, draw a frame and update the background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
// --- Display button text
   CLabel::Draw(false);
// --- Clear the drawing area
   this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
// --- Set the arrow color for the normal and locked states of the button and draw an up arrow
   color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
   this.m_painter.ArrowUp(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
      
// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Down arrow button class |
//+------------------------------------------------------------------+
class CButtonArrowDown : public CButton
  {
public:
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
   virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_ARROW_DOWN); }
   
// --- Initialize (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void){}
   
// --- Constructors/destructor
                     CButtonArrowDown(void);
                     CButtonArrowDown(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CButtonArrowDown(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CButtonArrowDown(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButtonArrowDown (void) {}
  };
//+------------------------------------------------------------------+
// | CButtonArrowDown::Default constructor.                      |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CButtonArrowDown::CButtonArrowDown(void) : CButton("Arrow Up Button","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowDown::Parametric constructor.                   |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowDown::CButtonArrowDown(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,::ChartID(),0,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowDown::Parametric constructor.                   |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowDown::CButtonArrowDown(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,::ChartID(),wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowDown::Parametric constructor.                   |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowDown::CButtonArrowDown(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowDown::Initialization |
//+------------------------------------------------------------------+
void CButtonArrowDown::Init(const string text)
  {
// --- Initialize default colors
   this.InitColors();
// --- Set the offset and dimensions of the image area
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);

// --- Initialize auto-repeat counters
   this.m_autorepeat_flag=true;

// --- Initialize the properties of the event auto-repeat control object
   this.m_autorepeat.SetChartID(this.m_chart_id);
   this.m_autorepeat.SetID(0);
   this.m_autorepeat.SetName("ButtDownAutorepeatControl");
   this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
   this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
   this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
  }
//+------------------------------------------------------------------+
// | CButtonArrowDown::Comparing two objects |
//+------------------------------------------------------------------+
int CButtonArrowDown::Compare(const CObject *node,const int mode=0) const
  {
   return CButton::Compare(node,mode);
  }
//+------------------------------------------------------------------+
// | CButtonArrowDown::Draws appearance |
//+------------------------------------------------------------------+
void CButtonArrowDown::Draw(const bool chart_redraw)
  {
// --- Fill the button with the background color, draw a frame and update the background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
// --- Display button text
   CLabel::Draw(false);
// --- Clear the drawing area
   this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
// --- Set the arrow color for the normal and locked states of the button and draw a down arrow
   color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
   this.m_painter.ArrowDown(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
      
// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Left arrow button class |
//+------------------------------------------------------------------+
class CButtonArrowLeft : public CButton
  {
public:
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
   virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_ARROW_DOWN); }
   
// --- Initialize (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void){}
   
// --- Constructors/destructor
                     CButtonArrowLeft(void);
                     CButtonArrowLeft(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CButtonArrowLeft(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CButtonArrowLeft(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButtonArrowLeft (void) {}
  };
//+------------------------------------------------------------------+
// | CButtonArrowLeft::Default constructor.                      |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CButtonArrowLeft::CButtonArrowLeft(void) : CButton("Arrow Up Button","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowLeft::Parametric constructor.                   |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowLeft::CButtonArrowLeft(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,::ChartID(),0,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowLeft::Parametric constructor.                   |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowLeft::CButtonArrowLeft(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,::ChartID(),wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowLeft::Parametric constructor.                   |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowLeft::CButtonArrowLeft(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowLeft::Initialization |
//+------------------------------------------------------------------+
void CButtonArrowLeft::Init(const string text)
  {
// --- Initialize default colors
   this.InitColors();
// --- Set the offset and dimensions of the image area
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);

// --- Initialize auto-repeat counters
   this.m_autorepeat_flag=true;

// --- Initialize the properties of the event auto-repeat control object
   this.m_autorepeat.SetChartID(this.m_chart_id);
   this.m_autorepeat.SetID(0);
   this.m_autorepeat.SetName("ButtLeftAutorepeatControl");
   this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
   this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
   this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
  }
//+------------------------------------------------------------------+
// | CButtonArrowLeft::Comparing two objects |
//+------------------------------------------------------------------+
int CButtonArrowLeft::Compare(const CObject *node,const int mode=0) const
  {
   return CButton::Compare(node,mode);
  }
//+------------------------------------------------------------------+
// | CButtonArrowLeft::Draws appearance |
//+------------------------------------------------------------------+
void CButtonArrowLeft::Draw(const bool chart_redraw)
  {
// --- Fill the button with the background color, draw a frame and update the background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
// --- Display button text
   CLabel::Draw(false);
// --- Clear the drawing area
   this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
// --- Set the arrow color for the normal and locked states of the button and draw a left arrow
   color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
   this.m_painter.ArrowLeft(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
      
// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Right arrow button class |
//+------------------------------------------------------------------+
class CButtonArrowRight : public CButton
  {
public:
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
   virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_ARROW_DOWN); }
   
// --- Initialize (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void){}
   
// --- Constructors/destructor
                     CButtonArrowRight(void);
                     CButtonArrowRight(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CButtonArrowRight(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CButtonArrowRight(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButtonArrowRight (void) {}
  };
//+------------------------------------------------------------------+
// | CButtonArrowRight::Default constructor.                     |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CButtonArrowRight::CButtonArrowRight(void) : CButton("Arrow Up Button","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowRight::Parametric constructor.                  |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowRight::CButtonArrowRight(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,::ChartID(),0,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowRight::Parametric constructor.                  |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowRight::CButtonArrowRight(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,::ChartID(),wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowRight::Parametric constructor.                  |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowRight::CButtonArrowRight(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CButtonArrowRight::Initializing |
//+------------------------------------------------------------------+
void CButtonArrowRight::Init(const string text)
  {
// --- Initialize default colors
   this.InitColors();
// --- Set the offset and dimensions of the image area
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);

// --- Initialize auto-repeat counters
   this.m_autorepeat_flag=true;

// --- Initialize the properties of the event auto-repeat control object
   this.m_autorepeat.SetChartID(this.m_chart_id);
   this.m_autorepeat.SetID(0);
   this.m_autorepeat.SetName("ButtRightAutorepeatControl");
   this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
   this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
   this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
  }
//+------------------------------------------------------------------+
// | CButtonArrowRight::Comparing two objects |
//+------------------------------------------------------------------+
int CButtonArrowRight::Compare(const CObject *node,const int mode=0) const
  {
   return CButton::Compare(node,mode);
  }
//+------------------------------------------------------------------+
// | CButtonArrowRight::Draws appearance |
//+------------------------------------------------------------------+
void CButtonArrowRight::Draw(const bool chart_redraw)
  {
// --- Fill the button with the background color, draw a frame and update the background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
// --- Display button text
   CLabel::Draw(false);
// --- Clear the drawing area
   this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
// --- Set the arrow color for the normal and locked states of the button and draw an arrow to the right
   color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
   this.m_painter.ArrowRight(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
      
// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Checkbox Control Class |
//+------------------------------------------------------------------+
class CCheckBox : public CButtonTriggered
  {
public:
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
   virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_CHECKBOX);       }
  
// --- Initialize (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void);
   
// --- Constructors/destructor
                     CCheckBox(void);
                     CCheckBox(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CCheckBox(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CCheckBox(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CCheckBox (void) {}
  };
//+------------------------------------------------------------------+
// | CCheckBox::Default constructor.                             |
// | Plots an element in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CCheckBox::CCheckBox(void) : CButtonTriggered("CheckBox","CheckBox",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CCheckBox::Parametric constructor.                          |
// | Plots an element in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CCheckBox::CCheckBox(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CButtonTriggered(object_name,text,::ChartID(),0,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CCheckBox::Parametric constructor.                          |
// | Plots an element in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CCheckBox::CCheckBox(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CButtonTriggered(object_name,text,::ChartID(),wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CCheckBox::Parametric constructor.                          |
// | Строит элемент в указанном окне указанного графика               |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CCheckBox::CCheckBox(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButtonTriggered(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CCheckBox::Initialization |
//+------------------------------------------------------------------+
void CCheckBox::Init(const string text)
  {
// --- Set default colors, transparency for background and foreground,
// --- and coordinates and boundaries of the button icon drawing area
   this.InitColors();
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CCheckBox::Initializing default object colors |
//+------------------------------------------------------------------+
void CCheckBox::InitColors(void)
  {
// --- Initialize the background colors for normal and activated states and make it the current background color
   this.InitBackColors(clrNULL);
   this.InitBackColorsAct(clrNULL);
   this.BackColorToDefault();
   
// --- Initialize the foreground colors for normal and activated states and make it the current text color
   this.InitForeColors(clrBlack);
   this.InitForeColorsAct(clrBlack);
   this.InitForeColorFocused(clrNavy);
   this.InitForeColorActFocused(clrNavy);
   this.ForeColorToDefault();
   
// --- Initialize the border colors for the normal and activated states and make it the current border color
   this.InitBorderColors(clrNULL);
   this.InitBorderColorsAct(clrNULL);
   this.BorderColorToDefault();

// --- Initialize the border color and foreground color for the blocked element
   this.InitBorderColorBlocked(clrNULL);
   this.InitForeColorBlocked(clrSilver);
  }
//+------------------------------------------------------------------+
// | CCheckBox::Comparing two objects |
//+------------------------------------------------------------------+
int CCheckBox::Compare(const CObject *node,const int mode=0) const
  {
   return CButtonTriggered::Compare(node,mode);
  }
//+------------------------------------------------------------------+
// | CCheckBox::Draws appearance |
//+------------------------------------------------------------------+
void CCheckBox::Draw(const bool chart_redraw)
  {
// --- Fill the button with the background color, draw a frame and update the background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
// --- Display button text
   CLabel::Draw(false);
   
// --- Clear the drawing area
   this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
// --- Draw a marked icon for the active state of the button,
   if(this.m_state)
      this.m_painter.CheckedBox(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
// --- and unchecked - for inactive
   else
      this.m_painter.UncheckedBox(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
      
// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Radio Button Control Class |
//+------------------------------------------------------------------+
class CRadioButton : public CCheckBox
  {
public:
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
   virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_RADIOBUTTON);    }
  
// --- Initialize (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void){}
   
// --- Event handler for mouse button clicks (Press)
   virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);

// --- Constructors/destructor
                     CRadioButton(void);
                     CRadioButton(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CRadioButton(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CRadioButton(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CRadioButton (void) {}
  };
//+------------------------------------------------------------------+
// | CRadioButton::Default constructor.                          |
// | Plots an element in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CRadioButton::CRadioButton(void) : CCheckBox("RadioButton","",::ChartID(),0,0,0,DEF_BUTTON_H,DEF_BUTTON_H)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CRadioButton::Parametric constructor.                       |
// | Plots an element in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CRadioButton::CRadioButton(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CCheckBox(object_name,text,::ChartID(),0,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CRadioButton::Parametric constructor.                       |
// | Plots an element in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CRadioButton::CRadioButton(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CCheckBox(object_name,text,::ChartID(),wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CRadioButton::Parametric constructor.                       |
// | Plots an element in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CRadioButton::CRadioButton(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CCheckBox(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CRadioButton::Initialization |
//+------------------------------------------------------------------+
void CRadioButton::Init(const string text)
  {
   return;
  }
//+------------------------------------------------------------------+
// | CRadioButton::Comparing two objects |
//+------------------------------------------------------------------+
int CRadioButton::Compare(const CObject *node,const int mode=0) const
  {
   return CCheckBox::Compare(node,mode);
  }
//+------------------------------------------------------------------+
// | CRadioButton::Draws appearance |
//+------------------------------------------------------------------+
void CRadioButton::Draw(const bool chart_redraw)
  {
// --- Fill the button with the background color, draw a frame and update the background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
// --- Display button text
   CLabel::Draw(false);
   
// --- Clear the drawing area
   this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
// --- Draw a marked icon for the active state of the button,
   if(this.m_state)
      this.m_painter.CheckedRadioButton(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
// --- and unchecked - for inactive
   else
      this.m_painter.UncheckedRadioButton(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
      
// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CRadioButton::Event handler for mouse button clicks (Press) |
//+------------------------------------------------------------------+
void CRadioButton::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
// --- If the button is already marked, we leave
   if(this.m_state)
      return;
// --- Set the button state opposite to the one already set
   ENUM_ELEMENT_STATE state=(this.State()==ELEMENT_STATE_DEF ? ELEMENT_STATE_ACT : ELEMENT_STATE_DEF);
   this.SetState(state);
   
// --- Call the handler of the parent object indicating the identifier in lparam and the state in dparam
   CCanvasBase::OnPressEvent(id,this.m_id,this.m_state,sparam);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Panel class |
//+------------------------------------------------------------------+
class CPanel : public CLabel
  {
private:
   CElementBase      m_temp_elm;                // Temporary object for searching elements
   CBound            m_temp_bound;              // Temporary object for searching areas
protected:
   CListObj          m_list_elm;                // List of attached items
   CListObj          m_list_bounds;             // List of areas
// --- Adds a new element to the list
   bool              AddNewElement(CElementBase *element);

public:
// --- Returns a pointer to a list of (1) attached items, (2) areas
   CListObj         *GetListAttachedElements(void)             { return &this.m_list_elm;                         }
   CListObj         *GetListBounds(void)                       { return &this.m_list_bounds;                      }
// --- Returns the element by (1) index in the list, (2) identifier, (3) assigned object name
   CElementBase     *GetAttachedElementAt(const uint index)    { return this.m_list_elm.GetNodeAtIndex(index);    }
   CElementBase     *GetAttachedElementByID(const int id);
   CElementBase     *GetAttachedElementByName(const string name);
   
// --- Returns the area by (1) index in the list, (2) identifier, (3) assigned area name
   CBound           *GetBoundAt(const uint index)              { return this.m_list_bounds.GetNodeAtIndex(index); }
   CBound           *GetBoundByID(const int id);
   CBound           *GetBoundByName(const string name);
   
// --- Creates and adds (1) a new, (2) a previously created element to the list
   virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
   virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);

// --- Creates and adds a new area to the list
   CBound           *InsertNewBound(const string name,const int dx,const int dy,const int w,const int h);
   
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);
   
// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_PANEL);                      }
  
// --- Initialize (1) class object, (2) default object colors
   void              Init(void);
   virtual void      InitColors(void);
   
// --- Sets the object to new XY coordinates
   virtual bool      Move(const int x,const int y);
// --- Offsets the object along the XY axes by the specified offset
   virtual bool      Shift(const int dx,const int dy);

// --- (1) Hides (2) displays the object on all chart periods,
// --- (3) brings the item to the front, (4) locks, (5) unlocks the item,
   virtual void      Hide(const bool chart_redraw);
   virtual void      Show(const bool chart_redraw);
   virtual void      BringToTop(const bool chart_redraw);
   virtual void      Block(const bool chart_redraw);
   virtual void      Unblock(const bool chart_redraw);
   
// --- Logs a description of the object
   virtual void      Print(void);
   
// --- Prints a list of (1) attached objects, (2) areas
   void              PrintAttached(const uint tab=3);
   void              PrintBounds(void);

// --- Event handler
   virtual void      OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam);
   
// --- Timer event handler
   virtual void      TimerEventHandler(void);
   
// --- Constructors/destructor
                     CPanel(void);
                     CPanel(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CPanel(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CPanel(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CPanel (void) { this.m_list_elm.Clear(); this.m_list_bounds.Clear(); }
  };
//+------------------------------------------------------------------+
// | CPanel::Default constructor.                                |
// | Plots an element in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CPanel::CPanel(void) : CLabel("Panel","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CPanel::Parametric constructor.                             |
// | Plots an element in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CPanel::CPanel(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CLabel(object_name,text,::ChartID(),0,x,y,w,h)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CPanel::Parametric constructor.                             |
// | Plots an element in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CPanel::CPanel(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CLabel(object_name,text,::ChartID(),wnd,x,y,w,h)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CPanel::Parametric constructor.                             |
// | Plots an element in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CPanel::CPanel(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CLabel(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CPanel::Initialization |
//+------------------------------------------------------------------+
void CPanel::Init(void)
  {
// --- Initialize default colors
   this.InitColors();
// --- Background is transparent, foreground is not
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
// --- Set the offset and dimensions of the image area
   this.SetImageBound(0,0,this.Width(),this.Height());
// --- Frame width
   this.SetBorderWidth(2);
  }
//+------------------------------------------------------------------+
// | CPanel::Initializing default object colors |
//+------------------------------------------------------------------+
void CPanel::InitColors(void)
  {
// --- Initialize the background colors for normal and activated states and make it the current background color
   this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.BackColorToDefault();
   
// --- Initialize the foreground colors for normal and activated states and make it the current text color
   this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   this.ForeColorToDefault();
   
// --- Initialize the border colors for the normal and activated states and make it the current border color
   this.InitBorderColors(clrNULL,clrNULL,clrNULL,clrNULL);
   this.InitBorderColorsAct(clrNULL,clrNULL,clrNULL,clrNULL);
   this.BorderColorToDefault();
   
// --- Initialize the border color and foreground color for the blocked element
   this.InitBorderColorBlocked(clrNULL);
   this.InitForeColorBlocked(clrSilver);
  }
//+------------------------------------------------------------------+
// | CPanel::Comparing two objects |
//+------------------------------------------------------------------+
int CPanel::Compare(const CObject *node,const int mode=0) const
  {
   return CLabel::Compare(node,mode);
  }
//+------------------------------------------------------------------+
// | CPanel::Draws appearance |
//+------------------------------------------------------------------+
void CPanel::Draw(const bool chart_redraw)
  {
// --- Fill the button with the background color
   this.Fill(this.BackColor(),false);
   
// --- Clear the drawing area
   this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
// --- Set the color for the dark and light lines and draw the panel frame
   color clr_dark =(this.BackColor()==clrNULL ? this.BackColor() : this.GetBackColorControl().NewColor(this.BackColor(),-20,-20,-20));
   color clr_light=(this.BackColor()==clrNULL ? this.BackColor() : this.GetBackColorControl().NewColor(this.BackColor(),  6,  6,  6));
   this.m_painter.FrameGroupElements(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),
                                     this.m_painter.Width(),this.m_painter.Height(),this.Text(),
                                     this.ForeColor(),clr_dark,clr_light,this.AlphaFG(),true);
   
// --- Updating the background canvas without redrawing the graph
   this.m_background.Update(false);
   
// --- Drawing list elements
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.Draw(false);
     }
// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CPanel::Adds a new element to the list |
//+------------------------------------------------------------------+
bool CPanel::AddNewElement(CElementBase *element)
  {
// --- If an empty pointer is passed, we report this and return false
   if(element==NULL)
     {
      ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
      return false;
     }
// --- Set the list to sort by identifier
   this.m_list_elm.Sort(ELEMENT_SORT_BY_ID);
// --- If such an element is not in the list, return the result of adding it to the list
   if(this.m_list_elm.Search(element)==NULL)
      return(this.m_list_elm.Add(element)>-1);
// --- An element with the same identifier is already in the list - return false
   return false;
  }
//+------------------------------------------------------------------+
// | CPanel::Creates and adds a new element to the list |
//+------------------------------------------------------------------+
CElementBase *CPanel::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
  {
// --- Create a name for the graphic object
   int elm_total=this.m_list_elm.Total();
   string obj_name=this.NameFG()+"_"+ElementShortName(type)+(string)elm_total;
// --- Calculate coordinates
   int x=this.X()+dx;
   int y=this.Y()+dy;
// --- Depending on the type of object, we create a new object
   CElementBase *element=NULL;
   switch(type)
     {
      case ELEMENT_TYPE_LABEL             :  element = new CLabel(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);             break;   // Text label
      case ELEMENT_TYPE_BUTTON            :  element = new CButton(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);            break;   // Simple button
      case ELEMENT_TYPE_BUTTON_TRIGGERED  :  element = new CButtonTriggered(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Two-position button
      case ELEMENT_TYPE_BUTTON_ARROW_UP   :  element = new CButtonArrowUp(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);     break;   // Up arrow button
      case ELEMENT_TYPE_BUTTON_ARROW_DOWN :  element = new CButtonArrowDown(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Down arrow button
      case ELEMENT_TYPE_BUTTON_ARROW_LEFT :  element = new CButtonArrowLeft(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Left Arrow Button
      case ELEMENT_TYPE_BUTTON_ARROW_RIGHT:  element = new CButtonArrowRight(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);  break;   // Right arrow button
      case ELEMENT_TYPE_CHECKBOX          :  element = new CCheckBox(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);          break;   // CheckBox control
      case ELEMENT_TYPE_RADIOBUTTON       :  element = new CRadioButton(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);       break;   // RadioButton control
      case ELEMENT_TYPE_PANEL             :  element = new CPanel(obj_name,"",this.m_chart_id,this.m_wnd,x,y,w,h);               break;   // Panel control
      case ELEMENT_TYPE_GROUPBOX          :  element = new CGroupBox(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);          break;   // GroupBox control
      case ELEMENT_TYPE_SCROLLBAR_THUMB_H :  element = new CScrollBarThumbH(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Scrollbar horizontal ScrollBar
      case ELEMENT_TYPE_SCROLLBAR_THUMB_V :  element = new CScrollBarThumbV(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Vertical ScrollBar
      case ELEMENT_TYPE_SCROLLBAR_H       :  element = new CScrollBarH(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);        break;   // Horizontal ScrollBar control
      case ELEMENT_TYPE_SCROLLBAR_V       :  element = new CScrollBarV(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);        break;   // Vertical ScrollBar control
      case ELEMENT_TYPE_CONTAINER         :  element = new CContainer(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);         break;   // Container control
      default                             :  element = NULL;
     }
   
// --- If a new element is not created, we report this and return NULL
   if(element==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create graphic element %s",__FUNCTION__,ElementDescription(type));
      return NULL;
     }
// --- Set the identifier, name, container and z-order of the element
   element.SetID(elm_total);
   element.SetName(user_name);
   element.SetContainerObj(&this);
   element.ObjectSetZOrder(this.ObjectZOrder()+1);
   
// --- If the created element is not added to the list, we report this, delete the created element and return NULL
   if(!this.AddNewElement(element))
     {
      ::PrintFormat("%s: Error. Failed to add %s element with ID %d to list",__FUNCTION__,ElementDescription(type),element.ID());
      delete element;
      return NULL;
     }
// --- We get the parent element to which the children are attached
   CElementBase *elm=this.GetContainer();
// --- If the parent element is of type "Container", then it has scrollbars
   if(elm!=NULL && elm.Type()==ELEMENT_TYPE_CONTAINER)
     {
      // --- Convert CElementBase to CContainer
      CContainer *container_obj=elm;
      // --- If the horizontal scroll bar is visible,
      if(container_obj.ScrollBarHorIsVisible())
        {
         // --- get a pointer to the horizontal scrollbar and move it to the front
         CScrollBarH *sbh=container_obj.GetScrollBarH();
         if(sbh!=NULL)
            sbh.BringToTop(false);
        }
      // --- If the vertical scroll bar is visible,
      if(container_obj.ScrollBarVerIsVisible())
        {
         // --- get the pointer to the vertical scrollbar and move it to the front
         CScrollBarV *sbv=container_obj.GetScrollBarV();
         if(sbv!=NULL)
            sbv.BringToTop(false);
        }
     }
// --- Return a pointer to the created and attached element
   return element;
  }
//+------------------------------------------------------------------+
// | CPanel::Adds the specified element to the list |
//+------------------------------------------------------------------+
CElementBase *CPanel::InsertElement(CElementBase *element,const int dx,const int dy)
  {
// --- If an empty or invalid pointer to an element is passed, return NULL
   if(::CheckPointer(element)==POINTER_INVALID)
     {
      ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
      return NULL;
     }
// --- If a base element is passed, return NULL
   if(element.Type()==ELEMENT_TYPE_BASE)
     {
      ::PrintFormat("%s: Error. The base element cannot be used",__FUNCTION__);
      return NULL;
     }
// --- Remember the element identifier and set a new one
   int id=element.ID();
   element.SetID(this.m_list_elm.Total());
   
// --- Add an element to the list; if it fails, we report this, set the initial identifier and return NULL
   if(!this.AddNewElement(element))
     {
      ::PrintFormat("%s: Error. Failed to add element %s to list",__FUNCTION__,ElementDescription((ENUM_ELEMENT_TYPE)element.Type()));
      element.SetID(id);
      return NULL;
     }
// --- Set new coordinates, container and z-order of the element
   int x=this.X()+dx;
   int y=this.Y()+dy;
   element.Move(x,y);
   element.SetContainerObj(&this);
   element.ObjectSetZOrder(this.ObjectZOrder()+1);
     
// --- Return a pointer to the attached element
   return element;
  }
//+------------------------------------------------------------------+
// | CPanel::Returns an element by ID |
//+------------------------------------------------------------------+
CElementBase *CPanel::GetAttachedElementByID(const int id)
  {
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL && elm.ID()==id)
         return elm;
     }
   return NULL;
  }
//+------------------------------------------------------------------+
// | CPanel::Returns an element by the assigned object name |
//+------------------------------------------------------------------+
CElementBase *CPanel::GetAttachedElementByName(const string name)
  {
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL && elm.Name()==name)
         return elm;
     }
   return NULL;
  }
//+------------------------------------------------------------------+
// | Creates and adds a new area to the list |
//+------------------------------------------------------------------+
CBound *CPanel::InsertNewBound(const string name,const int dx,const int dy,const int w,const int h)
  {
// --- Check if there is an area with the specified name in the list and, if so, report it and return NULL
   this.m_temp_bound.SetName(name);
   if(this.m_list_bounds.Search(&this.m_temp_bound)!=NULL)
     {
      ::PrintFormat("%s: Error. An area named \"%s\" is already in the list",__FUNCTION__,name);
      return NULL;
     }
// --- Create a new area object; if it fails, we report it and return NULL
   CBound *bound=new CBound(dx,dy,w,h);
   if(bound==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create CBound object",__FUNCTION__);
      return NULL;
     }
// --- If a new object could not be added to the list, we report this, delete the object and return NULL
   if(this.m_list_bounds.Add(bound)==-1)
     {
      ::PrintFormat("%s: Error. Failed to add CBound object to list",__FUNCTION__);
      delete bound;
      return NULL;
     }
// --- Set the area name and identifier, and return a pointer to the object
   bound.SetName(name);
   bound.SetID(this.m_list_bounds.Total());
   return bound;
  }
//+------------------------------------------------------------------+
// | Logs a description of an object |
//+------------------------------------------------------------------+
void CPanel::Print(void)
  {
   CBaseObj::Print();
   this.PrintAttached();
  }
//+------------------------------------------------------------------+
// | CPanel::Prints a list of attached objects |
//+------------------------------------------------------------------+
void CPanel::PrintAttached(const uint tab=3)
  {
// --- In a loop through all bound elements
   int total=this.m_list_elm.Total();
   for(int i=0;i<total;i++)
     {
      // --- get another element
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm==NULL)
         continue;
      // --- Get the element type and, if it is a scroll bar, skip it
      ENUM_ELEMENT_TYPE type=(ENUM_ELEMENT_TYPE)elm.Type();
      if(type==ELEMENT_TYPE_SCROLLBAR_H || type==ELEMENT_TYPE_SCROLLBAR_V)
         continue;
      // --- Print out the description of the element in the magazine
      ::PrintFormat("%*s[%d]: %s",tab,"",i,elm.Description());
      // --- If the element is a container, print its list of attached elements to the log
      if(type==ELEMENT_TYPE_PANEL || type==ELEMENT_TYPE_GROUPBOX || type==ELEMENT_TYPE_CONTAINER)
        {
         CPanel *obj=elm;
         obj.PrintAttached(tab*2);
        }
     }
  }
//+------------------------------------------------------------------+
// | CPanel::Prints a list of areas |
//+------------------------------------------------------------------+
void CPanel::PrintBounds(void)
  {
// --- In a loop through a list of element areas
   int total=this.m_list_bounds.Total();
   for(int i=0;i<total;i++)
     {
      // --- get the next area and print its description into the journal
      CBound *obj=this.GetBoundAt(i);
      if(obj==NULL)
         continue;
      ::PrintFormat("  [%d]: %s",i,obj.Description());
     }
  }
//+------------------------------------------------------------------+
// | CPanel::Sets an object to new X and Y coordinates |
//+------------------------------------------------------------------+
bool CPanel::Move(const int x,const int y)
  {
   // --- Calculate the distance by which the element will move
   int delta_x=x-this.X();
   int delta_y=y-this.Y();

   // --- Move the element to the specified coordinates
   bool res=this.ObjectMove(x,y);
   if(!res)
      return false;
   this.BoundMove(x,y);
   this.ObjectTrim();
   
// --- Move all anchored elements to the calculated distance
   int total=this.m_list_elm.Total();
   for(int i=0;i<total;i++)
     {
      // --- Move the anchored element taking into account the offset of the parent element
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         res &=elm.Move(elm.X()+delta_x, elm.Y()+delta_y);
     }
// --- Return the result of moving all bound elements
   return res;
  }
//+------------------------------------------------------------------+
// | CPanel::Shifts an object along the X and Y axes by the specified offset |
//+------------------------------------------------------------------+
bool CPanel::Shift(const int dx,const int dy)
  {
// --- Shift the element by the specified distance
   bool res=this.ObjectShift(dx,dy);
   if(!res)
      return false;
   this.BoundShift(dx,dy);
   this.ObjectTrim();
   
// --- Move all anchored elements
   int total=this.m_list_elm.Total();
   for(int i=0;i<total;i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         res &=elm.Shift(dx,dy);
     }
// --- Return the result of the offset of all anchored elements
   return res;
  }
//+------------------------------------------------------------------+
// | CPanel::Hides the object on all chart periods |
//+------------------------------------------------------------------+
void CPanel::Hide(const bool chart_redraw)
  {
// --- If the object is already hidden, we leave
   if(this.m_hidden)
      return;
      
// --- Hide the panel
   CCanvasBase::Hide(false);
// --- Hiding attached objects
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.Hide(false);
     }
// --- If indicated, redraw the graph
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CPanel::Displays an object on all chart periods |
//+------------------------------------------------------------------+
void CPanel::Show(const bool chart_redraw)
  {
// --- If the object is already visible, we leave
   if(!this.m_hidden)
      return;
      
// --- Display the panel
   CCanvasBase::Show(false);
// --- Display attached objects
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.Show(false);
     }
// --- If indicated, redraw the graph
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CPanel::Brings the object to the front |
//+------------------------------------------------------------------+
void CPanel::BringToTop(const bool chart_redraw)
  {
// --- Move the panel to the front
   CCanvasBase::BringToTop(false);
// --- Place attached objects in the foreground
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.BringToTop(false);
     }
// --- If indicated, redraw the graph
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CPanel::Blocks element |
//+------------------------------------------------------------------+
void CPanel::Block(const bool chart_redraw)
  {
// --- If the element is already blocked, we leave
   if(this.m_blocked)
      return;
      
// --- Lock the panel
   CCanvasBase::Block(false);
// --- Blocking attached objects
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.Block(false);
     }
// --- If indicated, redraw the graph
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CPanel::Unlocks element |
//+------------------------------------------------------------------+
void CPanel::Unblock(const bool chart_redraw)
  {
// --- If the element is already unlocked, we leave
   if(!this.m_blocked)
      return;
      
// --- Unlock the panel
   CCanvasBase::Unblock(false);
// --- Unlock attached objects
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.Unblock(false);
     }
// --- If indicated, redraw the graph
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CPanel::Saving to file |
//+------------------------------------------------------------------+
bool CPanel::Save(const int file_handle)
  {
// --- Save the data of the parent object
   if(!CElementBase::Save(file_handle))
      return false;
  
// --- Save the list of attached elements
   if(!this.m_list_elm.Save(file_handle))
      return false;
// --- Save the list of areas
   if(!this.m_list_bounds.Save(file_handle))
      return false;
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | CPanel::Loading from file |
//+------------------------------------------------------------------+
bool CPanel::Load(const int file_handle)
  {
// --- Loading the data of the parent object
   if(!CElementBase::Load(file_handle))
      return false;
      
// --- Loading the list of attached elements
   if(!this.m_list_elm.Load(file_handle))
      return false;
// --- Loading a list of areas
   if(!this.m_list_bounds.Load(file_handle))
      return false;
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | CPanel::Event Handler |
//+------------------------------------------------------------------+
void CPanel::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Call the event handler of the parent class
   CCanvasBase::OnChartEvent(id,lparam,dparam,sparam);
// --- In a loop through all bound elements
   int total=this.m_list_elm.Total();
   for(int i=0;i<total;i++)
     {
      // --- get the next element and call its event handler
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.OnChartEvent(id,lparam,dparam,sparam);
     }
  }
//+------------------------------------------------------------------+
// | CPanel::Timer event handler |
//+------------------------------------------------------------------+
void CPanel::TimerEventHandler(void)
  {
// --- In a loop through all bound elements
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      // --- get the next element and call its timer event handler
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.TimerEventHandler();
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Object Group Class |
//+------------------------------------------------------------------+
class CGroupBox : public CPanel
  {
public:
// ---Object type
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_GROUPBOX); }
  
// --- Initializing a class object
   void              Init(void);
   
// --- Sets a group of elements
   virtual void      SetGroup(const int group);
   
// --- Creates and adds (1) a new, (2) a previously created element to the list
   virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
   virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);

// --- Constructors/destructor
                     CGroupBox(void);
                     CGroupBox(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CGroupBox(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CGroupBox(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CGroupBox(void) {}
  };
//+------------------------------------------------------------------+
// | CGroupBox::Default constructor.                             |
// | Plots an element in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CGroupBox::CGroupBox(void) : CPanel("GroupBox","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CGroupBox::Parametric constructor.                          |
// | Plots an element in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CGroupBox::CGroupBox(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CPanel(object_name,text,::ChartID(),0,x,y,w,h)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CGroupBox::Parametric constructor.                          |
// | Plots an element in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CGroupBox::CGroupBox(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CPanel(object_name,text,::ChartID(),wnd,x,y,w,h)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CGroupBox::Parametric constructor.                          |
// | Plots an element in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CGroupBox::CGroupBox(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CPanel(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CGroupBox::Initialization |
//+------------------------------------------------------------------+
void CGroupBox::Init(void)
  {
// ---Initialization using parent class
   CPanel::Init();
  }
//+------------------------------------------------------------------+
// | CGroupBox::Sets a group of elements |
//+------------------------------------------------------------------+
void CGroupBox::SetGroup(const int group)
  {
// --- Set the group to this element using the parent class method
   CElementBase::SetGroup(group);
// --- In a loop through a list of bound elements
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      // --- get the next element and assign a group to it
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.SetGroup(group);
     }
  }
//+------------------------------------------------------------------+
// | CGroupBox::Creates and adds a new element to the list |
//+------------------------------------------------------------------+
CElementBase *CGroupBox::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
  {
// --- Create and add a new element to the list of elements
   CElementBase *element=CPanel::InsertNewElement(type,text,user_name,dx,dy,w,h);
   if(element==NULL)
      return NULL;
// --- Set the created element to a group equal to the group of this object
   element.SetGroup(this.Group());
   return element;
  }
//+------------------------------------------------------------------+
// | CGroupBox::Adds the specified element to the list |
//+------------------------------------------------------------------+
CElementBase *CGroupBox::InsertElement(CElementBase *element,const int dx,const int dy)
  {
// --- Add a new element to the list of elements
   if(CPanel::InsertElement(element,dx,dy)==NULL)
      return NULL;
// --- Set the added element to a group equal to the group of this object
   element.SetGroup(this.Group());
   return element;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Horizontal Scroll Slider Class |
//+------------------------------------------------------------------+
class CScrollBarThumbH : public CButton
  {
protected:
   bool              m_chart_redraw;                           // Graph update flag
public:
// --- (1) Sets, (2) returns the graph update flag
   void              SetChartRedrawFlag(const bool flag)       { this.m_chart_redraw=flag;               }
   bool              ChartRedrawFlag(void)               const { return this.m_chart_redraw;             }
   
// --- Virtual methods (1) save to file, (2) load from file, (3) object type
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_THUMB_H); }
   
// --- Initialize (1) class object, (2) default object colors
   void              Init(const string text);
   
// --- Event handlers for (1) cursor movement, (2) wheel scrolling
   virtual void      OnMoveEvent(const int id, const long lparam, const double dparam, const string sparam);
   virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);
   
// --- Constructors/destructor
                     CScrollBarThumbH(void);
                     CScrollBarThumbH(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CScrollBarThumbH (void) {}
  };
//+------------------------------------------------------------------+
// | CScrollBarThumbH::Default constructor.                      |
// | Plots an element in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CScrollBarThumbH::CScrollBarThumbH(void) : CButton("SBThumb","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_SCROLLBAR_TH)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbH::The constructor is parametric.                   |
// | Plots an element in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CScrollBarThumbH::CScrollBarThumbH(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbH::Initializing |
//+------------------------------------------------------------------+
void CScrollBarThumbH::Init(const string text)
  {
// ---Initializing the parent class
   CButton::Init("");
// --- Set the relocatability and schedule update flags
   this.SetMovable(true);
   this.SetChartRedrawFlag(false);
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbH::Cursor move handler |
//+------------------------------------------------------------------+
void CScrollBarThumbH::OnMoveEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
// --- Base object cursor movement handler
   CCanvasBase::OnMoveEvent(id,lparam,dparam,sparam);
// --- Get a pointer to the base object (horizontal scrollbar control)
   CCanvasBase *base_obj=this.GetContainer();
// --- If the movability flag is not set for the slider, or the pointer to the base object is not received, we leave
   if(!this.IsMovable() || base_obj==NULL)
      return;
   
// --- Get the width of the base object and calculate the boundaries of the space for the slider
   int base_w=base_obj.Width();
   int base_left=base_obj.X()+base_obj.Height();
   int base_right=base_obj.Right()-base_obj.Height()+1;
   
// --- From the coordinates of the cursor and the size of the slider, we calculate the restrictions for movement
   int x=(int)lparam-this.m_cursor_delta_x;
   if(x<base_left)
      x=base_left;
   if(x+this.Width()>base_right)
      x=base_right-this.Width();
// --- Move the slider to the calculated X coordinate
   if(!this.MoveX(x))
      return;
      
// --- Calculate the position of the slider
   int thumb_pos=this.X()-base_left;
   
// --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_MOVE, thumb_pos, dparam, this.NameFG());
// --- Redraw the graph
   if(this.m_chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbH::Wheel scroll handler |
//+------------------------------------------------------------------+
void CScrollBarThumbH::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
// --- Get a pointer to the base object (horizontal scroll bar control)
   CCanvasBase *base_obj=this.GetContainer();
// --- If the movability flag is not set for the slider, or the pointer to the base object is not received, we leave
   if(!this.IsMovable() || base_obj==NULL)
      return;
   
// --- Get the width of the base object and calculate the boundaries of the space for the slider
   int base_w=base_obj.Width();
   int base_left=base_obj.X()+base_obj.Height();
   int base_right=base_obj.Right()-base_obj.Height()+1;
   
// --- Set the direction of displacement depending on the direction of rotation of the mouse wheel
   int dx=(dparam<0 ? 2 : dparam>0 ? -2 : 0);
   if(dx==0)
      dx=(int)lparam;

// --- If, when shifted, the slider goes beyond the left edge of its area, set it to the left edge
   if(dx<0 && this.X()+dx<=base_left)
      this.MoveX(base_left);
// --- otherwise, if, when shifted, the slider goes beyond the right edge of its area, position it along the right edge
   else if(dx>0 && this.Right()+dx>=base_right)
      this.MoveX(base_right-this.Width());
// --- Otherwise, if the slider is within its area, move it by the offset amount
   else if(this.ShiftX(dx))
      this.OnFocusEvent(id,lparam,dparam,sparam);
      
// --- Calculate the position of the slider
   int thumb_pos=this.X()-base_left;
   
// --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_WHEEL, thumb_pos, dparam, this.NameFG());
// --- Redraw the graph
   if(this.m_chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbH::Saving to file |
//+------------------------------------------------------------------+
bool CScrollBarThumbH::Save(const int file_handle)
  {
// --- Save the data of the parent object
   if(!CButton::Save(file_handle))
      return false;
  
// --- Save the graph update flag
   if(::FileWriteInteger(file_handle,this.m_chart_redraw,INT_VALUE)!=INT_VALUE)
      return false;
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbH::Loading from file |
//+------------------------------------------------------------------+
bool CScrollBarThumbH::Load(const int file_handle)
  {
// --- Loading the data of the parent object
   if(!CButton::Load(file_handle))
      return false;
      
// --- Loading the graph update flag
   this.m_chart_redraw=::FileReadInteger(file_handle,INT_VALUE);
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Vertical Scroll Slider Class |
//+------------------------------------------------------------------+
class CScrollBarThumbV : public CButton
  {
protected:
   bool              m_chart_redraw;                           // Graph update flag
public:
// --- (1) Sets, (2) returns the graph update flag
   void              SetChartRedrawFlag(const bool flag)       { this.m_chart_redraw=flag;               }
   bool              ChartRedrawFlag(void)               const { return this.m_chart_redraw;             }
   
// --- Virtual methods (1) save to file, (2) load from file, (3) object type
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_THUMB_V); }
   
// --- Initialize (1) class object, (2) default object colors
   void              Init(const string text);
   
// --- Event handlers for (1) cursor movement, (2) wheel scrolling
   virtual void      OnMoveEvent(const int id, const long lparam, const double dparam, const string sparam);
   virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);
   
// --- Constructors/destructor
                     CScrollBarThumbV(void);
                     CScrollBarThumbV(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CScrollBarThumbV (void) {}
  };
//+------------------------------------------------------------------+
// | CScrollBarThumbV::Default constructor.                      |
// | Plots an element in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CScrollBarThumbV::CScrollBarThumbV(void) : CButton("SBThumb","",::ChartID(),0,0,0,DEF_SCROLLBAR_TH,DEF_PANEL_W)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbV::Parametric constructor.                   |
// | Plots an element in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CScrollBarThumbV::CScrollBarThumbV(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h)
  {
// ---Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbV::Initializing |
//+------------------------------------------------------------------+
void CScrollBarThumbV::Init(const string text)
  {
// ---Initializing the parent class
   CButton::Init("");
// --- Set the relocatability and schedule update flags
   this.SetMovable(true);
   this.SetChartRedrawFlag(false);
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbV::Cursor move handler |
//+------------------------------------------------------------------+
void CScrollBarThumbV::OnMoveEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
// --- Base object cursor movement handler
   CCanvasBase::OnMoveEvent(id,lparam,dparam,sparam);
// --- Get a pointer to the base object (vertical scroll bar control)
   CCanvasBase *base_obj=this.GetContainer();
// --- If the movability flag is not set for the slider, or the pointer to the base object is not received, we leave
   if(!this.IsMovable() || base_obj==NULL)
      return;
   
// --- Get the height of the base object and calculate the boundaries of the space for the slider
   int base_h=base_obj.Height();
   int base_top=base_obj.Y()+base_obj.Width();
   int base_bottom=base_obj.Bottom()-base_obj.Width()+1;
   
// --- From the coordinates of the cursor and the size of the slider, we calculate the restrictions for movement
   int y=(int)dparam-this.m_cursor_delta_y;
   if(y<base_top)
      y=base_top;
   if(y+this.Height()>base_bottom)
      y=base_bottom-this.Height();
// --- Move the slider to the calculated Y coordinate
   if(!this.MoveY(y))
      return;
   
// --- Calculate the position of the slider
   int thumb_pos=this.Y()-base_top;
   
// --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_MOVE, thumb_pos, dparam, this.NameFG());
// --- Redraw the graph
   if(this.m_chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbV::Wheel scroll handler |
//+------------------------------------------------------------------+
void CScrollBarThumbV::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
// --- Get a pointer to the base object (vertical scroll bar control)
   CCanvasBase *base_obj=this.GetContainer();
// --- If the movability flag is not set for the slider, or the pointer to the base object is not received, we leave
   if(!this.IsMovable() || base_obj==NULL)
      return;
   
// --- Get the height of the base object and calculate the boundaries of the space for the slider
   int base_h=base_obj.Height();
   int base_top=base_obj.Y()+base_obj.Width();
   int base_bottom=base_obj.Bottom()-base_obj.Width()+1;
   
// --- Set the direction of displacement depending on the direction of rotation of the mouse wheel
   int dy=(dparam<0 ? 2 : dparam>0 ? -2 : 0);
   if(dy==0)
      dy=(int)lparam;

// --- If, when shifted, the slider goes beyond the top edge of its area, set it to the top edge
   if(dy<0 && this.Y()+dy<=base_top)
      this.MoveY(base_top);
// --- otherwise, if, when shifted, the slider goes beyond the bottom edge of its area, position it along the bottom edge
   else if(dy>0 && this.Bottom()+dy>=base_bottom)
      this.MoveY(base_bottom-this.Height());
// --- Otherwise, if the slider is within its area, move it by the offset amount
   else if(this.ShiftY(dy))
      this.OnFocusEvent(id,lparam,dparam,sparam);
      
// --- Calculate the position of the slider
   int thumb_pos=this.Y()-base_top;
   
// --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_WHEEL, thumb_pos, dparam, this.NameFG());
// --- Redraw the graph
   if(this.m_chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbV::Saving to file |
//+------------------------------------------------------------------+
bool CScrollBarThumbV::Save(const int file_handle)
  {
// --- Save the data of the parent object
   if(!CButton::Save(file_handle))
      return false;
  
// --- Save the graph update flag
   if(::FileWriteInteger(file_handle,this.m_chart_redraw,INT_VALUE)!=INT_VALUE)
      return false;
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | CScrollBarThumbV::Loading from file |
//+------------------------------------------------------------------+
bool CScrollBarThumbV::Load(const int file_handle)
  {
// --- Loading the data of the parent object
   if(!CButton::Load(file_handle))
      return false;
      
// --- Loading the graph update flag
   this.m_chart_redraw=::FileReadInteger(file_handle,INT_VALUE);
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Horizontal Scrollbar Class |
//+------------------------------------------------------------------+
class CScrollBarH : public CPanel
  {
protected:
   CButtonArrowLeft *m_butt_left;                              // Left Arrow Button
   CButtonArrowRight*m_butt_right;                             // Right arrow button
   CScrollBarThumbH *m_thumb;                                  // Scrollbar slider
   
public:
// --- Returns a pointer to (1) left, (2) right button, (3) slider
   CButtonArrowLeft *GetButtonLeft(void)                       { return this.m_butt_left;                                              }
   CButtonArrowRight*GetButtonRight(void)                      { return this.m_butt_right;                                             }
   CScrollBarThumbH *GetThumb(void)                            { return this.m_thumb;                                                  }

// --- (1) Sets, (2) returns the graph update flag
   void              SetChartRedrawFlag(const bool flag)       { if(this.m_thumb!=NULL) this.m_thumb.SetChartRedrawFlag(flag);         }
   bool              ChartRedrawFlag(void)               const { return(this.m_thumb!=NULL ? this.m_thumb.ChartRedrawFlag() : false);  }

// --- Returns (1) the length (2) the start of the track, (3) the position of the slider
   int               TrackLength(void)    const;
   int               TrackBegin(void)     const;
   int               ThumbPosition(void)  const;
   
// --- Changes the size of the slider
   bool              SetThumbSize(const uint size)       const { return(this.m_thumb!=NULL ? this.m_thumb.ResizeW(size) : false);      }

// --- Changes the width of an object
   virtual bool      ResizeW(const int size);
   
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);
   
// ---Object type
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_H);                                     }
   
// --- Initialize (1) class object, (2) default object colors
   void              Init(void);
   virtual void      InitColors(void);
   
// --- Wheel scroll handler
   virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);

// --- Constructors/destructor
                     CScrollBarH(void);
                     CScrollBarH(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CScrollBarH(void) {}
  };
//+------------------------------------------------------------------+
// | CScrollBarH::Default constructor.                           |
// | Plots an element in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CScrollBarH::CScrollBarH(void) : CPanel("ScrollBarH","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H),m_butt_left(NULL),m_butt_right(NULL),m_thumb(NULL)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CScrollBarH::The constructor is parametric.                        |
// | Plots an element in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CScrollBarH::CScrollBarH(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CPanel(object_name,text,chart_id,wnd,x,y,w,h),m_butt_left(NULL),m_butt_right(NULL),m_thumb(NULL)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CScrollBarH::Initializing |
//+------------------------------------------------------------------+
void CScrollBarH::Init(void)
  {
// ---Initializing the parent class
   CPanel::Init();
// --- Background - opaque
   this.SetAlphaBG(255);
// --- Frame width and text
   this.SetBorderWidth(0);
   this.SetText("");
// --- Element is not clipped to container boundaries
   this.m_trim_flag=false;
   
// ---Creating scroll buttons
   int w=this.Height();
   int h=this.Height();
   this.m_butt_left = this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_LEFT, "","ButtL",0,0,w,h);
   this.m_butt_right= this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_RIGHT,"","ButtR",this.Width()-w,0,w,h);
   if(this.m_butt_left==NULL || this.m_butt_right==NULL)
     {
      ::PrintFormat("%s: Init failed",__FUNCTION__);
      return;
     }
// --- Customize the colors and appearance of the left arrow button
   this.m_butt_left.SetImageBound(1,1,w-2,h-4);
   this.m_butt_left.InitBackColors(this.m_butt_left.BackColorFocused());
   this.m_butt_left.ColorsToDefault();
   this.m_butt_left.InitBorderColors(this.BorderColor(),this.m_butt_left.BackColorFocused(),this.m_butt_left.BackColorPressed(),this.m_butt_left.BackColorBlocked());
   this.m_butt_left.ColorsToDefault();
   
// --- Customize the colors and appearance of the right arrow button
   this.m_butt_right.SetImageBound(1,1,w-2,h-4);
   this.m_butt_right.InitBackColors(this.m_butt_right.BackColorFocused());
   this.m_butt_right.ColorsToDefault();
   this.m_butt_right.InitBorderColors(this.BorderColor(),this.m_butt_right.BackColorFocused(),this.m_butt_right.BackColorPressed(),this.m_butt_right.BackColorBlocked());
   this.m_butt_right.ColorsToDefault();
   
// --- Create a slider
   int tsz=this.Width()-w*2;
   this.m_thumb=this.InsertNewElement(ELEMENT_TYPE_SCROLLBAR_THUMB_H,"","ThumbH",w,1,tsz-w*4,h-2);
   if(this.m_thumb==NULL)
     {
      ::PrintFormat("%s: Init failed",__FUNCTION__);
      return;
     }
// --- Customize the colors of the slider and set the movability flag for it
   this.m_thumb.InitBackColors(this.m_thumb.BackColorFocused());
   this.m_thumb.ColorsToDefault();
   this.m_thumb.InitBorderColors(this.m_thumb.BackColor(),this.m_thumb.BackColorFocused(),this.m_thumb.BackColorPressed(),this.m_thumb.BackColorBlocked());
   this.m_thumb.ColorsToDefault();
   this.m_thumb.SetMovable(true);
// --- we prohibit independent redrawing of the graph
   this.m_thumb.SetChartRedrawFlag(false);
  }
//+------------------------------------------------------------------+
// | CScrollBarH::Initializing default object colors |
//+------------------------------------------------------------------+
void CScrollBarH::InitColors(void)
  {
// --- Initialize the background colors for normal and activated states and make it the current background color
   this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.BackColorToDefault();
   
// --- Initialize the foreground colors for normal and activated states and make it the current text color
   this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   this.ForeColorToDefault();
   
// --- Initialize the border colors for the normal and activated states and make it the current border color
   this.InitBorderColors(clrLightGray,clrLightGray,clrLightGray,clrSilver);
   this.InitBorderColorsAct(clrLightGray,clrLightGray,clrLightGray,clrSilver);
   this.BorderColorToDefault();
   
// --- Initialize the border color and foreground color for the blocked element
   this.InitBorderColorBlocked(clrSilver);
   this.InitForeColorBlocked(clrSilver);
  }
//+------------------------------------------------------------------+
// | CScrollBarH::Draws appearance |
//+------------------------------------------------------------------+
void CScrollBarH::Draw(const bool chart_redraw)
  {
// --- Fill the button with the background color, draw a frame and update the background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
// --- Updating the background canvas without redrawing the graph
   this.m_background.Update(false);
   
// --- Drawing list elements without redrawing the graph
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.Draw(false);
     }
// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CScrollBarH::Returns track length |
//+------------------------------------------------------------------+
int CScrollBarH::TrackLength(void) const
  {
   if(this.m_butt_left==NULL || this.m_butt_right==NULL)
      return 0;
   return(this.m_butt_right.X()-this.m_butt_left.Right());
  }
//+------------------------------------------------------------------+
// | CScrollBarH::Returns the start of the track |
//+------------------------------------------------------------------+
int CScrollBarH::TrackBegin(void) const
  {
   return(this.m_butt_left!=NULL ? this.m_butt_left.Width() : 0);
  }
//+------------------------------------------------------------------+
// | CScrollBarH::Returns the position of the slider |
//+------------------------------------------------------------------+
int CScrollBarH::ThumbPosition(void) const
  {
   return(this.m_thumb!=NULL ? this.m_thumb.X()-this.TrackBegin()-this.X() : 0);
  }
//+------------------------------------------------------------------+
// | CScrollBarH::Changes the width of an object |
//+------------------------------------------------------------------+
bool CScrollBarH::ResizeW(const int size)
  {
// --- Getting pointers to the left and right buttons
   if(this.m_butt_left==NULL || this.m_butt_right==NULL)
      return false;
// --- Changing the width of the object
   if(!CCanvasBase::ResizeW(size))
      return false;
// --- Move the buttons to a new location relative to the left and right borders of the element that has changed size
   if(!this.m_butt_left.MoveX(this.X()))
      return false;
   return(this.m_butt_right.MoveX(this.Right()-this.m_butt_right.Width()+1));
  }
//+------------------------------------------------------------------+
// | CScrollBarH::Wheel scroll handler |
//+------------------------------------------------------------------+
void CScrollBarH::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
// --- Call the scroll handler for the slider
   if(this.m_thumb!=NULL)
      this.m_thumb.OnWheelEvent(id,this.ThumbPosition(),dparam,this.NameFG());
      
// --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   ::EventChartCustom(this.m_chart_id,CHARTEVENT_MOUSE_WHEEL,this.ThumbPosition(),dparam,this.NameFG());
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Vertical scrollbar class |
//+------------------------------------------------------------------+
class CScrollBarV : public CPanel
  {
protected:
   CButtonArrowUp   *m_butt_up;                                // Up arrow button
   CButtonArrowDown *m_butt_down;                              // Down arrow button
   CScrollBarThumbV *m_thumb;                                  // Scrollbar slider

public:
// --- Returns a pointer to (1) left, (2) right button, (3) slider
   CButtonArrowUp   *GetButtonUp(void)                         { return this.m_butt_up;      }
   CButtonArrowDown *GetButtonDown(void)                       { return this.m_butt_down;    }
   CScrollBarThumbV *GetThumb(void)                            { return this.m_thumb;        }

// --- (1) Sets, (2) returns the graph update flag
   void              SetChartRedrawFlag(const bool flag)       { if(this.m_thumb!=NULL) this.m_thumb.SetChartRedrawFlag(flag);         }
   bool              ChartRedrawFlag(void)               const { return(this.m_thumb!=NULL ? this.m_thumb.ChartRedrawFlag() : false);  }

// --- Returns (1) the length (2) the start of the track, (3) the position of the slider
   int               TrackLength(void)    const;
   int               TrackBegin(void)     const;
   int               ThumbPosition(void)  const;
   
// --- Changes the size of the slider
   bool              SetThumbSize(const uint size)       const { return(this.m_thumb!=NULL ? this.m_thumb.ResizeH(size) : false);      }
   
// --- Changes the height of an object
   virtual bool      ResizeH(const int size);
   
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);
   
// ---Object type
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_V);                                     }
   
// --- Initialize (1) class object, (2) default object colors
   void              Init(void);
   virtual void      InitColors(void);
   
// --- Wheel scroll handler
   virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);
   
// --- Constructors/destructor
                     CScrollBarV(void);
                     CScrollBarV(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CScrollBarV(void) {}
  };
//+------------------------------------------------------------------+
// | CScrollBarV::Default constructor.                           |
// | Plots an element in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CScrollBarV::CScrollBarV(void) : CPanel("ScrollBarV","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H),m_butt_up(NULL),m_butt_down(NULL),m_thumb(NULL)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CScrollBarV::Parametric constructor.                        |
// | Plots an element in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CScrollBarV::CScrollBarV(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CPanel(object_name,text,chart_id,wnd,x,y,w,h),m_butt_up(NULL),m_butt_down(NULL),m_thumb(NULL)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CScrollBarV::Initializing |
//+------------------------------------------------------------------+
void CScrollBarV::Init(void)
  {
// ---Initializing the parent class
   CPanel::Init();
// --- Background - opaque
   this.SetAlphaBG(255);
// --- Frame width and text
   this.SetBorderWidth(0);
   this.SetText("");
// --- Element is not clipped to container boundaries
   this.m_trim_flag=false;
   
// ---Creating scroll buttons
   int w=this.Width();
   int h=this.Width();
   this.m_butt_up = this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_UP, "","ButtU",0,0,w,h);
   this.m_butt_down= this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_DOWN,"","ButtD",0,this.Height()-w,w,h);
   if(this.m_butt_up==NULL || this.m_butt_down==NULL)
     {
      ::PrintFormat("%s: Init failed",__FUNCTION__);
      return;
     }
// --- Customize the colors and appearance of the up arrow button
   this.m_butt_up.SetImageBound(1,0,w-4,h-2);
   this.m_butt_up.InitBackColors(this.m_butt_up.BackColorFocused());
   this.m_butt_up.ColorsToDefault();
   this.m_butt_up.InitBorderColors(this.BorderColor(),this.m_butt_up.BackColorFocused(),this.m_butt_up.BackColorPressed(),this.m_butt_up.BackColorBlocked());
   this.m_butt_up.ColorsToDefault();
   
// --- Customize the colors and appearance of the down arrow button
   this.m_butt_down.SetImageBound(1,0,w-4,h-2);
   this.m_butt_down.InitBackColors(this.m_butt_down.BackColorFocused());
   this.m_butt_down.ColorsToDefault();
   this.m_butt_down.InitBorderColors(this.BorderColor(),this.m_butt_down.BackColorFocused(),this.m_butt_down.BackColorPressed(),this.m_butt_down.BackColorBlocked());
   this.m_butt_down.ColorsToDefault();
   
// --- Create a slider
   int tsz=this.Height()-w*2;
   this.m_thumb=this.InsertNewElement(ELEMENT_TYPE_SCROLLBAR_THUMB_V,"","ThumbV",1,w,w-2,tsz/2);
   if(this.m_thumb==NULL)
     {
      ::PrintFormat("%s: Init failed",__FUNCTION__);
      return;
     }
// --- Customize the colors of the slider and set the movability flag for it
   this.m_thumb.InitBackColors(this.m_thumb.BackColorFocused());
   this.m_thumb.ColorsToDefault();
   this.m_thumb.InitBorderColors(this.m_thumb.BackColor(),this.m_thumb.BackColorFocused(),this.m_thumb.BackColorPressed(),this.m_thumb.BackColorBlocked());
   this.m_thumb.ColorsToDefault();
   this.m_thumb.SetMovable(true);
// --- we prohibit independent redrawing of the graph
   this.m_thumb.SetChartRedrawFlag(false);
  }
//+------------------------------------------------------------------+
// | CScrollBarV::Initializing default object colors |
//+------------------------------------------------------------------+
void CScrollBarV::InitColors(void)
  {
// --- Initialize the background colors for normal and activated states and make it the current background color
   this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.BackColorToDefault();
   
// --- Initialize the foreground colors for normal and activated states and make it the current text color
   this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   this.ForeColorToDefault();
   
// --- Initialize the border colors for the normal and activated states and make it the current border color
   this.InitBorderColors(clrLightGray,clrLightGray,clrLightGray,clrSilver);
   this.InitBorderColorsAct(clrLightGray,clrLightGray,clrLightGray,clrSilver);
   this.BorderColorToDefault();
   
// --- Initialize the border color and foreground color for the blocked element
   this.InitBorderColorBlocked(clrSilver);
   this.InitForeColorBlocked(clrSilver);
  }
//+------------------------------------------------------------------+
// | CScrollBarV::Draws appearance |
//+------------------------------------------------------------------+
void CScrollBarV::Draw(const bool chart_redraw)
  {
// --- Fill the button with the background color, draw a frame and update the background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
// --- Updating the background canvas without redrawing the graph
   this.m_background.Update(false);
   
// --- Drawing list elements without redrawing the graph
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.Draw(false);
     }
// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CScrollBarV::Returns track length |
//+------------------------------------------------------------------+
int CScrollBarV::TrackLength(void) const
  {
   if(this.m_butt_up==NULL || this.m_butt_down==NULL)
      return 0;
   return(this.m_butt_down.Y()-this.m_butt_up.Bottom());
  }
//+------------------------------------------------------------------+
// | CScrollBarV::Returns the start of the slider |
//+------------------------------------------------------------------+
int CScrollBarV::TrackBegin(void) const
  {
   return(this.m_butt_up!=NULL ? this.m_butt_up.Height() : 0);
  }
//+------------------------------------------------------------------+
// | CScrollBarV::Returns the position of the slider |
//+------------------------------------------------------------------+
int CScrollBarV::ThumbPosition(void) const
  {
   return(this.m_thumb!=NULL ? this.m_thumb.Y()-this.TrackBegin()-this.Y() : 0);
  }
//+------------------------------------------------------------------+
// | CScrollBarV::Changes the height of an object |
//+------------------------------------------------------------------+
bool CScrollBarV::ResizeH(const int size)
  {
// --- Getting pointers to the top and bottom buttons
   if(this.m_butt_up==NULL || this.m_butt_down==NULL)
      return false;
// --- Changing the height of the object
   if(!CCanvasBase::ResizeH(size))
      return false;
// --- Move the buttons to a new location relative to the top and bottom borders of the element that changed the size
   if(!this.m_butt_up.MoveY(this.Y()))
      return false;
   return(this.m_butt_down.MoveY(this.Bottom()-this.m_butt_down.Height()+1));
  }
//+------------------------------------------------------------------+
// | CScrollBarV::Wheel scroll handler |
//+------------------------------------------------------------------+
void CScrollBarV::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
// --- Call the scroll handler for the slider
   if(this.m_thumb!=NULL)
      this.m_thumb.OnWheelEvent(id,this.ThumbPosition(),dparam,this.NameFG());
      
// --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
   ::EventChartCustom(this.m_chart_id,CHARTEVENT_MOUSE_WHEEL,this.ThumbPosition(),dparam,this.NameFG());
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Class Container |
//+------------------------------------------------------------------+
class CContainer : public CPanel
  {
private:
   bool              m_visible_scrollbar_h;                    // Horizontal scrollbar visibility flag
   bool              m_visible_scrollbar_v;                    // Vertical scrollbar visibility flag
// --- Returns the type of the element that sent the event
   ENUM_ELEMENT_TYPE GetEventElementType(const string name);
   
protected:
   CScrollBarH      *m_scrollbar_h;                            // Pointer to horizontal scroll bar
   CScrollBarV      *m_scrollbar_v;                            // Pointer to vertical scroll bar
   
// --- Checks the dimensions of an element to display scrollbars
   void              CheckElementSizes(CElementBase *element);
// --- Calculates and returns the size of (1) the slider, (2) full, (3) the working size of the horizontal scrollbar track
   int               ThumbSizeHor(void);
   int               TrackLengthHor(void)                const { return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.TrackLength() : 0);       }
   int               TrackEffectiveLengthHor(void)             { return(this.TrackLengthHor()-this.ThumbSizeHor());                             }
// --- Calculates and returns the size of the (1) slider, (2) full, (3) working size of the vertical scrollbar track
   int               ThumbSizeVer(void);
   int               TrackLengthVer(void)                const { return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.TrackLength() : 0);       }
   int               TrackEffectiveLengthVer(void)             { return(this.TrackLengthVer()-this.ThumbSizeVer());                             }
// --- Size of visible content area (1) horizontally, (2) vertically
   int               ContentVisibleHor(void)             const { return int(this.Width()-this.BorderWidthLeft()-this.BorderWidthRight());       }
   int               ContentVisibleVer(void)             const { return int(this.Height()-this.BorderWidthTop()-this.BorderWidthBottom());      }
   
// --- Full content size in (1) horizontal, (2) vertical
   int               ContentSizeHor(void);
   int               ContentSizeVer(void);
   
// --- Position of content along (1) horizontal, (2) vertical
   int               ContentPositionHor(void);
   int               ContentPositionVer(void);
// --- Calculates and returns the amount of content offset (1) horizontally, (2) vertically depending on the position of the slider
   int               CalculateContentOffsetHor(const uint thumb_position);
   int               CalculateContentOffsetVer(const uint thumb_position);
// --- Calculates and returns the amount of slider displacement along (1) horizontal, (2) vertical depending on the position of the content
   int               CalculateThumbOffsetHor(const uint content_position);
   int               CalculateThumbOffsetVer(const uint content_position);
   
// --- Shifts content (1) horizontally, (2) vertically by the specified amount
   bool              ContentShiftHor(const int value);
   bool              ContentShiftVer(const int value);
   
public:
// --- Returning pointers to scrollbars, buttons and scrollbar sliders
   CScrollBarH      *GetScrollBarH(void)                       { return this.m_scrollbar_h;                                                     }
   CScrollBarV      *GetScrollBarV(void)                       { return this.m_scrollbar_v;                                                     }
   CButtonArrowUp   *GetScrollBarButtonUp(void)                { return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.GetButtonUp()   : NULL);  }
   CButtonArrowDown *GetScrollBarButtonDown(void)              { return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.GetButtonDown() : NULL);  }
   CButtonArrowLeft *GetScrollBarButtonLeft(void)              { return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.GetButtonLeft() : NULL);  }
   CButtonArrowRight*GetScrollBarButtonRight(void)             { return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.GetButtonRight(): NULL);  }
   CScrollBarThumbH *GetScrollBarThumbH(void)                  { return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.GetThumb()      : NULL);  }
   CScrollBarThumbV *GetScrollBarThumbV(void)                  { return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.GetThumb()      : NULL);  }
   
// --- Sets the content scroll flag
   void              SetScrolling(const bool flag)             { this.m_scroll_flag=flag;                                                       }

// --- Returns the visibility flag of (1) horizontal, (2) vertical scrollbar
   bool              ScrollBarHorIsVisible(void)         const { return this.m_visible_scrollbar_h;                                             }
   bool              ScrollBarVerIsVisible(void)         const { return this.m_visible_scrollbar_v;                                             }

// --- Creates and adds (1) a new, (2) a previously created element to the list
   virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
   virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);

// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// ---Object type
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_CONTAINER);                                                }
   
// --- Element custom event handlers for hover, click, and wheel scroll in an object area
   virtual void      MouseMoveHandler(const int id, const long lparam, const double dparam, const string sparam);
   virtual void      MousePressHandler(const int id, const long lparam, const double dparam, const string sparam);
   virtual void      MouseWheelHandler(const int id, const long lparam, const double dparam, const string sparam);
   
// --- Initializing a class object
   void              Init(void);
   
// --- Constructors/destructor
                     CContainer(void);
                     CContainer(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CContainer(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CContainer(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CContainer (void) {}
  };
//+------------------------------------------------------------------+
// | CContainer::Default constructor.                            |
// | Plots an element in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CContainer::CContainer(void) : CPanel("Container","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H), m_visible_scrollbar_h(false), m_visible_scrollbar_v(false)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CContainer::Parametric constructor.                         |
// | Plots an element in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CContainer::CContainer(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CPanel(object_name,text,::ChartID(),0,x,y,w,h), m_visible_scrollbar_h(false), m_visible_scrollbar_v(false)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CContainer::Parametric constructor.                         |
// | Plots an element in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CContainer::CContainer(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CPanel(object_name,text,::ChartID(),wnd,x,y,w,h), m_visible_scrollbar_h(false), m_visible_scrollbar_v(false)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CContainer::Parametric constructor.                         |
// | Plots an element in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CContainer::CContainer(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CPanel(object_name,text,chart_id,wnd,x,y,w,h), m_visible_scrollbar_h(false), m_visible_scrollbar_v(false)
  {
// ---Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
// | CContainer::Initialization |
//+------------------------------------------------------------------+
void CContainer::Init(void)
  {
// --- Initializing the parent object
   CPanel::Init();
// --- Frame width
   this.SetBorderWidth(0);
// --- Create a horizontal scrollbar
   this.m_scrollbar_h=dynamic_cast<CScrollBarH *>(CPanel::InsertNewElement(ELEMENT_TYPE_SCROLLBAR_H,"","ScrollBarH",0,this.Height()-DEF_SCROLLBAR_TH-1,this.Width()-1,DEF_SCROLLBAR_TH));
   if(m_scrollbar_h!=NULL)
     {
      // --- Hide the element and set a ban on independent redrawing of the graph
      this.m_scrollbar_h.Hide(false);
      this.m_scrollbar_h.SetChartRedrawFlag(false);
     }
// --- Create a vertical scrollbar
   this.m_scrollbar_v=dynamic_cast<CScrollBarV *>(CPanel::InsertNewElement(ELEMENT_TYPE_SCROLLBAR_V,"","ScrollBarV",this.Width()-DEF_SCROLLBAR_TH-1,0,DEF_SCROLLBAR_TH,this.Height()-1));
   if(m_scrollbar_v!=NULL)
     {
      // --- Hide the element and set a ban on independent redrawing of the graph
      this.m_scrollbar_v.Hide(false);
      this.m_scrollbar_v.SetChartRedrawFlag(false);
     }
// --- Allow content scrolling
   this.m_scroll_flag=true;
  }
//+------------------------------------------------------------------+
// | CContainer::Draws appearance |
//+------------------------------------------------------------------+
void CContainer::Draw(const bool chart_redraw)
  {
// --- Drawing the appearance
   CPanel::Draw(false);
   
// --- If scrolling is enabled
   if(this.m_scroll_flag)
     {
      // --- If both scrollbars are visible
      if(this.m_visible_scrollbar_h && this.m_visible_scrollbar_v)
        {
         // --- we get pointers to two buttons in the lower right corner
         CButtonArrowDown *butt_dn=this.GetScrollBarButtonDown();
         CButtonArrowRight*butt_rt=this.GetScrollBarButtonRight();
         // --- Get a pointer to the horizontal scrollbar and take its background color
         CScrollBarH *scroll_bar=this.GetScrollBarH();
         color clr=(scroll_bar!=NULL ? scroll_bar.BackColor() : clrWhiteSmoke);
         
         // --- Determine the size of the rectangle in the lower right corner based on the size of the two buttons
         int bw=(butt_rt!=NULL ? butt_rt.Width() : DEF_SCROLLBAR_TH-3);
         int bh=(butt_dn!=NULL ? butt_dn.Height(): DEF_SCROLLBAR_TH-3);
         
         // --- Set the coordinates at which the filled rectangle will be drawn
         int x1=this.Width()-bw-1;
         int y1=this.Height()-bh-1;
         int x2=this.Width()-3;
         int y2=this.Height()-3;
         
         // --- Draw a rectangle with the background color of the scrollbar in the lower right corner
         this.m_foreground.FillRectangle(x1,y1,x2,y2,::ColorToARGB(clr));
         this.m_foreground.Update(false);
        }
     }

// --- If indicated, update the schedule
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CContainer::Creates and adds a new element to the list |
//+------------------------------------------------------------------+
CElementBase *CContainer::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
  {
// --- We check that there are no more than three objects in the list - two scroll bars and the one being added
   if(this.m_list_elm.Total()>2)
     {
      ::PrintFormat("%s: Error. You can only add one element to a container\nTo add multiple elements, use the panel",__FUNCTION__);
      return NULL;
     }
// --- Create and add a new element using the parent class method
// --- The element is placed at coordinates 0,0 regardless of those specified in the parameters
   CElementBase *elm=CPanel::InsertNewElement(type,text,user_name,0,0,w,h);
// --- Checking the dimensions of the element to display scroll bars
   this.CheckElementSizes(elm);
// --- Return a pointer to the element
   return elm;
  }
//+------------------------------------------------------------------+
// | CContainer::Adds the specified element to the list |
//+------------------------------------------------------------------+
CElementBase *CContainer::InsertElement(CElementBase *element,const int dx,const int dy)
  {
// --- We check that there are no more than three objects in the list - two scroll bars and the one being added
   if(this.m_list_elm.Total()>2)
     {
      ::PrintFormat("%s: Error. You can only add one element to a container\nTo add multiple elements, use the panel",__FUNCTION__);
      return NULL;
     }
// --- Add the specified element using the parent class method
// --- The element is placed at coordinates 0,0 regardless of those specified in the parameters
   CElementBase *elm=CPanel::InsertElement(element,0,0);
// --- Checking the dimensions of the element to display scroll bars
   this.CheckElementSizes(elm);
// --- Return a pointer to the element
   return elm;
  }
//+------------------------------------------------------------------+
// | CContainer::Checks element dimensions |
// | to display scroll bars |
//+------------------------------------------------------------------+
void CContainer::CheckElementSizes(CElementBase *element)
  {
// --- If an empty element is passed, or scrolling is prohibited, we leave
   if(element==NULL || !this.m_scroll_flag)
      return;
      
// --- We get the element type and, if it is a scrollbar, we leave
   ENUM_ELEMENT_TYPE type=(ENUM_ELEMENT_TYPE)element.Type();
   if(type==ELEMENT_TYPE_SCROLLBAR_H || type==ELEMENT_TYPE_SCROLLBAR_V)
      return;
      
// --- Initialize scrollbar display flags
   this.m_visible_scrollbar_h=false;
   this.m_visible_scrollbar_v=false;
   
// --- If the width of the element is greater than the width of the visible area of ​​the container -
// --- set the horizontal scrollbar display flag
   if(element.Width()>this.ContentVisibleHor())
      this.m_visible_scrollbar_h=true;
// --- If the height of the element is greater than the height of the visible area of ​​the container -
// --- set the vertical scrollbar display flag
   if(element.Height()>this.ContentVisibleVer())
      this.m_visible_scrollbar_v=true;

// ---If both scrollbars should be displayed
   if(this.m_visible_scrollbar_h && this.m_visible_scrollbar_v)
     {
      // --- We get pointers to two scroll buttons in the lower right corner
      CButtonArrowRight *br=this.m_scrollbar_h.GetButtonRight();
      CButtonArrowDown  *bd=this.m_scrollbar_v.GetButtonDown();
   
      // --- Get the dimensions of the scroll buttons in height and width,
      // --- by which you need to reduce the scrollbars, and
      int v=(bd!=NULL ? bd.Height() : DEF_SCROLLBAR_TH);
      int h=(br!=NULL ? br.Width()  : DEF_SCROLLBAR_TH);
      // --- change the size of both scroll bars to the size of the buttons
      this.m_scrollbar_v.ResizeH(this.m_scrollbar_v.Height()-v);
      this.m_scrollbar_h.ResizeW(this.m_scrollbar_h.Width() -h);
     }
// ---If the horizontal scrollbar should be shown
   if(this.m_visible_scrollbar_h)
     {
      // --- Reduce the size of the visible container window from below by the thickness of the scroll bar + 1 pixel
      this.SetBorderWidthBottom(this.m_scrollbar_h.Height()+1);
      // --- Adjust the size of the slider to the new size of the scroll bar and
      // --- move the scrollbar to the foreground, making it visible
      this.m_scrollbar_h.SetThumbSize(this.ThumbSizeHor());
      this.m_scrollbar_h.BringToTop(false);
     }
// ---If the vertical scrollbar should be shown
   if(this.m_visible_scrollbar_v)
     {
      // --- Reduce the size of the visible container window on the right by the width of the scroll bar + 1 pixel
      this.SetBorderWidthRight(this.m_scrollbar_v.Width()+1);
      // --- Adjust the size of the slider to the new size of the scroll bar and
      // --- move the scrollbar to the foreground, making it visible
      this.m_scrollbar_v.SetThumbSize(this.ThumbSizeVer());
      this.m_scrollbar_v.BringToTop(false);
     }
// --- If any of the scroll bars are visible, crop the anchored element to the new dimensions of the visible area
   if(this.m_visible_scrollbar_h || this.m_visible_scrollbar_v)
     {
      CElementBase *elm=this.GetAttachedElementAt(2);
      if(elm!=NULL)
         elm.ObjectTrim();
     }
  }
//+-------------------------------------------------------------------+
// |CContainer::Calculates the size of the horizontal scrollbar slider|
//+-------------------------------------------------------------------+
int CContainer::ThumbSizeHor(void)
  {
   CElementBase *elm=this.GetAttachedElementAt(2);
   if(elm==NULL || elm.Width()==0 || this.TrackLengthHor()==0)
      return 0;
   return int(::round(::fmax(((double)this.ContentVisibleHor() / (double)elm.Width()) * (double)this.TrackLengthHor(), DEF_THUMB_MIN_SIZE)));
  }
//+------------------------------------------------------------------+
// | CContainer::Calculates the size of the vertical scrollbar slider|
//+------------------------------------------------------------------+
int CContainer::ThumbSizeVer(void)
  {
   CElementBase *elm=this.GetAttachedElementAt(2);
   if(elm==NULL || elm.Height()==0 || this.TrackLengthVer()==0)
      return 0;
   return int(::round(::fmax(((double)this.ContentVisibleVer() / (double)elm.Height()) * (double)this.TrackLengthVer(), DEF_THUMB_MIN_SIZE)));
  }
//+------------------------------------------------------------------+
// | CContainer::Full content horizontal size |
//+------------------------------------------------------------------+
int CContainer::ContentSizeHor(void)
  {
   CElementBase *elm=this.GetAttachedElementAt(2);
   return(elm!=NULL ? elm.Width() : 0);
  }
//+------------------------------------------------------------------+
// | CContainer::Full content vertical size |
//+------------------------------------------------------------------+
int CContainer::ContentSizeVer(void)
  {
   CElementBase *elm=this.GetAttachedElementAt(2);
   return(elm!=NULL ? elm.Height() : 0);
  }
//+--------------------------------------------------------------------+
// |CContainer::Returns the horizontal position of the container's contents|
//+--------------------------------------------------------------------+
int CContainer::ContentPositionHor(void)
  {
   CElementBase *elm=this.GetAttachedElementAt(2);
   return(elm!=NULL ? elm.X()-this.X() : 0);
  }
//+------------------------------------------------------------------+
// |CContainer::Returns the vertical position of the container's contents|
//+------------------------------------------------------------------+
int CContainer::ContentPositionVer(void)
  {
   CElementBase *elm=this.GetAttachedElementAt(2);
   return(elm!=NULL ? elm.Y()-this.Y() : 0);
  }
//+------------------------------------------------------------------+
// | CContainer::Calculates and returns offset value |
// | container contents horizontally by slider position |
//+------------------------------------------------------------------+
int CContainer::CalculateContentOffsetHor(const uint thumb_position)
  {
   CElementBase *elm=this.GetAttachedElementAt(2);
   int effective_track_length=this.TrackEffectiveLengthHor();
   if(elm==NULL || effective_track_length==0)
      return 0;
   return (int)::round(((double)thumb_position / (double)effective_track_length) * ((double)elm.Width() - (double)this.ContentVisibleHor()));
  }
//+------------------------------------------------------------------+
// | CContainer::Calculates and returns offset value |
// | container contents vertically by slider position |
//+------------------------------------------------------------------+
int CContainer::CalculateContentOffsetVer(const uint thumb_position)
  {
   CElementBase *elm=this.GetAttachedElementAt(2);
   int effective_track_length=this.TrackEffectiveLengthVer();
   if(elm==NULL || effective_track_length==0)
      return 0;
   return (int)::round(((double)thumb_position / (double)effective_track_length) * ((double)elm.Height() - (double)this.ContentVisibleVer()));
  }
//+------------------------------------------------------------------+
// | CContainer::Calculates and returns the slider offset value |
// | horizontally depending on the position of the content |
//+------------------------------------------------------------------+
int CContainer::CalculateThumbOffsetHor(const uint content_position)
  {
   CElementBase *elm=this.GetAttachedElementAt(2);
   if(elm==NULL)
      return 0;
   int value=elm.Width()-this.ContentVisibleHor();
   if(value==0)
      return 0;
   return (int)::round(((double)content_position / (double)value) * (double)this.TrackEffectiveLengthHor());
  }
//+------------------------------------------------------------------+
// | CContainer::Calculates and returns the slider offset value |
// | vertically depending on the position of the content |
//+------------------------------------------------------------------+
int CContainer::CalculateThumbOffsetVer(const uint content_position)
  {
   CElementBase *elm=this.GetAttachedElementAt(2);
   if(elm==NULL)
      return 0;
   int value=elm.Height()-this.ContentVisibleVer();
   if(value==0)
      return 0;
   return (int)::round(((double)content_position / (double)value) * (double)this.TrackEffectiveLengthVer());
  }
//+-------------------------------------------------------------------+
// |CContainer::Shifts content horizontally by the specified amount|
//+-------------------------------------------------------------------+
bool CContainer::ContentShiftHor(const int value)
  {
// --- Get a pointer to the contents of the container
   CElementBase *elm=this.GetAttachedElementAt(2);
   if(elm==NULL)
      return false;
// --- Calculate the offset value based on the position of the slider
   int content_offset=this.CalculateContentOffsetHor(value);
// --- Return the result of shifting the content by the calculated amount
   return(elm.MoveX(this.X()-content_offset));
  }
//+------------------------------------------------------------------+
// | CContainer::Shifts the content vertically by the specified value|
//+------------------------------------------------------------------+
bool CContainer::ContentShiftVer(const int value)
  {
// --- Get a pointer to the contents of the container
   CElementBase *elm=this.GetAttachedElementAt(2);
   if(elm==NULL)
      return false;
// --- Calculate the offset value based on the position of the slider
   int content_offset=this.CalculateContentOffsetVer(value);
// --- Return the result of shifting the content by the calculated amount
   return(elm.MoveY(this.Y()-content_offset));
  }
//+------------------------------------------------------------------+
// | Returns the type of the element that sent the event |
//+------------------------------------------------------------------+
ENUM_ELEMENT_TYPE CContainer::GetEventElementType(const string name)
  {
// --- Get the names of all elements in the hierarchy (if there is an error, return -1)
   string names[]={};
   int total = GetElementNames(name,"_",names);
   if(total==WRONG_VALUE)
      return WRONG_VALUE;
      
// --- If the name of the base element in the hierarchy does not match the name of the container, then this is not our event - we leave
   string base_name=names[0];
   if(base_name!=this.NameFG())
      return WRONG_VALUE;
      
// --- Events that did not come from scrollbars are skipped
   string check_name=::StringSubstr(names[1],0,4);
   if(check_name!="SCBH" && check_name!="SCBV")
      return WRONG_VALUE;
      
// --- Get the name of the element from which the event came and initialize the element type
   string elm_name=names[names.Size()-1];
   ENUM_ELEMENT_TYPE type=WRONG_VALUE;
   
// --- Check and record the element type
// --- Up arrow button
   if(::StringFind(elm_name,"BTARU")==0)
      type=ELEMENT_TYPE_BUTTON_ARROW_UP;
// --- Down arrow button
   else if(::StringFind(elm_name,"BTARD")==0)
      type=ELEMENT_TYPE_BUTTON_ARROW_DOWN;
// ---Left arrow button
   else if(::StringFind(elm_name,"BTARL")==0)
      type=ELEMENT_TYPE_BUTTON_ARROW_LEFT;
// --- Right arrow button
   else if(::StringFind(elm_name,"BTARR")==0)
      type=ELEMENT_TYPE_BUTTON_ARROW_RIGHT;
// ---Horizontal scroll bar slider
   else if(::StringFind(elm_name,"THMBH")==0)
      type=ELEMENT_TYPE_SCROLLBAR_THUMB_H;
// ---Vertical scroll bar slider
   else if(::StringFind(elm_name,"THMBV")==0)
      type=ELEMENT_TYPE_SCROLLBAR_THUMB_V;
// ---ScrollBarHorizontal control
   else if(::StringFind(elm_name,"SCBH")==0)
      type=ELEMENT_TYPE_SCROLLBAR_H;
// --- ScrollBarVertical control
   else if(::StringFind(elm_name,"SCBV")==0)
      type=ELEMENT_TYPE_SCROLLBAR_V;
      
// --- Return the element type
   return type;
  }
//+------------------------------------------------------------------+
// | CContainer::Element Custom Event Handler |
// | when moving the cursor in the object area |
//+------------------------------------------------------------------+
void CContainer::MouseMoveHandler(const int id,const long lparam,const double dparam,const string sparam)
  {
   bool res=false;
// --- Get a pointer to the contents of the container
   CElementBase *elm=this.GetAttachedElementAt(2);
// --- Get the type of element from which the event came
   ENUM_ELEMENT_TYPE type=this.GetEventElementType(sparam);
// --- If we couldn’t get the element type or a pointer to the content, leave
   if(type==WRONG_VALUE || elm==NULL)
      return;
   
// --- If the horizontal scrollbar slider event - shift the content horizontally
   if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_H)
      res=this.ContentShiftHor((int)lparam);

// --- If the vertical scrollbar slider event - shift the content vertically
   if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_V)
      res=this.ContentShiftVer((int)lparam);
   
// --- If the content is successfully shifted, we update the graph
   if(res)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CContainer::Element Custom Event Handler |
// | when clicking in the object area |
//+------------------------------------------------------------------+
void CContainer::MousePressHandler(const int id,const long lparam,const double dparam,const string sparam)
  {
   bool res=false;
// --- Get a pointer to the contents of the container
   CElementBase *elm=this.GetAttachedElementAt(2);
// --- Get the type of element from which the event came
   ENUM_ELEMENT_TYPE type=this.GetEventElementType(sparam);
// --- If we couldn’t get the element type or a pointer to the content, leave
   if(type==WRONG_VALUE || elm==NULL)
      return;
   
// --- If the events of the horizontal scrollbar buttons,
   if(type==ELEMENT_TYPE_BUTTON_ARROW_LEFT || type==ELEMENT_TYPE_BUTTON_ARROW_RIGHT)
     {
      // --- Check the pointer to the horizontal scrollbar
      if(this.m_scrollbar_h==NULL)
         return;
      // --- get a pointer to the scrollbar slider
      CScrollBarThumbH *obj=this.m_scrollbar_h.GetThumb();
      if(obj==NULL)
         return;
      // --- determine the direction of slider shift based on the type of button pressed
      int direction=(type==ELEMENT_TYPE_BUTTON_ARROW_LEFT ? 120 : -120);
      // --- call the scroll handler of the slider object to move the slider in the direction
      obj.OnWheelEvent(id,0,direction,this.NameFG());
      // --- Successfully
      res=true;
     }
   
// --- If the events of the vertical scrollbar buttons,
   if(type==ELEMENT_TYPE_BUTTON_ARROW_UP || type==ELEMENT_TYPE_BUTTON_ARROW_DOWN)
     {
      // --- Checking the pointer to the vertical scrollbar
      if(this.m_scrollbar_v==NULL)
         return;
      // --- get a pointer to the scrollbar slider
      CScrollBarThumbV *obj=this.m_scrollbar_v.GetThumb();
      if(obj==NULL)
         return;
      // --- determine the direction of slider shift based on the type of button pressed
      int direction=(type==ELEMENT_TYPE_BUTTON_ARROW_UP ? 120 : -120);
      // --- call the scroll handler of the slider object to move the slider in the direction
      obj.OnWheelEvent(id,0,direction,this.NameFG());
      // --- Successfully
      res=true;
     }

// --- If the click event is on a horizontal scrollbar (between the slider and scroll buttons),
   if(type==ELEMENT_TYPE_SCROLLBAR_H)
     {
      // --- Check the pointer to the horizontal scrollbar
      if(this.m_scrollbar_h==NULL)
         return;
      // --- get a pointer to the scrollbar slider
      CScrollBarThumbH *thumb=this.m_scrollbar_h.GetThumb();
      if(thumb==NULL)
         return;
      // --- Slider offset direction
      int direction=(lparam>=thumb.Right() ? 1 : lparam<=thumb.X() ? -1 : 0);

      // --- Check the divisor for a zero value
      if(this.ContentSizeHor()-this.ContentVisibleHor()==0)
         return;     
      
      // --- Calculate the slider offset proportional to the content offset by one screen
      int thumb_shift=(int)::round(direction * ((double)this.ContentVisibleHor() / double(this.ContentSizeHor()-this.ContentVisibleHor())) * (double)this.TrackEffectiveLengthHor());
      // --- call the scroll handler of the slider object to move the slider in the direction of the offset
      thumb.OnWheelEvent(id,thumb_shift,0,this.NameFG());
      // --- Record the result of shifting the contents of the container
      res=this.ContentShiftHor(thumb_shift);
     }
   
// --- If the click event is on a vertical scrollbar (between the slider and scroll buttons),
   if(type==ELEMENT_TYPE_SCROLLBAR_V)
     {
      // --- Checking the pointer to the vertical scrollbar
      if(this.m_scrollbar_v==NULL)
         return;
      // --- get a pointer to the scrollbar slider
      CScrollBarThumbV *thumb=this.m_scrollbar_v.GetThumb();
      if(thumb==NULL)
         return;
      // --- Slider offset direction
      int cursor=int(dparam-this.m_wnd_y);
      int direction=(cursor>=thumb.Bottom() ? 1 : cursor<=thumb.Y() ? -1 : 0);

      // --- Check the divisor for a zero value
      if(this.ContentSizeVer()-this.ContentVisibleVer()==0)
         return;     
      
      // --- Calculate the slider offset proportional to the content offset by one screen
      int thumb_shift=(int)::round(direction * ((double)this.ContentVisibleVer() / double(this.ContentSizeVer()-this.ContentVisibleVer())) * (double)this.TrackEffectiveLengthVer());
      // --- call the scroll handler of the slider object to move the slider in the direction of the offset
      thumb.OnWheelEvent(id,thumb_shift,0,this.NameFG());
      // --- Record the result of shifting the contents of the container
      res=this.ContentShiftVer(thumb_shift);
     }
   
// --- If everything is successful, update the schedule
   if(res)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
// | CContainer::Element Custom Event Handler |
// | when scrolling the wheel in the scrollbar slider area |
//+------------------------------------------------------------------+
void CContainer::MouseWheelHandler(const int id,const long lparam,const double dparam,const string sparam)
  {
   bool res=false;
// --- Get a pointer to the contents of the container
   CElementBase *elm=this.GetAttachedElementAt(2);
// --- Get the type of element from which the event came
   ENUM_ELEMENT_TYPE type=this.GetEventElementType(sparam);
// --- If we were unable to obtain a pointer to the contents or the type of the element, we leave
   if(type==WRONG_VALUE || elm==NULL)
      return;
   
// --- If the horizontal scrollbar slider event - shift the content horizontally
   if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_H)
      res=this.ContentShiftHor((int)lparam);

// --- If the vertical scrollbar slider event - shift the content vertically
   if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_V)
      res=this.ContentShiftVer((int)lparam);
   
// --- If the content is successfully shifted, we update the graph
   if(res)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
