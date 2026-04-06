//+------------------------------------------------------------------+
//|                                               ImagePainter.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/18221  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Picture Drawing Class                                            |
//+------------------------------------------------------------------+
#ifndef __IMAGEPAINTER_MQH__
#define __IMAGEPAINTER_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   #include <Arrays\List.mqh>
   #include <Canvas\Canvas.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "..\Defines\TableDefines.mqh"
   #include "..\Defines\TableEnums.mqh"
   #include "..\Defines\BaseDefines.mqh"
   #include "..\Defines\BaseEnums.mqh"
   #include "..\Defines\ControlsDefines.mqh"
   #include "..\Defines\ControlsEnums.mqh"
   #include "Bound.mqh"   
class CImagePainter : public CBaseObj
 {
  protected:
   CCanvas          *m_canvas;                                 // Pointer to the canvas where we draw
   CBound            m_bound;                                  // Image coordinates and boundaries
   uchar             m_alpha;                                  // Transparency
   
  // --- Checks the validity of the canvas and the correct dimensions
   bool              CheckBound(const string source);

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
   
   // --- Draws (1) horizontal 17x7, (2) vertical 7x17 double arrow
      bool              ArrowHorz(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true); 
      bool              ArrowVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true); 
   
   // --- Draws a diagonal (1) top-left --- down-right, (2) bottom-left --- up-right 17x17 double arrow
      bool              ArrowNWSE(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
      bool              ArrowNESW(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   
   // --- Draws an 18x18 offset arrow along (1) horizontal, (2) vertical
      bool              ArrowShiftHorz(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
      bool              ArrowShiftVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   
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
   
   // --- Draws a filled triangle at (1) top-left, (2) bottom-left, (3) top-right, (4) bottom-right corner
      bool              TriangleLT(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
      bool              TriangleLB(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
      bool              TriangleRT(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
      bool              TriangleRB(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);

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
 #ifndef CIMAGEPAINTER_IMPLEMENTATION
 #define CIMAGEPAINTER_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| CImagePainter::Comparing two objects |
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
  bool CImagePainter::CheckBound(const string source)
   {
      if(this.m_canvas==NULL)
      {
         ::PrintFormat("%s: Error. First you need to assign the canvas using the CanvasAssign() method",__FUNCTION__);
         return false;
      }
      if(this.Width()==0 || this.Height()==0)
      {
         ::PrintFormat("%s::%s Error: (w %d, h %d). First you need to set the area size using the SetSize() or SetImageBound() methods",source,__FUNCTION__,this.Width(),this.Height());
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
      if(!this.CheckBound(__FUNCTION__))
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
  //| CImagePainter::Draws a filled up arrow                           |
  //+------------------------------------------------------------------+
  bool CImagePainter::ArrowUp(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
     // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
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
      if(!this.CheckBound(__FUNCTION__))
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
  //| CImagePainter::Draws a filled left arrow                         |
  //+------------------------------------------------------------------+
  bool CImagePainter::ArrowLeft(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
     // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
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
  // | CImagePainter::Draws a filled right arrow                       |
  //+------------------------------------------------------------------+
  bool CImagePainter::ArrowRight(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
     // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
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
  // | CImagePainter::Draws a horizontal 17x7 double arrow             |
  //+------------------------------------------------------------------+
  bool CImagePainter::ArrowHorz(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
     // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
         return false;
      
     // --- Shape coordinates
      int arrx[15]={0, 3, 4, 4, 12, 12, 13, 16, 13, 12, 12, 4, 4, 3, 0};
      int arry[15]={3, 0, 0, 2,  2,  0,  0,  3,  6,  6,  4, 4, 6, 6, 3};
      
     // --- Draw a white background
      this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

     // --- Draw a line of arrows
      this.m_canvas.Line(1,3, 15,3,::ColorToARGB(clr,alpha));
     // --- Draw the left triangle
      this.m_canvas.Line(1,3, 1,3,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(2,2, 2,4,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(3,1, 3,5,::ColorToARGB(clr,alpha));
     // --- Draw the right triangle
      this.m_canvas.Line(13,1, 13,5,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(14,2, 14,4,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(15,3, 15,3,::ColorToARGB(clr,alpha));
      
      if(update)
         this.m_canvas.Update(false);
      return true;
   }
  //+------------------------------------------------------------------+
  //| CImagePainter::Draws a vertical 7x17 double arrow                |
  //+------------------------------------------------------------------+
  bool CImagePainter::ArrowVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
     // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
         return false;

     // --- Shape coordinates
      int arrx[15]={3, 6, 6, 4,  4,  6,  6,  3,  0,  0,  2, 2, 0, 0, 3};
      int arry[15]={0, 3, 4, 4, 12, 12, 13, 16, 13, 12, 12, 4, 4, 3, 0};
      
     // --- Draw a white background
      this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

     // --- Draw a line of arrows
      this.m_canvas.Line(3,1, 3,15,::ColorToARGB(clr,alpha));
     // --- Draw the upper triangle
      this.m_canvas.Line(3,1, 3,1,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(2,2, 4,2,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(1,3, 5,3,::ColorToARGB(clr,alpha));
     // --- Draw the lower triangle
      this.m_canvas.Line(1,13, 5,13,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(2,14, 4,14,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(3,15, 3,15,::ColorToARGB(clr,alpha));

      if(update)
         this.m_canvas.Update(false);
      return true;
   }
  //+------------------------------------------------------------------+
  //| CImagePainter::Draws an 18x18 horizontal offset arrow            |
  //+------------------------------------------------------------------+
  bool CImagePainter::ArrowShiftHorz(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
         return false;

    // --- Shape coordinates
      int arrx[25]={0, 3, 4, 4, 7, 7, 10, 10, 13, 13, 14, 17, 17, 14, 13, 13, 10, 10,  7,  7,  4,  4,  3, 0, 0};
      int arry[25]={8, 5, 5, 7, 7, 0,  0,  7,  7,  5,  5,  8,  9, 12, 12, 10, 10, 17, 17, 10, 10, 12, 12, 9, 8};
      
    // --- Draw a white background
      this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

    // --- Draw a line of arrows
      this.m_canvas.FillRectangle(1,8, 16,9,::ColorToARGB(clr,alpha));
    // --- Draw a dividing line
      this.m_canvas.FillRectangle(8,1, 9,16,::ColorToARGB(clr,alpha));
    // --- Draw the left triangle
      this.m_canvas.Line(2,7, 2,10,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(3,6, 3,11,::ColorToARGB(clr,alpha));
    // --- Draw the right triangle
      this.m_canvas.Line(14,6, 14,11,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(15,7, 15,10,::ColorToARGB(clr,alpha));

      if(update)
         this.m_canvas.Update(false);
      return true;
   }
  //+------------------------------------------------------------------+
  //| CImagePainter::Draws an 18x18 vertical offset arrow              |
  //+------------------------------------------------------------------+
  bool CImagePainter::ArrowShiftVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
         return false;
      ///*
    // --- Shape coordinates
      int arrx[25]={0, 7, 7, 5, 5, 8, 9, 12, 12, 10, 10, 17, 17, 10, 10, 12, 12,  9,  8,  5,  5,  7,  7,  0, 0};
      int arry[25]={7, 7, 4, 4, 3, 0, 0,  3,  4,  4,  7,  7, 10, 10, 13, 13, 14, 17, 17, 14, 13, 13, 10, 10, 7};
      
    // --- Draw a white background
      this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

    // --- Draw a dividing line
      this.m_canvas.FillRectangle(1,8, 16,9,::ColorToARGB(clr,alpha));
    // --- Draw a line of arrows
      this.m_canvas.FillRectangle(8,1, 9,16,::ColorToARGB(clr,alpha));
    // --- Draw the upper triangle
      this.m_canvas.Line(7,2, 10,2,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(6,3, 11,3,::ColorToARGB(clr,alpha));
    // --- Draw the lower triangle
      this.m_canvas.Line(6,14, 11,14,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(7,15, 10,15,::ColorToARGB(clr,alpha));

      if(update)
         this.m_canvas.Update(false);
      //*/
      return true;
   }
  //+------------------------------------------------------------------+
  //| CImagePainter::Draws a diagonal top-left --- bottom-right        |
  //| 13x13 double arrow (NorthWest-SouthEast)                         |
  //+------------------------------------------------------------------+
  bool CImagePainter::ArrowNWSE(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
         return false;

    // --- Shape coordinates
      int arrx[19]={0, 4, 5, 4, 4, 9, 10, 11, 12, 12,  8,  7,  8, 8, 3, 2, 1, 0, 0};
      int arry[19]={0, 0, 1, 2, 3, 8,  8,  7,  8, 12, 12, 11, 10, 9, 4, 4, 5, 4, 0};
      
    // --- Draw a white background
      this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

    // --- Draw a line of arrows
      this.m_canvas.Line(3,3, 9,9,::ColorToARGB(clr,alpha));
    // --- Draw the upper-left triangle
      this.m_canvas.Line(1,1, 4,1,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(1,2, 3,2,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(1,3, 3,3,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(1,4, 1,4,::ColorToARGB(clr,alpha));
     // --- Draw the lower-right triangle
      this.m_canvas.Line(11,8, 11, 8,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(9, 9, 11, 9,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(9,10, 11,10,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(8,11, 11,11,::ColorToARGB(clr,alpha));

      if(update)
         this.m_canvas.Update(false);
      return true;
   }
  //+------------------------------------------------------------------+
  // | CImagePainter::Draws a diagonal bottom-left --- up-right        |
  // | 13x13 double arrow (NorthEast-SouthWest)                        |
  //+------------------------------------------------------------------+
  bool CImagePainter::ArrowNESW(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
         return false;

    // --- Shape coordinates
      int arrx[19]={ 0, 0, 1, 2, 3, 8, 8, 7, 8, 12, 12, 11, 10, 9, 4,  4,  5,  4,  0};
      int arry[19]={12, 8, 7, 8, 8, 3, 2, 1, 0,  0,  4,  5,  4, 4, 9, 10, 11, 12, 12};
      
    // --- Draw a white background
      this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

    // --- Draw a line of arrows
      this.m_canvas.Line(3,9, 9,3,::ColorToARGB(clr,alpha));
    // --- Draw the lower-left triangle
      this.m_canvas.Line(1, 8, 1,8, ::ColorToARGB(clr,alpha));
      this.m_canvas.Line(1, 9, 3,9, ::ColorToARGB(clr,alpha));
      this.m_canvas.Line(1,10, 3,10,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(1,11, 4,11,::ColorToARGB(clr,alpha));
    // --- Draw the upper-right triangle
      this.m_canvas.Line(8, 1, 11,1,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(9, 2, 11,2,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(9, 3, 11,3,::ColorToARGB(clr,alpha));
      this.m_canvas.Line(11,4, 11,4,::ColorToARGB(clr,alpha));

      if(update)
         this.m_canvas.Update(false);
      return true;
   }
  //+------------------------------------------------------------------+
  //| CImagePainter::Draws a checked CheckBox                          |
  //+------------------------------------------------------------------+
  bool CImagePainter::CheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
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
  // | CImagePainter::Draws an unchecked CheckBox                      |
  //+------------------------------------------------------------------+
  bool CImagePainter::UncheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
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
  // | CImagePainter::Draws the marked RadioButton                     |
  //+------------------------------------------------------------------+
  bool CImagePainter::CheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
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
  // | CImagePainter::Draws an unchecked RadioButton                   |
  //+------------------------------------------------------------------+
  bool CImagePainter::UncheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
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
  // | Draws a frame for a group of elements                           |
  //+------------------------------------------------------------------+
  bool CImagePainter::FrameGroupElements(const int x,const int y,const int w,const int h,const string text,
                                       const color clr_text,const color clr_dark,const color clr_light,
                                       const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
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
  //| Draws a filled triangle in the upper-left corner                 |
  //+------------------------------------------------------------------+
  bool CImagePainter::TriangleLT(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
         return false;

    // --- Shape coordinates
      int x1=x;
      int y1=y+h;
      int x2=x1;
      int y2=y;
      int x3=x2+w;
      int y3=y2;
      
    // --- Draw a triangle
      this.m_canvas.FillTriangle(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,alpha));

      if(update)
         this.m_canvas.Update(false);
      return true;
   }
  //+------------------------------------------------------------------+
  //| Draws a filled triangle in the lower-left corner                 |
  //+------------------------------------------------------------------+
  bool CImagePainter::TriangleLB(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
         return false;

    // --- Shape coordinates
      int x1=x;
      int y1=y;
      int x2=x1+w;
      int y2=y1+h;
      int x3=x1;
      int y3=y2;
      
    // --- Draw a triangle
      this.m_canvas.FillTriangle(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,alpha));

      if(update)
         this.m_canvas.Update(false);
      return true;
   }
  //+------------------------------------------------------------------+
  //| Draws a filled triangle in the upper right corner                |
  //+------------------------------------------------------------------+
  bool CImagePainter::TriangleRT(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
         return false;

    // --- Shape coordinates
      int x1=x;
      int y1=y;
      int x2=x1+w;
      int y2=y;
      int x3=x2;
      int y3=y2+h;
      
    // --- Draw a triangle
      this.m_canvas.FillTriangle(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,alpha));

      if(update)
         this.m_canvas.Update(false);
      return true;
   }
  //+------------------------------------------------------------------+
  //| Draws a filled triangle in the lower-right corner                |
  //+------------------------------------------------------------------+
  bool CImagePainter::TriangleRB(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
   {
    // --- If the image area is not valid, return false
      if(!this.CheckBound(__FUNCTION__))
         return false;

    // --- Shape coordinates
      int x1=x+w;
      int y1=y;
      int x2=x1;
      int y2=y+h;
      int x3=x;
      int y3=y2;
      
    // --- Draw a triangle
      this.m_canvas.FillTriangle(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,alpha));

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
 #endif // CIMAGEPAINTER_IMPLEMENTATION
#endif // __IMAGEPAINTER_MQH__




