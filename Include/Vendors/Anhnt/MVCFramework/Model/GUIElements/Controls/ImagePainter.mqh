//+------------------------------------------------------------------+
//|                                                 ImagePainter.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __IMAGEPAINTER_MQH__
#define __IMAGEPAINTER_MQH__
//+------------------------------------------------------------------+
//| Image drawing class                                              |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Canvas\Canvas.mqh>

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "..\Base\BaseObj.mqh"
#include "..\Base\BaseDefines.mqh"
#include "..\Base\BaseEnums.mqh"
#include "ControlDefines.mqh"
#include "ControlEnums.mqh"

#include "..\Base\Bound.mqh"
//CImagePainter
// → CBaseObj
// → CObject→BaseDefines.mqh
//          →BaseEnums.mqh

class CImagePainter : public CBaseObj
  {
protected:
   CCanvas *m_canvas;        // Pointer to the canvas where drawing occurs
   CBound   m_bound;         // Coordinates and bounds of the image
   uchar    m_alpha;         // Transparency

//--- Check canvas validity and size correctness
   bool CheckBound(const string source);

public:
//--- (1) Assign canvas for drawing, (2) set transparency, (3) get transparency
   void CanvasAssign(CCanvas *canvas){ this.m_canvas=canvas; }
   void SetAlpha(const uchar value){ this.m_alpha=value; }
   uchar Alpha(void) const { return this.m_alpha; }

//--- (1) Set coordinates, (2) change area size
   void SetXY(const int x,const int y){ this.m_bound.SetXY(x,y); }
   void SetSize(const int w,const int h){ this.m_bound.Resize(w,h); }

//--- Set coordinates and size of area
   void SetBound(const int x,const int y,const int w,const int h)
     {
      this.SetXY(x,y);
      this.SetSize(w,h);
     }

//--- Return drawing bounds and dimensions
   int X(void) const { return this.m_bound.X(); }
   int Y(void) const { return this.m_bound.Y(); }
   int Right(void) const { return this.m_bound.Right(); }
   int Bottom(void) const { return this.m_bound.Bottom(); }
   int Width(void) const { return this.m_bound.Width(); }
   int Height(void) const { return this.m_bound.Height(); }

//--- Clear area
   bool Clear(const int x,const int y,const int w,const int h,const bool update=true);

//--- Draw filled arrows
   bool ArrowUp(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool ArrowDown(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool ArrowLeft(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool ArrowRight(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);

//--- Draw double arrows
   bool ArrowHorz(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true); 
   bool ArrowVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true); 

//--- Draw diagonal double arrows
   bool ArrowNWSE(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool ArrowNESW(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);

//--- Draw shift arrows
   bool ArrowShiftHorz(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool ArrowShiftVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);

//--- Draw checkbox states
   bool CheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool UncheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);

//--- Draw radio button states
   bool CheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);
   bool UncheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true);

//--- Draw frame around group elements
   bool FrameGroupElements(const int x,const int y,const int w,const int h,const string text,
                           const color clr_text,const color clr_dark,const color clr_light,
                           const uchar alpha,const bool update=true);

//--- Virtual methods
   virtual int  Compare(const CObject *node,const int mode=0) const;
   virtual bool Save(const int file_handle);
   virtual bool Load(const int file_handle);
   virtual int  Type(void) const { return(ELEMENT_TYPE_IMAGE_PAINTER); }

//--- Constructors
   CImagePainter(void):m_canvas(NULL){ this.SetBound(1,1,DEF_BUTTON_H-2,DEF_BUTTON_H-2); this.SetName("Image Painter"); }
   CImagePainter(CCanvas *canvas):m_canvas(canvas){ this.SetBound(1,1,DEF_BUTTON_H-2,DEF_BUTTON_H-2); this.SetName("Image Painter"); }

   ~CImagePainter(void){}
  };
//+------------------------------------------------------------------+
//| CImagePainter::Draws a vertical 7x17 double arrow                |
//+------------------------------------------------------------------+
bool CImagePainter::ArrowVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
//--- If image bounds are invalid, return false
   if(!this.CheckBound(__FUNCTION__))
      return false;

//--- Shape coordinates
   int arrx[15]={3, 6, 6, 4,  4,  6,  6,  3,  0,  0,  2, 2, 0, 0, 3};
   int arry[15]={0, 3, 4, 4, 12, 12, 13, 16, 13, 12, 12, 4, 4, 3, 0};
   
//--- Draw white background (shadow/outline)
   this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

//--- Draw arrow line
   this.m_canvas.Line(3,1, 3,15,::ColorToARGB(clr,alpha));
//--- Draw top triangle
   this.m_canvas.Line(3,1, 3,1,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(2,2, 4,2,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(1,3, 5,3,::ColorToARGB(clr,alpha));
//--- Draw bottom triangle
   this.m_canvas.Line(1,13, 5,13,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(2,14, 4,14,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(3,15, 3,15,::ColorToARGB(clr,alpha));

   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
//| CImagePainter::Draws an 18x18 horizontal shift arrow             |
//+------------------------------------------------------------------+
bool CImagePainter::ArrowShiftHorz(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
//--- If image bounds are invalid, return false
   if(!this.CheckBound(__FUNCTION__))
      return false;

//--- Shape coordinates
   int arrx[25]={0, 3, 4, 4, 7, 7, 10, 10, 13, 13, 14, 17, 17, 14, 13, 13, 10, 10,  7,  7,  4,  4,  3, 0, 0};
   int arry[25]={8, 5, 5, 7, 7, 0,  0,  7,  7,  5,  5,  8,  9, 12, 12, 10, 10, 17, 17, 10, 10, 12, 12, 9, 8};
   
//--- Draw white background (shadow/outline)
   this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

//--- Draw arrows line
   this.m_canvas.FillRectangle(1,8, 16,9,::ColorToARGB(clr,alpha));
//--- Draw separation line
   this.m_canvas.FillRectangle(8,1, 9,16,::ColorToARGB(clr,alpha));
//--- Draw left triangle
   this.m_canvas.Line(2,7, 2,10,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(3,6, 3,11,::ColorToARGB(clr,alpha));
//--- Draw right triangle
   this.m_canvas.Line(14,6, 14,11,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(15,7, 15,10,::ColorToARGB(clr,alpha));

   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
//| CImagePainter::Draws an 18x18 vertical shift arrow               |
//+------------------------------------------------------------------+
bool CImagePainter::ArrowShiftVert(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
//--- If image bounds are invalid, return false
   if(!this.CheckBound(__FUNCTION__))
      return false;

//--- Shape coordinates
   int arrx[25]={0, 7, 7, 5, 5, 8, 9, 12, 12, 10, 10, 17, 17, 10, 10, 12, 12,  9,  8,  5,  5,  7,  7,  0, 0};
   int arry[25]={7, 7, 4, 4, 3, 0, 0,  3,  4,  4,  7,  7, 10, 10, 13, 13, 14, 17, 17, 14, 13, 13, 10, 10, 7};
   
//--- Draw white background (shadow/outline)
   this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

//--- Draw separation line
   this.m_canvas.FillRectangle(1,8, 16,9,::ColorToARGB(clr,alpha));
//--- Draw arrows line
   this.m_canvas.FillRectangle(8,1, 9,16,::ColorToARGB(clr,alpha));
//--- Draw top triangle
   this.m_canvas.Line(7,2, 10,2,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(6,3, 11,3,::ColorToARGB(clr,alpha));
//--- Draw bottom triangle
   this.m_canvas.Line(6,14, 11,14,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(7,15, 10,15,::ColorToARGB(clr,alpha));

   if(update)
      this.m_canvas.Update(false);

   return true;
  }
//+------------------------------------------------------------------+
//| CImagePainter::Draws a diagonal top-left to bottom-right         |
//| 13x13 double arrow (NorthWest-SouthEast)                         |
//+------------------------------------------------------------------+
bool CImagePainter::ArrowNWSE(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
//--- If image bounds are invalid, return false
   if(!this.CheckBound(__FUNCTION__))
      return false;

//--- Shape coordinates
   int arrx[19]={0, 4, 5, 4, 4, 9, 10, 11, 12, 12,  8,  7,  8, 8, 3, 2, 1, 0, 0};
   int arry[19]={0, 0, 1, 2, 3, 8,  8,  7,  8, 12, 12, 11, 10, 9, 4, 4, 5, 4, 0};
   
//--- Draw white background (shadow/outline)
   this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

//--- Draw arrow line
   this.m_canvas.Line(3,3, 9,9,::ColorToARGB(clr,alpha));
//--- Draw top-left triangle
   this.m_canvas.Line(1,1, 4,1,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(1,2, 3,2,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(1,3, 3,3,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(1,4, 1,4,::ColorToARGB(clr,alpha));
//--- Draw bottom-right triangle
   this.m_canvas.Line(11,8, 11, 8,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(9, 9, 11, 9,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(9,10, 11,10,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(8,11, 11,11,::ColorToARGB(clr,alpha));

   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
//| CImagePainter::Draws a diagonal bottom-left to top-right         |
//| 13x13 double arrow (NorthEast-SouthWest)                         |
//+------------------------------------------------------------------+
bool CImagePainter::ArrowNESW(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
//--- If image bounds are invalid, return false
   if(!this.CheckBound(__FUNCTION__))
      return false;

//--- Shape coordinates
   int arrx[19]={ 0, 0, 1, 2, 3, 8, 8, 7, 8, 12, 12, 11, 10, 9, 4,  4,  5,  4,  0};
   int arry[19]={12, 8, 7, 8, 8, 3, 2, 1, 0,  0,  4,  5,  4, 4, 9, 10, 11, 12, 12};
   
//--- Draw white background (shadow/outline)
   this.m_canvas.Polyline(arrx,arry,::ColorToARGB(clrWhite,alpha));

//--- Draw arrow line
   this.m_canvas.Line(3,9, 9,3,::ColorToARGB(clr,alpha));
//--- Draw bottom-left triangle
   this.m_canvas.Line(1, 8, 1,8, ::ColorToARGB(clr,alpha));
   this.m_canvas.Line(1, 9, 3,9, ::ColorToARGB(clr,alpha));
   this.m_canvas.Line(1,10, 3,10,::ColorToARGB(clr,alpha));
   this.m_canvas.Line(1,11, 4,11,::ColorToARGB(clr,alpha));
//--- Draw top-right triangle
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
//--- If image bounds are invalid, return false
   if(!this.CheckBound(__FUNCTION__))
      return false;

//--- Rectangle coordinates
   int x1=x+1;                // Top-left corner, X
   int y1=y+1;                // Top-left corner, Y
   int x2=x+w-2;              // Bottom-right corner, X
   int y2=y+h-2;              // Bottom-right corner, Y

//--- Draw rectangle frame
   this.m_canvas.Rectangle(x1, y1, x2, y2, ::ColorToARGB(clr, alpha));
   
//--- Checkmark coordinates
   int arrx[3], arry[3];
   
   arrx[0]=x1+(x2-x1)/4;      // X. Left point
   arrx[1]=x1+w/3;            // X. Center point
   arrx[2]=x2-(x2-x1)/4;      // X. Right point
   
   arry[0]=y1+1+(y2-y1)/2;    // Y. Left point
   arry[1]=y2-(y2-y1)/3;      // Y. Center point
   arry[2]=y1+(y2-y1)/3;      // Y. Right point
   
//--- Draw checkmark using double thickness line
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
//| CImagePainter::Draws an unchecked CheckBox                        |
//+------------------------------------------------------------------+
bool CImagePainter::UncheckedBox(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
//--- If image bounds are invalid, return false
   if(!this.CheckBound(__FUNCTION__))
      return false;

//--- Rectangle coordinates
   int x1=x+1;                // Top-left corner, X
   int y1=y+1;                // Top-left corner, Y
   int x2=x+w-2;              // Bottom-right corner, X
   int y2=y+h-2;              // Bottom-right corner, Y

//--- Draw rectangle frame
   this.m_canvas.Rectangle(x1, y1, x2, y2, ::ColorToARGB(clr, alpha));
   
   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
//| CImagePainter::Draws a checked RadioButton                       |
//+------------------------------------------------------------------+
bool CImagePainter::CheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
//--- If image bounds are invalid, return false
   if(!this.CheckBound(__FUNCTION__))
      return false;

//--- Circle area coordinates
   int x1=x+1;                // Top-left corner of circle area, X
   int y1=y+1;                // Top-left corner of circle area, Y
   int x2=x+w-2;              // Bottom-right corner of circle area, X
   int y2=y+h-2;              // Bottom-right corner of circle area, Y
   
//--- Diameter and radius calculation
   int d=::fmin(x2-x1,y2-y1); // Diameter by the shorter side
   int r=d/2;                 // Radius
   if(r<2)
      r=2;
   int cx=x1+r;               // Center X coordinate
   int cy=y1+r;               // Center Y coordinate

//--- Draw outer circle using anti-aliasing (Wu algorithm)
   this.m_canvas.CircleWu(cx, cy, r, ::ColorToARGB(clr, alpha));
   
//--- Marker radius
   r/=2;
   if(r<1)
      r=1;
//--- Draw internal marker (filled circle)
   this.m_canvas.FillCircle(cx, cy, r, ::ColorToARGB(clr, alpha));
   
   if(update)
      this.m_canvas.Update(false);
   return true;
  }
  //+------------------------------------------------------------------+
//| CImagePainter::Draws an unchecked RadioButton                    |
//+------------------------------------------------------------------+
bool CImagePainter::UncheckedRadioButton(const int x,const int y,const int w,const int h,const color clr,const uchar alpha,const bool update=true)
  {
//--- If image bounds are invalid, return false
   if(!this.CheckBound(__FUNCTION__))
      return false;

//--- Circle area coordinates and radius
   int x1=x+1;                // Top-left corner of the circle area, X
   int y1=y+1;                // Top-left corner of the circle area, Y
   int x2=x+w-2;              // Bottom-right corner of the circle area, X
   int y2=y+h-2;              // Bottom-right corner of the circle area, Y
   
//--- Diameter and radius calculation
   int d=::fmin(x2-x1,y2-y1); // Diameter based on the shorter side (width or height)
   int r=d/2;                 // Radius
   int cx=x1+r;               // Center X coordinate
   int cy=y1+r;               // Center Y coordinate

//--- Draw the circle (anti-aliased)
   this.m_canvas.CircleWu(cx, cy, r, ::ColorToARGB(clr, alpha));
   
   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
//| Draws a group box frame for elements                             |
//+------------------------------------------------------------------+
bool CImagePainter::FrameGroupElements(const int x,const int y,const int w,const int h,const string text,
                                       const color clr_text,const color clr_dark,const color clr_light,
                                       const uchar alpha,const bool update=true)
  {
//--- If image bounds are invalid, return false
   if(!this.CheckBound(__FUNCTION__))
      return false;

//--- Adjust Y coordinate
   int tw=0, th=0;
   if(text!="" && text!=NULL)
      this.m_canvas.TextSize(text,tw,th);
   int shift_v=int(th!=0 ? ::ceil(th/2) : 0);

//--- Frame coordinates and dimensions
   int x1=x;                  // Top-left corner of the frame area, X
   int y1=y+shift_v;          // Top-left corner of the frame area, Y
   int x2=x+w-1;              // Bottom-right corner of the frame area, X
   int y2=y+h-1;              // Bottom-right corner of the frame area, Y
   
//--- Draw top-left part of the frame
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
//--- Draw bottom-right part of the frame
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
   
//--- Clear area for the text label and draw it
   if(tw>0)
      this.m_canvas.FillRectangle(x+5,y,x+7+tw,y+th,clrNULL);
   this.m_canvas.TextOut(x+6,y-1,text,::ColorToARGB(clr_text, alpha));
   
   if(update)
      this.m_canvas.Update(false);
   return true;
  }
//+------------------------------------------------------------------+
//| CImagePainter::Save to file                                      |
//+------------------------------------------------------------------+
bool CImagePainter::Save(const int file_handle)
  {
//--- Save parent object data
   if(!CBaseObj::Save(file_handle))
      return false;
  
//--- Save transparency
   if(::FileWriteInteger(file_handle,this.m_alpha,INT_VALUE)!=INT_VALUE)
      return false;
//--- Save boundary data
   if(!this.m_bound.Save(file_handle))
      return false;
      
//--- Successful
   return true;
  }
//+------------------------------------------------------------------+
//| CImagePainter::Load from file                                    |
//+------------------------------------------------------------------+
bool CImagePainter::Load(const int file_handle)
{
   //--- Load parent object data
      if(!CBaseObj::Load(file_handle))
         return false;
         
   //--- Load transparency
      this.m_alpha=(uchar)::FileReadInteger(file_handle,INT_VALUE);
   //--- Load boundary data
      if(!this.m_bound.Load(file_handle))
         return false;
      
   //--- Successful
      return true;
}

#endif