//+------------------------------------------------------------------+
//|                                                  ElementBase.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+
//| Base class of graphical element                                  |
//+------------------------------------------------------------------+
#ifndef __ELEMENTBASE_MQH__
#define __ELEMENTBASE_MQH__
class CListElm;
class CCommonManager;
//--- Standard
#include <Object.mqh>

//--- Base
#include "../Base/CanvasBase.mqh"
#include "../Base/BaseEnums.mqh"
#include "../Base/BaseDefines.mqh"

//--- Elements
#include "ImagePainter.mqh"
#include "ListElm.mqh"
#include "VisualHint.mqh"

class CElementBase : public CCanvasBase
  {
protected:
   CImagePainter     m_painter;                                // Drawing class
   CListElm          m_list_hints;                             // Hint list
   int               m_group;                                  // Element group
   bool              m_visible_in_container;                   // Visibility flag inside container

//--- Adds the specified hint object to the list
   bool              AddHintToList(CVisualHint *obj);
//--- Creates and adds a new hint object to the list
   CVisualHint      *CreateAndAddNewHint(const ENUM_HINT_TYPE type, const string user_name, const int w, const int h);
//--- Adds an existing hint object to the list
   CVisualHint      *AddHint(CVisualHint *obj, const int dx, const int dy);
//--- (1) Adds arrow hints to the list, (2) removes arrow hint objects from the list
   virtual bool      AddHintsArrowed(void);
   bool              DeleteHintsArrowed(void);
//--- Displays resize cursor hint
   virtual bool      ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y);

//--- Handler for dragging edges and corners of the element
   virtual void      ResizeActionDragHandler(const int x, const int y);

//--- Resize handlers for element edges and corners
   virtual bool      ResizeZoneLeftHandler(const int x, const int y);
   virtual bool      ResizeZoneRightHandler(const int x, const int y);
   virtual bool      ResizeZoneTopHandler(const int x, const int y);
   virtual bool      ResizeZoneBottomHandler(const int x, const int y);
   virtual bool      ResizeZoneLeftTopHandler(const int x, const int y);
   virtual bool      ResizeZoneRightTopHandler(const int x, const int y);
   virtual bool      ResizeZoneLeftBottomHandler(const int x, const int y);
   virtual bool      ResizeZoneRightBottomHandler(const int x, const int y);

//--- Returns pointer to hint by (1) index, (2) ID, (3) name
   CVisualHint      *GetHintAt(const int index);
   CVisualHint      *GetHint(const int id);
   CVisualHint      *GetHint(const string name);

//--- Creates a new hint
   CVisualHint      *CreateNewHint(const ENUM_HINT_TYPE type, const string object_name, const string user_name, const int id, const int x, const int y, const int w, const int h);
//--- (1) Displays specified arrow hint, (2) hides all hints
   void              ShowHintArrowed(const ENUM_HINT_TYPE type,const int x,const int y);
   void              HideHintsAll(const bool chart_redraw);

public:
//--- Returns itself
   CElementBase     *GetObject(void)                           { return &this;                     }
//--- Returns pointer to (1) drawing class, (2) hint list
   CImagePainter    *Painter(void)                             { return &this.m_painter;           }
   CListElm         *GetListHints(void)                        { return &this.m_list_hints;        }

//--- Creates and adds (1) new, (2) existing tooltip object to list
   CVisualHint      *InsertNewTooltip(const ENUM_HINT_TYPE type, const string user_name, const int w, const int h);
   CVisualHint      *InsertTooltip(CVisualHint *obj, const int dx, const int dy);

//--- (1) Set coordinates, (2) change image area size
   void              SetImageXY(const int x,const int y)       { this.m_painter.SetXY(x,y);        }
   void              SetImageSize(const int w,const int h)     { this.m_painter.SetSize(w,h);      }

//--- Set image area coordinates and size
   void              SetImageBound(const int x,const int y,const int w,const int h)
                       {
                        this.SetImageXY(x,y);
                        this.SetImageSize(w,h);
                       }

//--- Return (1) X, (2) Y, (3) width, (4) height, (5) right, (6) bottom of image area
   int               ImageX(void)                        const { return this.m_painter.X();        }
   int               ImageY(void)                        const { return this.m_painter.Y();        }
   int               ImageWidth(void)                    const { return this.m_painter.Width();    }
   int               ImageHeight(void)                   const { return this.m_painter.Height();   }
   int               ImageRight(void)                    const { return this.m_painter.Right();    }
   int               ImageBottom(void)                   const { return this.m_painter.Bottom();   }

//--- (1) Set, (2) get element group
   virtual void      SetGroup(const int group)                 { this.m_group=group;               }
   int               Group(void)                         const { return this.m_group;              }

//--- Set resizable flag
   virtual void      SetResizable(const bool flag);

//--- (1) Set, (2) get visibility flag inside container
   virtual void      SetVisibleInContainer(const bool flag)    { this.m_visible_in_container=flag; }
   bool              IsVisibleInContainer(void)          const { return this.m_visible_in_container;}

//--- Return object description
   virtual string    Description(void);

//--- Resize event handler
   virtual void      OnResizeZoneEvent(const int id, const long lparam, const double dparam, const string sparam);

//--- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_ELEMENT_BASE);}

//--- Constructors / destructor
                     CElementBase(void) { this.m_painter.CanvasAssign(this.GetForeground()); this.m_visible_in_container=true; }
                     CElementBase(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CElementBase(void) { this.m_list_hints.Clear(); }
  };

//+-----------------------------------------------------------------------+
//| CElementBase parameterized constructor. Creates an element in the     |
//| specified chart window with specified text, coordinates and size      |
//+-----------------------------------------------------------------------+
CElementBase::CElementBase(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CCanvasBase(object_name,chart_id,wnd,x,y,w,h),m_group(-1)
  {
//--- Assign foreground canvas to drawing object
//--- Reset coordinates and size to make it inactive
//--- Set visibility flag inside container
   this.m_painter.CanvasAssign(this.GetForeground());
   this.m_painter.SetXY(0,0);
   this.m_painter.SetSize(0,0);
   this.m_visible_in_container=true;
  }

//+------------------------------------------------------------------+
//| CElementBase::Compare two objects                                |
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
//| Return object description                                        |
//+------------------------------------------------------------------+
string CElementBase::Description(void)
  {
   string nm=this.Name();
   string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   string area=::StringFormat("x %d, y %d, w %d, h %d, right %d, bottom %d",this.X(),this.Y(),this.Width(),this.Height(),this.Right(),this.Bottom());

   return ::StringFormat("%s%s (%s, %s): ID %d, Group %d, %s",
                         ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),
                         name,this.NameBG(),this.NameFG(),
                         this.ID(),this.Group(),area);
  }

//+------------------------------------------------------------------+
//| Set resizable flag                                               |
//+------------------------------------------------------------------+
void CElementBase::SetResizable(const bool flag)
  {
//--- Store flag in parent class
   CCanvasBase::SetResizable(flag);

//--- If true → create arrow hints for cursor
   if(flag)
      this.AddHintsArrowed();
//--- Otherwise remove them
   else
      this.DeleteHintsArrowed();
  }

//+------------------------------------------------------------------+
//| Return hint pointer by index                                     |
//+------------------------------------------------------------------+
CVisualHint *CElementBase::GetHintAt(const int index)
  {
   return this.m_list_hints.GetNodeAtIndex(index);
  }

//+------------------------------------------------------------------+
//| Return hint pointer by ID                                        |
//+------------------------------------------------------------------+
CVisualHint *CElementBase::GetHint(const int id)
  {
   int total=this.m_list_hints.Total();

   for(int i=0;i<total;i++)
     {
      CVisualHint *obj=this.GetHintAt(i);

      if(obj!=NULL && obj.ID()==id)
         return obj;
     }

   return NULL;
  }

//+------------------------------------------------------------------+
//| Return hint pointer by name                                      |
//+------------------------------------------------------------------+
CVisualHint *CElementBase::GetHint(const string name)
  {
   int total=this.m_list_hints.Total();

   for(int i=0;i<total;i++)
     {
      CVisualHint *obj=this.GetHintAt(i);

      if(obj!=NULL && obj.Name()==name)
         return obj;
     }

   return NULL;
  }
//+------------------------------------------------------------------+
//| CElementBase::Adds the specified hint object to the list         |
//+------------------------------------------------------------------+
bool CElementBase::AddHintToList(CVisualHint *obj)
  {
//--- If a null pointer is passed, report it and return false
   if(obj==NULL)
     {
      ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
      return false;
     }
//--- Remember the current list sorting mode
   int sort_mode=this.m_list_hints.SortMode();
//--- Set the sorting flag by ID for the list
   this.m_list_hints.Sort(ELEMENT_SORT_BY_ID);
//--- If the element is not already in the list
   if(this.m_list_hints.Search(obj)==NULL)
     {
      //--- Restore the original sorting and return the result of adding to the list
      this.m_list_hints.Sort(sort_mode);
      return(this.m_list_hints.Add(obj)>-1);
     }
//--- Restore the original sorting mode
   this.m_list_hints.Sort(sort_mode);
//--- Element with this ID already exists - return false
   return false;
  }
//+------------------------------------------------------------------+
//| CElementBase::Creates a new hint                                 |
//+------------------------------------------------------------------+
CVisualHint *CElementBase::CreateNewHint(const ENUM_HINT_TYPE type,const string object_name,const string user_name,const int id, const int x,const int y,const int w,const int h)
  {
//--- Create a new hint object
   CVisualHint *obj=new CVisualHint(object_name,this.m_chart_id,this.m_wnd,x,y,w,h);
   if(obj==NULL)
     {
      ::PrintFormat("%s: Error: Failed to create Hint object",__FUNCTION__);
      return NULL;
     }
//--- Set identifier, name, and hint type
   obj.SetID(id);
   obj.SetName(user_name);
   obj.SetHintType(type);
   
//--- Return the pointer to the created object
   return obj;
  }
//+------------------------------------------------------------------+
//| CElementBase::Creates and adds a new hint object to the list     |
//+------------------------------------------------------------------+
CVisualHint *CElementBase::CreateAndAddNewHint(const ENUM_HINT_TYPE type,const string user_name,const int w,const int h)
  {
//--- Generate the graphic object name
   int obj_total=this.m_list_hints.Total();
   string obj_name=this.NameFG()+"_HNT"+(string)obj_total;
   
//--- Calculate coordinates below and to the right of the element's bottom-right corner
   int x=this.Right()+1;
   int y=this.Bottom()+1;
   
//--- Create a new hint object
   CVisualHint *obj=this.CreateNewHint(type,obj_name,user_name,obj_total,x,y,w,h);
   
//--- If the object was not created, return NULL
   if(obj==NULL)
      return NULL;

//--- Set image boundaries, container, and z-order
   obj.SetImageBound(0,0,this.Width(),this.Height());
   obj.SetContainerObj(&this);
   obj.ObjectSetZOrder(this.ObjectZOrder()+1);

//--- If the created element cannot be added to the list, report it, delete the object, and return NULL
   if(!this.AddHintToList(obj))
     {
      ::PrintFormat("%s: Error. Failed to add Hint object with ID %d to list",__FUNCTION__,obj.ID());
      delete obj;
      return NULL;
     }
     
//--- Return the pointer to the created and attached object
   return obj;
  }
//+------------------------------------------------------------------+
//| CElementBase::Adds an existing hint object to the list           |
//+------------------------------------------------------------------+
CVisualHint *CElementBase::AddHint(CVisualHint *obj,const int dx,const int dy)
  {
//--- If the passed object is not a Hint type, return NULL
   if(obj.Type()!=ELEMENT_TYPE_HINT)
     {
      ::PrintFormat("%s: Error. Only an object with the Hint type can be used here. The element type \"%s\" was passed",__FUNCTION__,ElementDescription((ENUM_ELEMENT_TYPE)obj.Type()));
      return NULL;
     }
//--- Remember the object ID and set a new one based on list count
   int id=obj.ID();
   obj.SetID(this.m_list_hints.Total());
   
//--- Add the object to the list; if it fails, restore the initial ID and return NULL
   if(!this.AddHintToList(obj))
     {
      ::PrintFormat("%s: Error. Failed to add Hint object to list",__FUNCTION__);
      obj.SetID(id);
      return NULL;
     }
//--- Set new coordinates, container, and z-order for the object
   int x=this.X()+dx;
   int y=this.Y()+dy;
   obj.Move(x,y);
   obj.SetContainerObj(&this);
   obj.ObjectSetZOrder(this.ObjectZOrder()+1);
     
//--- Return the pointer to the attached object
   return obj;
  }
//+------------------------------------------------------------------+
//| CElementBase::Adds arrow-style hint objects to the list          |
//+------------------------------------------------------------------+
bool CElementBase::AddHintsArrowed(void)
  {
//--- Arrays for hint names and types
   string array[4]={DEF_HINT_NAME_HORZ,DEF_HINT_NAME_VERT,DEF_HINT_NAME_NWSE,DEF_HINT_NAME_NESW};
   
   ENUM_HINT_TYPE type[4]={HINT_TYPE_ARROW_HORZ,HINT_TYPE_ARROW_VERT,HINT_TYPE_ARROW_NWSE,HINT_TYPE_ARROW_NESW};
   
//--- Create four arrow hints in a loop
   bool res=true;
   for(int i=0;i<(int)array.Size();i++)
      res &=(this.CreateAndAddNewHint(type[i],array[i],0,0)!=NULL);
      
//--- If creation errors occurred, return false
   if(!res)
      return false;
      
//--- Iterate through the hint names array
   for(int i=0;i<(int)array.Size();i++)
     {
      //--- Get each object by name
      CVisualHint *obj=this.GetHint(array[i]);
      if(obj==NULL)
         continue;
      //--- Hide the object and draw its appearance (arrows corresponding to the type)
      obj.Hide(false);
      obj.Draw(false);
     }
//--- Success
   return true;
  }
//+------------------------------------------------------------------+
//| CElementBase::Deletes arrow-style hint objects from the list     |
//+------------------------------------------------------------------+
bool CElementBase::DeleteHintsArrowed(void)
  {
//--- Iterate backwards through the hint list
   bool res=true;
   for(int i=this.m_list_hints.Total()-1;i>=0;i--)
     {
      //--- Get the current object; if it's not a tooltip, delete it
      CVisualHint *obj=this.m_list_hints.GetNodeAtIndex(i);
      if(obj!=NULL && obj.HintType()!=HINT_TYPE_TOOLTIP)
         res &=this.m_list_hints.DeleteCurrent();
     }
//--- Return the result of removing arrow hints
   return res;
  }
//+------------------------------------------------------------------+
//| CElementBase::Creates and adds a new tooltip object to the list  |
//+------------------------------------------------------------------+
CVisualHint *CElementBase::InsertNewTooltip(const ENUM_HINT_TYPE type,const string user_name,const int w,const int h)
  {
//--- If the hint type is not a tooltip, report it and return NULL
   if(type!=HINT_TYPE_TOOLTIP)
     {
      ::PrintFormat("%s: Error. Only a tooltip can be added to an element",__FUNCTION__);
      return NULL;
     }
//--- Create and add a new hint object to the list; return the pointer
   return this.CreateAndAddNewHint(type,user_name,w,h);
  }
//+------------------------------------------------------------------+
//| CElementBase::Adds a previously created tooltip to the list      |
//+------------------------------------------------------------------+
CVisualHint *CElementBase::InsertTooltip(CVisualHint *obj,const int dx,const int dy)
  {
//--- Check if the pointer is valid
   if(::CheckPointer(obj)==POINTER_INVALID)
     {
      ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
      return NULL;
     }
//--- Ensure the hint type is HINT_TYPE_TOOLTIP
   if(obj.HintType()!=HINT_TYPE_TOOLTIP)
     {
      ::PrintFormat("%s: Error. Only a tooltip can be added to an element",__FUNCTION__);
      return NULL;
     }
//--- Add the object and return the pointer
   return this.AddHint(obj,dx,dy);
  }
//+------------------------------------------------------------------+
//| CElementBase::Displays the specified hint at given coordinates   |
//+------------------------------------------------------------------+
void CElementBase::ShowHintArrowed(const ENUM_HINT_TYPE type,const int x,const int y)
  {
   CVisualHint *hint=NULL; // Pointer to the target object
//--- Iterate through the hint list
   for(int i=0;i<this.m_list_hints.Total();i++)
     {
      //--- Get pointer to current object
      CVisualHint *obj=this.GetHintAt(i);
      if(obj==NULL)
         continue;
      //--- If it matches the requested type, store the pointer
      if(obj.HintType()==type)
         hint=obj;
      //--- Otherwise, hide the object
      else
         obj.Hide(false);
     }
//--- If the target hint is found and is currently hidden
   if(hint!=NULL && hint.IsHidden())
     {
      //--- Position the object, draw it, and bring to top making it visible
      hint.Move(x,y);
      hint.Draw(false);
      hint.BringToTop(true);
     }
  }
//+------------------------------------------------------------------+
//| CElementBase::Hides all hints                                    |
//+------------------------------------------------------------------+
void CElementBase::HideHintsAll(const bool chart_redraw)
  {
//--- Iterate and hide every object in the hint list
   for(int i=0;i<this.m_list_hints.Total();i++)
     {
      CVisualHint *obj=this.GetHintAt(i);
      if(obj!=NULL)
         obj.Hide(false);
     }
//--- Redraw chart if requested
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CElementBase::Displays the resizing cursor hint                  |
//+------------------------------------------------------------------+
bool CElementBase::ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y)
  {
   CVisualHint *hint=NULL;          // Pointer to the hint
   int hint_shift_x=0;              // Hint X offset
   int hint_shift_y=0;              // Hint Y offset
   
//--- Set offsets based on cursor position relative to element boundaries
   switch(edge)
     {
      //--- Cursor on right or left boundary - horizontal double arrow
      case CURSOR_REGION_RIGHT         :
      case CURSOR_REGION_LEFT          :
         hint_shift_x=1;
         hint_shift_y=18;
         this.ShowHintArrowed(HINT_TYPE_ARROW_HORZ,x+hint_shift_x,y+hint_shift_y);
         hint=this.GetHint(DEF_HINT_NAME_HORZ);
        break;
    
      //--- Cursor on top or bottom boundary - vertical double arrow
      case CURSOR_REGION_TOP           :
      case CURSOR_REGION_BOTTOM        :
         hint_shift_x=12;
         hint_shift_y=4;
         this.ShowHintArrowed(HINT_TYPE_ARROW_VERT,x+hint_shift_x,y+hint_shift_y);
         hint=this.GetHint(DEF_HINT_NAME_VERT);
        break;
    
      //--- Cursor at Top-Left or Bottom-Right corner - diagonal arrow (NW to SE)
      case CURSOR_REGION_LEFT_TOP      :
      case CURSOR_REGION_RIGHT_BOTTOM  :
         hint_shift_x=10;
         hint_shift_y=2;
         this.ShowHintArrowed(HINT_TYPE_ARROW_NWSE,x+hint_shift_x,y+hint_shift_y);
         hint=this.GetHint(DEF_HINT_NAME_NWSE);
        break;
    
      //--- Cursor at Bottom-Left or Top-Right corner - diagonal arrow (SW to NE)
      case CURSOR_REGION_LEFT_BOTTOM   :
      case CURSOR_REGION_RIGHT_TOP     :
         hint_shift_x=5;
         hint_shift_y=12;
         this.ShowHintArrowed(HINT_TYPE_ARROW_NESW,x+hint_shift_x,y+hint_shift_y);
         hint=this.GetHint(DEF_HINT_NAME_NESW);
        break;
      
      default: break;
     }

//--- Return the result of adjusting hint position relative to the cursor
   return(hint!=NULL ? hint.Move(x+hint_shift_x,y+hint_shift_y) : false);
  }
//+------------------------------------------------------------------+
//| CElementBase::Resize zone event handler                          |
//+------------------------------------------------------------------+
void CElementBase::OnResizeZoneEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
   int x=(int)lparam;               // Cursor X coordinate
   int y=(int)dparam;               // Cursor Y coordinate
   
//--- Determine cursor position relative to boundaries and interaction mode
   ENUM_CURSOR_REGION edge=(this.ResizeRegion()==CURSOR_REGION_NONE ? this.CheckResizeZone(x,y) : this.ResizeRegion());
   ENUM_RESIZE_ZONE_ACTION action=(ENUM_RESIZE_ZONE_ACTION)id;
   
//--- If cursor is outside resize boundaries or just entered the interaction zone
   if(action==RESIZE_ZONE_ACTION_NONE || (action==RESIZE_ZONE_ACTION_HOVER && edge==CURSOR_REGION_NONE))
     {
      //--- Disable resizing mode and interaction region, hide all hints
      this.SetResizeMode(false);
      this.SetResizeRegion(CURSOR_REGION_NONE);
      this.HideHintsAll(true);
     }

//--- Cursor hovering over a resize boundary
   if(action==RESIZE_ZONE_ACTION_HOVER)
     {
      //--- Show the appropriate arrow hint for the interaction region
      if(this.ShowCursorHint(edge,x,y))
         ::ChartRedraw(this.m_chart_id);
     }
   
//--- Resizing start
   if(action==RESIZE_ZONE_ACTION_BEGIN)
     {
      //--- Enable resizing mode and region, display appropriate cursor hint
      this.SetResizeMode(true);
      this.SetResizeRegion(edge);
      this.ShowCursorHint(edge,x,y);
     }
   
//--- Dragging object boundary to resize the element
   if(action==RESIZE_ZONE_ACTION_DRAG)
     {
      //--- Call the drag handler and update cursor hint position
      this.ResizeActionDragHandler(x,y);
      this.ShowCursorHint(edge,x,y);
     }
  }
//+------------------------------------------------------------------+
//| CElementBase::Handler for dragging edges and corners of element  |
//+------------------------------------------------------------------+
void CElementBase::ResizeActionDragHandler(const int x, const int y)
  {
//--- Logic for individual edges and corners based on current ResizeRegion
   if(this.ResizeRegion()==CURSOR_REGION_RIGHT)
      this.ResizeZoneRightHandler(x,y);
   if(this.ResizeRegion()==CURSOR_REGION_BOTTOM)
      this.ResizeZoneBottomHandler(x,y);
   if(this.ResizeRegion()==CURSOR_REGION_LEFT)
      this.ResizeZoneLeftHandler(x,y);
   if(this.ResizeRegion()==CURSOR_REGION_TOP)
      this.ResizeZoneTopHandler(x,y);
   if(this.ResizeRegion()==CURSOR_REGION_RIGHT_BOTTOM)
      this.ResizeZoneRightBottomHandler(x,y);
   if(this.ResizeRegion()==CURSOR_REGION_RIGHT_TOP)
      this.ResizeZoneRightTopHandler(x,y);
   if(this.ResizeRegion()==CURSOR_REGION_LEFT_BOTTOM)
      this.ResizeZoneLeftBottomHandler(x,y);
   if(this.ResizeRegion()==CURSOR_REGION_LEFT_TOP)
      this.ResizeZoneLeftTopHandler(x,y);
  }
//+------------------------------------------------------------------+
//| CElementBase::Handler for resizing by the right edge             |
//+------------------------------------------------------------------+
bool CElementBase::ResizeZoneRightHandler(const int x,const int y)
  {
//--- Calculate and set new element width
   int width=::fmax(x-this.X()+1,DEF_PANEL_MIN_W);
   if(!this.ResizeW(width))
      return false;
//--- Get hint pointer and update its position
   CVisualHint *hint=this.GetHint(DEF_HINT_NAME_HORZ);
   if(hint==NULL)
      return false;
   return hint.Move(x+1,y+18);
  }
//+------------------------------------------------------------------+
//| CElementBase::Handler for resizing by the bottom edge            |
//+------------------------------------------------------------------+
bool CElementBase::ResizeZoneBottomHandler(const int x,const int y)
  {
//--- Calculate and set new element height
   int height=::fmax(y-this.Y(),DEF_PANEL_MIN_H);
   if(!this.ResizeH(height))
      return false;
//--- Get hint pointer and update its position
   CVisualHint *hint=this.GetHint(DEF_HINT_NAME_VERT);
   if(hint==NULL)
      return false;
   return hint.Move(x+12,y+4);
  }
//+------------------------------------------------------------------+
//| CElementBase::Handler for resizing by the left edge              |
//+------------------------------------------------------------------+
bool CElementBase::ResizeZoneLeftHandler(const int x,const int y)
  {
//--- Calculate new X coordinate and width
   int new_x=::fmin(x,this.Right()-DEF_PANEL_MIN_W+1);
   int width=this.Right()-new_x+1;
//--- Set new X and Width
   if(!this.MoveXYWidthResize(new_x,this.Y(),width,this.Height()))
      return false;
   CVisualHint *hint=this.GetHint(DEF_HINT_NAME_HORZ);
   if(hint==NULL)
      return false;
   return hint.Move(x+1,y+18);
  }
//+------------------------------------------------------------------+
//| CElementBase::Handler for resizing by the top edge               |
//+------------------------------------------------------------------+
bool CElementBase::ResizeZoneTopHandler(const int x,const int y)
  {
//--- Calculate new Y coordinate and height
   int new_y=::fmin(y,this.Bottom()-DEF_PANEL_MIN_H+1);
   int height=this.Bottom()-new_y+1;
//--- Set new Y and Height
   if(!this.MoveXYWidthResize(this.X(),new_y,this.Width(),height))
      return false;
   CVisualHint *hint=this.GetHint(DEF_HINT_NAME_VERT);
   if(hint==NULL)
      return false;
   return hint.Move(x+12,y+4);
  }
  //+------------------------------------------------------------------+
//| CElementBase::Handler for resizing by the bottom-right corner    |
//+------------------------------------------------------------------+
bool CElementBase::ResizeZoneRightBottomHandler(const int x,const int y)
  {
//--- Calculate and set the new width and height of the element
   int width =::fmax(x-this.X()+1, DEF_PANEL_MIN_W);
   int height=::fmax(y-this.Y()+1, DEF_PANEL_MIN_H);
   if(!this.Resize(width,height))
      return false;
//--- Get the pointer to the hint
   CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NWSE);
   if(hint==NULL)
      return false;
//--- Offset the hint by the specified values relative to the cursor
   int shift_x=10;
   int shift_y=2;
   return hint.Move(x+shift_x,y+shift_y);
  }
//+------------------------------------------------------------------+
//| CElementBase::Handler for resizing by the top-right corner       |
//+------------------------------------------------------------------+
bool CElementBase::ResizeZoneRightTopHandler(const int x,const int y)
  {
//--- Calculate and set the new Y coordinate, width, and height of the element
   int new_y=::fmin(y, this.Bottom()-DEF_PANEL_MIN_H+1);
   int width =::fmax(x-this.X()+1, DEF_PANEL_MIN_W);
   int height=this.Bottom()-new_y+1;
   if(!this.MoveXYWidthResize(this.X(),new_y,width,height))
      return false;
//--- Get the pointer to the hint
   CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NESW);
   if(hint==NULL)
      return false;
//--- Offset the hint by the specified values relative to the cursor
   int shift_x=5;
   int shift_y=12;
   return hint.Move(x+shift_x,y+shift_y);
  }
//+------------------------------------------------------------------+
//| CElementBase::Handler for resizing by the bottom-left corner     |
//+------------------------------------------------------------------+
bool CElementBase::ResizeZoneLeftBottomHandler(const int x,const int y)
  {
//--- Calculate and set the new X coordinate, width, and height of the element
   int new_x=::fmin(x, this.Right()-DEF_PANEL_MIN_W+1);
   int width =this.Right()-new_x+1;
   int height=::fmax(y-this.Y()+1, DEF_PANEL_MIN_H);
   if(!this.MoveXYWidthResize(new_x,this.Y(),width,height))
      return false;
//--- Get the pointer to the hint
   CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NESW);
   if(hint==NULL)
      return false;
//--- Offset the hint by the specified values relative to the cursor
   int shift_x=5;
   int shift_y=12;
   return hint.Move(x+shift_x,y+shift_y);
  }
//+------------------------------------------------------------------+
//| CElementBase::Handler for resizing by the top-left corner        |
//+------------------------------------------------------------------+
bool CElementBase::ResizeZoneLeftTopHandler(const int x,const int y)
  {
//--- Calculate and set the new X and Y coordinates, width, and height of the element
   int new_x=::fmin(x,this.Right()-DEF_PANEL_MIN_W+1);
   int new_y=::fmin(y,this.Bottom()-DEF_PANEL_MIN_H+1);
   int width =this.Right() -new_x+1;
   int height=this.Bottom()-new_y+1;
   if(!this.MoveXYWidthResize(new_x, new_y,width,height))
      return false;
//--- Get the pointer to the hint
   CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NWSE);
   if(hint==NULL)
      return false;
//--- Offset the hint by the specified values relative to the cursor
   int shift_x=10;
   int shift_y=2;
   return hint.Move(x+shift_x,y+shift_y);
  }
//+------------------------------------------------------------------+
//| CElementBase::Save to file                                       |
//+------------------------------------------------------------------+
bool CElementBase::Save(const int file_handle)
  {
//--- Save the parent object data
   if(!CCanvasBase::Save(file_handle))
      return false;
  
//--- Save the list of hints
   if(!this.m_list_hints.Save(file_handle))
      return false;
//--- Save the painter object
   if(!this.m_painter.Save(file_handle))
      return false;
//--- Save the group
   if(::FileWriteInteger(file_handle,this.m_group,INT_VALUE)!=INT_VALUE)
      return false;
//--- Save the visibility flag in the container
   if(::FileWriteInteger(file_handle,this.m_visible_in_container,INT_VALUE)!=INT_VALUE)
      return false;
   
//--- Everything successful 
   return true;
  }
//+------------------------------------------------------------------+
//| CElementBase::Load from file                                     |
//+------------------------------------------------------------------+
bool CElementBase::Load(const int file_handle)
  {
//--- Load the parent object data
   if(!CCanvasBase::Load(file_handle))
      return false;
      
//--- Load the list of hints
   if(!this.m_list_hints.Load(file_handle))
      return false;      
//--- Load the painter object
   if(!this.m_painter.Load(file_handle))
      return false;
//--- Load the group
   this.m_group=::FileReadInteger(file_handle,INT_VALUE);
//--- Load the visibility flag in the container
   this.m_visible_in_container=(bool)::FileReadInteger(file_handle,INT_VALUE);
   
//--- Everything successful
   return true;
  }
  //+------------------------------------------------------------------+
#endif