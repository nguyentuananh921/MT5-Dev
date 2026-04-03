//+------------------------------------------------------------------+
//|                                                         Base.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include <Canvas\Canvas.mqh>              // Class SB CCanvas
#include <Arrays\List.mqh>                // Class SB CList

//+------------------------------------------------------------------+
// | Macro substitutions |
//+------------------------------------------------------------------+
#define  clrNULL              0x00FFFFFF  // Transparent color for CCanvas
#define  MARKER_START_DATA    -1          // Marker for the start of data in a file

//+------------------------------------------------------------------+
// | Transfers |
//+------------------------------------------------------------------+
enum ENUM_ELEMENT_TYPE                    // Enumeration of types of graphic elements
  {
   ELEMENT_TYPE_BASE = 0x10000,           // Basic object of graphic elements
   ELEMENT_TYPE_COLOR,                    // Color object
   ELEMENT_TYPE_COLORS_ELEMENT,           // Graphics Element Colors Object
   ELEMENT_TYPE_RECTANGLE_AREA,           // Rectangular element area
   ELEMENT_TYPE_CANVAS_BASE,              // Basic graphic element canvas object
  };

enum ENUM_COLOR_STATE                     // Enumerating element state colors
  {
   COLOR_STATE_DEFAULT,                   // Normal color
   COLOR_STATE_FOCUSED,                   // Color when hovering over an element
   COLOR_STATE_PRESSED,                   // Color when clicking on an element
   COLOR_STATE_BLOCKED,                   // Blocked element color
  };
//+------------------------------------------------------------------+ 
// | Functions |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// |  Returns the element type as a string |
//+------------------------------------------------------------------+
string ElementDescription(const ENUM_ELEMENT_TYPE type)
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
// | Classes |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Basic class of graphic elements |
//+------------------------------------------------------------------+
class CBaseObj : public CObject
{
   protected:
      int               m_id;                                     // Identifier
      ushort            m_name[];                                 // Name
      
   public:
   // --- Sets (1) name, (2) identifier
      void              SetName(const string name)                { ::StringToShortArray(name,this.m_name);    }
      void              SetID(const int id)                       { this.m_id=id;                              }
   // --- Returns (1) name, (2) identifier
      string            Name(void)                          const { return ::ShortArrayToString(this.m_name);  }
      int               ID(void)                            const { return this.m_id;                          }

   // --- Virtual methods (1) comparison, (2) object type
      virtual int       Compare(const CObject *node,const int mode=0) const;
      virtual int       Type(void)                          const { return(ELEMENT_TYPE_BASE); }
      
   // --- Constructors/destructor
                        CBaseObj (void) : m_id(-1) {}
                     ~CBaseObj (void) {}
};
//+------------------------------------------------------------------+
// | CBaseObj::Comparing two objects |
//+------------------------------------------------------------------+
int CBaseObj::Compare(const CObject *node,const int mode=0) const
{
   const CBaseObj *obj=node;
   switch(mode)
     {
      case 0   :  return(this.Name()>obj.Name() ? 1 : this.Name()<obj.Name() ? -1 : 0);
      default  :  return(this.ID()>obj.ID()     ? 1 : this.ID()<obj.ID()     ? -1 : 0);
     }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Color class |
//+------------------------------------------------------------------+
class CColor : public CBaseObj
{
   protected:
      color             m_color;                                  // Color
      
   public:
   // --- Sets the color
      bool              SetColor(const color clr)
                        {
                           if(this.m_color==clr)
                              return false;
                           this.m_color=clr;
                           return true;
                        }
   // --- Returns the color
      color             Get(void)                           const { return this.m_color;              }

   // --- (1) Returns, (2) logs a description of the object
      virtual string    Description(void);
      void              Print(void);
      
   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0) const;
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                          const { return(ELEMENT_TYPE_COLOR);       }
      
   // --- Constructors/destructor
                        CColor(void) : m_color(clrNULL)                          { this.SetName("");  }
                        CColor(const color clr) : m_color(clr)                   { this.SetName("");  }
                        CColor(const color clr,const string name) : m_color(clr) { this.SetName(name);}
                     ~CColor(void) {}
};
//+------------------------------------------------------------------+
// | CColor::Returns the description of an object |
//+------------------------------------------------------------------+
string CColor::Description(void)
{
   string color_name=(this.Get()!=clrNULL ? ::ColorToString(this.Get(),true) : "clrNULL (0x00FFFFFF)");
   return(this.Name()+(this.Name()!="" ? " " : "")+"Color: "+color_name);
}
//+------------------------------------------------------------------+
// | CColor::Log a description of an object |
//+------------------------------------------------------------------+
void CColor::Print(void)
{
   ::Print(this.Description());
}
//+------------------------------------------------------------------+
// | CColor::Save to file |
//+------------------------------------------------------------------+
bool CColor::Save(const int file_handle)
{
   // --- Checking the handle
      if(file_handle==INVALID_HANDLE)
         return false;
   // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
      if(::FileWriteLong(file_handle,-1)!=sizeof(long))
         return false;
   // --- Save the object type
      if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
         return false;

   // --- Preserve color
      if(::FileWriteInteger(file_handle,this.m_color,INT_VALUE)!=INT_VALUE)
         return false;
   // --- Save the ID
      if(::FileWriteInteger(file_handle,this.m_id,INT_VALUE)!=INT_VALUE)
         return false;
   // --- Save the name
      if(::FileWriteArray(file_handle,this.m_name)!=sizeof(this.m_name))
         return false;
      
   // --- Everything is successful
      return true;
}
//+------------------------------------------------------------------+
// | CColor::Loading from file |
//+------------------------------------------------------------------+
bool CColor::Load(const int file_handle)
{
   // --- Checking the handle
      if(file_handle==INVALID_HANDLE)
         return false;
   // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
      if(::FileReadLong(file_handle)!=-1)
         return false;
   // --- Loading the object type
      if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
         return false;

   // --- Loading color
      this.m_color=(color)::FileReadInteger(file_handle,INT_VALUE);
   // --- Loading ID
      this.m_id=::FileReadInteger(file_handle,INT_VALUE);
   // --- Loading the name
      if(::FileReadArray(file_handle,this.m_name)!=sizeof(this.m_name))
         return false;
      
   // --- Everything is successful
      return true;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Graphics element color class |
//+------------------------------------------------------------------+
class CColorElement : public CBaseObj
{
   protected:
      CColor            m_current;                                // Current color. Can be one of the following
      CColor            m_default;                                // Normal color
      CColor            m_focused;                                // Hover color
      CColor            m_pressed;                                // Touch color
      CColor            m_blocked;                                // Blocked element color
      
   // --- Converts RGB to color
      color             RGBToColor(const double r,const double g,const double b) const;
   // --- Writes RGB component values ​​to variables
      void              ColorToRGB(const color clr,double &r,double &g,double &b);
   // --- Returns the color component (1) Red, (2) Green, (3) Blue
      double            GetR(const color clr)                     { return clr&0xFF;                           }
      double            GetG(const color clr)                     { return(clr>>8)&0xFF;                       }
      double            GetB(const color clr)                     { return(clr>>16)&0xFF;                      }
   
   public:
   // --- Returns the new color
      color             NewColor(color base_color, int shift_red, int shift_green, int shift_blue);

   // --- Initializing the colors of various states
      bool              InitDefault(const color clr)              { return this.m_default.SetColor(clr);       }
      bool              InitFocused(const color clr)              { return this.m_focused.SetColor(clr);       }
      bool              InitPressed(const color clr)              { return this.m_pressed.SetColor(clr);       }
      bool              InitBlocked(const color clr)              { return this.m_blocked.SetColor(clr);       }
      
   // --- Set colors for all states
      void              InitColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked);
      void              InitColors(const color clr);
      
   // ---Return colors of different states
      color             GetCurrent(void)                    const { return this.m_current.Get();               }
      color             GetDefault(void)                    const { return this.m_default.Get();               }
      color             GetFocused(void)                    const { return this.m_focused.Get();               }
      color             GetPressed(void)                    const { return this.m_pressed.Get();               }
      color             GetBlocked(void)                    const { return this.m_blocked.Get();               }
      
   // --- Sets one of the list of colors as the current one
      bool              SetCurrentAs(const ENUM_COLOR_STATE color_state);

   // --- (1) Returns, (2) logs a description of the object
      virtual string    Description(void);
      void              Print(void);
      
   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0) const;
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                          const { return(ELEMENT_TYPE_COLORS_ELEMENT);       }
      
   // --- Constructors/destructor
                        CColorElement(void);
                        CColorElement(const color clr);
                        CColorElement(const color clr_default,const color clr_focused,const color clr_pressed,const color clr_blocked);
                     ~CColorElement(void) {}
};
//+------------------------------------------------------------------+
// | CColorControl::Constructor with setting transparent object colors|
//+------------------------------------------------------------------+
CColorElement::CColorElement(void)
{
   this.InitColors(clrNULL,clrNULL,clrNULL,clrNULL);
   this.m_default.SetName("Default"); this.m_default.SetID(1);
   this.m_focused.SetName("Focused"); this.m_focused.SetID(2);
   this.m_pressed.SetName("Pressed"); this.m_pressed.SetID(3);
   this.m_blocked.SetName("Blocked"); this.m_blocked.SetID(4);
   this.SetCurrentAs(COLOR_STATE_DEFAULT);
   this.m_current.SetName("Current");
   this.m_current.SetID(0);
}
//+------------------------------------------------------------------+
// | CColorControl::Constructor specifying object colors |
//+------------------------------------------------------------------+
CColorElement::CColorElement(const color clr_default,const color clr_focused,const color clr_pressed,const color clr_blocked)
{
   this.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
   this.m_default.SetName("Default"); this.m_default.SetID(1);
   this.m_focused.SetName("Focused"); this.m_focused.SetID(2);
   this.m_pressed.SetName("Pressed"); this.m_pressed.SetID(3);
   this.m_blocked.SetName("Blocked"); this.m_blocked.SetID(4);
   this.SetCurrentAs(COLOR_STATE_DEFAULT);
   this.m_current.SetName("Current");
   this.m_current.SetID(0);
}
//+------------------------------------------------------------------+
// | CColorControl::Constructor specifying the color of an object |
//+------------------------------------------------------------------+
CColorElement::CColorElement(const color clr)
{
   this.InitColors(clr);
   this.m_default.SetName("Default"); this.m_default.SetID(1);
   this.m_focused.SetName("Focused"); this.m_focused.SetID(2);
   this.m_pressed.SetName("Pressed"); this.m_pressed.SetID(3);
   this.m_blocked.SetName("Blocked"); this.m_blocked.SetID(4);
   this.SetCurrentAs(COLOR_STATE_DEFAULT);
   this.m_current.SetName("Current");
   this.m_current.SetID(0);
}
//+------------------------------------------------------------------+
// | CColorControl::Sets colors for all states |
//+------------------------------------------------------------------+
void CColorElement::InitColors(const color clr_default,const color clr_focused,const color clr_pressed,const color clr_blocked)
{
   this.InitDefault(clr_default);
   this.InitFocused(clr_focused);
   this.InitPressed(clr_pressed);
   this.InitBlocked(clr_blocked);   
}
//+------------------------------------------------------------------+
// | CColorControl::Sets colors for all states based on the current one|
//+------------------------------------------------------------------+
void CColorElement::InitColors(const color clr)
{
   this.InitDefault(clr);
   this.InitFocused(this.NewColor(clr,-3,-3,-3));
   this.InitPressed(this.NewColor(clr,-6,-6,-6));
   this.InitBlocked(clrSilver);   
}
//+-------------------------------------------------------------------+
// |CColorControl::Sets one color from a list of colors as the current|
//+-------------------------------------------------------------------+
bool CColorElement::SetCurrentAs(const ENUM_COLOR_STATE color_state)
{
   switch(color_state)
     {
      case COLOR_STATE_DEFAULT   :  return this.m_current.SetColor(this.m_default.Get());
      case COLOR_STATE_FOCUSED   :  return this.m_current.SetColor(this.m_focused.Get());
      case COLOR_STATE_PRESSED   :  return this.m_current.SetColor(this.m_pressed.Get());
      case COLOR_STATE_BLOCKED   :  return this.m_current.SetColor(this.m_blocked.Get());
      default                    :  return false;
     }
}
//+------------------------------------------------------------------+
// | CColorControl::Converts RGB to color |
//+------------------------------------------------------------------+
color CColorElement::RGBToColor(const double r,const double g,const double b) const
{
   int int_r=(int)::round(r);
   int int_g=(int)::round(g);
   int int_b=(int)::round(b);
   int clr=0;
   clr=int_b;
   clr<<=8;
   clr|=int_g;
   clr<<=8;
   clr|=int_r;

   return (color)clr;
}
//+------------------------------------------------------------------+
// | CColorControl::Getting RGB component values ​​|
//+------------------------------------------------------------------+
void CColorElement::ColorToRGB(const color clr,double &r,double &g,double &b)
  {
   r=this.GetR(clr);
   g=this.GetG(clr);
   b=this.GetB(clr);
  }
//+------------------------------------------------------------------+
// | CColorControl::Returns a color with a new color component |
//+------------------------------------------------------------------+
color CColorElement::NewColor(color base_color, int shift_red, int shift_green, int shift_blue)
  {
   double clrR=0, clrG=0, clrB=0;
   this.ColorToRGB(base_color,clrR,clrG,clrB);
   double clrRx=(clrR+shift_red  < 0 ? 0 : clrR+shift_red  > 255 ? 255 : clrR+shift_red);
   double clrGx=(clrG+shift_green< 0 ? 0 : clrG+shift_green> 255 ? 255 : clrG+shift_green);
   double clrBx=(clrB+shift_blue < 0 ? 0 : clrB+shift_blue > 255 ? 255 : clrB+shift_blue);
   return this.RGBToColor(clrRx,clrGx,clrBx);
  }
//+------------------------------------------------------------------+
// | CColorElement::Returns the description of the object |
//+------------------------------------------------------------------+
string CColorElement::Description(void)
  {
   string res=::StringFormat("%s Colors. %s",this.Name(),this.m_current.Description());
   res+="\n  1: "+this.m_default.Description();
   res+="\n  2: "+this.m_focused.Description();
   res+="\n  3: "+this.m_pressed.Description();
   res+="\n  4: "+this.m_blocked.Description();
   return res;
  }
//+------------------------------------------------------------------+
// | CColorElement::Log a description of an object |
//+------------------------------------------------------------------+
void CColorElement::Print(void)
  {
   ::Print(this.Description());
  }
//+------------------------------------------------------------------+
// | CColorElement::Saving to file |
//+------------------------------------------------------------------+
bool CColorElement::Save(const int file_handle)
  {
// --- Checking the handle
   if(file_handle==INVALID_HANDLE)
      return false;
// --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
   if(::FileWriteLong(file_handle,-1)!=sizeof(long))
      return false;
// --- Save the object type
   if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
      return false;
   
// --- Save the ID
   if(::FileWriteInteger(file_handle,this.m_id,INT_VALUE)!=INT_VALUE)
      return false;
// --- Save the name of the element colors
   if(::FileWriteArray(file_handle,this.m_name)!=sizeof(this.m_name))
      return false;
// --- Save the current color
   if(!this.m_current.Save(file_handle))
      return false;
// --- Maintain the color of the normal state
   if(!this.m_default.Save(file_handle))
      return false;
// --- Maintain color on hover
   if(!this.m_focused.Save(file_handle))
      return false;
// --- Save color when clicked
   if(!this.m_pressed.Save(file_handle))
      return false;
// --- Preserve the color of the blocked element
   if(!this.m_blocked.Save(file_handle))
      return false;
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | CColorElement::Loading from file |
//+------------------------------------------------------------------+
bool CColorElement::Load(const int file_handle)
{
   // --- Checking the handle
      if(file_handle==INVALID_HANDLE)
         return false;
   // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
      if(::FileReadLong(file_handle)!=-1)
         return false;
   // --- Loading the object type
      if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
         return false;
      
   // --- Loading ID
      this.m_id=::FileReadInteger(file_handle,INT_VALUE);
   // --- Load the name of the element's colors
      if(::FileReadArray(file_handle,this.m_name)!=sizeof(this.m_name))
         return false;
   // --- Load the current color
      if(!this.m_current.Load(file_handle))
         return false;
   // --- Loading the color of the normal state
      if(!this.m_default.Load(file_handle))
         return false;
   // --- Load color on hover
      if(!this.m_focused.Load(file_handle))
         return false;
   // --- Load color when clicked
      if(!this.m_pressed.Load(file_handle))
         return false;
   // --- Load the color of the blocked element
      if(!this.m_blocked.Load(file_handle))
         return false;
      
   // --- Everything is successful
      return true;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Rectangular Area Class |
//+------------------------------------------------------------------+
class CBound : public CBaseObj
{
   protected:
      CRect             m_bound;                                  // Rectangular area structure

   public:
   // --- Changes the (1) width, (2) height, (3) size of the bounding box
      void              ResizeW(const int size)                   { this.m_bound.Width(size);                        }
      void              ResizeH(const int size)                   { this.m_bound.Height(size);                       }
      void              Resize(const int w,const int h)           { this.m_bound.Width(w); this.m_bound.Height(h);   }
      
   // --- Sets the (1) X, (2) Y, (3) both coordinates of the bounding box
      void              SetX(const int x)                         { this.m_bound.left=x;                             }
      void              SetY(const int y)                         { this.m_bound.top=y;                              }
      void              SetXY(const int x,const int y)            { this.m_bound.LeftTop(x,y);                       }
      
   // --- (1) Sets, (2) offsets the bounding box by the specified coordinates/offset size
      void              Move(const int x,const int y)             { this.m_bound.Move(x,y);                          }
      void              Shift(const int dx,const int dy)          { this.m_bound.Shift(dx,dy);                       }
      
   // --- Returns the coordinates, dimensions and boundaries of an object
      int               X(void)                             const { return this.m_bound.left;                        }
      int               Y(void)                             const { return this.m_bound.top;                         }
      int               Width(void)                         const { return this.m_bound.Width();                     }
      int               Height(void)                        const { return this.m_bound.Height();                    }
      int               Right(void)                         const { return this.m_bound.right-1;                     }
      int               Bottom(void)                        const { return this.m_bound.bottom-1;                    }
      
   // --- (1) Returns, (2) logs a description of the object
      virtual string    Description(void);
      void              Print(void);
      
   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0) const;
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                          const { return(ELEMENT_TYPE_RECTANGLE_AREA);             }
      
   // --- Constructors/destructor
                        CBound(void) { ::ZeroMemory(this.m_bound); }
                        CBound(const int x,const int y,const int w,const int h) { this.SetXY(x,y); this.Resize(w,h); }
                     ~CBound(void) { ::ZeroMemory(this.m_bound); }
};
//+------------------------------------------------------------------+
// | CBound::Returns the description of an object |
//+------------------------------------------------------------------+
string CBound::Description(void)
  {
   string nm=this.Name();
   string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   return ::StringFormat("%s%s: x %d, y %d, w %d, h %d",
                         ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,
                         this.X(),this.Y(),this.Width(),this.Height());
  }
//+------------------------------------------------------------------+
// | CBound::Log a description of an object |
//+------------------------------------------------------------------+
void CBound::Print(void)
  {
   ::Print(this.Description());
  }
//+------------------------------------------------------------------+
// | CBound::Saving to file |
//+------------------------------------------------------------------+
bool CBound::Save(const int file_handle)
{
   // --- Checking the handle
      if(file_handle==INVALID_HANDLE)
         return false;
   // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
      if(::FileWriteLong(file_handle,-1)!=sizeof(long))
         return false;
   // --- Save the object type
      if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
         return false;
      
   // --- Save the ID
      if(::FileWriteInteger(file_handle,this.m_id,INT_VALUE)!=INT_VALUE)
         return false;
   // --- Save the name
      if(::FileWriteArray(file_handle,this.m_name)!=sizeof(this.m_name))
         return false;
      // --- Preserve the structure of the area
      if(::FileWriteStruct(file_handle,this.m_bound)!=sizeof(this.m_bound))
         return(false);
      
   // --- Everything is successful
      return true;
}
//+------------------------------------------------------------------+
// | CBound::Loading from file |
//+------------------------------------------------------------------+
bool CBound::Load(const int file_handle)
  {
// --- Checking the handle
   if(file_handle==INVALID_HANDLE)
      return false;
// --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
   if(::FileReadLong(file_handle)!=-1)
      return false;
// --- Loading the object type
   if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
      return false;
   
// --- Loading ID
   this.m_id=::FileReadInteger(file_handle,INT_VALUE);
// --- Loading the name
   if(::FileReadArray(file_handle,this.m_name)!=sizeof(this.m_name))
      return false;
   // --- Loading the area structure
   if(::FileReadStruct(file_handle,this.m_bound)!=sizeof(this.m_bound))
      return(false);
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Base graphic element canvas class |
//+------------------------------------------------------------------+
class CCanvasBase : public CBaseObj
{
   protected:
      CCanvas           m_background;                             // Canvas for drawing background
      CCanvas           m_foreground;                             // Canvas for drawing the foreground
      CBound            m_bound;                                  // Object boundaries
      CCanvasBase      *m_container;                              // Parent container object
      CColorElement     m_color_background;                       // Background color control object
      CColorElement     m_color_foreground;                       // Foreground color control object
      CColorElement     m_color_border;                           // Border color control object
      long              m_chart_id;                               // Graph ID
      int               m_wnd;                                    // Chart subwindow number
      int               m_wnd_y;                                  // Offset of the Y coordinate of the cursor in the subwindow
      int               m_obj_x;                                  // X coordinate of the graphic object
      int               m_obj_y;                                  // Y coordinate of the graphic object
      uchar             m_alpha;                                  // Transparency
      uint              m_border_width;                           // Frame width
      string            m_program_name;                           // Program name
      bool              m_hidden;                                 // Hidden Object Flag
      bool              m_blocked;                                // Blocked element flag
      bool              m_focused;                                // Flag of the element in focus
      
   private:
   // --- Return the offset of the initial coordinates of drawing on the canvas relative to the canvas and object coordinates
      int               CanvasOffsetX(void)                 const { return(this.ObjectX()-this.X());                                                  }
      int               CanvasOffsetY(void)                 const { return(this.ObjectY()-this.Y());                                                  }
   // --- Returns the adjusted coordinate of a point on the canvas, taking into account the offset of the canvas relative to the object
      int               AdjX(const int x)                   const { return(x-this.CanvasOffsetX());                                                   }
      int               AdjY(const int y)                   const { return(y-this.CanvasOffsetY());                                                   }
      
   protected:
   // --- Returns the adjusted chart identifier
      long              CorrectChartID(const long chart_id) const { return(chart_id!=0 ? chart_id : ::ChartID());                                     }

   // --- Getting the bounds of the parent container object
      int               ContainerLimitLeft(void)            const { return(this.m_container==NULL ? this.X()      :  this.m_container.LimitLeft());   }
      int               ContainerLimitRight(void)           const { return(this.m_container==NULL ? this.Right()  :  this.m_container.LimitRight());  }
      int               ContainerLimitTop(void)             const { return(this.m_container==NULL ? this.Y()      :  this.m_container.LimitTop());    }
      int               ContainerLimitBottom(void)          const { return(this.m_container==NULL ? this.Bottom() :  this.m_container.LimitBottom()); }
      
   // --- Return coordinates, boundaries and dimensions of a graphic object
      int               ObjectX(void)                       const { return this.m_obj_x;                                                              }
      int               ObjectY(void)                       const { return this.m_obj_y;                                                              }
      int               ObjectWidth(void)                   const { return this.m_background.Width();                                                 }
      int               ObjectHeight(void)                  const { return this.m_background.Height();                                                }
      int               ObjectRight(void)                   const { return this.ObjectX()+this.ObjectWidth()-1;                                       }
      int               ObjectBottom(void)                  const { return this.ObjectY()+this.ObjectHeight()-1;                                      }
      
   // --- Changes the (1) width, (2) height, (3) size of the bounding box
      void              BoundResizeW(const int size)              { this.m_bound.ResizeW(size);                                                       }
      void              BoundResizeH(const int size)              { this.m_bound.ResizeH(size);                                                       }
      void              BoundResize(const int w,const int h)      { this.m_bound.Resize(w,h);                                                         }
      
   // --- Sets the (1) X, (2) Y, (3) both coordinates of the bounding box
      void              BoundSetX(const int x)                    { this.m_bound.SetX(x);                                                             }
      void              BoundSetY(const int y)                    { this.m_bound.SetY(y);                                                             }
      void              BoundSetXY(const int x,const int y)       { this.m_bound.SetXY(x,y);                                                          }
      
   // --- (1) Sets, (2) offsets the bounding box by the specified coordinates/offset size
      void              BoundMove(const int x,const int y)        { this.m_bound.Move(x,y);                                                           }
      void              BoundShift(const int dx,const int dy)     { this.m_bound.Shift(dx,dy);                                                        }
      
   // --- Changes the (1) width, (2) height, (3) size of a graphic object
      bool              ObjectResizeW(const int size);
      bool              ObjectResizeH(const int size);
      bool              ObjectResize(const int w,const int h);
      
   // --- Sets the (1) X, (2) Y, (3) both coordinates of the graphic object
      bool              ObjectSetX(const int x);
      bool              ObjectSetY(const int y);
      bool              ObjectSetXY(const int x,const int y)      { return(this.ObjectSetX(x) && this.ObjectSetY(y));                                 }
      
   // --- (1) Sets, (2) offsets the graphic object by the specified coordinates/offset size
      bool              ObjectMove(const int x,const int y)       { return this.ObjectSetXY(x,y);                                                     }
      bool              ObjectShift(const int dx,const int dy)    { return this.ObjectSetXY(this.ObjectX()+dx,this.ObjectY()+dy);                     }
      
   // --- Limits the graphic object to the size of the container
      virtual void      ObjectTrim(void);
      
   public:
   // --- Returns a pointer to the (1) background, (2) foreground canvas
      CCanvas          *GetBackground(void)                       { return &this.m_background;                                                        }
      CCanvas          *GetForeground(void)                       { return &this.m_foreground;                                                        }
      
   // --- Returns a pointer to the color control object of (1) background, (2) foreground, (3) frame
      CColorElement    *GetBackColorControl(void)                 { return &this.m_color_background;                                                  }
      CColorElement    *GetForeColorControl(void)                 { return &this.m_color_foreground;                                                  }
      CColorElement    *GetBorderColorControl(void)               { return &this.m_color_border;                                                      }
      
   // --- Return the color of (1) background, (2) foreground, (3) frame
      color             BackColor(void)                     const { return this.m_color_background.GetCurrent();                                      }
      color             ForeColor(void)                     const { return this.m_color_foreground.GetCurrent();                                      }
      color             BorderColor(void)                   const { return this.m_color_border.GetCurrent();                                          }
      
   // --- Set background colors for all states
      void              InitBackColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                        {
                           this.m_color_background.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                        }
      void              InitBackColors(const color clr)           { this.m_color_background.InitColors(clr);                                          }

   // --- Set foreground colors for all states
      void              InitForeColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                        {
                           this.m_color_foreground.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                        }
      void              InitForeColors(const color clr)           { this.m_color_foreground.InitColors(clr);                                          }

   // --- Set frame colors for all states
      void              InitBorderColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                        {
                           this.m_color_border.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                        }
      void              InitBorderColors(const color clr)         { this.m_color_border.InitColors(clr);                                              }

   // --- Initialize the color of (1) background, (2) foreground, (3) border with initial values
      void              InitBackColorDefault(const color clr)     { this.m_color_background.InitDefault(clr);                                         }
      void              InitForeColorDefault(const color clr)     { this.m_color_foreground.InitDefault(clr);                                         }
      void              InitBorderColorDefault(const color clr)   { this.m_color_border.InitDefault(clr);                                             }
      
   // --- Initialize the color of (1) background, (2) foreground, (3) frame on hover with initial values
      void              InitBackColorFocused(const color clr)     { this.m_color_background.InitFocused(clr);                                         }
      void              InitForeColorFocused(const color clr)     { this.m_color_foreground.InitFocused(clr);                                         }
      void              InitBorderColorFocused(const color clr)   { this.m_color_border.InitFocused(clr);                                             }
      
   // --- Initialize the color of (1) background, (2) foreground, (3) frame when clicking on an object with initial values
      void              InitBackColorPressed(const color clr)     { this.m_color_background.InitPressed(clr);                                         }
      void              InitForeColorPressed(const color clr)     { this.m_color_foreground.InitPressed(clr);                                         }
      void              InitBorderColorPressed(const color clr)   { this.m_color_border.InitPressed(clr);                                             }
      
   // --- Initialize the color of (1) background, (2) foreground, (3) border for a locked object with initial values
      void              InitBackColorBlocked(const color clr)     { this.m_color_background.InitBlocked(clr);                                         }
      void              InitForeColorBlocked(const color clr)     { this.m_color_foreground.InitBlocked(clr);                                         }
      void              InitBorderColorBlocked(const color clr)   { this.m_color_border.InitBlocked(clr);                                             }
      
   // --- Set the current background color to different states
      bool              BackColorToDefault(void)                  { return this.m_color_background.SetCurrentAs(COLOR_STATE_DEFAULT);                 }
      bool              BackColorToFocused(void)                  { return this.m_color_background.SetCurrentAs(COLOR_STATE_FOCUSED);                 }
      bool              BackColorToPressed(void)                  { return this.m_color_background.SetCurrentAs(COLOR_STATE_PRESSED);                 }
      bool              BackColorToBlocked(void)                  { return this.m_color_background.SetCurrentAs(COLOR_STATE_BLOCKED);                 }
      
   // ---Set the current foreground color to different states
      bool              ForeColorToDefault(void)                  { return this.m_color_foreground.SetCurrentAs(COLOR_STATE_DEFAULT);                 }
      bool              ForeColorToFocused(void)                  { return this.m_color_foreground.SetCurrentAs(COLOR_STATE_FOCUSED);                 }
      bool              ForeColorToPressed(void)                  { return this.m_color_foreground.SetCurrentAs(COLOR_STATE_PRESSED);                 }
      bool              ForeColorToBlocked(void)                  { return this.m_color_foreground.SetCurrentAs(COLOR_STATE_BLOCKED);                 }
      
   // --- Set the current frame color to different states
      bool              BorderColorToDefault(void)                { return this.m_color_border.SetCurrentAs(COLOR_STATE_DEFAULT);                     }
      bool              BorderColorToFocused(void)                { return this.m_color_border.SetCurrentAs(COLOR_STATE_FOCUSED);                     }
      bool              BorderColorToPressed(void)                { return this.m_color_border.SetCurrentAs(COLOR_STATE_PRESSED);                     }
      bool              BorderColorToBlocked(void)                { return this.m_color_border.SetCurrentAs(COLOR_STATE_BLOCKED);                     }
      
   // ---Set the current colors of an element to different states
      bool              ColorsToDefault(void);
      bool              ColorsToFocused(void);
      bool              ColorsToPressed(void);
      bool              ColorsToBlocked(void);
      
   // --- Sets a pointer to the parent container object
      void              SetContainerObj(CCanvasBase *obj);
      
   // --- Creates OBJ_BITMAP_LABEL
      bool              Create(const long chart_id,const int wnd,const string name,const int x,const int y,const int w,const int h);

   // --- Returns (1) the ownership of the object to the program, the flag of (2) hidden, (3) blocked element, (4) the name of the graphic object
      bool              IsBelongsToThis(void)   const { return(::ObjectGetString(this.m_chart_id,this.NameBG(),OBJPROP_TEXT)==this.m_program_name);   }
      bool              IsHidden(void)          const { return this.m_hidden;                                                                         }
      bool              IsBlocked(void)         const { return this.m_blocked;                                                                        }
      bool              IsFocused(void)         const { return this.m_focused;                                                                        }
      string            NameBG(void)    const { return this.m_background.ChartObjectName();                                                           }
      string            NameFG(void)    const { return this.m_foreground.ChartObjectName();                                                           }
      
   // --- (1) Returns, (2) sets transparency
      uchar             Alpha(void)                         const { return this.m_alpha;                                                              }
      void              SetAlpha(const uchar value)               { this.m_alpha=value;                                                               }
      
   // --- (1) Returns, (2) sets the border width
      uint             BorderWidth(void)                   const { return this.m_border_width;                                                       } 
      void             SetBorderWidth(const uint width)          { this.m_border_width=width;                                                        }
                        
   // --- Returns the coordinates, dimensions and boundaries of an object
      int               X(void)                             const { return this.m_bound.X();                                                          }
      int               Y(void)                             const { return this.m_bound.Y();                                                          }
      int               Width(void)                         const { return this.m_bound.Width();                                                      }
      int               Height(void)                        const { return this.m_bound.Height();                                                     }
      int               Right(void)                         const { return this.m_bound.Right();                                                      }
      int               Bottom(void)                        const { return this.m_bound.Bottom();                                                     }
      
   // --- Sets the object to a new coordinate (1) X, (2) Y, (3) XY
      bool              MoveX(const int x);
      bool              MoveY(const int y);
      bool              Move(const int x,const int y);
      
   // --- Shifts the object along the (1) X, (2) Y, (3) XY axis by the specified offset
      bool              ShiftX(const int dx);
      bool              ShiftY(const int dy);
      bool              Shift(const int dx,const int dy);

   // --- Returning the boundaries of an object taking into account the frame
      int               LimitLeft(void)                     const { return this.X()+(int)this.m_border_width;                                         }
      int               LimitRight(void)                    const { return this.Right()-(int)this.m_border_width;                                     }
      int               LimitTop(void)                      const { return this.Y()+(int)this.m_border_width;                                         }
      int               LimitBottom(void)                   const { return this.Bottom()-(int)this.m_border_width;                                    }

   // --- (1) Hides (2) displays the object on all chart periods,
   // --- (3) brings the item to the front, (4) locks, (5) unlocks the item,
   // --- (6) fills the object with the specified color with the transparency set
      virtual void      Hide(const bool chart_redraw);
      virtual void      Show(const bool chart_redraw);
      virtual void      BringToTop(const bool chart_redraw);
      virtual void      Block(const bool chart_redraw);
      virtual void      Unblock(const bool chart_redraw);
      void              Fill(const color clr,const bool chart_redraw);
      
   // --- (1) Fills the object with a transparent color, (2) updates the object to reflect the changes,
   // --- (3) draws the appearance, (4) destroys the object
      virtual void      Clear(const bool chart_redraw);
      virtual void      Update(const bool chart_redraw);
      virtual void      Draw(const bool chart_redraw);
      virtual void      Destroy(void);
      
   // --- (1) Returns, (2) logs a description of the object
      virtual string    Description(void);
      void              Print(void);
      
   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0) const;
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                          const { return(ELEMENT_TYPE_CANVAS_BASE); }
      
   // --- Constructors/destructor
                        CCanvasBase(void) :
                           m_program_name(::MQLInfoString(MQL_PROGRAM_NAME)), m_chart_id(::ChartID()), m_wnd(0),
                           m_alpha(0), m_hidden(false), m_blocked(false), m_focused(false), m_border_width(0), m_wnd_y(0) { }
                        CCanvasBase(const long chart_id,const int wnd,const string name,const int x,const int y,const int w,const int h);
                     ~CCanvasBase(void);
};
//+------------------------------------------------------------------+
// | CCanvasBase::Constructor |
//+------------------------------------------------------------------+
CCanvasBase::CCanvasBase(const long chart_id,const int wnd,const string name,const int x,const int y,const int w,const int h) :
   m_program_name(::MQLInfoString(MQL_PROGRAM_NAME)), m_wnd(wnd<0 ? 0 : wnd), m_alpha(0), m_hidden(false), m_blocked(false), m_focused(false), m_border_width(0)
{
   // --- Get the adjusted graph ID and distance in pixels along the vertical Y axis
   // --- between the top frame of the indicator subwindow and the top frame of the main chart window
      this.m_chart_id=this.CorrectChartID(chart_id);
      this.m_wnd_y=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOW_YDISTANCE,this.m_wnd);
   // --- If the graphic resource and graphic object are created
      if(this.Create(this.m_chart_id,this.m_wnd,name,x,y,w,h))
      {
         // --- Clear the background and foreground canvases and set the initial coordinate values,
         // --- names of graphic objects and properties of text drawn in the foreground
         this.Clear(false);
         this.m_obj_x=x;
         this.m_obj_y=y;
         this.m_color_background.SetName("Background");
         this.m_color_foreground.SetName("Foreground");
         this.m_color_border.SetName("Border");
         this.m_foreground.FontSet("Calibri",12);
         this.m_bound.SetName("Perimeter");
      }
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Destructor |
//+------------------------------------------------------------------+
CCanvasBase::~CCanvasBase(void)
  {
   this.Destroy();
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Creates background and foreground graphic objects |
//+------------------------------------------------------------------+
bool CCanvasBase::Create(const long chart_id,const int wnd,const string name,const int x,const int y,const int w,const int h)
{
// --- Getting the adjusted chart identifier
   long id=this.CorrectChartID(chart_id);
// --- Create a name for the graphic object for the background and create a canvas
   string obj_name=name+"_BG";
   if(!this.m_background.CreateBitmapLabel(id,(wnd<0 ? 0 : wnd),obj_name,x,y,(w>0 ? w : 1),(h>0 ? h : 1),COLOR_FORMAT_ARGB_NORMALIZE))
     {
      ::PrintFormat("%s: The CreateBitmapLabel() method of the CCanvas class returned an error creating a \"%s\" graphic object",__FUNCTION__,obj_name);
      return false;
     }
// --- Create a name for the graphic object for the foreground and create a canvas
   obj_name=name+"_FG";
   if(!this.m_foreground.CreateBitmapLabel(id,(wnd<0 ? 0 : wnd),obj_name,x,y,(w>0 ? w : 1),(h>0 ? h : 1),COLOR_FORMAT_ARGB_NORMALIZE))
     {
      ::PrintFormat("%s: The CreateBitmapLabel() method of the CCanvas class returned an error creating a \"%s\" graphic object",__FUNCTION__,obj_name);
      return false;
     }
// --- If creation is successful, enter the name of the program into the OBJPROP_TEXT property of the graphic object
   ::ObjectSetString(id,this.NameBG(),OBJPROP_TEXT,this.m_program_name);
   ::ObjectSetString(id,this.NameFG(),OBJPROP_TEXT,this.m_program_name);
   
// --- Set the dimensions of the rectangular area and return true
   this.m_bound.SetXY(x,y);
   this.m_bound.Resize(w,h);
   return true;
}
//+------------------------------------------------------------------+
// | CCanvasBase::Set pointer |
// | to the parent container object |
//+------------------------------------------------------------------+
void CCanvasBase::SetContainerObj(CCanvasBase *obj)
{
// --- Set the passed pointer to the object
   this.m_container=obj;
// --- If the pointer is empty, we leave
   if(this.m_container==NULL)
      return;
// --- If an invalid pointer is passed, we reset it in the object and leave
   if(::CheckPointer(this.m_container)==POINTER_INVALID)
     {
      this.m_container=NULL;
      return;
     }
// --- Crop the object along the boundaries of the container assigned to it
   this.ObjectTrim();
}
//+------------------------------------------------------------------+
// | CCanvasBase::Crops a graphic object along the contour of the container |
//+------------------------------------------------------------------+
void CCanvasBase::ObjectTrim()
  {
// --- Getting the boundaries of the container
   int container_left   = this.ContainerLimitLeft();
   int container_right  = this.ContainerLimitRight();
   int container_top    = this.ContainerLimitTop();
   int container_bottom = this.ContainerLimitBottom();
   
// --- Get the current boundaries of the object
   int object_left   = this.X();
   int object_right  = this.Right();
   int object_top    = this.Y();
   int object_bottom = this.Bottom();

// --- Check if the object completely extends beyond the container and hide it if so
   if(object_right <= container_left || object_left >= container_right ||
      object_bottom <= container_top || object_top >= container_bottom)
     {
      this.Hide(true);
      this.ObjectResize(this.Width(),this.Height());
      return;
     }

// --- We check whether the object goes horizontally and vertically outside the container
   bool modified_horizontal=false;     // Horizontal change flag
   bool modified_vertical  =false;     // Vertical change flag
   
// ---Horizontal cropping
   int new_left = object_left;
   int new_width = this.Width();
// --- If the object extends beyond the left border of the container
   if(object_left<=container_left)
     {
      int crop_left=container_left-object_left;
      new_left=container_left;
      new_width-=crop_left;
      modified_horizontal=true;
     }
// --- If the object goes beyond the right border of the container
   if(object_right>=container_right)
     {
      int crop_right=object_right-container_right;
      new_width-=crop_right;
      modified_horizontal=true;
     }
// --- If there were changes horizontally
   if(modified_horizontal)
     {
      this.ObjectSetX(new_left);
      this.ObjectResizeW(new_width);
     }

// --- Vertical cropping
   int new_top=object_top;
   int new_height=this.Height();
// --- If the object goes beyond the top border of the container
   if(object_top<=container_top)
     {
      int crop_top=container_top-object_top;
      new_top=container_top;
      new_height-=crop_top;
      modified_vertical=true;
     }
// --- If the object extends beyond the bottom border of the container
   if(object_bottom>=container_bottom)
     {
      int crop_bottom=object_bottom-container_bottom;
      new_height-=crop_bottom;
      modified_vertical=true;
     }
// --- If there were changes vertically
   if(modified_vertical)
     {
      this.ObjectSetY(new_top);
      this.ObjectResizeH(new_height);
     }

// --- After calculations, the object may be hidden, but is now in the container area - display it
   this.Show(false);

// --- If the object has been changed, redraw it
   if(modified_horizontal || modified_vertical)
     {
      this.Update(false);
      this.Draw(false);
     }
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Sets the X coordinate of a graphic object |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectSetX(const int x)
  {
// --- If an existing coordinate is passed, return true
   if(this.ObjectX()==x)
      return true;
// --- If it was not possible to set a new coordinate in the background and foreground graphic objects, return false
   if(!::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_XDISTANCE,x) || !::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_XDISTANCE,x))
      return false;
// --- Write the new coordinate to a variable and return true
   this.m_obj_x=x;
   return true;
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Sets the Y coordinate of a graphic object |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectSetY(const int y)
  {
// --- If an existing coordinate is passed, return true
   if(this.ObjectY()==y)
      return true;
// --- If it was not possible to set a new coordinate in the background and foreground graphic objects, return false
   if(!::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_YDISTANCE,y) || !::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_YDISTANCE,y))
      return false;
// --- Write the new coordinate to a variable and return true
   this.m_obj_y=y;
   return true;
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Changes the width of a graphic object |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectResizeW(const int size)
  {
// --- If the existing width is passed, return true
   if(this.ObjectWidth()==size)
      return true;
// --- If a size greater than 0 is passed, we return the result of changing the width of the background and foreground, otherwise - false
   return(size>0 ? (this.m_background.Resize(size,this.ObjectHeight()) && this.m_foreground.Resize(size,this.ObjectHeight())) : false);
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Changes the height of a graphic object |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectResizeH(const int size)
  {
//--- Если передана существующая высота - возвращаем true
   if(this.ObjectHeight()==size)
      return true;
// --- If a size greater than 0 is passed, we return the result of changing the height of the background and foreground, otherwise - false
   return(size>0 ? (this.m_background.Resize(this.ObjectWidth(),size) && this.m_foreground.Resize(this.ObjectWidth(),size)) : false);
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Resizes a graphic object |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectResize(const int w,const int h)
  {
   if(!this.ObjectResizeW(w))
      return false;
   return this.ObjectResizeH(h);
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Sets an object to new X and Y coordinates |
//+------------------------------------------------------------------+
bool CCanvasBase::Move(const int x,const int y)
  {
   if(!this.ObjectMove(x,y))
      return false;
   this.BoundMove(x,y);
   this.ObjectTrim();
   return true;
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Sets an object to a new X coordinate |
//+------------------------------------------------------------------+
bool CCanvasBase::MoveX(const int x)
  {
   return this.Move(x,this.ObjectY());
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Sets an object to a new Y coordinate |
//+------------------------------------------------------------------+
bool CCanvasBase::MoveY(const int y)
  {
   return this.Move(this.ObjectX(),y);
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Shifts an object along the X and Y axes by the specified offset |
//+------------------------------------------------------------------+
bool CCanvasBase::Shift(const int dx,const int dy)
  {
   if(!this.ObjectShift(dx,dy))
      return false;
   this.BoundShift(dx,dy);
   this.ObjectTrim();
   return true;
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Shifts the object along the X axis by the specified offset |
//+------------------------------------------------------------------+
bool CCanvasBase::ShiftX(const int dx)
  {
   return this.Shift(dx,0);
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Shifts the object along the Y axis by the specified offset |
//+------------------------------------------------------------------+
bool CCanvasBase::ShiftY(const int dy)
{
   return this.Shift(0,dy);
}
//+------------------------------------------------------------------+
// | CCanvasBase::Hides the object on all chart periods |
//+------------------------------------------------------------------+
void CCanvasBase::Hide(const bool chart_redraw)
{
// --- If the object is already hidden, we leave
   if(this.m_hidden)
      return;
// --- If the visibility change for background and foreground is successfully set
// --- to the graphics command queue - set the hidden object flag
   if(::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS) &&
      ::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS)
      ) this.m_hidden=true;
// --- If indicated, redraw the graph
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
}
//+------------------------------------------------------------------+
// | CCanvasBase::Displays an object on all chart periods |
//+------------------------------------------------------------------+
void CCanvasBase::Show(const bool chart_redraw)
{
   // --- If the object is already visible, we leave
      if(!this.m_hidden)
         return;
   // --- If the visibility change for background and foreground is successfully set
   // --- to the graphics command queue - reset the hidden object flag
      if(::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS) &&
         ::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS)
         ) this.m_hidden=false;
   // --- If indicated, redraw the graph
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
}
//+------------------------------------------------------------------+
// | CCanvasBase::Brings the object to the front |
//+------------------------------------------------------------------+
void CCanvasBase::BringToTop(const bool chart_redraw)
  {
   this.Hide(false);
   this.Show(chart_redraw);
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Sets the current colors |
// | element to default state |
//+------------------------------------------------------------------+
bool CCanvasBase::ColorsToDefault(void)
{
   bool res=true;
   res &=this.BackColorToDefault();
   res &=this.ForeColorToDefault();
   res &=this.BorderColorToDefault();
   return res;
}
//+------------------------------------------------------------------+
// | CCanvasBase::Sets the current colors |
// | element into hover state |
//+------------------------------------------------------------------+
bool CCanvasBase::ColorsToFocused(void)
{
   bool res=true;
   res &=this.BackColorToFocused();
   res &=this.ForeColorToFocused();
   res &=this.BorderColorToFocused();
   return res;
}
//+------------------------------------------------------------------+
// | CCanvasBase::Sets the current colors |
// | element into state when the cursor is pressed |
//+------------------------------------------------------------------+
bool CCanvasBase::ColorsToPressed(void)
{
   bool res=true;
   res &=this.BackColorToPressed();
   res &=this.ForeColorToPressed();
   res &=this.BorderColorToPressed();
   return res;
}
//+------------------------------------------------------------------+
// | CCanvasBase::Sets the current colors |
// | element to a locked state |
//+------------------------------------------------------------------+
bool CCanvasBase::ColorsToBlocked(void)
{
   bool res=true;
   res &=this.BackColorToBlocked();
   res &=this.ForeColorToBlocked();
   res &=this.BorderColorToBlocked();
   return res;
}
//+------------------------------------------------------------------+
// | CCanvasBase::Blocks element |
//+------------------------------------------------------------------+
void CCanvasBase::Block(const bool chart_redraw)
{
   // --- If the element is already blocked, we leave
      if(this.m_blocked)
         return;
   // --- Set the current colors as the colors of the blocked element,
   // --- redraw the object and set the blocking flag
      this.ColorsToBlocked();
      this.Draw(chart_redraw);
      this.m_blocked=true;
}
//+------------------------------------------------------------------+
// | CCanvasBase::Unlocks element |
//+------------------------------------------------------------------+
void CCanvasBase::Unblock(const bool chart_redraw)
{
   // --- If the element is already unlocked, we leave
      if(!this.m_blocked)
         return;
   // --- Set the current colors to be the colors of the element in its normal state,
   // --- redraw the object and reset the blocking flag
      this.ColorsToDefault();
      this.Draw(chart_redraw);
      this.m_blocked=false;
}
//+------------------------------------------------------------------+
// | CCanvasBase::Fills an object with the specified color |
// | with transparency set to m_alpha |
//+------------------------------------------------------------------+
void CCanvasBase::Fill(const color clr,const bool chart_redraw)
  {
   this.m_background.Erase(::ColorToARGB(clr,this.m_alpha));
   this.m_background.Update(chart_redraw);
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Fills an object with a transparent color |
//+------------------------------------------------------------------+
void CCanvasBase::Clear(const bool chart_redraw)
  {
   // this.m_background.Erase(clrNULL);
   // this.m_foreground.Erase(clrNULL); 
   this.m_background.Erase(0x00000000);  // Modify clrNULL → 0x00000000
   this.m_foreground.Erase(0x00000000);  // Modify clrNULL → 0x00000000  
   this.Update(chart_redraw);
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Updates an object to reflect changes |
//+------------------------------------------------------------------+
void CCanvasBase::Update(const bool chart_redraw)
{
   this.m_background.Update(false);
   this.m_foreground.Update(chart_redraw);
}
//+------------------------------------------------------------------+
// | CCanvasBase::Draws appearance |
//+------------------------------------------------------------------+
void CCanvasBase::Draw(const bool chart_redraw)
  {
   return;
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Destroys an object |
//+------------------------------------------------------------------+
void CCanvasBase::Destroy(void)
  {
   this.m_background.Destroy();
   this.m_foreground.Destroy();
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Returns object description |
//+------------------------------------------------------------------+
string CCanvasBase::Description(void)
  {
   string nm=this.Name();
   string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   string area=::StringFormat("x %d, y %d, w %d, h %d",this.X(),this.Y(),this.Width(),this.Height());
   return ::StringFormat("%s%s (%s, %s): ID %d, %s",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.NameBG(),this.NameFG(),this.ID(),area);
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Log a description of an object |
//+------------------------------------------------------------------+
void CCanvasBase::Print(void)
  {
   ::Print(this.Description());
  }
//+------------------------------------------------------------------+
// | CCanvasBase::Saving to file |
//+------------------------------------------------------------------+
bool CCanvasBase::Save(const int file_handle)
  {
// --- Method temporarily disabled
   return false;
   
// --- Checking the handle
   if(file_handle==INVALID_HANDLE)
      return false;
// --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
   if(::FileWriteLong(file_handle,-1)!=sizeof(long))
      return false;
// --- Save the object type
   if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
      return false;

/*
// ---Saving properties
      
*/
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | Loading from file |
//+------------------------------------------------------------------+
bool CCanvasBase::Load(const int file_handle)
  {
// --- Method temporarily disabled
   return false;
   
// --- Checking the handle
   if(file_handle==INVALID_HANDLE)
      return false;
// --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
   if(::FileReadLong(file_handle)!=-1)
      return false;
// --- Loading the object type
   if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
      return false;

/*
// --- Loading properties
   
*/
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
