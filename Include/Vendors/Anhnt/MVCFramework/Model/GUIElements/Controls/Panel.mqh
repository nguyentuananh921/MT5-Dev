//+------------------------------------------------------------------+
//|                                                         Panel.mqh|
//+------------------------------------------------------------------+

#ifndef __PANEL_MQH__
#define __PANEL_MQH__
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Object.mqh>          // CObject
//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "TableCellView.mqh"
#include "Container.mqh"
#include "..\Table\TableRow.mqh"
#include "..\Table\TableCell.mqh"
#include "..\Base\Bound.mqh"
#include "..\Base\BaseEnums.mqh"
#include "Label.mqh"
#include "ElementBase.mqh"
#include "ListElm.mqh"
// CPanel
// → CLabel
// → CElementBase
// → CCanvasBase
// → CBoundedObj
// → CBaseObj
// → CObject

//--- Forward declaration of control element classes
class CBaseObj;

//+------------------------------------------------------------------+
//| Panel class                                                      |
//+------------------------------------------------------------------+
class CPanel : public CLabel
{
   private:
      CElementBase m_temp_elm;     // temporary object for element search
      CBound       m_temp_bound;   // temporary object for bound search

   protected:
      CListElm     m_list_elm;     // list of attached elements
      CListElm     m_list_bounds;  // list of bounds

   //--- Add new element to list
      bool AddNewElement(CElementBase *element);

   public:

   //--- Get pointer to lists
      CListElm *GetListAttachedElements(void){ return &this.m_list_elm; }
      CListElm *GetListBounds(void){ return &this.m_list_bounds; }

   //--- Get attached element
      CElementBase *GetAttachedElementAt(const uint index){ return this.m_list_elm.GetNodeAtIndex(index); }
      CElementBase *GetAttachedElementByID(const int id);
      CElementBase *GetAttachedElementByName(const string name);

   //--- Number of attached elements
      int AttachedElementsTotal(void) const { return this.m_list_elm.Total(); }

   //--- Bound access
      CBound *GetBoundAt(const uint index){ return this.m_list_bounds.GetNodeAtIndex(index); }
      CBound *GetBoundByID(const int id);
      CBound *GetBoundByName(const string name);

   //--- Insert elements
      virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
      virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);

   //--- Delete element
      bool DeleteElement(const int index){ return this.m_list_elm.Delete(index); }

   //--- Bound operations
      CBound *InsertNewBound(const string name,const int dx,const int dy,const int w,const int h);
      bool DeleteBound(const int index){ return this.m_list_bounds.Delete(index); }

   //--- Assign objects
      bool AssignObjectToBound(const int bound,CBaseObj *object);
      bool UnassignObjectFromBound(const int bound);

   //--- Resize
      virtual bool ResizeW(const int w);
      virtual bool ResizeH(const int h);
      virtual bool Resize(const int w,const int h);

   //--- Draw
      virtual void Draw(const bool chart_redraw);

   //--- Virtual methods
      virtual int  Compare(const CObject *node,const int mode=0) const;
      virtual bool Save(const int file_handle);
      virtual bool Load(const int file_handle);
      virtual int  Type(void) const { return(ELEMENT_TYPE_PANEL); }

   //--- Initialization
      void Init(void);
      virtual void InitColors(void);

   //--- Move
      virtual bool Move(const int x,const int y);
      virtual bool Shift(const int dx,const int dy);
      virtual bool MoveXYWidthResize(const int x,const int y,const int w,const int h);

   //--- Visibility / state
      virtual void Hide(const bool chart_redraw);
      virtual void Show(const bool chart_redraw);
      virtual void BringToTop(const bool chart_redraw);
      virtual void Block(const bool chart_redraw);
      virtual void Unblock(const bool chart_redraw);

   //--- Debug
      virtual void Print(void);
      void PrintAttached(const uint tab=3);
      void PrintBounds(void);

   //--- Events
      virtual void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam);
      virtual void TimerEventHandler(void);

   //--- Constructors
      CPanel(void);
      CPanel(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
      ~CPanel(void){ this.m_list_elm.Clear(); this.m_list_bounds.Clear(); }
};
//+------------------------------------------------------------------+
//| CPanel::Default constructor.                                     |
//| Builds the element in the main window of the current chart       |
//| at coordinates 0,0 with default dimensions.                      |
//+------------------------------------------------------------------+
CPanel::CPanel(void) : CLabel("Panel","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H)
  {
//--- Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
//| CPanel::Parametric constructor.                                  |
//| Builds the element in the specified window of the specified chart|
//| with the given text, coordinates, and dimensions.                |
//+------------------------------------------------------------------+
CPanel::CPanel(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CLabel(object_name,text,chart_id,wnd,x,y,w,h)
  {
//--- Initialization
   this.Init();
  }
//+------------------------------------------------------------------+
//| CPanel::Initialization                                           |
//+------------------------------------------------------------------+
void CPanel::Init(void)
  {
//--- Initialize default colors
   this.InitColors();
//--- Background is transparent (Alpha 0), foreground is opaque (Alpha 255)
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
//--- Set the offset and dimensions of the image area
   this.SetImageBound(0,0,this.Width(),this.Height());
//--- Border width
   this.SetBorderWidth(2);
  }
//+------------------------------------------------------------------+
//| CPanel::Initialize default object colors                         |
//+------------------------------------------------------------------+
void CPanel::InitColors(void)
  {
//--- Initialize background colors for normal and active states
   this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.BackColorToDefault();
   
//--- Initialize foreground colors for normal and active states (text color)
   this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   this.ForeColorToDefault();
   
//--- Initialize border colors (set to clrNULL/transparent by default)
   this.InitBorderColors(clrNULL,clrNULL,clrNULL,clrNULL);
   this.InitBorderColorsAct(clrNULL,clrNULL,clrNULL,clrNULL);
   this.BorderColorToDefault();
   
//--- Initialize colors for the blocked (disabled) state
   this.InitBorderColorBlocked(clrNULL);
   this.InitForeColorBlocked(clrSilver);
  }
//+------------------------------------------------------------------+
//| CPanel::Compare two objects                                      |
//+------------------------------------------------------------------+
int CPanel::Compare(const CObject *node,const int mode=0) const
  {
   return CLabel::Compare(node,mode);
  }
//+------------------------------------------------------------------+
//| CPanel::Resizes the object width                                 |
//+------------------------------------------------------------------+
bool CPanel::ResizeW(const int w)
  {
   if(!this.ObjectResizeW(w))
      return false;
   this.BoundResizeW(w);
   this.SetImageSize(w,this.Height());
   if(!this.ObjectTrim())
     {
      this.Update(false);
      this.Draw(false);
     }
//--- If the container is a CContainer type, check dimensions 
//--- to determine if scrollbars need to be displayed.
   /*CContainer  *container=NULL;
   //container=(CContainer*)base;
   //CCanvasBase *base=this.GetContainer();
   if(base!=NULL && base.Type()==ELEMENT_TYPE_CONTAINER)
     {
      container=base;
      container.CheckElementSizes(&this);
     }
     */
   CCanvasBase *base=this.GetContainer();
   CContainer *container=NULL;
   if(base!=NULL && base.Type()==ELEMENT_TYPE_CONTAINER)
   {
      container=(CContainer*)base;
      container.CheckElementSizes(&this);
   }
     
//--- Trim all attached child elements according to the new panel boundaries
   int total=this.m_list_elm.Total();
   for(int i=total-1; i>=0; i--)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.ObjectTrim();
     }
//--- Success
   return true;
  }
//+------------------------------------------------------------------+
//| CPanel::Resizes the object height                                |
//+------------------------------------------------------------------+
bool CPanel::ResizeH(const int h)
  {
   if(!this.ObjectResizeH(h))
      return false;
   this.BoundResizeH(h);
   this.SetImageSize(this.Width(),h);
   if(!this.ObjectTrim())
     {
      this.Update(false);
      this.Draw(false);
     }
//--- Check relation to container dimensions for scrollbars
   CContainer *base=this.GetContainer();
   if(base!=NULL && base.Type()==ELEMENT_TYPE_CONTAINER)
      base.CheckElementSizes(&this);
      
//--- Trim attached elements
   int total=this.m_list_elm.Total();
   for(int i=0;i<total;i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.ObjectTrim();
     }
   return true;
  }
//+------------------------------------------------------------------+
//| CPanel::Resizes the object (Width and Height)                    |
//+------------------------------------------------------------------+
bool CPanel::Resize(const int w,const int h)
  {
   if(!this.ObjectResize(w,h))
      return false;
   this.BoundResize(w,h);
   this.SetImageSize(w,h);
   if(!this.ObjectTrim())
     {
      this.Update(false);
      this.Draw(false);
     }
//--- Check relation to container dimensions
   CContainer *base=this.GetContainer();
   if(base!=NULL && base.Type()==ELEMENT_TYPE_CONTAINER)
      base.CheckElementSizes(&this);
      
//--- Loop through attached elements and trim them
   int total=this.m_list_elm.Total();
   for(int i=0;i<total;i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.ObjectTrim();
     }
   return true;
  }
//+------------------------------------------------------------------+
//| CPanel::Draws the appearance                                     |
//+------------------------------------------------------------------+
void CPanel::Draw(const bool chart_redraw)
  {
//--- Fill the object with the background color
   this.Fill(this.BackColor(),false);
   
//--- Clear the drawing area
   this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);

//--- Calculate dark and light shades for the 3D frame effect
   color clr_dark =(this.BackColor()==clrNULL ? this.BackColor() : this.GetBackColorControl().NewColor(this.BackColor(),-20,-20,-20));
   color clr_light=(this.BackColor()==clrNULL ? this.BackColor() : this.GetBackColorControl().NewColor(this.BackColor(),  6,  6,  6));

//--- Draw the panel frame if any border width is set
   if(this.BorderWidthBottom()+this.BorderWidthLeft()+this.BorderWidthRight()+this.BorderWidthTop()!=0)
      this.m_painter.FrameGroupElements(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),
                                        this.m_painter.Width(),this.m_painter.Height(),this.Text(),
                                        this.ForeColor(),clr_dark,clr_light,this.AlphaFG(),true);
   
//--- Update the background canvas
   this.m_background.Update(false);
   
//--- Draw all attached list elements (excluding scrollbars which are handled separately)
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL && elm.Type()!=ELEMENT_TYPE_SCROLLBAR_H && elm.Type()!=ELEMENT_TYPE_SCROLLBAR_V)
         elm.Draw(false);
     }
//--- Redraw chart if requested
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CPanel::Adds a new element to the internal list                 |
//+------------------------------------------------------------------+
bool CPanel::AddNewElement(CElementBase *element)
  {
   if(element==NULL)
     {
      ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
      return false;
     }
   int sort_mode=this.m_list_elm.SortMode();
   this.m_list_elm.Sort(ELEMENT_SORT_BY_ID);
   if(this.m_list_elm.Search(element)==NULL)
     {
      this.m_list_elm.Sort(sort_mode);
      return(this.m_list_elm.Add(element)>-1);
     }
   this.m_list_elm.Sort(sort_mode);
   return false;
  }
//+------------------------------------------------------------------+
//| CPanel::Creates and adds a new element to the list               |
//+------------------------------------------------------------------+
CElementBase *CPanel::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
  {
//--- Generate graphic object name based on type and count
   int elm_total=this.m_list_elm.Total();
   string obj_name=this.NameFG()+"_"+ElementShortName(type)+(string)elm_total;

//--- Calculate absolute coordinates based on offsets (dx, dy)
   int x=this.X()+dx;
   int y=this.Y()+dy;

//--- Factory: Create the specific object based on the type
   CElementBase *element=NULL;
   switch(type)
     {
      case ELEMENT_TYPE_LABEL        : element = new CLabel(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);             break;
      case ELEMENT_TYPE_BUTTON       : element = new CButton(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);            break;
      case ELEMENT_TYPE_CHECKBOX     : element = new CCheckBox(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);          break;
      case ELEMENT_TYPE_SCROLLBAR_H  : element = new CScrollBarH(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);         break;
      case ELEMENT_TYPE_SCROLLBAR_V  : element = new CScrollBarV(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);         break;
      case ELEMENT_TYPE_PANEL        : element = new CPanel(obj_name,"",this.m_chart_id,this.m_wnd,x,y,w,h);               break;
      case ELEMENT_TYPE_CONTAINER    : element = new CContainer(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);         break;
      // ... (other cases simplified for brevity)
      default                        : element = NULL;
     }

   if(element==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create graphic element %s",__FUNCTION__,ElementDescription(type));
      return NULL;
     }

//--- Set metadata and hierarchy
   /*element.SetID(elm_total);
   element.SetName(user_name);
   element.SetContainerObj(&this);
   element.ObjectSetZOrder(this.ObjectZOrder()+1);
   */
   element->SetID(elm_total);
   element->SetName(user_name);
   element->SetContainerObj(&this);
   element->ObjectSetZOrder(this.ObjectZOrder()+1);
//--- Add to list
   if(!this.AddNewElement(element))
     {
      ::PrintFormat("%s: Error. Failed to add %s element with ID %d to list",__FUNCTION__,ElementDescription(type),element.ID());
      delete element;
      return NULL;
     }

//--- If the parent is a Container, ensure scrollbars stay on top of the new element
   CElementBase *elm=this.GetContainer();
   if(elm!=NULL && elm.Type()==ELEMENT_TYPE_CONTAINER)
     {
      CContainer *container_obj=elm;
      if(container_obj.ScrollBarHorzIsVisible())
        {
         CScrollBarH *sbh=container_obj.GetScrollBarH();
         if(sbh!=NULL) sbh.BringToTop(false);
        }
      if(container_obj.ScrollBarVertIsVisible())
        {
         CScrollBarV *sbv=container_obj.GetScrollBarV();
         if(sbv!=NULL) sbv.BringToTop(false);
        }
     }

   return element;
  }
//+------------------------------------------------------------------+
//| CPanel::Adds the specified existing element to the list          |
//+------------------------------------------------------------------+
CElementBase *CPanel::InsertElement(CElementBase *element,const int dx,const int dy)
  {
   if(::CheckPointer(element)==POINTER_INVALID)
     {
      ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
      return NULL;
     }
   if(element.Type()==ELEMENT_TYPE_BASE)
     {
      ::PrintFormat("%s: Error. The base element cannot be used",__FUNCTION__);
      return NULL;
     }

   int id=element.ID();
   //element.SetID(this.m_list_elm.Total());
   element->SetID(this.m_list_elm.Total());
   
   if(!this.AddNewElement(element))
     {
      ::PrintFormat("%s: Error. Failed to add element %s to list",__FUNCTION__,ElementDescription((ENUM_ELEMENT_TYPE)element.Type()));
      //element.SetID(id);
      element->SetID(id);
      return NULL;
     }

   element.Move(this.X()+dx, this.Y()+dy);
   element.SetContainerObj(&this);
   element.ObjectSetZOrder(this.ObjectZOrder()+1);
     
   return element;
  }
//+------------------------------------------------------------------+
//| CPanel::Returns an element by its ID                             |
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
//| CPanel::Returns an element by its assigned object name           |
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
//| Creates and adds a new area (bound) to the list                  |
//+------------------------------------------------------------------+
CBound *CPanel::InsertNewBound(const string name,const int dx,const int dy,const int w,const int h)
  {
//--- Check if an area with the specified name already exists
   this.m_temp_bound.SetName(name);
//--- Save the current list sorting mode
   int sort_mode=this.m_list_bounds.SortMode();
//--- Set sorting by name for the search
   this.m_list_bounds.Sort(ELEMENT_SORT_BY_NAME);
   if(this.m_list_bounds.Search(&this.m_temp_bound)!=NULL)
     {
      //--- Restore original sorting, notify of duplicate, and return NULL
      this.m_list_bounds.Sort(sort_mode);
      ::PrintFormat("%s: Error. An area named \"%s\" is already in the list",__FUNCTION__,name);
      return NULL;
     }
//--- Restore original sorting
   this.m_list_bounds.Sort(sort_mode);
//--- Create a new bound object
   CBound *bound=new CBound(dx,dy,w,h);
   if(bound==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create CBound object",__FUNCTION__);
      return NULL;
     }
//--- Set name and ID, then return the pointer
   //bound.SetName(name);
   bound->SetName(name);
   //bound.SetID(this.m_list_bounds.Total());
   bound->SetID(this.m_list_bounds.Total());
//--- If adding to the list fails, delete the object and return NULL
   if(this.m_list_bounds.Add(bound)==-1)
     {
      ::PrintFormat("%s: Error. Failed to add CBound object to list",__FUNCTION__);
      delete bound;
      return NULL;
     }
   return bound;
  }
//+------------------------------------------------------------------+
//| CPanel::Returns a bound by its ID                                |
//+------------------------------------------------------------------+
CBound *CPanel::GetBoundByID(const int id)
  {
   int total=this.m_list_bounds.Total();
   for(int i=0;i<total;i++)
     {
      CBound *bound=this.GetBoundAt(i);
      if(bound!=NULL && bound.ID()==id)
         return bound;
     }
   return NULL;
  }
//+------------------------------------------------------------------+
//| CPanel::Returns a bound by its assigned name                     |
//+------------------------------------------------------------------+
CBound *CPanel::GetBoundByName(const string name)
  {
   int total=this.m_list_bounds.Total();
   for(int i=0;i<total;i++)
     {
      CBound *bound=this.GetBoundAt(i);
      if(bound!=NULL && bound.Name()==name)
         return bound;
     }
   return NULL;
  }
//+------------------------------------------------------------------+
//| CPanel::Assigns an object to the specified bound                 |
//+------------------------------------------------------------------+
bool CPanel::AssignObjectToBound(const int bound,CBaseObj *object)
  {
   CBound *bound_obj=this.GetBoundAt(bound);
   if(bound_obj==NULL)
     {
      ::PrintFormat("%s: Error. Failed to get Bound at index %d",__FUNCTION__,bound);
      return false;
     }
   bound_obj.AssignObject(object);
   return true;
  }
//+------------------------------------------------------------------+
//| CPanel::Unassigns an object from the specified bound             |
//+------------------------------------------------------------------+
bool CPanel::UnassignObjectFromBound(const int bound)
  {
   CBound *bound_obj=this.GetBoundAt(bound);
   if(bound_obj==NULL)
     {
      ::PrintFormat("%s: Error. Failed to get Bound at index %d",__FUNCTION__,bound);
      return false;
     }
   bound_obj.UnassignObject();
   return true;
  }
//+------------------------------------------------------------------+
//| Prints the object description to the journal                     |
//+------------------------------------------------------------------+
void CPanel::Print(void)
  {
   CBaseObj::Print();
   this.PrintAttached();
  }
//+------------------------------------------------------------------+
//| CPanel::Prints the list of attached objects                       |
//+------------------------------------------------------------------+
void CPanel::PrintAttached(const uint tab=3)
  {
//--- Iterate through all attached elements
   int total=this.m_list_elm.Total();
   for(int i=0;i<total;i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm==NULL)
         continue;
//--- Skip scrollbars in the description
      ENUM_ELEMENT_TYPE type=(ENUM_ELEMENT_TYPE)elm.Type();
      if(type==ELEMENT_TYPE_SCROLLBAR_H || type==ELEMENT_TYPE_SCROLLBAR_V)
         continue;
//--- Log the element description
      ::PrintFormat("%*s[%d]: %s",tab,"",i,elm.Description());
//--- If the element is a container, recursively print its children
      if(type==ELEMENT_TYPE_PANEL || type==ELEMENT_TYPE_GROUPBOX || type==ELEMENT_TYPE_CONTAINER)
        {
         //CPanel *obj=elm;
         CPanel *obj=(CPanel*)elm;
         obj.PrintAttached(tab*2);
        }
     }
  }
//+------------------------------------------------------------------+
//| CPanel::Prints the list of bounds                                |
//+------------------------------------------------------------------+
void CPanel::PrintBounds(void)
  {
   int total=this.m_list_bounds.Total();
   for(int i=0;i<total;i++)
     {
      CBound *obj=this.GetBoundAt(i);
      if(obj==NULL)
         continue;
      ::PrintFormat("  [%d]: %s",i,obj.Description());
     }
  }
//+------------------------------------------------------------------+
//| CPanel::Sets new X and Y coordinates                              |
//+------------------------------------------------------------------+
bool CPanel::Move(const int x,const int y)
  {
//--- Calculate the distance the element will shift
   int delta_x=x-this.X();
   int delta_y=y-this.Y();

//--- Move the element
   bool res=this.ObjectMove(x,y);
   if(!res)
      return false;
   this.BoundMove(x,y);
   this.ObjectTrim();
   
//--- Move all attached elements by the same distance
   int total=this.m_list_elm.Total();
   for(int i=0;i<total;i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         res &=elm.Move(elm.X()+delta_x,elm.Y()+delta_y);
     }
   return res;
  }
//+------------------------------------------------------------------+
//| CPanel::Shifts the object by dx and dy                            |
//+------------------------------------------------------------------+
bool CPanel::Shift(const int dx,const int dy)
  {
//--- Shift the element
   bool res=this.ObjectShift(dx,dy);
   if(!res)
      return false;
   this.BoundShift(dx,dy);
   this.ObjectTrim();
   
//--- Shift all attached elements
   int total=this.m_list_elm.Total();
   for(int i=0;i<total;i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         res &=elm.Shift(dx,dy);
     }
   return res;
  }
//+------------------------------------------------------------------+
//| CPanel::Sets coordinates and dimensions simultaneously           |
//+------------------------------------------------------------------+
bool CPanel::MoveXYWidthResize(const int x,const int y,const int w,const int h)
  {
   int delta_x=x-this.X();
   int delta_y=y-this.Y();

   if(!CCanvasBase::MoveXYWidthResize(x,y,w,h))
      return false;
   this.BoundMove(x,y);
   this.BoundResize(w,h);
   this.SetImageBound(0,0,this.Width(),this.Height());
   if(!this.ObjectTrim())
     {
      this.Update(false);
      this.Draw(false);
     }
   
//--- Move all attached elements
   bool res=true;
   int total=this.m_list_elm.Total();
   for(int i=0;i<total;i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         res &=elm.Move(elm.X()+delta_x,elm.Y()+delta_y);
     }
   return res;
  }
//+------------------------------------------------------------------+
//| CPanel::Hides the object                                         |
//+------------------------------------------------------------------+
void CPanel::Hide(const bool chart_redraw)
  {
   if(this.m_hidden)
      return;
      
   CCanvasBase::Hide(false);
//--- Hide attached objects
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.Hide(false);
     }
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CPanel::Shows the object                                         |
//+------------------------------------------------------------------+
void CPanel::Show(const bool chart_redraw)
  {
   if(!this.m_hidden || !this.m_visible_in_container)
      return;
      
   CCanvasBase::Show(false);
//--- Show attached objects (excluding scrollbars)
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
        {
         if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_H || elm.Type()==ELEMENT_TYPE_SCROLLBAR_V)
            continue;
         elm.Show(false);
        }
     }
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CPanel::Brings the object to the foreground                      |
//+------------------------------------------------------------------+
void CPanel::BringToTop(const bool chart_redraw)
  {
   CCanvasBase::BringToTop(false);
//--- Bring attached objects to top
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
        {
         if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_H || elm.Type()==ELEMENT_TYPE_SCROLLBAR_V)
            continue;
         elm.ObjectTrim();
         elm.BringToTop(false);
        }
     }
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CPanel::Blocks (disables) the element                            |
//+------------------------------------------------------------------+
void CPanel::Block(const bool chart_redraw)
  {
   if(this.m_blocked)
      return;
      
   CCanvasBase::Block(false);
//--- Block attached objects
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.Block(false);
     }
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CPanel::Unblocks (enables) the element                           |
//+------------------------------------------------------------------+
void CPanel::Unblock(const bool chart_redraw)
  {
   if(!this.m_blocked)
      return;
      
   CCanvasBase::Unblock(false);
//--- Unblock attached objects
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.Unblock(false);
     }
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CPanel::Save to file                                             |
//+------------------------------------------------------------------+
bool CPanel::Save(const int file_handle)
  {
   if(!CElementBase::Save(file_handle))
      return false;
  
   if(!this.m_list_elm.Save(file_handle))
      return false;
   if(!this.m_list_bounds.Save(file_handle))
      return false;
   
   return true;
  }
//+------------------------------------------------------------------+
//| CPanel::Load from file                                           |
//+------------------------------------------------------------------+
bool CPanel::Load(const int file_handle)
  {
   if(!CElementBase::Load(file_handle))
      return false;
      
   if(!this.m_list_elm.Load(file_handle))
      return false;
   if(!this.m_list_bounds.Load(file_handle))
      return false;
   
   return true;
  }
//+------------------------------------------------------------------+
//| CPanel::Event handler                                            |
//+------------------------------------------------------------------+
void CPanel::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   CCanvasBase::OnChartEvent(id,lparam,dparam,sparam);
   int total=this.m_list_elm.Total();
   for(int i=0;i<total;i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.OnChartEvent(id,lparam,dparam,sparam);
     }
  }
//+------------------------------------------------------------------+
//| CPanel::Timer event handler                                      |
//+------------------------------------------------------------------+
void CPanel::TimerEventHandler(void)
  {
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.TimerEventHandler();
     }
  }

#endif