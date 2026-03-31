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

//+------------------------------------------------------------------+
// | Macro substitutions |
//+------------------------------------------------------------------+
#define  DEF_LABEL_W          40          // Default text label width
#define  DEF_LABEL_H          16          // Default text label height
#define  DEF_BUTTON_W         50          // Default button width
#define  DEF_BUTTON_H         16          // Default button height

//+------------------------------------------------------------------+
// | Transfers |
//+------------------------------------------------------------------+
enum ENUM_ELEMENT_COMPARE_BY              // Comparable properties
  {
   ELEMENT_SORT_BY_ID   =  0,             // Comparison by element ID
   ELEMENT_SORT_BY_NAME,                  // Comparison by element name
   ELEMENT_SORT_BY_TEXT,                  // Comparison by element text
   ELEMENT_SORT_BY_COLOR,                 // Comparison by element color
   ELEMENT_SORT_BY_ALPHA,                 // Comparison by element transparency
   ELEMENT_SORT_BY_STATE,                 // Comparison by item condition
  };
//+------------------------------------------------------------------+ 
// | Functions |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// | Classes |
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
   const CImagePainter *obj=node;
   switch(mode)
     {
      case ELEMENT_SORT_BY_NAME  :  return(this.Name() >obj.Name()   ? 1 : this.Name() <obj.Name() ? -1 : 0);
      case ELEMENT_SORT_BY_ALPHA :  return(this.Alpha()>obj.Alpha()  ? 1 : this.Alpha()<obj.Alpha()? -1 : 0);
      default                    :  return(this.ID()   >obj.ID()     ? 1 : this.ID()   <obj.ID()   ? -1 : 0);
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
// | Text Label Class |
//+------------------------------------------------------------------+
class CLabel : public CCanvasBase
  {
protected:
   CImagePainter     m_painter;                                // Drawing class
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
// --- Returns a pointer to the drawing class
   CImagePainter    *Painter(void)                             { return &this.m_painter;           }
   
// --- (1) Sets, (2) returns text
   void              SetText(const string text)                { ::StringToShortArray(text,this.m_text);       }
   string            Text(void)                          const { return ::ShortArrayToString(this.m_text);     }
   
// --- Returns the (1) X, (2) Y coordinate of the text
   int               TextX(void)                         const { return this.m_text_x;                         }
   int               TextY(void)                         const { return this.m_text_y;                         }

// --- Sets the (1) X, (2) Y coordinate of the text
   void              SetTextShiftH(const int x)                { this.m_text_x=x;                              }
   void              SetTextShiftV(const int y)                { this.m_text_y=y;                              }
   
// --- (1) Sets coordinates, (2) resizes image area
   void              SetImageXY(const int x,const int y)       { this.m_painter.SetXY(x,y);                    }
   void              SetImageSize(const int w,const int h)     { this.m_painter.SetSize(w,h);                  }
// --- Sets the coordinates and dimensions of the image area
   void              SetImageBound(const int x,const int y,const int w,const int h)
                       {
                        this.SetImageXY(x,y);
                        this.SetImageSize(w,h);
                       }
// --- Returns the coordinates of the (1) X, (2) Y, (3) width, (4) height, (5) right, (6) bottom border of the image area
   int               ImageX(void)                        const { return this.m_painter.X();                    }
   int               ImageY(void)                        const { return this.m_painter.Y();                    }
   int               ImageWidth(void)                    const { return this.m_painter.Width();                }
   int               ImageHeight(void)                   const { return this.m_painter.Height();               }
   int               ImageRight(void)                    const { return this.m_painter.Right();                }
   int               ImageBottom(void)                   const { return this.m_painter.Bottom();               }

// --- Outputs text
   void              DrawText(const int dx, const int dy, const string text, const bool chart_redraw);
   
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_LABEL);                   }
   
// --- Constructors/destructor
                     CLabel(void);
                     CLabel(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CLabel(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CLabel(const string object_name, const long chart_id, const int wnd, const string text, const int x, const int y, const int w, const int h);
                    ~CLabel(void) {}
  };
//+------------------------------------------------------------------+
// | CLabel::Default constructor. Builds a label in the main window |
// | current chart in coordinates 0,0 with default sizes |
//+------------------------------------------------------------------+
CLabel::CLabel(void) : CCanvasBase("Label",::ChartID(),0,0,0,DEF_LABEL_W,DEF_LABEL_H), m_text_x(0), m_text_y(0)
  {
// --- Assign the foreground canvas to the drawing object and
// --- reset the coordinates and dimensions, which makes it inactive
   this.m_painter.CanvasAssign(this.GetForeground());
   this.m_painter.SetXY(0,0);
   this.m_painter.SetSize(0,0);
// --- Set the current and previous text
   this.SetText("Label");
   this.SetTextPrev("");
// --- Background is transparent, foreground is not
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
  }
//+------------------------------------------------------------------+
// | CLabel::The constructor is parametric. Builds a label in the main window |
// | current chart with the specified text, coordinates and sizes |
//+------------------------------------------------------------------+
CLabel::CLabel(const string object_name, const string text,const int x,const int y,const int w,const int h) :
   CCanvasBase(object_name,::ChartID(),0,x,y,w,h), m_text_x(0), m_text_y(0)
  {
// --- Assign the foreground canvas to the drawing object and
// --- reset the coordinates and dimensions, which makes it inactive
   this.m_painter.CanvasAssign(this.GetForeground());
   this.m_painter.SetXY(0,0);
   this.m_painter.SetSize(0,0);
// --- Set the current and previous text
   this.SetText(text);
   this.SetTextPrev("");
// --- Background is transparent, foreground is not
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
  }
//+-------------------------------------------------------------------+
// | CLabel::The constructor is parametric. Builds a label in the specified window|
// | current chart with the specified text, coordinates and sizes |
//+-------------------------------------------------------------------+
CLabel::CLabel(const string object_name, const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CCanvasBase(object_name,::ChartID(),wnd,x,y,w,h), m_text_x(0), m_text_y(0)
  {
// --- Assign the foreground canvas to the drawing object and
// --- reset the coordinates and dimensions, which makes it inactive
   this.m_painter.CanvasAssign(this.GetForeground());
   this.m_painter.SetXY(0,0);
   this.m_painter.SetSize(0,0);
// --- Set the current and previous text
   this.SetText(text);
   this.SetTextPrev("");
// --- Background is transparent, foreground is not
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
  }
//+-------------------------------------------------------------------+
// | CLabel::The constructor is parametric. Builds a label in the specified window|
// | specified graphics with specified text, coordinates and dimensions |
//+-------------------------------------------------------------------+
CLabel::CLabel(const string object_name,const long chart_id,const int wnd,const string text,const int x,const int y,const int w,const int h) :
   CCanvasBase(object_name,chart_id,wnd,x,y,w,h), m_text_x(0), m_text_y(0)
  {
// --- Assign the foreground canvas to the drawing object and
// --- reset the coordinates and dimensions, which makes it inactive
   this.m_painter.CanvasAssign(this.GetForeground());
   this.m_painter.SetXY(0,0);
   this.m_painter.SetSize(0,0);
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
   const CLabel *obj=node;
   switch(mode)
     {
      case ELEMENT_SORT_BY_NAME  :  return(this.Name()     >obj.Name()      ? 1 : this.Name()     <obj.Name()      ? -1 : 0);
      case ELEMENT_SORT_BY_TEXT  :  return(this.Text()     >obj.Text()      ? 1 : this.Text()     <obj.Text()      ? -1 : 0);
      case ELEMENT_SORT_BY_COLOR :  return(this.ForeColor()>obj.ForeColor() ? 1 : this.ForeColor()<obj.ForeColor() ? -1 : 0);
      case ELEMENT_SORT_BY_ALPHA :  return(this.AlphaFG()  >obj.AlphaFG()   ? 1 : this.AlphaFG()  <obj.AlphaFG()   ? -1 : 0);
      default                    :  return(this.ID()       >obj.ID()        ? 1 : this.ID()       <obj.ID()        ? -1 : 0);
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
   if(!CCanvasBase::Save(file_handle))
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
   if(!CCanvasBase::Load(file_handle))
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
   
// --- Constructors/destructor
                     CButton(void);
                     CButton(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CButton(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CButton(const string object_name, const long chart_id, const int wnd, const string text, const int x, const int y, const int w, const int h);
                    ~CButton (void) {}
  };
//+------------------------------------------------------------------+
// | CButton::Default constructor. Builds a button in the main window |
// | current chart in coordinates 0,0 with default sizes |
//+------------------------------------------------------------------+
CButton::CButton(void) : CLabel("Button",::ChartID(),0,"Button",0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
   this.SetState(ELEMENT_STATE_DEF);
   this.SetAlpha(255);
  }
//+-------------------------------------------------------------------+
// | CButton::The constructor is parametric. Builds a button in the main window|
// | current chart with the specified text, coordinates and sizes |
//+-------------------------------------------------------------------+
CButton::CButton(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CLabel(object_name,::ChartID(),0,text,x,y,w,h)
  {
   this.SetState(ELEMENT_STATE_DEF);
   this.SetAlpha(255);
  }
//+---------------------------------------------------------------------+
// | CButton::The constructor is parametric. Builds a button in the specified window|
// | current chart with the specified text, coordinates and sizes |
//+---------------------------------------------------------------------+
CButton::CButton(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CLabel(object_name,::ChartID(),wnd,text,x,y,w,h)
  {
   this.SetState(ELEMENT_STATE_DEF);
   this.SetAlpha(255);
  }
//+---------------------------------------------------------------------+
// | CButton::The constructor is parametric. Builds a button in the specified window|
// | specified graphics with specified text, coordinates and dimensions |
//+---------------------------------------------------------------------+
CButton::CButton(const string object_name,const long chart_id,const int wnd,const string text,const int x,const int y,const int w,const int h) :
   CLabel(object_name,chart_id,wnd,text,x,y,w,h)
  {
   this.SetState(ELEMENT_STATE_DEF);
   this.SetAlpha(255);
  }
//+------------------------------------------------------------------+
// | CButton::Comparing two objects |
//+------------------------------------------------------------------+
int CButton::Compare(const CObject *node,const int mode=0) const
  {
   const CButton *obj=node;
   switch(mode)
     {
      case ELEMENT_SORT_BY_NAME  :  return(this.Name()     >obj.Name()      ? 1 : this.Name()     <obj.Name()      ? -1 : 0);
      case ELEMENT_SORT_BY_TEXT  :  return(this.Text()     >obj.Text()      ? 1 : this.Text()     <obj.Text()      ? -1 : 0);
      case ELEMENT_SORT_BY_COLOR :  return(this.BackColor()>obj.BackColor() ? 1 : this.BackColor()<obj.BackColor() ? -1 : 0);
      case ELEMENT_SORT_BY_ALPHA :  return(this.AlphaBG()  >obj.AlphaBG()   ? 1 : this.AlphaBG()  <obj.AlphaBG()   ? -1 : 0);
      default                    :  return(this.ID()       >obj.ID()        ? 1 : this.ID()       <obj.ID()        ? -1 : 0);
     }
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
//+------------------------------------------------------------------+
// | Two-way button class |
//+------------------------------------------------------------------+
class CButtonTriggered : public CButton
  {
public:
// ---Draws the appearance
   virtual void      Draw(const bool chart_redraw);

// --- Event handler for mouse button clicks (Press)
   virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
   virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_TRIGGERED);  }
  
// --- Initialize object colors to default
   virtual void      InitColors(void);
   
// --- Constructors/destructor
                     CButtonTriggered(void);
                     CButtonTriggered(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CButtonTriggered(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CButtonTriggered(const string object_name, const long chart_id, const int wnd, const string text, const int x, const int y, const int w, const int h);
                    ~CButtonTriggered (void) {}
  };
//+------------------------------------------------------------------+
// | CButtonTriggered::Default constructor.                      |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CButtonTriggered::CButtonTriggered(void) : CButton("Button",::ChartID(),0,"Button",0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
   this.InitColors();
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Parametric constructor.                   |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonTriggered::CButtonTriggered(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CButton(object_name,::ChartID(),0,text,x,y,w,h)
  {
   this.InitColors();
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Parametric constructor.                   |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonTriggered::CButtonTriggered(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,::ChartID(),wnd,text,x,y,w,h)
  {
   this.InitColors();
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Parametric constructor.                   |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonTriggered::CButtonTriggered(const string object_name,const long chart_id,const int wnd,const string text,const int x,const int y,const int w,const int h) :
   CButton(object_name,chart_id,wnd,text,x,y,w,h)
  {
   this.InitColors();
  }
//+------------------------------------------------------------------+
// | CButtonTriggered::Comparing two objects |
//+------------------------------------------------------------------+
int CButtonTriggered::Compare(const CObject *node,const int mode=0) const
  {
   const CButtonTriggered *obj=node;
   switch(mode)
     {
      case ELEMENT_SORT_BY_NAME  :  return(this.Name()     >obj.Name()      ? 1 : this.Name()     <obj.Name()      ? -1 : 0);
      case ELEMENT_SORT_BY_TEXT  :  return(this.Text()     >obj.Text()      ? 1 : this.Text()     <obj.Text()      ? -1 : 0);
      case ELEMENT_SORT_BY_COLOR :  return(this.BackColor()>obj.BackColor() ? 1 : this.BackColor()<obj.BackColor() ? -1 : 0);
      case ELEMENT_SORT_BY_ALPHA :  return(this.AlphaBG()  >obj.AlphaBG()   ? 1 : this.AlphaBG()  <obj.AlphaBG()   ? -1 : 0);
      case ELEMENT_SORT_BY_STATE :  return(this.State()    >obj.State()     ? 1 : this.State()    <obj.State()     ? -1 : 0);
      default                    :  return(this.ID()       >obj.ID()        ? 1 : this.ID()       <obj.ID()        ? -1 : 0);
     }
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
   
// --- Constructors/destructor
                     CButtonArrowUp(void);
                     CButtonArrowUp(const string object_name, const int x, const int y, const int w, const int h);
                     CButtonArrowUp(const string object_name, const int wnd, const int x, const int y, const int w, const int h);
                     CButtonArrowUp(const string object_name, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButtonArrowUp (void) {}
  };
//+------------------------------------------------------------------+
// | CButtonArrowUp::Default constructor.                        |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CButtonArrowUp::CButtonArrowUp(void) : CButton("Arrow Up Button",::ChartID(),0,"",0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowUp::Parametric constructor.                     |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowUp::CButtonArrowUp(const string object_name,const int x,const int y,const int w,const int h) :
   CButton(object_name,::ChartID(),0,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowUp::Parametric constructor.                     |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowUp::CButtonArrowUp(const string object_name,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,::ChartID(),wnd,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowUp::Parametric constructor.                     |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowUp::CButtonArrowUp(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,chart_id,wnd,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
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
   
// --- Constructors/destructor
                     CButtonArrowDown(void);
                     CButtonArrowDown(const string object_name, const int x, const int y, const int w, const int h);
                     CButtonArrowDown(const string object_name, const int wnd, const int x, const int y, const int w, const int h);
                     CButtonArrowDown(const string object_name, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButtonArrowDown (void) {}
  };
//+------------------------------------------------------------------+
// | CButtonArrowDown::Default constructor.                      |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CButtonArrowDown::CButtonArrowDown(void) : CButton("Arrow Up Button",::ChartID(),0,"",0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowDown::Parametric constructor.                   |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowDown::CButtonArrowDown(const string object_name,const int x,const int y,const int w,const int h) :
   CButton(object_name,::ChartID(),0,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowDown::Parametric constructor.                   |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowDown::CButtonArrowDown(const string object_name,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,::ChartID(),wnd,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowDown::Parametric constructor.                   |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowDown::CButtonArrowDown(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,chart_id,wnd,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
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
   
// --- Constructors/destructor
                     CButtonArrowLeft(void);
                     CButtonArrowLeft(const string object_name, const int x, const int y, const int w, const int h);
                     CButtonArrowLeft(const string object_name, const int wnd, const int x, const int y, const int w, const int h);
                     CButtonArrowLeft(const string object_name, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButtonArrowLeft (void) {}
  };
//+------------------------------------------------------------------+
// | CButtonArrowLeft::Default constructor.                      |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CButtonArrowLeft::CButtonArrowLeft(void) : CButton("Arrow Up Button",::ChartID(),0,"",0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowLeft::Parametric constructor.                   |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowLeft::CButtonArrowLeft(const string object_name,const int x,const int y,const int w,const int h) :
   CButton(object_name,::ChartID(),0,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowLeft::Parametric constructor.                   |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowLeft::CButtonArrowLeft(const string object_name,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,::ChartID(),wnd,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowLeft::Parametric constructor.                   |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowLeft::CButtonArrowLeft(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,chart_id,wnd,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
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
   
// --- Constructors/destructor
                     CButtonArrowRight(void);
                     CButtonArrowRight(const string object_name, const int x, const int y, const int w, const int h);
                     CButtonArrowRight(const string object_name, const int wnd, const int x, const int y, const int w, const int h);
                     CButtonArrowRight(const string object_name, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButtonArrowRight (void) {}
  };
//+------------------------------------------------------------------+
// | CButtonArrowRight::Default constructor.                     |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CButtonArrowRight::CButtonArrowRight(void) : CButton("Arrow Up Button",::ChartID(),0,"",0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowRight::Parametric constructor.                  |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowRight::CButtonArrowRight(const string object_name,const int x,const int y,const int w,const int h) :
   CButton(object_name,::ChartID(),0,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowRight::Parametric constructor.                  |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowRight::CButtonArrowRight(const string object_name,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,::ChartID(),wnd,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CButtonArrowRight::Parametric constructor.                  |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CButtonArrowRight::CButtonArrowRight(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,chart_id,wnd,"",x,y,w,h)
  {
   this.InitColors();
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
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
  
// --- Initialize object colors to default
   virtual void      InitColors(void);
   
// --- Constructors/destructor
                     CCheckBox(void);
                     CCheckBox(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CCheckBox(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CCheckBox(const string object_name, const long chart_id, const int wnd, const string text, const int x, const int y, const int w, const int h);
                    ~CCheckBox (void) {}
  };
//+------------------------------------------------------------------+
// | CCheckBox::Default constructor.                             |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CCheckBox::CCheckBox(void) : CButtonTriggered("CheckBox",::ChartID(),0,"CheckBox",0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
// --- Set default colors, transparency for background and foreground,
// --- and coordinates and boundaries of the button icon drawing area
   this.InitColors();
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CCheckBox::Parametric constructor.                          |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CCheckBox::CCheckBox(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CButtonTriggered(object_name,::ChartID(),0,text,x,y,w,h)
  {
// --- Set default colors, transparency for background and foreground,
// --- and coordinates and boundaries of the button icon drawing area
   this.InitColors();
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CCheckBox::Parametric constructor.                          |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CCheckBox::CCheckBox(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CButtonTriggered(object_name,::ChartID(),wnd,text,x,y,w,h)
  {
// --- Set default colors, transparency for background and foreground,
// --- and coordinates and boundaries of the button icon drawing area
   this.InitColors();
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CCheckBox::Parametric constructor.                          |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CCheckBox::CCheckBox(const string object_name,const long chart_id,const int wnd,const string text,const int x,const int y,const int w,const int h) :
   CButtonTriggered(object_name,chart_id,wnd,text,x,y,w,h)
  {
// --- Set default colors, transparency for background and foreground,
// --- and coordinates and boundaries of the button icon drawing area
   this.InitColors();
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }
//+------------------------------------------------------------------+
// | CCheckBox::Comparing two objects |
//+------------------------------------------------------------------+
int CCheckBox::Compare(const CObject *node,const int mode=0) const
  {
   return CButtonTriggered::Compare(node,mode);
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

// --- Event handler for mouse button clicks (Press)
   virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);

// --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
   virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_RADIOBUTTON);    }
  
// --- Constructors/destructor
                     CRadioButton(void);
                     CRadioButton(const string object_name, const string text, const int x, const int y, const int w, const int h);
                     CRadioButton(const string object_name, const string text, const int wnd, const int x, const int y, const int w, const int h);
                     CRadioButton(const string object_name, const long chart_id, const int wnd, const string text, const int x, const int y, const int w, const int h);
                    ~CRadioButton (void) {}
  };
//+------------------------------------------------------------------+
// | CRadioButton::Default constructor.                          |
// | Builds a button in the main window of the current chart |
// | at coordinates 0,0 with default dimensions |
//+------------------------------------------------------------------+
CRadioButton::CRadioButton(void) : CCheckBox("RadioButton",::ChartID(),0,"",0,0,DEF_BUTTON_H,DEF_BUTTON_H)
  {
  }
//+------------------------------------------------------------------+
// | CRadioButton::Parametric constructor.                       |
// | Builds a button in the main window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CRadioButton::CRadioButton(const string object_name,const string text,const int x,const int y,const int w,const int h) :
   CCheckBox(object_name,::ChartID(),0,text,x,y,w,h)
  {
  }
//+------------------------------------------------------------------+
// | CRadioButton::Parametric constructor.                       |
// | Builds a button in the specified window of the current chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CRadioButton::CRadioButton(const string object_name,const string text,const int wnd,const int x,const int y,const int w,const int h) :
   CCheckBox(object_name,::ChartID(),wnd,text,x,y,w,h)
  {
  }
//+------------------------------------------------------------------+
// | CRadioButton::Parametric constructor.                       |
// | Builds a button in the specified window of the specified chart |
// | with specified text, coordinates and dimensions |
//+------------------------------------------------------------------+
CRadioButton::CRadioButton(const string object_name,const long chart_id,const int wnd,const string text,const int x,const int y,const int w,const int h) :
   CCheckBox(object_name,chart_id,wnd,text,x,y,w,h)
  {
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
