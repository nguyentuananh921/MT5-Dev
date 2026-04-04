//+------------------------------------------------------------------+
//|                                                ElementBase.mqh   |
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

#ifndef __ELEMENTBASE_MQH__
#define __ELEMENTBASE_MQH__
       //+------------------------------------------------------------------+
   // | Graphic element base class |
   //+------------------------------------------------------------------+
   class CElementBase : public CCanvasBase
      {
      protected:
         CImagePainter     m_painter;                                // Drawing class
         CListElm          m_list_hints;                             // List of hints
         int               m_group;                                  // Group of elements
         bool              m_visible_in_container;                   // Container visibility flag

      // --- Adds the specified tooltip object to the list
         bool              AddHintToList(CVisualHint *obj);
      // --- Creates and adds a new tooltip object to the list
         CVisualHint      *CreateAndAddNewHint(const ENUM_HINT_TYPE type, const string user_name, const int w, const int h);
      // --- Adds an existing tooltip object to the list
         CVisualHint      *AddHint(CVisualHint *obj, const int dx, const int dy);
      // --- (1) Adds to the list, (2) removes arrow tooltip objects from the list
         virtual bool      AddHintsArrowed(void);
         bool              DeleteHintsArrowed(void);
      // --- Displays resizing cursor
         virtual bool      ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y);
         
      // --- Handler for dragging edges and corners of an element
         virtual void      ResizeActionDragHandler(const int x, const int y);
         
      // --- Handlers for resizing an element by sides and corners
         virtual bool      ResizeZoneLeftHandler(const int x, const int y);
         virtual bool      ResizeZoneRightHandler(const int x, const int y);
         virtual bool      ResizeZoneTopHandler(const int x, const int y);
         virtual bool      ResizeZoneBottomHandler(const int x, const int y);
         virtual bool      ResizeZoneLeftTopHandler(const int x, const int y);
         virtual bool      ResizeZoneRightTopHandler(const int x, const int y);
         virtual bool      ResizeZoneLeftBottomHandler(const int x, const int y);
         virtual bool      ResizeZoneRightBottomHandler(const int x, const int y);
         
      // --- Returns a pointer to a hint by (1) index, (2) identifier, (3) name
         CVisualHint      *GetHintAt(const int index);
         CVisualHint      *GetHint(const int id);
         CVisualHint      *GetHint(const string name);

      // --- Creates a new tooltip
         CVisualHint      *CreateNewHint(const ENUM_HINT_TYPE type, const string object_name, const string user_name, const int id, const int x, const int y, const int w, const int h);
      // --- (1) Displays the specified tooltip with arrows, (2) hides all tooltips
         void              ShowHintArrowed(const ENUM_HINT_TYPE type,const int x,const int y);
         void              HideHintsAll(const bool chart_redraw);

      public:
      // --- Returns itself
         CElementBase     *GetObject(void)                           { return &this;                     }
      // --- Returns a pointer to (1) the drawing class, (2) the list of tooltips
         CImagePainter    *Painter(void)                             { return &this.m_painter;           }
         CListElm         *GetListHints(void)                        { return &this.m_list_hints;        }

      // --- Creates and adds (1) a new, (2) a previously created tooltip object (tooltip only) to the list
         CVisualHint      *InsertNewTooltip(const ENUM_HINT_TYPE type, const string user_name, const int w, const int h);
         CVisualHint      *InsertTooltip(CVisualHint *obj, const int dx, const int dy);

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
         
      // --- Sets the resizing flag
         virtual void      SetResizable(const bool flag);
         
      // --- (1) Sets, (2) returns the visibility flag in the container
         virtual void      SetVisibleInContainer(const bool flag)    { this.m_visible_in_container=flag; }
         bool              IsVisibleInContainer(void)          const { return this.m_visible_in_container;}

      // --- Returns a description of the object
         virtual string    Description(void);
         
      // --- Resize handler
         virtual void      OnResizeZoneEvent(const int id, const long lparam, const double dparam, const string sparam);
         
      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0) const;
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_ELEMENT_BASE);}

      // --- Constructors/destructor
                           CElementBase(void) { this.m_painter.CanvasAssign(this.GetForeground()); this.m_visible_in_container=true; }
                           CElementBase(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                           ~CElementBase(void) { this.m_list_hints.Clear(); }
      };
   #ifndef CELEMENTBASE_IMPLEMENTATION
   #define CELEMENTBASE_IMPLEMENTATION
      //+-----------------------------------------------------------------------+
      // | CElementBase::Parametric constructor. Builds an element at the specified |
      // | window of the specified graph with the specified text, coordinates and dimensions|
      //+-----------------------------------------------------------------------+
      CElementBase::CElementBase(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
         CCanvasBase(object_name,chart_id,wnd,x,y,w,h),m_group(-1)
      {
         // --- Assign the foreground canvas to the drawing object and
         // --- reset the coordinates and dimensions, which makes it inactive,
         // --- set the visibility flag of the element in the container
            this.m_painter.CanvasAssign(this.GetForeground());
            this.m_painter.SetXY(0,0);
            this.m_painter.SetSize(0,0);
            this.m_visible_in_container=true;
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
         string area=::StringFormat("x %d, y %d, w %d, h %d, right %d, bottom %d",this.X(),this.Y(),this.Width(),this.Height(),this.Right(),this.Bottom());
         return ::StringFormat("%s%s (%s, %s): ID %d, Group %d, %s",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.NameBG(),this.NameFG(),this.ID(),this.Group(),area);
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Sets the resizability flag |
      //+------------------------------------------------------------------+
      void CElementBase::SetResizable(const bool flag)
      {
         // --- Write a flag to the parent object
            CCanvasBase::SetResizable(flag);
         // --- If the flag is passed as true, we create four tooltips with arrows for the cursor,
            if(flag)
               this.AddHintsArrowed();
         // --- otherwise - remove hints with arrows for the cursor
            else
               this.DeleteHintsArrowed();
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Returns a pointer to the tooltip by index |
      //+------------------------------------------------------------------+
      CVisualHint *CElementBase::GetHintAt(const int index)
      {
         return this.m_list_hints.GetNodeAtIndex(index);
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Returns a pointer to a tooltip by ID|
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
      // |CElementBase:: Returns a pointer to the name hint |
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
      // | CElementBase::Adds the specified tooltip object to the list |
      //+------------------------------------------------------------------+
      bool CElementBase::AddHintToList(CVisualHint *obj)
      {
      // --- If an empty pointer is passed, we report this and return false
         if(obj==NULL)
         {
            ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
            return false;
         }
      // --- Remember the list sorting method
         int sort_mode=this.m_list_hints.SortMode();
      // --- Set the list to sort by identifier
         this.m_list_hints.Sort(ELEMENT_SORT_BY_ID);
      // --- If such element is not in the list,
         if(this.m_list_hints.Search(obj)==NULL)
         {
            // --- return the list to its original sorting and return the result of adding it to the list
            this.m_list_hints.Sort(sort_mode);
            return(this.m_list_hints.Add(obj)>-1);
         }
      // --- Return the list to its original sorting
         this.m_list_hints.Sort(sort_mode);
      // --- An element with the same identifier is already in the list - return false
         return false;
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Creates a new tooltip |
      //+------------------------------------------------------------------+
      CVisualHint *CElementBase::CreateNewHint(const ENUM_HINT_TYPE type,const string object_name,const string user_name,const int id, const int x,const int y,const int w,const int h)
      {
      // --- Create a new tooltip object
         CVisualHint *obj=new CVisualHint(object_name,this.m_chart_id,this.m_wnd,x,y,w,h);
         if(obj==NULL)
         {
            ::PrintFormat("%s: Error: Failed to create Hint object",__FUNCTION__);
            return NULL;
         }
      // --- Set the identifier, name and type of tooltip
         obj.SetID(id);
         obj.SetName(user_name);
         obj.SetHintType(type);
         
      // --- Return a pointer to the created object
         return obj;
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Creates and adds a new tooltip object to the list|
      //+------------------------------------------------------------------+
      CVisualHint *CElementBase::CreateAndAddNewHint(const ENUM_HINT_TYPE type,const string user_name,const int w,const int h)
      {
      // --- Create a name for the graphic object
         int obj_total=this.m_list_hints.Total();
         string obj_name=this.NameFG()+"_HNT"+(string)obj_total;
         
      // --- Calculate the coordinates of the object below and to the right of the lower right corner of the element
         int x=this.Right()+1;
         int y=this.Bottom()+1;
         
      // --- Create a new tooltip object
         CVisualHint *obj=this.CreateNewHint(type,obj_name,user_name,obj_total,x,y,w,h);
         
      // --- If a new object is not created, return NULL
         if(obj==NULL)
            return NULL;

      // --- Set image limits, container and z-order
         obj.SetImageBound(0,0,this.Width(),this.Height());
         obj.SetContainerObj(&this);
         obj.ObjectSetZOrder(this.ObjectZOrder()+1);

      // --- If the created element is not added to the list, we report this, delete the created element and return NULL
         if(!this.AddHintToList(obj))
         {
            ::PrintFormat("%s: Error. Failed to add Hint object with ID %d to list",__FUNCTION__,obj.ID());
            delete obj;
            return NULL;
         }
         
      // --- Return a pointer to the created and attached object
         return obj;
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Adds an existing tooltip object to the list |
      //+------------------------------------------------------------------+
      CVisualHint *CElementBase::AddHint(CVisualHint *obj,const int dx,const int dy)
      {
      // --- If an object is passed that does not have a hint type, we return NULL
         if(obj.Type()!=ELEMENT_TYPE_HINT)
         {
            ::PrintFormat("%s: Error. Only an object with the Hint type can be used here. The element type \"%s\" was passed",__FUNCTION__,ElementDescription((ENUM_ELEMENT_TYPE)obj.Type()));
            return NULL;
         }
      // --- Remember the object identifier and set a new one
         int id=obj.ID();
         obj.SetID(this.m_list_hints.Total());
         
      // --- Add an object to the list; if it fails, we report this, set the initial identifier and return NULL
         if(!this.AddHintToList(obj))
         {
            ::PrintFormat("%s: Error. Failed to add Hint object to list",__FUNCTION__);
            obj.SetID(id);
            return NULL;
         }
      // --- Set new coordinates, container and z-order of the object
         int x=this.X()+dx;
         int y=this.Y()+dy;
         obj.Move(x,y);
         obj.SetContainerObj(&this);
         obj.ObjectSetZOrder(this.ObjectZOrder()+1);
         
      // --- Return a pointer to the attached object
         return obj;
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Adds arrow tooltip objects to the list |
      //+------------------------------------------------------------------+
      bool CElementBase::AddHintsArrowed(void)
      {
      // --- Arrays of names and types of hints
         string array[4]={DEF_HINT_NAME_HORZ,DEF_HINT_NAME_VERT,DEF_HINT_NAME_NWSE,DEF_HINT_NAME_NESW};
         
         ENUM_HINT_TYPE type[4]={HINT_TYPE_ARROW_HORZ,HINT_TYPE_ARROW_VERT,HINT_TYPE_ARROW_NWSE,HINT_TYPE_ARROW_NESW};
         
      // --- In a loop we create four tooltips with arrows
         bool res=true;
         for(int i=0;i<(int)array.Size();i++)
            res &=(this.CreateAndAddNewHint(type[i],array[i],0,0)!=NULL);
            
      // --- If there were errors during creation, return false
         if(!res)
            return false;
            
      // --- In a loop through an array of names of hint objects
         for(int i=0;i<(int)array.Size();i++)
         {
            // --- we get the next object by name,
            CVisualHint *obj=this.GetHint(array[i]);
            if(obj==NULL)
               continue;
            // --- hide the object and draw the appearance (arrows according to the type of object)
            obj.Hide(false);
            obj.Draw(false);
         }
      // --- Everything is successful
         return true;
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Removes arrow tooltip objects from the list |
      //+------------------------------------------------------------------+
      bool CElementBase::DeleteHintsArrowed(void)
      {
      // --- In a loop through a list of hint objects
         bool res=true;
         for(int i=this.m_list_hints.Total()-1;i>=0;i--)
         {
            // --- we get another object and, if it is not a tooltip, we delete it
            CVisualHint *obj=this.m_list_hints.GetNodeAtIndex(i);
            if(obj!=NULL && obj.HintType()!=HINT_TYPE_TOOLTIP)
               res &=this.m_list_hints.DeleteCurrent();
         }
      // --- Return the result of removing tooltips with arrows
         return res;
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Creates and adds a new tooltip object to the list|
      //+------------------------------------------------------------------+
      CVisualHint *CElementBase::InsertNewTooltip(const ENUM_HINT_TYPE type,const string user_name,const int w,const int h)
      {
      // --- If the tooltip type is not a tooltip, we report this and return NULL
         if(type!=HINT_TYPE_TOOLTIP)
         {
            ::PrintFormat("%s: Error. Only a tooltip can be added to an element",__FUNCTION__);
            return NULL;
         }
      // --- Create and add a new hint object to the list;
      // --- Return a pointer to the created and attached object
         return this.CreateAndAddNewHint(type,user_name,w,h);
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Adds a previously created tooltip object to the list|
      //+------------------------------------------------------------------+
      CVisualHint *CElementBase::InsertTooltip(CVisualHint *obj,const int dx,const int dy)
      {
         // --- If an empty or invalid pointer to an object is passed, return NULL
            if(::CheckPointer(obj)==POINTER_INVALID)
            {
               ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
               return NULL;
            }
         // --- If the tooltip type is not tooltype, we report this and return NULL
            if(obj.HintType()!=HINT_TYPE_TOOLTIP)
            {
               ::PrintFormat("%s: Error. Only a tooltip can be added to an element",__FUNCTION__);
               return NULL;
            }
         // --- Add the specified hint object to the list;
         // --- Return a pointer to the created and attached object
            return this.AddHint(obj,dx,dy);
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Displays the specified tooltip |
      // | at the specified coordinates |
      //+------------------------------------------------------------------+
      void CElementBase::ShowHintArrowed(const ENUM_HINT_TYPE type,const int x,const int y)
      {
            CVisualHint *hint=NULL; // Pointer to the object being searched for
         // --- In a loop through a list of tooltip objects
            for(int i=0;i<this.m_list_hints.Total();i++)
            {
               // --- get a pointer to the next object
               CVisualHint *obj=this.GetHintAt(i);
               if(obj==NULL)
                  continue;
               // --- If this is the type of hint you are looking for, remember the pointer,
               if(obj.HintType()==type)
                  hint=obj;
               // --- otherwise - hide the object
               else
                  obj.Hide(false);
            }
         // --- If the desired object is found and it is hidden
            if(hint!=NULL && hint.IsHidden())
            {
               // --- place the object at the specified coordinates,
               // --- draw the appearance and bring the object to the foreground, making it visible
               hint.Move(x,y);
               hint.Draw(false);
               hint.BringToTop(true);
            }
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Hide all tooltips |
      //+------------------------------------------------------------------+
      void CElementBase::HideHintsAll(const bool chart_redraw)
         {
         // --- In a loop through a list of hint objects
            for(int i=0;i<this.m_list_hints.Total();i++)
            {
               // --- get another object and hide it
               CVisualHint *obj=this.GetHintAt(i);
               if(obj!=NULL)
                  obj.Hide(false);
            }
         // --- If indicated, redraw the graph
            if(chart_redraw)
               ::ChartRedraw(this.m_chart_id);
         }
      //+------------------------------------------------------------------+
      // | CElementBase::Displays resizing cursor |
      //+------------------------------------------------------------------+
      bool CElementBase::ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y)
         {
               CVisualHint *hint=NULL;          // Pointer to tooltip
               int hint_shift_x=0;              // Tooltip X offset
               int hint_shift_y=0;              // Tooltip Y Offset
               
            // --- Depending on the location of the cursor on the borders of the element
            // --- indicate the offset of the tooltip relative to the cursor coordinates,
            // --- display the required hint on the chart and get a pointer to this object
               switch(edge)
               {
                  // --- Cursor on the right or left border - horizontal double arrow
                  case CURSOR_REGION_RIGHT         :
                  case CURSOR_REGION_LEFT          :
                     hint_shift_x=1;
                     hint_shift_y=18;
                     this.ShowHintArrowed(HINT_TYPE_ARROW_HORZ,x+hint_shift_x,y+hint_shift_y);
                     hint=this.GetHint(DEF_HINT_NAME_HORZ);
                  break;
               
                  // --- Cursor on the top or bottom border - vertical double arrow
                  case CURSOR_REGION_TOP           :
                  case CURSOR_REGION_BOTTOM        :
                     hint_shift_x=12;
                     hint_shift_y=4;
                     this.ShowHintArrowed(HINT_TYPE_ARROW_VERT,x+hint_shift_x,y+hint_shift_y);
                     hint=this.GetHint(DEF_HINT_NAME_VERT);
                  break;
               
                  // --- Cursor in the upper left or lower right corner - diagonal double arrow from top left to bottom right
                  case CURSOR_REGION_LEFT_TOP      :
                  case CURSOR_REGION_RIGHT_BOTTOM  :
                     hint_shift_x=10;
                     hint_shift_y=2;
                     this.ShowHintArrowed(HINT_TYPE_ARROW_NWSE,x+hint_shift_x,y+hint_shift_y);
                     hint=this.GetHint(DEF_HINT_NAME_NWSE);
                  break;
               
                  // --- Cursor in the lower left or upper right corner - diagonal double arrow from bottom left to top right
                  case CURSOR_REGION_LEFT_BOTTOM   :
                  case CURSOR_REGION_RIGHT_TOP     :
                     hint_shift_x=5;
                     hint_shift_y=12;
                     this.ShowHintArrowed(HINT_TYPE_ARROW_NESW,x+hint_shift_x,y+hint_shift_y);
                     hint=this.GetHint(DEF_HINT_NAME_NESW);
                  break;
                  
                  // --- By default we do nothing
                  default: break;
               }

            // --- Return the result of adjusting the position of the tooltip relative to the cursor
               return(hint!=NULL ? hint.Move(x+hint_shift_x,y+hint_shift_y) : false);
         }
      //+------------------------------------------------------------------+
      //| CElementBase::Resizing Handler |
      //+------------------------------------------------------------------+
      void CElementBase::OnResizeZoneEvent(const int id,const long lparam,const double dparam,const string sparam)
         {
               int x=(int)lparam;               // X coordinate of cursor
               int y=(int)dparam;               // Cursor Y coordinate
               int shift_x=0;                   // Tooltip X offset
               int shift_y=0;                   // Tooltip Y Offset
               
            // --- Get the cursor position relative to the element's boundaries and the interaction mode
               ENUM_CURSOR_REGION edge=(this.ResizeRegion()==CURSOR_REGION_NONE ? this.CheckResizeZone(x,y) : this.ResizeRegion());
               ENUM_RESIZE_ZONE_ACTION action=(ENUM_RESIZE_ZONE_ACTION)id;
               
            // --- If the cursor is outside the resizing boundaries or just hovered over the interaction zone
               if(action==RESIZE_ZONE_ACTION_NONE || (action==RESIZE_ZONE_ACTION_HOVER && edge==CURSOR_REGION_NONE))
               {
                  // --- disable resizing mode and interaction region,
                  // --- hide all hints
                  this.SetResizeMode(false);
                  this.SetResizeRegion(CURSOR_REGION_NONE);
                  this.HideHintsAll(true);
               }

            // --- Cursor on one of the resizing boundaries
               if(action==RESIZE_ZONE_ACTION_HOVER)
               {
                  // --- Display a tooltip with an arrow for the interaction region
                  if(this.ShowCursorHint(edge,x,y))
                     ::ChartRedraw(this.m_chart_id);
               }
               
            // ---Start resizing
               if(action==RESIZE_ZONE_ACTION_BEGIN)
               {
                  // --- enable resizing mode and interaction region,
                  // --- display the corresponding cursor tooltip
                  this.SetResizeMode(true);
                  this.SetResizeRegion(edge);
                  this.ShowCursorHint(edge,x,y);
               }
               
            // ---Drag an object's border to resize an element
               if(action==RESIZE_ZONE_ACTION_DRAG)
               {
                  // --- Call the handler for dragging the boundaries of the object to change its size,
                  // --- display the corresponding cursor tooltip
                  this.ResizeActionDragHandler(x,y);
                  this.ShowCursorHint(edge,x,y);
               }
         }
      //+------------------------------------------------------------------+
      //| CElementBase::Element edges and corners drag handler |
      //+------------------------------------------------------------------+
      void CElementBase::ResizeActionDragHandler(const int x, const int y)
         {
            // --- Resizing beyond the right border
               if(this.ResizeRegion()==CURSOR_REGION_RIGHT)
                  this.ResizeZoneRightHandler(x,y);
            // --- Resizing beyond the bottom border
               if(this.ResizeRegion()==CURSOR_REGION_BOTTOM)
                  this.ResizeZoneBottomHandler(x,y);
            // --- Resizing beyond the left border
               if(this.ResizeRegion()==CURSOR_REGION_LEFT)
                  this.ResizeZoneLeftHandler(x,y);
            // --- Resizing beyond the top border
               if(this.ResizeRegion()==CURSOR_REGION_TOP)
                  this.ResizeZoneTopHandler(x,y);
            // --- Resizing by the lower right corner
               if(this.ResizeRegion()==CURSOR_REGION_RIGHT_BOTTOM)
                  this.ResizeZoneRightBottomHandler(x,y);
            // --- Resizing by the upper right corner
               if(this.ResizeRegion()==CURSOR_REGION_RIGHT_TOP)
                  this.ResizeZoneRightTopHandler(x,y);
            // --- Resizing by the lower left corner
               if(this.ResizeRegion()==CURSOR_REGION_LEFT_BOTTOM)
                  this.ResizeZoneLeftBottomHandler(x,y);
            // --- Resizing by the upper left corner
               if(this.ResizeRegion()==CURSOR_REGION_LEFT_TOP)
                  this.ResizeZoneLeftTopHandler(x,y);
         }
      //+------------------------------------------------------------------+
      // | CElementBase::Right resize handler |
      //+------------------------------------------------------------------+
      bool CElementBase::ResizeZoneRightHandler(const int x,const int y)
      {
         // --- Calculate and set the new width of the element
            int width=::fmax(x-this.X()+1,DEF_PANEL_MIN_W);
            if(!this.ResizeW(width))
               return false;
         // --- Get a pointer to a hint
            CVisualHint *hint=this.GetHint(DEF_HINT_NAME_HORZ);
            if(hint==NULL)
               return false;
         // --- Shift the tooltip by the specified amounts relative to the cursor
            int shift_x=1;
            int shift_y=18;
            return hint.Move(x+shift_x,y+shift_y);
      }
      //+------------------------------------------------------------------+
      // | CElementBase::Handler for resizing beyond the bottom edge |
      //+------------------------------------------------------------------+
      bool CElementBase::ResizeZoneBottomHandler(const int x,const int y)
         {
            // --- Calculate and set the new height of the element
               int height=::fmax(y-this.Y(),DEF_PANEL_MIN_H);
               if(!this.ResizeH(height))
                  return false;
            // --- Get a pointer to a hint
               CVisualHint *hint=this.GetHint(DEF_HINT_NAME_VERT);
               if(hint==NULL)
                  return false;
            // --- Shift the tooltip by the specified amounts relative to the cursor
               int shift_x=12;
               int shift_y=4;
               return hint.Move(x+shift_x,y+shift_y);
         }
      //+------------------------------------------------------------------+
      // | CElementBase::Resizing beyond the left edge |
      //+------------------------------------------------------------------+
      bool CElementBase::ResizeZoneLeftHandler(const int x,const int y)
         {
            // --- Calculate the new X coordinate and width of the element
               int new_x=::fmin(x,this.Right()-DEF_PANEL_MIN_W+1);
               int width=this.Right()-new_x+1;
            // --- Set new X coordinate and element width
               if(!this.MoveXYWidthResize(new_x,this.Y(),width,this.Height()))
                  return false;
            // --- Get a pointer to a hint
               CVisualHint *hint=this.GetHint(DEF_HINT_NAME_HORZ);
               if(hint==NULL)
                  return false;
            // --- Shift the tooltip by the specified amounts relative to the cursor
               int shift_x=1;
               int shift_y=18;
               return hint.Move(x+shift_x,y+shift_y);
         }
      //+------------------------------------------------------------------+
      // | CElementBase::Resizing beyond the top edge |
      //+------------------------------------------------------------------+
      bool CElementBase::ResizeZoneTopHandler(const int x,const int y)
         {
            // --- Calculate the new Y coordinate and height of the element
               int new_y=::fmin(y,this.Bottom()-DEF_PANEL_MIN_H+1);
               int height=this.Bottom()-new_y+1;
            // --- Set new Y coordinate and element height
               if(!this.MoveXYWidthResize(this.X(),new_y,this.Width(),height))
                  return false;
            // --- Get a pointer to a hint
               CVisualHint *hint=this.GetHint(DEF_HINT_NAME_VERT);
               if(hint==NULL)
                  return false;
            // --- Shift the tooltip by the specified amounts relative to the cursor
               int shift_x=12;
               int shift_y=4;
               return hint.Move(x+shift_x,y+shift_y);
         }
      //+------------------------------------------------------------------+
      // | CElementBase::Resize for lower right corner |
      //+------------------------------------------------------------------+
      bool CElementBase::ResizeZoneRightBottomHandler(const int x,const int y)
         {
            // --- Calculate and set the new width and height of the element
               int width =::fmax(x-this.X()+1, DEF_PANEL_MIN_W);
               int height=::fmax(y-this.Y()+1, DEF_PANEL_MIN_H);
               if(!this.Resize(width,height))
                  return false;
            // --- Get a pointer to a hint
               CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NWSE);
               if(hint==NULL)
                  return false;
            // --- Shift the tooltip by the specified amounts relative to the cursor
               int shift_x=10;
               int shift_y=2;
               return hint.Move(x+shift_x,y+shift_y);
         }
      //+------------------------------------------------------------------+
      // | CElementBase::Resizing for the upper right corner |
      //+------------------------------------------------------------------+
      bool CElementBase::ResizeZoneRightTopHandler(const int x,const int y)
         {
            // --- Calculate and set new Y coordinates, width and height of the element
               int new_y=::fmin(y, this.Bottom()-DEF_PANEL_MIN_H+1);
               int width =::fmax(x-this.X()+1, DEF_PANEL_MIN_W);
               int height=this.Bottom()-new_y+1;
               if(!this.MoveXYWidthResize(this.X(),new_y,width,height))
                  return false;
            // --- Get a pointer to a hint
               CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NESW);
               if(hint==NULL)
                  return false;
            // --- Shift the tooltip by the specified amounts relative to the cursor
               int shift_x=5;
               int shift_y=12;
               return hint.Move(x+shift_x,y+shift_y);
         }
      //+------------------------------------------------------------------+
      // | CElementBase::Resize to bottom left corner |
      //+------------------------------------------------------------------+
      bool CElementBase::ResizeZoneLeftBottomHandler(const int x,const int y)
         {
            // --- Calculate and set new X coordinates, width and height of the element
               int new_x=::fmin(x, this.Right()-DEF_PANEL_MIN_W+1);
               int width =this.Right()-new_x+1;
               int height=::fmax(y-this.Y()+1, DEF_PANEL_MIN_H);
               if(!this.MoveXYWidthResize(new_x,this.Y(),width,height))
                  return false;
            // --- Get a pointer to a hint
               CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NESW);
               if(hint==NULL)
                  return false;
            // --- Shift the tooltip by the specified amounts relative to the cursor
               int shift_x=5;
               int shift_y=12;
               return hint.Move(x+shift_x,y+shift_y);
         }
      //+------------------------------------------------------------------+
      // | CElementBase::Resize by upper left corner |
      //+------------------------------------------------------------------+
      bool CElementBase::ResizeZoneLeftTopHandler(const int x,const int y)
         {
            // --- Calculate and set new X and Y coordinates, width and height of the element
               int new_x=::fmin(x,this.Right()-DEF_PANEL_MIN_W+1);
               int new_y=::fmin(y,this.Bottom()-DEF_PANEL_MIN_H+1);
               int width =this.Right() -new_x+1;
               int height=this.Bottom()-new_y+1;
               if(!this.MoveXYWidthResize(new_x, new_y,width,height))
                  return false;
            // --- Get a pointer to a hint
               CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NWSE);
               if(hint==NULL)
                  return false;
            // --- Shift the tooltip by the specified amounts relative to the cursor
               int shift_x=10;
               int shift_y=2;
               return hint.Move(x+shift_x,y+shift_y);
         }
      //+------------------------------------------------------------------+
      // | CElementBase::Saving to file |
      //+------------------------------------------------------------------+
      bool CElementBase::Save(const int file_handle)
         {
            // --- Save the data of the parent object
               if(!CCanvasBase::Save(file_handle))
                  return false;
            
            // --- Save the list of hints
               if(!this.m_list_hints.Save(file_handle))
                  return false;
            // --- Save the image object
               if(!this.m_painter.Save(file_handle))
                  return false;
            // --- Save the group
               if(::FileWriteInteger(file_handle,this.m_group,INT_VALUE)!=INT_VALUE)
                  return false;
            // --- Store the visibility flag in the container
               if(::FileWriteInteger(file_handle,this.m_visible_in_container,INT_VALUE)!=INT_VALUE)
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
                  
            // --- Loading a list of tips
               if(!this.m_list_hints.Load(file_handle))
                  return false;      
            // --- Loading the image object
               if(!this.m_painter.Load(file_handle))
                  return false;
            // --- Loading the group
               this.m_group=::FileReadInteger(file_handle,INT_VALUE);
            // --- Load the visibility flag in the container
               this.m_visible_in_container=::FileReadInteger(file_handle,INT_VALUE);
               
            // --- Everything is successful
               return true;
         }
   #endif // CELEMENTBASE_IMPLEMENTATION
   //+------------------------------------------------------------------+
#endif // __ELEMENTBASE_MQH__



