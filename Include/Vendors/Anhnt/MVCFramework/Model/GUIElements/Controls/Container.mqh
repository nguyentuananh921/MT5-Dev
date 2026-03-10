//+------------------------------------------------------------------+
//|                                                   Container.mqh  |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                   https://www.mql5.com/en/articles/19979         |
//+------------------------------------------------------------------+

#ifndef __CONTAINER_MQH__
#define __CONTAINER_MQH__
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "..\Base\BaseEnums.mqh"
#include "Panel.mqh"
#include "ScrollBarH.mqh"
#include "ScrollBarV.mqh"
#include "ElementBase.mqh"

//+------------------------------------------------------------------+
//| Container class                                                  |
//+------------------------------------------------------------------+
class CContainer : public CPanel
  {
private:
   bool              m_visible_scrollbar_h;   // Horizontal scrollbar visibility flag
   bool              m_visible_scrollbar_v;   // Vertical scrollbar visibility flag
   int               m_init_border_size_top;    // Initial top border size
   int               m_init_border_size_bottom; // Initial bottom border size
   int               m_init_border_size_left;   // Initial left border size
   int               m_init_border_size_right;  // Initial right border size
   
//--- Returns the type of the element that sent the event
   ENUM_ELEMENT_TYPE GetEventElementType(const string name);
   
protected:
   CScrollBarH      *m_scrollbar_h;   // Pointer to horizontal scrollbar
   CScrollBarV      *m_scrollbar_v;   // Pointer to vertical scrollbar
 
//--- Handler for dragging edges and corners of the element
   virtual void      ResizeActionDragHandler(const int x, const int y);
   
public:
//--- Checks element sizes to determine if scrollbars should be shown
   void              CheckElementSizes(CElementBase *element);

protected:
//--- Calculates and returns (1) thumb size, (2) full, (3) effective track length of horizontal scrollbar
   int               ThumbSizeHorz(void);
   int               TrackLengthHorz(void) const { return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.TrackLength() : 0); }
   int               TrackEffectiveLengthHorz(void) { return(this.TrackLengthHorz()-this.ThumbSizeHorz()); }

//--- Calculates and returns (1) thumb size, (2) full, (3) effective track length of vertical scrollbar
   int               ThumbSizeVert(void);
   int               TrackLengthVert(void) const { return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.TrackLength() : 0); }
   int               TrackEffectiveLengthVert(void) { return(this.TrackLengthVert()-this.ThumbSizeVert()); }

//--- Visible content size horizontally / vertically
   int               ContentVisibleHorz(void) const { return int(this.Width()-this.BorderWidthLeft()-this.BorderWidthRight()); }
   int               ContentVisibleVert(void) const { return int(this.Height()-this.BorderWidthTop()-this.BorderWidthBottom()); }
   
//--- Full content size
   int               ContentSizeHorz(void);
   int               ContentSizeVert(void);
   
//--- Content position
   int               ContentPositionHorz(void);
   int               ContentPositionVert(void);

//--- Calculates content offset depending on thumb position
   int               CalculateContentOffsetHorz(const uint thumb_position);
   int               CalculateContentOffsetVert(const uint thumb_position);

//--- Calculates thumb offset depending on content position
   int               CalculateThumbOffsetHorz(const uint content_position);
   int               CalculateThumbOffsetVert(const uint content_position);
   
//--- Shifts content horizontally / vertically
   bool              ContentShiftHorz(const int value);
   bool              ContentShiftVert(const int value);
   
public:
//--- Return pointers to scrollbars, buttons and thumbs
   CScrollBarH      *GetScrollBarH(void) { return this.m_scrollbar_h; }
   CScrollBarV      *GetScrollBarV(void) { return this.m_scrollbar_v; }

   CButtonArrowUp   *GetScrollBarButtonUp(void) { return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.GetButtonUp()   : NULL); }
   CButtonArrowDown *GetScrollBarButtonDown(void){ return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.GetButtonDown() : NULL); }
   CButtonArrowLeft *GetScrollBarButtonLeft(void){ return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.GetButtonLeft() : NULL); }
   CButtonArrowRight*GetScrollBarButtonRight(void){ return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.GetButtonRight(): NULL); }

   CScrollBarThumbH *GetScrollBarThumbH(void){ return(this.m_scrollbar_h!=NULL ? this.m_scrollbar_h.GetThumb() : NULL); }
   CScrollBarThumbV *GetScrollBarThumbV(void){ return(this.m_scrollbar_v!=NULL ? this.m_scrollbar_v.GetThumb() : NULL); }
   
//--- Scrollbar visibility flags
   bool ScrollBarHorzIsVisible(void) const { return this.m_visible_scrollbar_h; }
   bool ScrollBarVertIsVisible(void) const { return this.m_visible_scrollbar_v; }

//--- Returns attached element (container content)
   CElementBase *GetAttachedElement(void){ return this.GetAttachedElementAt(2); }

//--- Creates and inserts (1) new or (2) existing element
   virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
   virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);
   
//--- (1) Show object on all chart periods, (2) bring object to front
   virtual void Show(const bool chart_redraw);
   virtual void BringToTop(const bool chart_redraw);
   
//--- Draw appearance
   virtual void Draw(const bool chart_redraw);

//--- Object type
   virtual int Type(void) const { return(ELEMENT_TYPE_CONTAINER); }

//--- Event handlers for cursor movement, click and mouse wheel
   virtual void MouseMoveHandler(const int id,const long lparam,const double dparam,const string sparam);
   virtual void MousePressHandler(const int id,const long lparam,const double dparam,const string sparam);
   virtual void MouseWheelHandler(const int id,const long lparam,const double dparam,const string sparam);
   
//--- Initialization
   void Init(void);
   
//--- Constructors / destructor
   CContainer(void);
   CContainer(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
   ~CContainer(void) {}
  };
  //+------------------------------------------------------------------+
//| CContainer::Initialization                                       |
//+------------------------------------------------------------------+
void CContainer::Init(void)
  {
//--- Initialize parent panel
   CPanel::Init();
   this.SetBorderWidth(0);

//--- Store initial border sizes to restore them when scrollbars hide
   this.m_init_border_size_top    = (int)this.BorderWidthTop();
   this.m_init_border_size_bottom = (int)this.BorderWidthBottom();
   this.m_init_border_size_left   = (int)this.BorderWidthLeft();
   this.m_init_border_size_right  = (int)this.BorderWidthRight();
   
//--- Create Horizontal ScrollBar
   this.m_scrollbar_h = dynamic_cast<CScrollBarH *>(CPanel::InsertNewElement(ELEMENT_TYPE_SCROLLBAR_H,"","ScrollBarH",0,this.Height()-DEF_SCROLLBAR_TH-1,this.Width()-1,DEF_SCROLLBAR_TH));
   if(m_scrollbar_h != NULL)
     {
      this.m_scrollbar_h.Hide(false);
      this.m_scrollbar_h.SetChartRedrawFlag(false);
     }

//--- Create Vertical ScrollBar
   this.m_scrollbar_v = dynamic_cast<CScrollBarV *>(CPanel::InsertNewElement(ELEMENT_TYPE_SCROLLBAR_V,"","ScrollBarV",this.Width()-DEF_SCROLLBAR_TH-1,0,DEF_SCROLLBAR_TH,this.Height()-1));
   if(m_scrollbar_v != NULL)
     {
      this.m_scrollbar_v.Hide(false);
      this.m_scrollbar_v.SetChartRedrawFlag(false);
     }

   this.m_scroll_flag = true; // Enable scrolling capability
  }

//+------------------------------------------------------------------+
//| CContainer::Check element sizes to toggle scrollbars             |
//+------------------------------------------------------------------+
void CContainer::CheckElementSizes(CElementBase *element)
  {
   if(element == NULL || !this.m_scroll_flag || this.m_scrollbar_h == NULL || this.m_scrollbar_v == NULL)
      return;
      
   ENUM_ELEMENT_TYPE type = (ENUM_ELEMENT_TYPE)element.Type();
   if(type == ELEMENT_TYPE_SCROLLBAR_H || type == ELEMENT_TYPE_SCROLLBAR_V)
      return;
      
   this.m_visible_scrollbar_h = false;
   this.m_visible_scrollbar_v = false;
   
//--- Determine if scrollbars are needed based on content vs visible area
   if(element.Width() > this.ContentVisibleHorz())
      this.m_visible_scrollbar_h = true;

   if(element.Height() > this.ContentVisibleVert())
      this.m_visible_scrollbar_v = true;

//--- Logic for Vertical Scrollbar visibility
   if(this.m_visible_scrollbar_v)
     {
      // Shrink the visible content area on the right to make room for the scrollbar
      this.SetBorderWidthRight(this.m_scrollbar_v.Width() + 1);
      this.m_scrollbar_v.SetThumbSize(this.ThumbSizeVert());
      this.m_scrollbar_v.SetVisibleInContainer(true);
      this.m_scrollbar_v.MoveX(this.Right() - DEF_SCROLLBAR_TH);
      this.m_scrollbar_v.BringToTop(false);
     }
   else
     {
      this.SetBorderWidthRight(this.m_init_border_size_right);
      this.m_scrollbar_v.Hide(false);
      this.m_scrollbar_v.SetVisibleInContainer(false);
     }

//--- Crop the child element to the new visible area boundaries
   if(this.m_visible_scrollbar_h || this.m_visible_scrollbar_v)
      element.ObjectTrim();
  }

//+------------------------------------------------------------------+
//| CContainer::Calculate vertical thumb size proportional to content|
//+------------------------------------------------------------------+
int CContainer::ThumbSizeVert(void)
  {
   CElementBase *elm = this.GetAttachedElement();
   if(elm == NULL || elm.Height() == 0 || this.TrackLengthVert() == 0)
      return 0;
   
   // Formula: (Visible Height / Total Content Height) * Track Length
   double ratio = (double)this.ContentVisibleVert() / (double)elm.Height();
   return (int)::round(::fmax(ratio * (double)this.TrackLengthVert(), DEF_THUMB_MIN_SIZE));
  }
  //+------------------------------------------------------------------+
//| Shifts content horizontally based on thumb position              |
//+------------------------------------------------------------------+
bool CContainer::ContentShiftHorz(const int value)
  {
   CElementBase *elm=this.GetAttachedElement();
   if(elm==NULL) return false;
   
   // Special case: If this is a TableView, we also need to shift the header
   CTableHeaderView *table_header=NULL;
   // ... (Logic to find table header in hierarchy) ...

   int content_offset=this.CalculateContentOffsetHorz(value);

   bool res=true;
   if(table_header!=NULL)
      res &=table_header.MoveX(this.X()-content_offset);
      
   res &=elm.MoveX(this.X()-content_offset);
   return res;
  }
//+------------------------------------------------------------------+
//| CContainer::Shifts content vertically by a specified value       |
//+------------------------------------------------------------------+
bool CContainer::ContentShiftVert(const int value)
  {
//--- Get pointer to the container's content
   CElementBase *elm=this.GetAttachedElement();
   if(elm==NULL)
      return false;
//--- Calculate the offset based on the thumb position
   int content_offset=this.CalculateContentOffsetVert(value);
//--- Return the result of shifting content by the calculated offset
   return(elm.MoveY(this.Y()-content_offset));
  }

//+------------------------------------------------------------------+
//| Returns the type of the element that sent the event              |
//+------------------------------------------------------------------+
ENUM_ELEMENT_TYPE CContainer::GetEventElementType(const string name)
  {
//--- Get names of all elements in the hierarchy (return -1 on error)
   string names[]={};
   int total = GetElementNames(name,"_",names);
   if(total==WRONG_VALUE)
      return WRONG_VALUE;
   
//--- Find the container name in the array closest to the event element's name
   int    cntr_index=-1;      // Index of container name in the hierarchy array
   string cntr_name="";       // Container name in the hierarchy array
   
//--- Loop to find the first occurrence of "CNTR" substring from the end
   for(int i=total-1;i>=0;i--)
     {
      if(::StringFind(names[i],"CNTR")==0)
        {
         cntr_name=names[i];
         cntr_index=i;
         break;
        }
     }
//--- If container name not found (index is -1), return -1
   if(cntr_index==WRONG_VALUE)
      return WRONG_VALUE;
   
//--- If the element name doesn't contain the base element's name, it's not our event - exit
   string base_name=names[cntr_index];
   if(::StringFind(this.NameFG(),base_name)==WRONG_VALUE)
      return WRONG_VALUE;

//--- Skip events that did not come from scrollbars
   string check_name=::StringSubstr(names[cntr_index+1],0,4);
   if(check_name!="SCBH" && check_name!="SCBV")
      return WRONG_VALUE;
      
//--- Get the name of the event source element and initialize the element type
   string elm_name=names[names.Size()-1];
   ENUM_ELEMENT_TYPE type=WRONG_VALUE;
   
//--- Check and set the element type
//--- Arrow up button
   if(::StringFind(elm_name,"BTARU")==0)
      type=ELEMENT_TYPE_BUTTON_ARROW_UP;
//--- Arrow down button
   else if(::StringFind(elm_name,"BTARD")==0)
      type=ELEMENT_TYPE_BUTTON_ARROW_DOWN;
//--- Arrow left button
   else if(::StringFind(elm_name,"BTARL")==0)
      type=ELEMENT_TYPE_BUTTON_ARROW_LEFT;
//--- Arrow right button
   else if(::StringFind(elm_name,"BTARR")==0)
      type=ELEMENT_TYPE_BUTTON_ARROW_RIGHT;
//--- Horizontal scrollbar thumb
   else if(::StringFind(elm_name,"THMBH")==0)
      type=ELEMENT_TYPE_SCROLLBAR_THUMB_H;
//--- Vertical scrollbar thumb
   else if(::StringFind(elm_name,"THMBV")==0)
      type=ELEMENT_TYPE_SCROLLBAR_THUMB_V;
//--- Horizontal ScrollBar control
   else if(::StringFind(elm_name,"SCBH")==0)
      type=ELEMENT_TYPE_SCROLLBAR_H;
//--- Vertical ScrollBar control
   else if(::StringFind(elm_name,"SCBV")==0)
      type=ELEMENT_TYPE_SCROLLBAR_V;
      
//--- Return the element type
   return type;
  }

//+------------------------------------------------------------------+
//| CContainer::Custom event handler for the element                 |
//| when moving the cursor within the object area                    |
//+------------------------------------------------------------------+
void CContainer::MouseMoveHandler(const int id,const long lparam,const double dparam,const string sparam)
  {
   bool res=false;
//--- Get pointer to the container's content
   CElementBase *elm=this.GetAttachedElement();
//--- Get the type of element that sent the event
   ENUM_ELEMENT_TYPE type=this.GetEventElementType(sparam);
//--- Exit if element type or content pointer couldn't be retrieved
   if(type==WRONG_VALUE || elm==NULL)
      return;
//--- If it's a horizontal scrollbar thumb event - shift content horizontally
   if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_H)
      res=this.ContentShiftHorz((int)lparam);

//--- If it's a vertical scrollbar thumb event - shift content vertically
   if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_V)
      res=this.ContentShiftVert((int)lparam);
   
//--- If content was successfully shifted - redraw the chart
   if(res)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| CContainer::Custom event handler for the element                 |
//| when clicking within the object area                             |
//+------------------------------------------------------------------+
void CContainer::MousePressHandler(const int id,const long lparam,const double dparam,const string sparam)
  {
   bool res=false;
//--- Get pointer to the container's content
   CElementBase *elm=this.GetAttachedElement();
//--- Get the type of element that sent the event
   ENUM_ELEMENT_TYPE type=this.GetEventElementType(sparam);
//--- Exit if element type or content pointer couldn't be retrieved
   if(type==WRONG_VALUE || elm==NULL)
      return;
   
//--- If it's a horizontal scrollbar button event
   if(type==ELEMENT_TYPE_BUTTON_ARROW_LEFT || type==ELEMENT_TYPE_BUTTON_ARROW_RIGHT)
     {
//--- Check horizontal scrollbar pointer
      if(this.m_scrollbar_h==NULL)
         return;
//--- Get pointer to the scrollbar thumb
      CScrollBarThumbH *obj=this.m_scrollbar_h.GetThumb();
      if(obj==NULL)
         return;
//--- Determine thumb displacement direction based on the pressed button type
      int direction=(type==ELEMENT_TYPE_BUTTON_ARROW_LEFT ? 120 : -120);
//--- Call the thumb object's wheel event handler to move it in the specified direction
      obj.OnWheelEvent(id,0,direction,this.NameFG());
//--- Success
      res=true;
     }
   
//--- If it's a vertical scrollbar button event
   if(type==ELEMENT_TYPE_BUTTON_ARROW_UP || type==ELEMENT_TYPE_BUTTON_ARROW_DOWN)
     {
//--- Check vertical scrollbar pointer
      if(this.m_scrollbar_v==NULL)
         return;
//--- Get pointer to the scrollbar thumb
      CScrollBarThumbV *obj=this.m_scrollbar_v.GetThumb();
      if(obj==NULL)
         return;
//--- Determine thumb displacement direction based on the pressed button type
      int direction=(type==ELEMENT_TYPE_BUTTON_ARROW_UP ? 120 : -120);
//--- Call the thumb object's wheel event handler to move it in the specified direction
      obj.OnWheelEvent(id,0,direction,this.NameFG());
//--- Success
      res=true;
     }

//--- If it's a horizontal scrollbar click event (between thumb and scroll buttons)
   if(type==ELEMENT_TYPE_SCROLLBAR_H)
     {
//--- Check horizontal scrollbar pointer
      if(this.m_scrollbar_h==NULL)
         return;
//--- Get pointer to the scrollbar thumb
      CScrollBarThumbH *thumb=this.m_scrollbar_h.GetThumb();
      if(thumb==NULL)
         return;
//--- Determine thumb displacement direction
      int direction=(lparam>=thumb.Right() ? 1 : lparam<=thumb.X() ? -1 : 0);

//--- Check for division by zero
      if(this.ContentSizeHorz()-this.ContentVisibleHorz()==0)
         return;     
      
//--- Calculate thumb shift proportional to shifting content by one screen
      int thumb_shift=(int)::round(direction * ((double)this.ContentVisibleHorz() / double(this.ContentSizeHorz()-this.ContentVisibleHorz())) * (double)this.TrackEffectiveLengthHorz());
//--- Call the thumb object's wheel event handler to move it in the calculated direction
      thumb.OnWheelEvent(id,thumb_shift,0,this.NameFG());
//--- Record the container content displacement result
      res=this.ContentShiftHorz(thumb_shift);
     }
   
//--- If it's a vertical scrollbar click event (between thumb and scroll buttons)
   if(type==ELEMENT_TYPE_SCROLLBAR_V)
     {
//--- Check vertical scrollbar pointer
      if(this.m_scrollbar_v==NULL)
         return;
//--- Get pointer to the scrollbar thumb
      CScrollBarThumbV *thumb=this.m_scrollbar_v.GetThumb();
      if(thumb==NULL)
         return;
//--- Determine thumb displacement direction
      int cursor=int(dparam-this.m_wnd_y);
      int direction=(cursor>=thumb.Bottom() ? 1 : cursor<=thumb.Y() ? -1 : 0);

//--- Check for division by zero
      if(this.ContentSizeVert()-this.ContentVisibleVert()==0)
         return;     
      
//--- Calculate thumb shift proportional to shifting content by one screen
      int thumb_shift=(int)::round(direction * ((double)this.ContentVisibleVert() / double(this.ContentSizeVert()-this.ContentVisibleVert())) * (double)this.TrackEffectiveLengthVert());
//--- Call the thumb object's wheel event handler to move it in the calculated direction
      thumb.OnWheelEvent(id,thumb_shift,0,this.NameFG());
//--- Record the container content displacement result
      res=this.ContentShiftVert(thumb_shift);
     }
   
//--- If everything is successful - redraw the chart
   if(res)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| CContainer::Custom event handler for the element                 |
//| when scrolling the mouse wheel over the scrollbar thumb area     |
//+------------------------------------------------------------------+
void CContainer::MouseWheelHandler(const int id,const long lparam,const double dparam,const string sparam)
  {
   bool res=false;
//--- Get pointer to the container's content
   CElementBase *elm=this.GetAttachedElement();
//--- Get the type of element that sent the event
   ENUM_ELEMENT_TYPE type=this.GetEventElementType(sparam);
//--- Exit if content pointer or element type couldn't be retrieved
   if(type==WRONG_VALUE || elm==NULL)
      return;
   
//--- If it's a horizontal scrollbar thumb event - shift content horizontally
   if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_H)
      res=this.ContentShiftHorz((int)lparam);

//--- If it's a vertical scrollbar thumb event - shift content vertically
   if(type==ELEMENT_TYPE_SCROLLBAR_THUMB_V)
      res=this.ContentShiftVert((int)lparam);
   
//--- If content was successfully shifted - redraw the chart
   if(res)
      ::ChartRedraw(this.m_chart_id);
  }
  //+------------------------------------------------------------------+
//| CContainer::Handler for dragging element edges and corners       |
//+------------------------------------------------------------------+
void CContainer::ResizeActionDragHandler(const int x, const int y)
  {
//--- Check scrollbars validity
   if(this.m_scrollbar_h==NULL || this.m_scrollbar_v==NULL)
      return;
   
//--- Depending on the cursor interaction region
   switch(this.ResizeRegion())
     {
      //--- Resize by the right edge
      case CURSOR_REGION_RIGHT :
         //--- If the new width is successfully set
         if(this.ResizeZoneRightHandler(x,y))
           {
            //--- Check container content size to display scrollbars,
            //--- shift content based on the new horizontal scrollbar thumb position
            this.CheckElementSizes(this.GetAttachedElement());
            this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
           }
        break;
        
      //--- Resize by the bottom edge
      case CURSOR_REGION_BOTTOM :
         //--- If the new height is successfully set
         if(this.ResizeZoneBottomHandler(x,y))
           {
            //--- Check container content size to display scrollbars,
            //--- shift content based on the new vertical scrollbar thumb position
            this.CheckElementSizes(this.GetAttachedElement());
            this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
           }
        break;
        
      //--- Resize by the left edge
      case CURSOR_REGION_LEFT :
         //--- If new X-coordinate and width are successfully set
         if(this.ResizeZoneLeftHandler(x,y))
           {
            //--- Check container content size to display scrollbars,
            //--- shift content based on the new horizontal scrollbar thumb position
            this.CheckElementSizes(this.GetAttachedElement());
            this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
           }
        break;
        
      //--- Resize by the top edge
      case CURSOR_REGION_TOP :
         //--- If new Y-coordinate and height are successfully set
         if(this.ResizeZoneTopHandler(x,y))
           {
            //--- Check container content size to display scrollbars,
            //--- shift content based on the new vertical scrollbar thumb position
            this.CheckElementSizes(this.GetAttachedElement());
            this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
           }
        break;
        
      //--- Resize by the bottom-right corner
      case CURSOR_REGION_RIGHT_BOTTOM :
         //--- If new width and height are successfully set
         if(this.ResizeZoneRightBottomHandler(x,y))
           {
            //--- Check container content size to display scrollbars,
            //--- shift content based on the new scrollbar thumb positions
            this.CheckElementSizes(this.GetAttachedElement());
            this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
            this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
           }
        break;
        
      //--- Resize by the top-right corner
      case CURSOR_REGION_RIGHT_TOP :
         //--- If new Y-coordinate, width, and height are successfully set
         if(this.ResizeZoneRightTopHandler(x,y))
           {
            //--- Check container content size to display scrollbars,
            //--- shift content based on the new scrollbar thumb positions
            this.CheckElementSizes(this.GetAttachedElement());
            this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
            this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
           }
        break;
      
      //--- Resize by the bottom-left corner
      case CURSOR_REGION_LEFT_BOTTOM :
         //--- If new X-coordinate, width, and height are successfully set
         if(this.ResizeZoneLeftBottomHandler(x,y))
           {
            //--- Check container content size to display scrollbars,
            //--- shift content based on the new scrollbar thumb positions
            this.CheckElementSizes(this.GetAttachedElement());
            this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
            this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
           }
        break;
      
      //--- Resize by the top-left corner
      case CURSOR_REGION_LEFT_TOP :
         //--- If new X and Y coordinates, width, and height are successfully set
         if(this.ResizeZoneLeftTopHandler(x,y))
           {
            //--- Check container content size to display scrollbars,
            //--- shift content based on the new scrollbar thumb positions
            this.CheckElementSizes(this.GetAttachedElement());
            this.ContentShiftHorz(this.m_scrollbar_h.ThumbPosition());
            this.ContentShiftVert(this.m_scrollbar_v.ThumbPosition());
           }
        break;
      
      //--- Default case - exit
      default: return;
     }
//--- Redraw the chart
   ::ChartRedraw(this.m_chart_id);
  }

#endif //__CONTAINER_MQH__