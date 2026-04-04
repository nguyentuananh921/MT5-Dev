//+------------------------------------------------------------------+
//|                                                  Container.mqh   |
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

#ifndef __SCROLLBARV_MQH__
#define __SCROLLBARV_MQH__
       //+------------------------------------------------------------------+
   // | Class Container |
   //+------------------------------------------------------------------+
   class CContainer : public CPanel
   {
      private:
         bool              m_visible_scrollbar_h;                    // Horizontal scrollbar visibility flag
         bool              m_visible_scrollbar_v;                    // Vertical scrollbar visibility flag
         int               m_init_border_size_top;                   // Initial frame size at top
         int               m_init_border_size_bottom;                // Initial frame size below
         int               m_init_border_size_left;                  // Initial frame size on the left
         int               m_init_border_size_right;                 // Initial frame size on the right
         
      // --- Returns the type of the element that sent the event
         ENUM_ELEMENT_TYPE GetEventElementType(const string name);
         
      protected:
         CScrollBarH      *m_scrollbar_h;                            // Pointer to horizontal scroll bar
         CScrollBarV      *m_scrollbar_v;                            // Pointer to vertical scroll bar
      
      // --- Handler for dragging edges and corners of an element
         virtual void      ResizeActionDragHandler(const int x, const int y);
         
      public:
      // --- Checks the dimensions of an element to display scrollbars
         void              CheckElementSizes(CElementBase *element);
      protected:
      // --- Calculates and returns the size of (1) the slider, (2) full, (3) the working size of the horizontal scrollbar track
         int               ThumbSizeHorz(void);
         int               TrackLengthHorz(void)               const { return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.TrackLength() : 0);       }
         int               TrackEffectiveLengthHorz(void)            { return(this.TrackLengthHorz()-this.ThumbSizeHorz());                           }
      // --- Calculates and returns the size of the (1) slider, (2) full, (3) working size of the vertical scrollbar track
         int               ThumbSizeVert(void);
         int               TrackLengthVert(void)               const { return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.TrackLength() : 0);       }
         int               TrackEffectiveLengthVert(void)            { return(this.TrackLengthVert()-this.ThumbSizeVert());                           }
      // --- Size of visible content area (1) horizontally, (2) vertically
         int               ContentVisibleHorz(void)            const { return int(this.Width()-this.BorderWidthLeft()-this.BorderWidthRight());       }
         int               ContentVisibleVert(void)            const { return int(this.Height()-this.BorderWidthTop()-this.BorderWidthBottom());      }
         
      // --- Full content size in (1) horizontal, (2) vertical
         int               ContentSizeHorz(void);
         int               ContentSizeVert(void);
         
      // --- Position of content along (1) horizontal, (2) vertical
         int               ContentPositionHorz(void);
         int               ContentPositionVert(void);
      // --- Calculates and returns the amount of content offset (1) horizontally, (2) vertically depending on the position of the slider
         int               CalculateContentOffsetHorz(const uint thumb_position);
         int               CalculateContentOffsetVert(const uint thumb_position);
      // --- Calculates and returns the amount of slider displacement along (1) horizontal, (2) vertical depending on the position of the content
         int               CalculateThumbOffsetHorz(const uint content_position);
         int               CalculateThumbOffsetVert(const uint content_position);
         
      // --- Shifts content (1) horizontally, (2) vertically by the specified amount
         bool              ContentShiftHorz(const int value);
         bool              ContentShiftVert(const int value);
         
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
         
      // --- Returns the visibility flag of (1) horizontal, (2) vertical scrollbar
         bool              ScrollBarHorzIsVisible(void)        const { return this.m_visible_scrollbar_h;                                             }
         bool              ScrollBarVertIsVisible(void)        const { return this.m_visible_scrollbar_v;                                             }

      // --- Returns the attached element (the contents of the container)
         CElementBase     *GetAttachedElement(void)                  { return this.GetAttachedElementAt(2);                                           }

      // --- Creates and adds (1) a new, (2) a previously created element to the list
         virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
         virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);
         
      // --- (1) Displays the object on all chart periods, (2) places the object in the foreground
         virtual void      Show(const bool chart_redraw);
         virtual void      BringToTop(const bool chart_redraw);
         
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
                           CContainer(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                        ~CContainer (void) {}
   };
   #ifndef CCONTAINER_IMPLEMENTATION
   #define CCONTAINER_IMPLEMENTATION
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
      // --- Remember the set width of the frame on each side
         this.m_init_border_size_top   = (int)this.BorderWidthTop();
         this.m_init_border_size_bottom= (int)this.BorderWidthBottom();
         this.m_init_border_size_left  = (int)this.BorderWidthLeft();
         this.m_init_border_size_right = (int)this.BorderWidthRight();
         
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
      // | CContainer::Displays an object on all chart periods |
      //+------------------------------------------------------------------+
      void CContainer::Show(const bool chart_redraw)
      {
      // --- If the object is already visible, or should not be displayed in the container, leave
         if(!this.m_hidden || !this.m_visible_in_container)
            return;
            
      // --- Display the panel
         CCanvasBase::Show(false);
      // --- Display attached objects
         for(int i=0;i<this.m_list_elm.Total();i++)
         {
            CElementBase *elm=this.GetAttachedElementAt(i);
            if(elm!=NULL)
            {
               if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_H && !this.m_visible_scrollbar_h)
                  continue;
               if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_V && !this.m_visible_scrollbar_v)
                  continue;
               elm.Show(false);
            }
         }
      // --- If indicated, redraw the graph
         if(chart_redraw)
            ::ChartRedraw(this.m_chart_id);
      }
      //+------------------------------------------------------------------+
      // | CContainer::Puts the object in front |
      //+------------------------------------------------------------------+
      void CContainer::BringToTop(const bool chart_redraw)
         {
         // --- Move the panel to the front
            CCanvasBase::BringToTop(false);
         // --- Place attached objects in the foreground
            for(int i=0;i<this.m_list_elm.Total();i++)
            {
               CElementBase *elm=this.GetAttachedElementAt(i);
               if(elm!=NULL)
               {
                  if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_H && !this.m_visible_scrollbar_h)
                  {
                     elm.Hide(false);
                     continue;
                  }
                  if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_V && !this.m_visible_scrollbar_v)
                  {
                     elm.Hide(false);
                     continue;
                  }
                  elm.BringToTop(false);
               }
            }
         // --- If indicated, redraw the graph
            if(chart_redraw)
               ::ChartRedraw(this.m_chart_id);
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
                  // --- Get a pointer to the horizontal scrollbar and take its background color
                  CScrollBarH *scroll_bar=this.GetScrollBarH();
                  color clr=(scroll_bar!=NULL ? scroll_bar.BackColor() : clrWhiteSmoke);
                  
                  // --- Set the coordinates at which the filled rectangle will be drawn
                  int x1=this.Width()-DEF_SCROLLBAR_TH-1;
                  int y1=this.Height()-DEF_SCROLLBAR_TH-1;
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
            CElementBase *elm=CPanel::InsertNewElement(type,text,user_name,dx,dy,w,h);
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
         // --- If an empty element is passed, or scrolling is prohibited, or scrollbars are not created, we leave
            
            if(element==NULL || !this.m_scroll_flag || this.m_scrollbar_h==NULL || this.m_scrollbar_v==NULL)
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
         // --- and container display flag
            if(element.Width()>this.ContentVisibleHorz())
            {
               this.m_visible_scrollbar_h=true;
               this.m_scrollbar_h.SetVisibleInContainer(true);
            }
         // --- If the height of the element is greater than the height of the visible area of ​​the container -
         // --- set the vertical scrollbar display flag
         // --- and container display flag
            if(element.Height()>this.ContentVisibleVert())
            {
               this.m_visible_scrollbar_v=true;
               this.m_scrollbar_v.SetVisibleInContainer(true);
            }

         // ---If both scrollbars should be displayed
            if(this.m_visible_scrollbar_h && this.m_visible_scrollbar_v)
            {
               // --- Adjust the size of both scroll bars to the thickness of the scrollbar and
               // --- set the slider sizes to the new track sizes
               if(this.m_scrollbar_v.ResizeH(this.Height()-DEF_SCROLLBAR_TH))
                  this.m_scrollbar_v.SetThumbSize(this.ThumbSizeVert());
               if(this.m_scrollbar_h.ResizeW(this.Width() -DEF_SCROLLBAR_TH))
                  this.m_scrollbar_h.SetThumbSize(this.ThumbSizeHorz());
            }
            
         // ---If the horizontal scrollbar should be shown
            if(this.m_visible_scrollbar_h)
            {
               // --- Reduce the size of the visible container window from below by the thickness of the scroll bar + 1 pixel
               this.SetBorderWidthBottom(this.m_scrollbar_h.Height()+1);
               // --- Adjust the size of the slider to the new size of the scroll bar and
               // --- move the scrollbar to the foreground, making it visible
               this.m_scrollbar_h.SetThumbSize(this.ThumbSizeHorz());
               
               int end_track=this.X()+this.m_scrollbar_h.TrackBegin()+this.m_scrollbar_h.TrackLength();
               int thumb_right=this.m_scrollbar_h.GetThumb().Right();
               if(thumb_right>=end_track)
               {
                  int pos=end_track-this.ThumbSizeHorz();
                  this.m_scrollbar_h.SetThumbPosition(pos);
               }
               
               this.m_scrollbar_h.SetVisibleInContainer(true);
               this.m_scrollbar_h.MoveY(this.Bottom()-DEF_SCROLLBAR_TH);
               this.m_scrollbar_h.BringToTop(false);
            }
            else
            {
               // --- Restore the size of the visible container window from below,
               // --- hide the horizontal scrollbar, disable its display in the container,
               // --- and set the height of the vertical scrollbar to the height of the container
               this.SetBorderWidthBottom(this.m_init_border_size_bottom);
               this.m_scrollbar_h.Hide(false);
               this.m_scrollbar_h.SetVisibleInContainer(false);
               if(this.m_scrollbar_v.ResizeH(this.Height()-1))
                  this.m_scrollbar_v.SetThumbSize(this.ThumbSizeVert());
            }
            
         // ---If the vertical scrollbar should be shown
            if(this.m_visible_scrollbar_v)
            {
               // --- Reduce the size of the visible container window on the right by the width of the scroll bar + 1 pixel
               this.SetBorderWidthRight(this.m_scrollbar_v.Width()+1);
               // --- Adjust the size of the slider to the new size of the scroll bar and
               // --- move the scrollbar to the foreground, making it visible
               this.m_scrollbar_v.SetThumbSize(this.ThumbSizeVert());
               
               int end_track=this.Y()+this.m_scrollbar_v.TrackBegin()+this.m_scrollbar_v.TrackLength();
               int thumb_bottom=this.m_scrollbar_v.GetThumb().Bottom();
               if(thumb_bottom>=end_track)
               {
                  int pos=end_track-this.ThumbSizeVert();
                  this.m_scrollbar_v.SetThumbPosition(pos);
               }
               
               this.m_scrollbar_v.SetVisibleInContainer(true);
               this.m_scrollbar_v.MoveX(this.Right()-DEF_SCROLLBAR_TH);
               this.m_scrollbar_v.BringToTop(false);
            }
            else
            {
               // --- Restore the size of the visible container window on the right,
               // --- hide the vertical scrollbar, disable its display in the container,
               // --- and set the width of the horizontal scrollbar to the width of the container
               this.SetBorderWidthRight(this.m_init_border_size_right);
               this.m_scrollbar_v.Hide(false);
               this.m_scrollbar_v.SetVisibleInContainer(false);
               if(this.m_scrollbar_h.ResizeW(this.Width()-1))
                  this.m_scrollbar_h.SetThumbSize(this.ThumbSizeHorz());
            }
         // --- If any of the scroll bars are visible, crop the anchored element to the new dimensions of the visible area
            if(this.m_visible_scrollbar_h || this.m_visible_scrollbar_v)
            {
               element.ObjectTrim();
            }
         }
      //+-------------------------------------------------------------------+
      // |CContainer::Calculates the size of the horizontal scrollbar slider|
      //+-------------------------------------------------------------------+
      int CContainer::ThumbSizeHorz(void)
         {
         CElementBase *elm=this.GetAttachedElement();
         if(elm==NULL || elm.Width()==0 || this.TrackLengthHorz()==0)
            return 0;
         return int(::round(::fmax(((double)this.ContentVisibleHorz() / (double)elm.Width()) * (double)this.TrackLengthHorz(), DEF_THUMB_MIN_SIZE)));
         }
      //+------------------------------------------------------------------+
      // | CContainer::Calculates the size of the vertical scrollbar slider|
      //+------------------------------------------------------------------+
      int CContainer::ThumbSizeVert(void)
         {
         CElementBase *elm=this.GetAttachedElement();
         if(elm==NULL || elm.Height()==0 || this.TrackLengthVert()==0)
            return 0;
         return int(::round(::fmax(((double)this.ContentVisibleVert() / (double)elm.Height()) * (double)this.TrackLengthVert(), DEF_THUMB_MIN_SIZE)));
         }
      //+------------------------------------------------------------------+
      // | CContainer::Full content horizontal size |
      //+------------------------------------------------------------------+
      int CContainer::ContentSizeHorz(void)
         {
         CElementBase *elm=this.GetAttachedElement();
         return(elm!=NULL ? elm.Width() : 0);
         }
      //+------------------------------------------------------------------+
      // | CContainer::Full content vertical size |
      //+------------------------------------------------------------------+
      int CContainer::ContentSizeVert(void)
         {
            CElementBase *elm=this.GetAttachedElement();
            return(elm!=NULL ? elm.Height() : 0);
         }
      //+--------------------------------------------------------------------+
      // |CContainer::Returns the horizontal position of the container's contents|
      //+--------------------------------------------------------------------+
      int CContainer::ContentPositionHorz(void)
         {
            CElementBase *elm=this.GetAttachedElement();
            return(elm!=NULL ? elm.X()-this.X() : 0);
         }
         //+------------------------------------------------------------------+
         // |CContainer::Returns the vertical position of the container's contents|
         //+------------------------------------------------------------------+
         int CContainer::ContentPositionVert(void)
         {
            CElementBase *elm=this.GetAttachedElement();
            return(elm!=NULL ? elm.Y()-this.Y() : 0);
         }
         //+------------------------------------------------------------------+
         // | CContainer::Calculates and returns offset value |
         // | container contents horizontally by slider position |
         //+------------------------------------------------------------------+
         int CContainer::CalculateContentOffsetHorz(const uint thumb_position)
         {
            CElementBase *elm=this.GetAttachedElement();
            int effective_track_length=this.TrackEffectiveLengthHorz();
            if(elm==NULL || effective_track_length==0)
               return 0;
            return (int)::round(((double)thumb_position / (double)effective_track_length) * ((double)elm.Width() - (double)this.ContentVisibleHorz()));
         }
         //+------------------------------------------------------------------+
         // | CContainer::Calculates and returns offset value |
         // | container contents vertically by slider position |
         //+------------------------------------------------------------------+
         int CContainer::CalculateContentOffsetVert(const uint thumb_position)
         {
            CElementBase *elm=this.GetAttachedElement();
            int effective_track_length=this.TrackEffectiveLengthVert();
            if(elm==NULL || effective_track_length==0)
               return 0;
            return (int)::round(((double)thumb_position / (double)effective_track_length) * ((double)elm.Height() - (double)this.ContentVisibleVert()));
         }
      //+------------------------------------------------------------------+
      // | CContainer::Calculates and returns the slider offset value |
      // | horizontally depending on the position of the content |
      //+------------------------------------------------------------------+
      int CContainer::CalculateThumbOffsetHorz(const uint content_position)
         {
            CElementBase *elm=this.GetAttachedElement();
            if(elm==NULL)
               return 0;
            int value=elm.Width()-this.ContentVisibleHorz();
            if(value==0)
               return 0;
            return (int)::round(((double)content_position / (double)value) * ((double)this.TrackEffectiveLengthHorz() - (double)this.ThumbSizeHorz()));
         }
         //+------------------------------------------------------------------+
         // | CContainer::Calculates and returns the slider offset value |
         // | vertically depending on the position of the content |
         //+------------------------------------------------------------------+
         int CContainer::CalculateThumbOffsetVert(const uint content_position)
         {
            CElementBase *elm=this.GetAttachedElement();
            if(elm==NULL)
               return 0;
            int value=elm.Height()-this.ContentVisibleVert();
            if(value==0)
               return 0;
            return (int)::round(((double)content_position / (double)value) * ((double)this.TrackEffectiveLengthVert() - (double)this.ThumbSizeVert()));
         }
      //+-------------------------------------------------------------------+
      // |CContainer::Shifts content horizontally by the specified amount|
      //+-------------------------------------------------------------------+
      bool CContainer::ContentShiftHorz(const int value)
         {
         // --- Get a pointer to the contents of the container
            CElementBase *elm=this.GetAttachedElement();
            if(elm==NULL)
               return false;
            
         // --- Calculate the offset value based on the position of the slider
            int content_offset=this.CalculateContentOffsetHorz(value);
            
         // --- For the CTableView element we get the table title
            bool res=true;
            CElementBase     *elm_container=elm.GetContainer();
            CTableHeaderView *table_header=NULL;
            if(elm_container!=NULL && ::StringFind(elm.Name(),"Table")==0)
            {
               CElementBase *obj=elm_container.GetContainer();
               if(obj!=NULL && obj.Type()==ELEMENT_TYPE_TABLE_VIEW)
               {
                  CTableView *table_view=obj;
                  table_header=table_view.GetHeader();
                  // --- Move the title
                  if(table_header!=NULL)
                     res &=table_header.MoveX(this.X()-content_offset);
               }
            }

         // --- Return the result of shifting the content by the calculated amount
            res &=elm.MoveX(this.X()-content_offset);
            return res;
         }
      //+------------------------------------------------------------------+
      // | CContainer::Shifts the content vertically by the specified value|
      //+------------------------------------------------------------------+
      bool CContainer::ContentShiftVert(const int value)
         {
         // --- Get a pointer to the contents of the container
            CElementBase *elm=this.GetAttachedElement();
            if(elm==NULL)
               return false;
            
         // --- Calculate the offset value based on the position of the slider
            int content_offset=this.CalculateContentOffsetVert(value);
            
         // --- For the CTableView element we get the vertical table header
            bool res=true;
            CElementBase         *elm_container=elm.GetContainer();
            CTableRowsHeaderView *table_header=NULL;
            if(elm_container!=NULL && ::StringFind(elm.Name(),"Table")==0)
            {
               CElementBase *obj=elm_container.GetContainer();
               if(obj!=NULL && obj.Type()==ELEMENT_TYPE_TABLE_VIEW)
               {
                  CTableView *table_view=obj;
                  table_header=table_view.GetRowsHeader();
                  // --- Move the title
                  if(table_header!=NULL)
                     res &=table_header.MoveY(this.Y()-content_offset);
               }
            }

         // --- Return the result of shifting the content by the calculated amount
            res &=elm.MoveY(this.Y()-content_offset);
            return res;
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
            
         // --- Find in the array the name of the container closest to the name of the element with the event
            int    cntr_index=-1;      // Index of the container name in the array of names in the element hierarchy
            string cntr_name="";       // The name of the container in the array of names in the hierarchy of elements
            
         // --- We are looking for the very first occurrence of the substring "CNTR" from the end in the loop
            for(int i=total-1;i>=0;i--)
            {
               if(::StringFind(names[i],"CNTR")==0)
               {
                  cntr_name=names[i];
                  cntr_index=i;
                  break;
               }
            }
         // --- If the container name is not found in the array (index is -1) - return -1
            if(cntr_index==WRONG_VALUE)
               return WRONG_VALUE;
            
         // --- If the element name does not contain a substring with the name of the base element, then this is not our event - we leave
            string base_name=names[cntr_index];
            if(::StringFind(this.NameFG(),base_name)==WRONG_VALUE)
               return WRONG_VALUE;

         // --- Events that did not come from scrollbars are skipped
            string check_name=::StringSubstr(names[cntr_index+1],0,4);
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
            CElementBase *elm=this.GetAttachedElement();
         // --- Get the type of element from which the event came
            ENUM_ELEMENT_TYPE type=this.GetEventElementType(sparam);
         // --- If we couldn’t get the element type or a pointer to the content, leave
            if(type==WRONG_VALUE || elm==NULL)
               return;
         // --- If the horizontal scrollbar slider event - shift the content horizontally
            if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_H)
               res=this.ContentShiftHorz((int)lparam);

         // --- If the vertical scrollbar slider event - shift the content vertically
            if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_V)
               res=this.ContentShiftVert((int)lparam);
            
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
            CElementBase *elm=this.GetAttachedElement();
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
               if(this.ContentSizeHorz()-this.ContentVisibleHorz()==0)
                  return;     
               
               // --- Calculate the slider offset proportional to the content offset by one screen
               int thumb_shift=(int)::round(direction * ((double)this.ContentVisibleHorz() / double(this.ContentSizeHorz()-this.ContentVisibleHorz())) * (double)this.TrackEffectiveLengthHorz());
               // --- call the scroll handler of the slider object to move the slider in the direction of the offset
               thumb.OnWheelEvent(id,thumb_shift,0,this.NameFG());
               // --- Record the result of shifting the contents of the container
               res=this.ContentShiftHorz(thumb_shift);
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
               if(this.ContentSizeVert()-this.ContentVisibleVert()==0)
                  return;     
               
               // --- Calculate the slider offset proportional to the content offset by one screen
               int thumb_shift=(int)::round(direction * ((double)this.ContentVisibleVert() / double(this.ContentSizeVert()-this.ContentVisibleVert())) * (double)this.TrackEffectiveLengthVert());
               // --- call the scroll handler of the slider object to move the slider in the direction of the offset
               thumb.OnWheelEvent(id,thumb_shift,0,this.NameFG());
               // --- Record the result of shifting the contents of the container
               res=this.ContentShiftVert(thumb_shift);
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
            CElementBase *elm=this.GetAttachedElement();
         // --- Get the type of element from which the event came
            ENUM_ELEMENT_TYPE type=this.GetEventElementType(sparam);
         // --- If we were unable to obtain a pointer to the contents or the type of the element, we leave
            if(type==WRONG_VALUE || elm==NULL)
               return;
            
         // --- If the horizontal scrollbar slider event - shift the content horizontally
            if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_H)
               res=this.ContentShiftHorz((int)lparam);

         // --- If the vertical scrollbar slider event - shift the content vertically
            if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_V)
               res=this.ContentShiftVert((int)lparam);
            
         // --- If the content is successfully shifted, we update the graph
            if(res)
               ::ChartRedraw(this.m_chart_id);
         }
      //+------------------------------------------------------------------+
      // | CContainer::Element edges and corners drag handler |
      //+------------------------------------------------------------------+
      void CContainer::ResizeActionDragHandler(const int x, const int y)
         {
         // --- Checking the validity of the scroll bars
            if(this.m_scrollbar_h==NULL || this.m_scrollbar_v==NULL)
               return;
            
         // ---Depending on the region of interaction with the cursor
            switch(this.ResizeRegion())
            {
               // --- Resizing beyond the right border
               case CURSOR_REGION_RIGHT :
                  // --- If the new width is successfully set
                  if(this.ResizeZoneRightHandler(x,y))
                  {
                     // --- check the size of the contents of the container for displaying scrollbars,
                     // --- shift the content to the new position of the horizontal scrollbar slider
                     this.CheckElementSizes(this.GetAttachedElement());
                     this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
                  }
               break;
               
               // --- Resizing beyond the bottom border
               case CURSOR_REGION_BOTTOM :
                  // --- If the new height is successfully set
                  if(this.ResizeZoneBottomHandler(x,y))
                  {
                     // --- check the size of the contents of the container for displaying scrollbars,
                     // --- shift the content to the new position of the vertical scrollbar slider
                     this.CheckElementSizes(this.GetAttachedElement());
                     this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
                  }
               break;
               
               // --- Resizing beyond the left border
               case CURSOR_REGION_LEFT :
                  // --- If the new X coordinate and width are successfully set
                  if(this.ResizeZoneLeftHandler(x,y))
                  {
                     // --- check the size of the contents of the container for displaying scrollbars,
                     // --- shift the content to the new position of the horizontal scrollbar slider
                     this.CheckElementSizes(this.GetAttachedElement());
                     this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
                  }
               break;
               
               // --- Resizing beyond the top border
               case CURSOR_REGION_TOP :
                  // --- If the new Y coordinate and height are successfully set
                  if(this.ResizeZoneTopHandler(x,y))
                  {
                     // --- check the size of the contents of the container for displaying scrollbars,
                     // --- shift the content to the new position of the vertical scrollbar slider
                     this.CheckElementSizes(this.GetAttachedElement());
                     this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
                  }
               break;
               
               // --- Resizing by the lower right corner
               case CURSOR_REGION_RIGHT_BOTTOM :
                  // --- If the new width and height are successfully set
                  if(this.ResizeZoneRightBottomHandler(x,y))
                  {
                     // --- check the size of the contents of the container for displaying scrollbars,
                     // --- shift the content to new positions of the scrollbar sliders
                     this.CheckElementSizes(this.GetAttachedElement());
                     this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
                     this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
                  }
               break;
               
               // --- Resizing by the upper right corner
               case CURSOR_REGION_RIGHT_TOP :
                  // ---If the new Y coordinate, width and height are successfully set
                  if(this.ResizeZoneRightTopHandler(x,y))
                  {
                     // --- check the size of the contents of the container for displaying scrollbars,
                     // --- shift the content to new positions of the scrollbar sliders
                     this.CheckElementSizes(this.GetAttachedElement());
                     this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
                     this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
                  }
               break;
               
               // --- Resizing by the lower left corner
               case CURSOR_REGION_LEFT_BOTTOM :
                  // ---If the new X coordinate, width and height are successfully set
                  if(this.ResizeZoneLeftBottomHandler(x,y))
                  {
                     // --- check the size of the contents of the container for displaying scrollbars,
                     // --- shift the content to new positions of the scrollbar sliders
                     this.CheckElementSizes(this.GetAttachedElement());
                     this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
                     this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
                  }
               break;
               
               // --- Resizing by the upper left corner
               case CURSOR_REGION_LEFT_TOP :
                  // --- If the new X and Y coordinates, width and height are set successfully
                  if(this.ResizeZoneLeftTopHandler(x,y)) {}
                  {
                     // --- check the size of the contents of the container for displaying scrollbars,
                     // --- shift the content to new positions of the scrollbar sliders
                     this.CheckElementSizes(this.GetAttachedElement());
                     this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
                     this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
                  }
               break;
               
               // --- By default - leave
               default: return;
            }
            ::ChartRedraw(this.m_chart_id);
         }
      //+------------------------------------------------------------------+
   #endif // CCONTAINER_IMPLEMENTATION
#endif // __SCROLLBARV_MQH__


