//+------------------------------------------------------------------+
//|                                                      Element.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "ElementBase.mqh"
class CWindow;
//+------------------------------------------------------------------+
// | Control derived class |
//+------------------------------------------------------------------+
class CElement : public CElementBase
  {
protected:
   // --- Pointer to form
   CWindow          *m_wnd;
   // --- Pointer to the main element
   CElement         *m_main;
   // --- Canvas for drawing element
   CRectCanvas       m_canvas;
   // --- Pointers to connected elements
   CElement         *m_elements[];
   // ---Image groups
   struct EImagesGroup
     {
      // --- Image array
      CImage            m_image[];
      // --- Label padding
      int               m_x_gap;
      int               m_y_gap;
      // --- The image selected for display in the group
      int               m_selected_image;
     };
   EImagesGroup      m_images_group[];
   // --- Label padding
   int               m_icon_x_gap;
   int               m_icon_y_gap;
   // ---Background color in different states
   color             m_back_color;
   color             m_back_color_hover;
   color             m_back_color_locked;
   color             m_back_color_pressed;
   // --- Frame color in different states
   color             m_border_color;
   color             m_border_color_hover;
   color             m_border_color_locked;
   color             m_border_color_pressed;
   // --- Text colors in different states
   color             m_label_color;
   color             m_label_color_hover;
   color             m_label_color_locked;
   color             m_label_color_pressed;
   // --- Description text
   string            m_label_text;
   // ---Text Label Indents
   int               m_label_x_gap;
   int               m_label_y_gap;
   // --- Font
   string            m_font;
   int               m_font_size;
   // --- Alpha channel value (element transparency)
   uchar             m_alpha;
   // --- Tooltip text
   string            m_tooltip_text;
   // ---Text alignment mode
   bool              m_is_center_text;
   // ---Priority on left mouse button click
   long              m_zorder;
   //---
public:
                     CElement(void);
                    ~CElement(void);
   //---
protected:
   // ---Creating a canvas for drawing
   bool              CreateCanvas(const string name,const int x,const int y,
                                  const int x_size,const int y_size,ENUM_COLOR_FORMAT clr_format=COLOR_FORMAT_ARGB_NORMALIZE);
   //---
public:
   // --- Saves and returns a pointer to the form
   CWindow          *WindowPointer(void)                             { return(::GetPointer(m_wnd));     }
   void              WindowPointer(CWindow &object)                  { m_wnd=::GetPointer(object);      }
   // --- Stores and returns a pointer to (1) the main element,
   // (2) returns a pointer to the element's canvas, (3) returns a pointer to a group of images
   CElement         *MainPointer(void)                               { return(::GetPointer(m_main));    }
   void              MainPointer(CElement &object)                   { m_main=::GetPointer(object);     }
   CRectCanvas      *CanvasPointer(void)                             { return(::GetPointer(m_canvas));  }
   // --- (1) Getting the number of connected elements, (2) freeing the array of connected elements
   int               ElementsTotal(void)                       const { return(::ArraySize(m_elements)); }
   void              FreeElementsArray(void)                         { ::ArrayFree(m_elements);         }
   // --- Returns a pointer to the connected element at the specified index
   CElement         *Element(const uint index);
   // --- Alpha channel value (element transparency)
   void              Alpha(const uchar value)                        { m_alpha=value;                   }
   uchar             Alpha(void)                               const { return(m_alpha);                 }
   // --- (1) Tooltip, (2) tooltip display mode
   void              Tooltip(const string text)                      { m_tooltip_text=text;             }
   string            Tooltip(void)                             const { return(m_tooltip_text);          }
   void              ShowTooltip(const bool state);
   // ---Background color in different states
   void              BackColor(const color clr)                      { m_back_color=clr;                }
   color             BackColor(void)                           const { return(m_back_color);            }
   void              BackColorHover(const color clr)                 { m_back_color_hover=clr;          }
   color             BackColorHover(void)                      const { return(m_back_color_hover);      }
   void              BackColorLocked(const color clr)                { m_back_color_locked=clr;         }
   color             BackColorLocked(void)                     const { return(m_back_color_locked);     }
   void              BackColorPressed(const color clr)               { m_back_color_pressed=clr;        }
   color             BackColorPressed(void)                    const { return(m_back_color_pressed);    }
   // --- Frame color in different states
   void              BorderColor(const color clr)                    { m_border_color=clr;              }
   color             BorderColor(void)                         const { return(m_border_color);          }
   void              BorderColorHover(const color clr)               { m_border_color_hover=clr;        }
   color             BorderColorHover(void)                    const { return(m_border_color_hover);    }
   void              BorderColorLocked(const color clr)              { m_border_color_locked=clr;       }
   color             BorderColorLocked(void)                   const { return(m_border_color_locked);   }
   void              BorderColorPressed(const color clr)             { m_border_color_pressed=clr;      }
   color             BorderColorPressed(void)                  const { return(m_border_color_pressed);  }
   // --- Text label colors in different states
   void              LabelColor(const color clr)                     { m_label_color=clr;               }
   color             LabelColor(void)                          const { return(m_label_color);           }
   void              LabelColorHover(const color clr)                { m_label_color_hover=clr;         }
   color             LabelColorHover(void)                     const { return(m_label_color_hover);     }
   void              LabelColorLocked(const color clr)               { m_label_color_locked=clr;        }
   color             LabelColorLocked(void)                    const { return(m_label_color_locked);    }
   void              LabelColorPressed(const color clr)              { m_label_color_pressed=clr;       }
   color             LabelColorPressed(void)                   const { return(m_label_color_pressed);   }
   // --- Label padding
   void              IconXGap(const int x_gap)                       { m_icon_x_gap=x_gap;              }
   int               IconXGap(void)                            const { return(m_icon_x_gap);            }
   void              IconYGap(const int y_gap)                       { m_icon_y_gap=y_gap;              }
   int               IconYGap(void)                            const { return(m_icon_y_gap);            }
   // --- (1) Input field description text, (2) text label indents
   void              LabelText(const string text)                    { m_label_text=text;               }
   string            LabelText(void)                           const { return(m_label_text);            }
   void              LabelXGap(const int x_gap)                      { m_label_x_gap=x_gap;             }
   int               LabelXGap(void)                           const { return(m_label_x_gap);           }
   void              LabelYGap(const int y_gap)                      { m_label_y_gap=y_gap;             }
   int               LabelYGap(void)                           const { return(m_label_y_gap);           }
   // --- (1) Font and (2) font size
   void              Font(const string font)                         { m_font=font;                     }
   string            Font(void)                                const { return(m_font);                  }
   void              FontSize(const int font_size)                   { m_font_size=font_size;           }
   int               FontSize(void)                            const { return(m_font_size);             }
   // --- (1) Center align text, (2) left click priority
   void              IsCenterText(const bool state)                  { m_is_center_text=state;          }
   bool              IsCenterText(void)                        const { return(m_is_center_text);        }
   long              Z_Order(void)                             const { return(m_zorder);                }
   void              Z_Order(const long z_order);
   // ---Element lock
   virtual void      IsLocked(const bool state);
   // --- Item availability
   virtual void      IsAvailable(const bool state);
   // --- Indentation for pictures of the specified group
   int               ImageGroupXGap(const uint index);
   void              ImageGroupXGap(const uint index,const int x_gap);
   // --- Set shortcuts for active and locked states
   void              IconFile(const string file_path);
   void              IconFile(const uint resource_index);
   string            IconFile(bool resource_index_mode = false);
   void              IconFileLocked(const string file_path);
   void              IconFileLocked(const uint resource_index);
   string            IconFileLocked(bool resource_index_mode = false);
   // --- Set shortcuts for an item in the pressed state (accessible/locked)
   void              IconFilePressed(const string file_path);
   void              IconFilePressed(const uint resource_index);
   string            IconFilePressed(bool resource_index_mode = false);
   void              IconFilePressedLocked(const string file_path);
   void              IconFilePressedLocked(const uint resource_index);
   string            IconFilePressedLocked(bool resource_index_mode = false);
   // --- Returns the number of image groups
   uint              ImagesGroupTotal(void) const { return(::ArraySize(m_images_group)); }
   // --- Returns the number of images in the specified group
   int               ImagesTotal(const uint group_index);
   // --- Adding a group of images with an array of images
   void              AddImagesGroup(const int x_gap,const int y_gap,const string &file_pathways[]);
   // --- Adding a group of images
   void              AddImagesGroup(const int x_gap,const int y_gap);
   // --- Adding an image (resource path) to the specified group
   void              AddImage(const uint group_index,const string file_path);
   // --- Adding an image (index to a resource) to the specified group
   void              AddImage(const uint group_index,const uint resource_index);
   // --- Installing/replacing an image (path to resource)
   void              SetImage(const uint group_index,const uint image_index,const string file_path);
   // --- Installing/replacing an image (index to resource)
   void              SetImage(const uint group_index,const uint image_index,const uint resource_index);
   // --- Image switching
   void              ChangeImage(const uint group_index,const uint image_index);
   // --- Returns the image selected for display in the specified group
   int               SelectedImage(const uint group_index=0);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
   // --- Timer
   virtual void      OnEventTimer(void) {}
   // ---Move element
   virtual void      Moving(const bool only_visible=true);
   // --- (1) Show, (2) hide, (3) move to top layer, (4) delete
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   // --- (1) Installation, (2) reset priorities by pressing the left mouse button
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   // --- Updates the element to reflect the latest changes
   virtual void      Update(const bool redraw=false);
   // --- Draws an element
   virtual void      Draw(void) {}
   //---
protected:
   // --- Method for adding pointers to descendant elements to a common array
   void              AddToArray(CElement &object);
   // --- Check if image groups are out of range
   virtual bool      CheckOutOfRange(const uint group_index,const uint image_index);
   // --- Checking for the presence of a pointer to the main element
   bool              CheckMainPointer(void);

   // --- Calculation of absolute coordinates
   int               CalculateX(const int x_gap);
   int               CalculateY(const int y_gap);
   // --- Calculation of relative coordinates from the extreme point of the form
   int               CalculateXGap(const int x);
   int               CalculateYGap(const int y);

   // --- Draws the background
   virtual void      DrawBackground(void);
   // --- Draws a frame
   virtual void      DrawBorder(void);
   // --- Draws a picture
   virtual void      DrawImage(void);
   // --- Draws text
   virtual void      DrawText(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CElement::CElement(void) : m_alpha(255),
                           m_tooltip_text("\n"),
                           m_back_color(clrNONE),
                           m_back_color_hover(clrNONE),
                           m_back_color_locked(clrNONE),
                           m_back_color_pressed(clrNONE),
                           m_border_color(clrNONE),
                           m_border_color_hover(clrNONE),
                           m_border_color_locked(clrNONE),
                           m_border_color_pressed(clrNONE),
                           m_icon_x_gap(WRONG_VALUE),
                           m_icon_y_gap(WRONG_VALUE),
                           m_label_text(""),
                           m_label_x_gap(WRONG_VALUE),
                           m_label_y_gap(WRONG_VALUE),
                           m_label_color(clrNONE),
                           m_label_color_hover(clrNONE),
                           m_label_color_locked(clrNONE),
                           m_label_color_pressed(clrNONE),
                           m_font("Calibri"),
                           m_font_size(8),
                           m_is_center_text(false),
                           m_zorder(WRONG_VALUE)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CElement::~CElement(void)
  {
  }
//+------------------------------------------------------------------+
// | Creating a Canvas for Drawing an Element |
//+------------------------------------------------------------------+
bool CElement::CreateCanvas(const string name,const int x,const int y,
                            const int x_size,const int y_size,ENUM_COLOR_FORMAT clr_format=COLOR_FORMAT_ARGB_NORMALIZE)
  {
// --- Size adjustment
   int xsize =(x_size<1)? 50 : x_size;
   int ysize =(y_size<1)? 20 : y_size;
// --- Reset last error
   ::ResetLastError();
// ---Create an object
   if(!m_canvas.CreateBitmapLabel(m_chart_id,m_subwin,name,x,y,xsize,ysize,clr_format))
     {
      ::Print(__FUNCTION__," > name: ",name);
      ::Print(__FUNCTION__," > Не удалось создать холст для рисования элемента ("+m_class_name+"): ",::GetLastError());
      return(false);
     }
// --- Reset last error
   ::ResetLastError();
// --- Get a pointer to the base class
   if(!m_canvas.Attach(m_chart_id,name,clr_format))
     {
      ::Print(__FUNCTION__," > Не удалось присоединить холст для рисования к графику: ",::GetLastError());
      return(false);
     }
// --- Properties
   ::ObjectSetString(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TOOLTIP,"\n");
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_CORNER,m_corner);
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_SELECTABLE,false);

// --- All elements except the form have a higher priority than the main element
   Z_Order((dynamic_cast<CWindow*>(&this)!=NULL)? 0 : m_main.Z_Order()+1);
// --- Coordinates
   m_canvas.X(x);
   m_canvas.Y(y);
// --- Dimensions
   m_canvas.XSize(x_size);
   m_canvas.YSize(y_size);
// --- Indents from the extreme point
   m_canvas.XGap(CalculateXGap(x));
   m_canvas.YGap(CalculateYGap(y));
   return(true);
  }
//+------------------------------------------------------------------+
// | Returns the indent for images from the specified group |
//+------------------------------------------------------------------+
int CElement::ImageGroupXGap(const uint index)
  {
// --- Return object pointer
   return(m_images_group[index].m_x_gap);
  }
//+------------------------------------------------------------------+
// | Setting the indent for pictures from the specified group |
//+------------------------------------------------------------------+
void CElement::ImageGroupXGap(const uint index,const int x_gap)
  {
   m_images_group[index].m_x_gap=x_gap;
  }
//+------------------------------------------------------------------+
// | Returns a pointer to the connected element |
//+------------------------------------------------------------------+
CElement *CElement::Element(const uint index)
  {
   uint array_size=::ArraySize(m_elements);
// --- Checking the size of an array of objects
   if(array_size<1)
     {
      ::Print(__FUNCTION__," > В этом элементе ("+m_class_name+") нет элементов-потомков!");
      return(NULL);
     }
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return object pointer
   return(::GetPointer(m_elements[i]));
  }
//+------------------------------------------------------------------+
// | Setting the tooltip to show |
//+------------------------------------------------------------------+
void CElement::ShowTooltip(const bool state)
  {
   if(state)
       ::ObjectSetString(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TOOLTIP,m_tooltip_text);
   else
       ::ObjectSetString(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TOOLTIP,"\n");
  }
//+------------------------------------------------------------------+
// | Left click priority |
//+------------------------------------------------------------------+
void CElement::Z_Order(const long z_order)
  {
   m_zorder=z_order;
   SetZorders();
  }
//+------------------------------------------------------------------+
// | Lock/unlock an element |
//+------------------------------------------------------------------+
void CElement::IsLocked(const bool state)
  {
// --- Exit if already installed
   if(state==CElementBase::IsLocked())
      return;
// ---Save state
   CElementBase::IsLocked(state);
// --- Other elements
   int elements_total=ElementsTotal();
   for(int i=0; i<elements_total; i++)
      m_elements[i].IsLocked(state);
// --- Pointer check
   if(::CheckPointer(m_main)==POINTER_INVALID)
      return;
// --- Event sends only the main element of the composite group
   if(this.Id()!=m_main.Id())
     {
      ::EventChartCustom(m_chart_id,ON_SET_LOCKED,CElementBase::Id(),(int)state,"");
      // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
     }
   else
     {
      if(state!=m_main.CElementBase::IsLocked())
        {
         ::EventChartCustom(m_chart_id,ON_SET_LOCKED,CElementBase::Id(),(int)state,"");
         // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
        }
     }
  }
//+------------------------------------------------------------------+
// | Item Availability |
//+------------------------------------------------------------------+
void CElement::IsAvailable(const bool state)
  {
// --- Exit if already installed
   if(state==CElementBase::IsAvailable())
      return;
// --- Install
   CElementBase::IsAvailable(state);
// --- Other elements
   int elements_total=ElementsTotal();
   for(int i=0; i<elements_total; i++)
      m_elements[i].IsAvailable(state);
// --- Set left click priorities
   if(state)
      SetZorders();
   else
      ResetZorders();
  }
//+------------------------------------------------------------------+
// | Setting a picture for the active state |
//+------------------------------------------------------------------+
void CElement::IconFile(const string file_path)
  {
// --- If there are no groups of images yet
   if(ImagesGroupTotal()<1)
     {
      m_icon_x_gap =(m_icon_x_gap!=WRONG_VALUE)? m_icon_x_gap : 0;
      m_icon_y_gap =(m_icon_y_gap!=WRONG_VALUE)? m_icon_y_gap : 0;
      // --- Add a group and an image
      AddImagesGroup(m_icon_x_gap,m_icon_y_gap);
      AddImage(0,file_path);
      AddImage(1,"");
      // ---Default image
      m_images_group[0].m_selected_image=0;
      return;
     }
// --- Set the image to the first group as the first element
   SetImage(0,0,file_path);
  }
//+------------------------------------------------------------------+
// | Setting a picture for the active state (index from the resource) |
//+------------------------------------------------------------------+
void CElement::IconFile(const uint resource_index)
  {
// --- If there are no groups of images yet
   if(ImagesGroupTotal()<1)
     {
      m_icon_x_gap =(m_icon_x_gap!=WRONG_VALUE)? m_icon_x_gap : 0;
      m_icon_y_gap =(m_icon_y_gap!=WRONG_VALUE)? m_icon_y_gap : 0;
      // --- Add a group and an image
      AddImagesGroup(m_icon_x_gap,m_icon_y_gap);
      AddImage(0,resource_index);
      AddImage(1,INT_MAX);
      // ---Default image
      m_images_group[0].m_selected_image=0;
      return;
     }
// --- Set the image to the first group as the first element
   SetImage(0,0,resource_index);
  }
//+------------------------------------------------------------------+
// | Returns the image |
//+------------------------------------------------------------------+
string CElement::IconFile(bool resource_index_mode = false)
  {
// --- Empty line if there are no image groups
   if(ImagesGroupTotal()<1)
      return("");
// ---If there is no image in the group
   if(::ArraySize(m_images_group[0].m_image)<1)
      return("");
// --- Return image path
   return((!resource_index_mode)? 
     m_images_group[0].m_image[0].BmpPath() : 
     (string)m_images_group[0].m_image[0].ResourceIndex());
  }
//+------------------------------------------------------------------+
// | Setting a picture for the locked state |
//+------------------------------------------------------------------+
void CElement::IconFileLocked(const string file_path)
  {
// --- If there are no groups of images yet
   if(ImagesGroupTotal()<1)
     {
      m_icon_x_gap =(m_icon_x_gap!=WRONG_VALUE)? m_icon_x_gap : 0;
      m_icon_y_gap =(m_icon_y_gap!=WRONG_VALUE)? m_icon_y_gap : 0;
      // --- Add a group and an image
      AddImagesGroup(m_icon_x_gap,m_icon_y_gap);
      AddImage(0,"");
      AddImage(1,file_path);
      // ---Default image
      m_images_group[0].m_selected_image=0;
      return;
     }
// --- Set the image to the first group as the second element
   SetImage(0,1,file_path);
  }
//+------------------------------------------------------------------+
// | Setting a picture for the locked state |
//+------------------------------------------------------------------+
void CElement::IconFileLocked(const uint resource_index)
  {
// --- If there are no groups of images yet
   if(ImagesGroupTotal()<1)
     {
      m_icon_x_gap =(m_icon_x_gap!=WRONG_VALUE)? m_icon_x_gap : 0;
      m_icon_y_gap =(m_icon_y_gap!=WRONG_VALUE)? m_icon_y_gap : 0;
      // --- Add a group and an image
      AddImagesGroup(m_icon_x_gap,m_icon_y_gap);
      AddImage(0,INT_MAX);
      AddImage(1,resource_index);
      // ---Default image
      m_images_group[0].m_selected_image=0;
      return;
     }
// --- Set the image to the first group as the second element
   SetImage(0,1,resource_index);
  }
//+------------------------------------------------------------------+
// | Returns the image |
//+------------------------------------------------------------------+
string CElement::IconFileLocked(bool resource_index_mode = false)
  {
// --- Empty line if there are no image groups
   if(ImagesGroupTotal()<1)
      return("");
// ---If there is no image in the group
   if(::ArraySize(m_images_group[0].m_image)<2)
      return("");
// --- Return image path
   return((!resource_index_mode)? 
     m_images_group[0].m_image[1].BmpPath() : 
     (string)m_images_group[0].m_image[1].ResourceIndex());
  }
//+------------------------------------------------------------------+
// | Setting a picture for the pressed state (available) |
//+------------------------------------------------------------------+
void CElement::IconFilePressed(const string file_path)
  {
// --- Add a place for the image if it doesn't exist yet
   while(!CElement::CheckOutOfRange(0,2))
      AddImage(0,"");
// --- Set picture
   CElement::SetImage(0,2,file_path);
  }
//+------------------------------------------------------------------+
// | Setting a picture for the pressed state (available) |
//+------------------------------------------------------------------+
void CElement::IconFilePressed(const uint resource_index)
  {
// --- Add a place for the image if it doesn't exist yet
   while(!CElement::CheckOutOfRange(0,2))
      AddImage(0,INT_MAX);
// --- Set picture
   CElement::SetImage(0,2,resource_index);
  }
//+------------------------------------------------------------------+
// | Returns the image |
//+------------------------------------------------------------------+
string CElement::IconFilePressed(bool resource_index_mode = false)
  {
// --- Empty line if there are no image groups
   if(ImagesGroupTotal()<1)
      return("");
// ---If there is no image in the group
   if(::ArraySize(m_images_group[0].m_image)<3)
      return("");
// --- Return image path
   return((!resource_index_mode)? 
     m_images_group[0].m_image[2].BmpPath() : 
     (string)m_images_group[0].m_image[2].ResourceIndex());
  }
//+------------------------------------------------------------------+
// | Setting the picture for the pressed state (locked) |
//+------------------------------------------------------------------+
void CElement::IconFilePressedLocked(const string file_path)
  {
// --- Add a place for the image if it doesn't exist yet
   while(!CElement::CheckOutOfRange(0,3))
      AddImage(0,"");
// --- Set picture
   CElement::SetImage(0,3,file_path);
  }
//+------------------------------------------------------------------+
// | Setting the picture for the pressed state (locked) |
//+------------------------------------------------------------------+
void CElement::IconFilePressedLocked(const uint resource_index)
  {
// --- Add a place for the image if it doesn't exist yet
   while(!CElement::CheckOutOfRange(0,3))
      AddImage(0,INT_MAX);
// --- Set picture
   CElement::SetImage(0,3,resource_index);
  }
//+------------------------------------------------------------------+
// | Returns the image |
//+------------------------------------------------------------------+
string CElement::IconFilePressedLocked(bool resource_index_mode = false)
  {
// --- Empty line if there are no image groups
   if(ImagesGroupTotal()<1)
      return("");
// ---If there is no image in the group
   if(::ArraySize(m_images_group[0].m_image)<4)
      return("");
// --- Return image path
   return((!resource_index_mode)? 
     m_images_group[0].m_image[3].BmpPath() : 
     (string)m_images_group[0].m_image[3].ResourceIndex());
  }
//+------------------------------------------------------------------+
// | Item Update |
//+------------------------------------------------------------------+
void CElement::Update(const bool redraw=false)
  {
// --- With element redrawing
   if(redraw)
     {
      Draw();
      m_canvas.Update(true);
      return;
     }
// --- Apply
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
// | Moving an element |
//+------------------------------------------------------------------+
void CElement::Moving(const bool only_visible=true)
  {
// --- Exit if element is hidden
   if(only_visible)
      if(!CElementBase::IsVisible())
         return;
// --- If the anchor is on the right
   if(m_anchor_right_window_side)
     {
      // ---Saving coordinates in element fields
      CElementBase::X(m_main.X2()-XGap());
      // ---Saving coordinates in object fields
      m_canvas.X(m_main.X2()-m_canvas.XGap());
     }
   else
     {
      CElementBase::X(m_main.X()+XGap());
      m_canvas.X(m_main.X()+m_canvas.XGap());
     }
// --- If the binding is below
   if(m_anchor_bottom_window_side)
     {
      CElementBase::Y(m_main.Y2()-YGap());
      m_canvas.Y(m_main.Y2()-m_canvas.YGap());
     }
   else
     {
      CElementBase::Y(m_main.Y()+YGap());
      m_canvas.Y(m_main.Y()+m_canvas.YGap());
     }
// --- Updating the coordinates of graphic objects
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XDISTANCE,m_canvas.X());
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_YDISTANCE,m_canvas.Y());
// --- Moving connected elements
   int elements_total=ElementsTotal();
   for(int i=0; i<elements_total; i++)
      m_elements[i].Moving(only_visible);
  }
//+------------------------------------------------------------------+
// | Shows element |
//+------------------------------------------------------------------+
void CElement::Show(void)
  {
// --- Exit if element is already visible
   if(CElementBase::IsVisible())
      return;
// --- Visibility state
   CElementBase::IsVisible(true);
// --- Update object position
   Moving();
// --- Show object
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
// --- Show connected items
   int elements_total=ElementsTotal();
   for(int i=0; i<elements_total; i++)
     {
      if(!m_elements[i].IsDropdown())
         m_elements[i].Show();
     }
  }
//+------------------------------------------------------------------+
// | Hides the element |
//+------------------------------------------------------------------+
void CElement::Hide(void)
  {
// --- Exit if element is already hidden
   if(!CElementBase::IsVisible())
      return;
// --- Hide object
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
// --- Visibility state
   CElementBase::IsVisible(false);
   CElementBase::MouseFocus(false);
// --- Hide connected items
   int elements_total=ElementsTotal();
   for(int i=0; i<elements_total; i++)
      m_elements[i].Hide();
  }
//+------------------------------------------------------------------+
// | Move to top layer |
//+------------------------------------------------------------------+
void CElement::Reset(void)
  {
// --- Exit if the element is a drop-down
   if(CElementBase::IsDropdown())
      return;
// --- Hide and show connected elements
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CElement::Delete(void)
  {
// --- Deleting objects
   m_canvas.Destroy();
// --- Delete connected elements
   int elements_total=ElementsTotal();
   for(int i=0; i<elements_total; i++)
      m_elements[i].Delete();
// --- Freeing an array of connected elements
   FreeElementsArray();
// --- Initializing variables to default values
   CElementBase::LastId(0);
   CElementBase::Id(WRONG_VALUE);
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
   CElementBase::IsAvailable(true);
// --- Reset priorities
   m_zorder=WRONG_VALUE;
  }
//+------------------------------------------------------------------+
// | Setting Priorities |
//+------------------------------------------------------------------+
void CElement::SetZorders(void)
  {
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_ZORDER,m_zorder);
   int elements_total=ElementsTotal();
   for(int i=0; i<elements_total; i++)
      m_elements[i].SetZorders();
  }
//+------------------------------------------------------------------+
// | Reset priorities |
//+------------------------------------------------------------------+
void CElement::ResetZorders(void)
  {
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_ZORDER,WRONG_VALUE);
   int elements_total=ElementsTotal();
   for(int i=0; i<elements_total; i++)
      m_elements[i].ResetZorders();
  }
//+------------------------------------------------------------------+
// | Method for adding pointers to connected elements |
//+------------------------------------------------------------------+
void CElement::AddToArray(CElement &object)
  {
   int size=ElementsTotal();
   ::ArrayResize(m_elements,size+1);
   m_elements[size]=::GetPointer(object);
  }
//+------------------------------------------------------------------+
// | Check out of range |
//+------------------------------------------------------------------+
bool CElement::CheckOutOfRange(const uint group_index,const uint image_index)
  {
// --- Group index check
   uint images_group_total=::ArraySize(m_images_group);
   if(images_group_total<1 || group_index>=images_group_total)
      return(false);
// --- Image index check
   uint images_total=::ArraySize(m_images_group[group_index].m_image);
   if(images_total<1 || image_index>=images_total)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Returns the number of images in the specified group |
//+------------------------------------------------------------------+
int CElement::ImagesTotal(const uint group_index)
  {
// --- Group index check
   uint images_group_total=::ArraySize(m_images_group);
   if(images_group_total<1 || group_index>=images_group_total)
      return(WRONG_VALUE);
// --- Number of images
   return(::ArraySize(m_images_group[group_index].m_image));
  }
//+------------------------------------------------------------------+
// | Adding an Image Group with an Image Array |
//+------------------------------------------------------------------+
void CElement::AddImagesGroup(const int x_gap,const int y_gap,const string &file_pathways[])
  {
// --- Get the size of the array of image groups
   uint images_group_total=::ArraySize(m_images_group);
// --- Add one group
   ::ArrayResize(m_images_group,images_group_total+1);
// --- Set padding for images
   m_images_group[images_group_total].m_x_gap =x_gap;
   m_images_group[images_group_total].m_y_gap =y_gap;
// ---Default image
   m_images_group[images_group_total].m_selected_image=0;
// --- Get the size of the array of added images
   uint images_total=::ArraySize(file_pathways);
// --- Add images to a new group if a non-empty array was passed
   for(uint i=0; i<images_total; i++)
      AddImage(images_group_total,file_pathways[i]);
  }
//+------------------------------------------------------------------+
// | Adding a group of images |
//+------------------------------------------------------------------+
void CElement::AddImagesGroup(const int x_gap,const int y_gap)
  {
// --- Get the size of the array of image groups
   uint images_group_total=::ArraySize(m_images_group);
// --- Add one group
   ::ArrayResize(m_images_group,images_group_total+1);
// --- Set padding for images
   m_images_group[images_group_total].m_x_gap=x_gap;
   m_images_group[images_group_total].m_y_gap=y_gap;
// ---Default image
   m_images_group[images_group_total].m_selected_image=0;
  }
//+------------------------------------------------------------------+
// | Adding an image (resource path) to the specified group |
//+------------------------------------------------------------------+
void CElement::AddImage(const uint group_index,const string file_path)
  {
// --- Get the size of the array of image groups
   uint images_group_total=::ArraySize(m_images_group);
// --- Quit if there are no groups
   if(images_group_total<1)
     {
      Print(__FUNCTION__," > Добавить группу изображений можно с помощью методов CElement::AddImagesGroup()");
      return;
     }
// --- Preventing out of range
   uint check_group_index=(group_index<images_group_total)? group_index : images_group_total-1;
// --- Get the size of the image array
   uint images_total=::ArraySize(m_images_group[check_group_index].m_image);
// --- Increase the size of the array by one element
   ::ArrayResize(m_images_group[check_group_index].m_image,images_total+1);
// --- Add an image
   m_images_group[check_group_index].m_image[images_total].ReadImageData(file_path);
  }
//+------------------------------------------------------------------+
// | Adding an image (index to a resource) to the specified group |
//+------------------------------------------------------------------+
void CElement::AddImage(const uint group_index,const uint resource_index)
  {
// --- Get the size of the array of image groups
   uint images_group_total=::ArraySize(m_images_group);
// --- Quit if there are no groups
   if(images_group_total<1)
     {
      Print(__FUNCTION__," > Добавить группу изображений можно с помощью методов CElement::AddImagesGroup()");
      return;
     }
// --- Preventing out of range
   uint check_group_index=(group_index<images_group_total)? group_index : images_group_total-1;
// --- Get the size of the image array
   uint images_total=::ArraySize(m_images_group[check_group_index].m_image);
// --- Increase the size of the array by one element
   ::ArrayResize(m_images_group[check_group_index].m_image,images_total+1);
// --- Add an image
   m_images_group[check_group_index].m_image[images_total].ReadImageData(resource_index);
  }
//+------------------------------------------------------------------+
// | Installing/replacing an image (path to resource) |
//+------------------------------------------------------------------+
void CElement::SetImage(const uint group_index,const uint image_index,const string file_path)
  {
// --- Check for out of range
   if(!CheckOutOfRange(group_index,image_index))
      return;
// ---Delete image
   m_images_group[group_index].m_image[image_index].DeleteImageData();
// --- Add an image
   m_images_group[group_index].m_image[image_index].ReadImageData(file_path);
  }
//+------------------------------------------------------------------+
// | Installing/replacing an image (index to resource) |
//+------------------------------------------------------------------+
void CElement::SetImage(const uint group_index,const uint image_index,const uint resource_index)
  {
// --- Check for out of range
   if(!CheckOutOfRange(group_index,image_index))
      return;
// ---Delete image
   m_images_group[group_index].m_image[image_index].DeleteImageData();
// --- Add an image
   m_images_group[group_index].m_image[image_index].ReadImageData(resource_index);
  }
//+------------------------------------------------------------------+
// | Switch image |
//+------------------------------------------------------------------+
void CElement::ChangeImage(const uint group_index,const uint image_index)
  {
// --- Check for out of range
   if(!CheckOutOfRange(group_index,image_index))
      return;
// --- Save image index for display
   m_images_group[group_index].m_selected_image=(int)image_index;
  }
//+------------------------------------------------------------------+
// | Returns the image selected for display in the specified group |
//+------------------------------------------------------------------+
int CElement::SelectedImage(const uint group_index=0)
  {
// --- Quit if there are no groups
   uint images_group_total=::ArraySize(m_images_group);
   if(images_group_total<1 || group_index>=images_group_total)
      return(WRONG_VALUE);
// --- Exit if there is not one image in the specified group
   uint images_total=::ArraySize(m_images_group[group_index].m_image);
   if(images_total<1)
      return(WRONG_VALUE);
// --- Return the image selected for display
   return(m_images_group[group_index].m_selected_image);
  }
//+------------------------------------------------------------------+
// | Checking for the presence of a pointer to the main element |
//+------------------------------------------------------------------+
bool CElement::CheckMainPointer(void)
  {
// --- If there is no pointer
   if(::CheckPointer(m_main)==POINTER_INVALID)
     {
      // --- Print a message to the terminal log
      ::Print(__FUNCTION__,
              " > Перед созданием элемента... \n...нужно передать указатель на главный элемент: "+
              ClassName()+"::MainPointer(CElementBase &object)");
      // --- Abort building the application GUI
      return(false);
     }
// ---Saving a pointer to the form
   m_wnd =m_main.WindowPointer();
// --- If there is no pointer to the form
   if(::CheckPointer(m_wnd)==POINTER_INVALID)
     {
      // --- Print a message to the terminal log
      ::Print(__FUNCTION__,
              " > У элемента "+ClassName()+" нет указателя на форму!...\n"+
              "...Элементы должны создаваться в порядке своей вложенности!");
      // --- Abort building the application GUI
      return(false);
     }
// --- Saving the pointer to the mouse cursor
   m_mouse =m_main.MousePointer();
   
// ---Saving properties

   //Print(__FUNCTION__,
   // " > dynamic_cast<CWindow*>(&this) != NULL: ", dynamic_cast<CWindow*>(&this) != NULL,
   // "; m_main.ClassName(): ", m_main.ClassName(),
   // "; m_wnd: ",m_wnd,
   // "; m_wnd.LastId(): ",m_wnd.LastId(),
   // "; m_main.LastId(): ",m_main.LastId());
   
   m_id       =m_wnd.LastId()+1;
   m_chart_id =m_wnd.ChartId();
   m_subwin   =m_wnd.SubwindowNumber();
   m_corner   =(ENUM_BASE_CORNER)m_wnd.Corner();
   m_anchor   =(ENUM_ANCHOR_POINT)m_wnd.Anchor();
   
// --- Send a sign of the presence of a pointer
   return(true);
  }
//+------------------------------------------------------------------+
// | Calculation of absolute X-coordinate |
//+------------------------------------------------------------------+
int CElement::CalculateX(const int x_gap)
  {
   return((AnchorRightWindowSide())? m_main.X2()-x_gap : m_main.X()+x_gap);
  }
//+------------------------------------------------------------------+
// | Calculation of absolute Y-coordinate |
//+------------------------------------------------------------------+
int CElement::CalculateY(const int y_gap)
  {
   return((AnchorBottomWindowSide())? m_main.Y2()-y_gap : m_main.Y()+y_gap);
  }
//+------------------------------------------------------------------+
// | Calculation of the relative X-coordinate from the extreme point of the form |
//+------------------------------------------------------------------+
int CElement::CalculateXGap(const int x)
  {
   return((AnchorRightWindowSide())? m_main.X2()-x : x-m_main.X());
  }
//+------------------------------------------------------------------+
// | Calculation of the relative Y-coordinate from the extreme point of the form |
//+------------------------------------------------------------------+
int CElement::CalculateYGap(const int y)
  {
   return((AnchorBottomWindowSide())? m_main.Y2()-y : y-m_main.Y());
  }
//+------------------------------------------------------------------+
// | Draws background |
//+------------------------------------------------------------------+
void CElement::DrawBackground(void)
  {
   m_canvas.Erase(::ColorToARGB(m_back_color,m_alpha));
  }
//+------------------------------------------------------------------+
// | Draws a frame |
//+------------------------------------------------------------------+
void CElement::DrawBorder(void)
  {
// --- Coordinates
   int x1=0,y1=0;
   int x2=(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XSIZE)-1;
   int y2=(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_YSIZE)-1;
// --- Draw a rectangle without fill
   m_canvas.Rectangle(x1,y1,x2,y2,::ColorToARGB(m_border_color,m_alpha));
  }
//+------------------------------------------------------------------+
// | Draws a picture |
//+------------------------------------------------------------------+
void CElement::DrawImage(void)
  {
// --- Number of groups
   uint group_total=ImagesGroupTotal();
// --- Drawing images
   for(uint g=0; g<group_total; g++)
     {
      // --- Index of selected image
      int i=SelectedImage(g);
      // ---If there are no images
      if(i==WRONG_VALUE)
         continue;
      // --- Coordinates
      int x =m_images_group[g].m_x_gap;
      int y =m_images_group[g].m_y_gap;
      // --- Dimensions
      uint height =m_images_group[g].m_image[i].Height();
      uint width  =m_images_group[g].m_image[i].Width();
      
      // --- Draw
      for(uint ly=0,p=0; ly<height; ly++)
        {
         for(uint lx=0; lx<width; lx++, p++)
           {
            // ---If there is no color, move to the next pixel
            if(m_images_group[g].m_image[i].Data(p)<1)
               continue;
            //---
            uint rx =x+lx;
            uint ry =y+ly;
            // --- Get the color of the bottom layer and the color of the specified pixel in the image
            uint background  =::ColorToARGB(m_canvas.PixelGet(rx,ry));
            uint pixel_color =m_images_group[g].m_image[i].Data(p);
            // --- Mix colors
            uint foreground=::ColorToARGB(m_clr.BlendColors(background,pixel_color));
            // --- Drawing a pixel of the layered image
            m_canvas.PixelSet(rx,ry,foreground);
           }
        }
     }
  }
//+------------------------------------------------------------------+
// | Draws text |
//+------------------------------------------------------------------+
void CElement::DrawText(void)
  {
// --- Coordinates
   int x =m_label_x_gap;
   int y =m_label_y_gap;
// --- Define the color for the text label
   color clr=clrBlack;
// --- If the element is locked
   if(m_is_locked)
      clr=m_label_color_locked;
   else
     {
      // --- If the element is in a pressed state
      if(!m_is_pressed)
         clr=(m_mouse_focus)? m_label_color_hover : m_label_color;
      else
        {
         if(m_class_name=="CButton")
            clr=m_label_color_pressed;
         else
            clr=(m_mouse_focus)? m_label_color_hover : m_label_color_pressed;
        }
     }
// --- Font properties
   m_canvas.FontSet(m_font,-m_font_size*10,FW_NORMAL);
// --- Draw text using the center alignment mode
   if(m_is_center_text)
     {
      x =m_x_size>>1;
      y =m_y_size>>1;
      m_canvas.TextOut(x,y,m_label_text,::ColorToARGB(clr),TA_CENTER|TA_VCENTER);
     }
   else
      m_canvas.TextOut(x,y,m_label_text,::ColorToARGB(clr),TA_LEFT);
  }
//+------------------------------------------------------------------+