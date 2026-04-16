//+------------------------------------------------------------------+
//|                                                      Panel.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in: Containers                                         |
//|                           https://www.mql5.com/en/articles/18658 |
//| Update in: Resizable elements                                    |
//|                           https://www.mql5.com/en/articles/18941 |
//| Update in   :                                                    |
//|   Integrating the Model Component into the View Component        |
//|                           https://www.mql5.com/en/articles/19288 |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Panel class                                                      |
//+------------------------------------------------------------------+
#ifndef __PANEL_MQH__
#define __PANEL_MQH__
//+------------------------------------------------------------------+
//| Included Standard Libraries                                      |
//+------------------------------------------------------------------+
//#include <Arrays\List.mqh>
//+------------------------------------------------------------------+
//| Included Custome Libraries                                       |
//+------------------------------------------------------------------+
#include "Label.mqh"
#include "ElementBase.mqh"
#include "..\Base\Bound.mqh"
#include "..\Collections\ListElm.mqh"
class CContainer;

 class CPanel : public CLabel
  {
   private:
      CElementBase      m_temp_elm;                // Temporary object for searching elements
      CBound            m_temp_bound;              // Temporary object for searching areas
   protected:
      CListElm          m_list_elm;                // List of attached items
      CListElm          m_list_bounds;             // List of areas
   // --- Adds a new element to the list
      bool              AddNewElement(CElementBase *element);

   public:
   // --- Returns a pointer to a list of (1) attached items, (2) areas
      CListElm         *GetListAttachedElements(void)             { return &this.m_list_elm;                         }
      CListElm         *GetListBounds(void)                       { return &this.m_list_bounds;                      }
      
   // --- Returns the attached element by (1) index in the list, (2) identifier, (3) assigned object name
      CElementBase     *GetAttachedElementAt(const uint index)    { return this.m_list_elm.GetNodeAtIndex(index);    }
      CElementBase     *GetAttachedElementByID(const int id);
      CElementBase     *GetAttachedElementByName(const string name);
      
   // --- Returns the number of (1) areas, (2) attached elements,
      int               BoundsTotal(void)                   const { return this.m_list_bounds.Total();               }
      int               AttachedElementsTotal(void)         const { return this.m_list_elm.Total();                  }

   // --- Returns the area by (1) index in the list, (2) identifier, (3) assigned area name
      CBound           *GetBoundAt(const uint index)              { return this.m_list_bounds.GetNodeAtIndex(index); }
      CBound           *GetBoundByID(const int id);
      CBound           *GetBoundByName(const string name);
      
   // --- Creates and adds (1) a new, (2) a previously created element to the list
      virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
      virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);
   // --- Removes the specified element
      bool              DeleteElement(const int index)            { return this.m_list_elm.Delete(index);            }

   // --- (1) Creates and adds a new area to the list, (2) deletes the specified area
      CBound           *InsertNewBound(const string name,const int dx,const int dy,const int w,const int h);
      bool              DeleteBound(const int index)              { return this.m_list_bounds.Delete(index);         }
      
   // --- (1) Assigns an object to the specified area, (2) unassigns an object from the specified area
      bool              AssignObjectToBound(const int bound, CBaseObj *object);
      bool              UnassignObjectFromBound(const int bound);
   //| Update in: Resizable elements                                    |
   //|                           https://www.mql5.com/en/articles/18941 |
      // --- Changes the size of an object
         virtual bool      ResizeW(const int w);
         virtual bool      ResizeH(const int h);
         virtual bool      Resize(const int w,const int h);
   // ---Draws the appearance
      virtual void      Draw(const bool chart_redraw);
      
   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0) const;
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                          const { return(ELEMENT_TYPE_PANEL);                      }

   // --- Initialize (1) class object, (2) default object colors
      void              Init(void);
      virtual void      InitColors(void);
      
   // --- Sets the object to new XY coordinates
      virtual bool      Move(const int x,const int y);
   // --- Offsets the object along the XY axes by the specified offset
      virtual bool      Shift(const int dx,const int dy);
   //| Update in                             Resizable elements         |
   //|                           https://www.mql5.com/en/articles/18941 |
      // --- Sets both the coordinates and dimensions of an element
         virtual bool      MoveXYWidthResize(const int x,const int y,const int w,const int h);
      
   // --- (1) Hides (2) displays the object on all chart periods,
   // --- (3) brings the object to the front, (4) locks, (5) unlocks the element,
      virtual void      Hide(const bool chart_redraw);
      virtual void      Show(const bool chart_redraw);
      virtual void      BringToTop(const bool chart_redraw);
      virtual void      Block(const bool chart_redraw);
      virtual void      Unblock(const bool chart_redraw);
      
   // --- Logs a description of the object
      virtual void      Print(void);
      
   // --- Prints a list of (1) attached objects, (2) areas
      void              PrintAttached(const uint tab=3);
      void              PrintBounds(void);

   // --- Event handler
      virtual void      OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam);
      
   // --- Timer event handler
      virtual void      TimerEventHandler(void);
      
   // --- Constructors/destructor
                        CPanel(void);
                        CPanel(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                        ~CPanel (void) { this.m_list_elm.Clear(); this.m_list_bounds.Clear(); }
  };
 #ifndef CPANEL_IMPLEMENTATION
 #define CPANEL_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CPanel::Default constructor.                                |
   // | Plots an element in the main window of the current chart |
   // | at coordinates 0,0 with default dimensions |
   //+------------------------------------------------------------------+
   CPanel::CPanel(void) : CLabel("Panel","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H)
    {
     // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CPanel::Parametric constructor.                             |
   // | Plots an element in the specified window of the specified chart |
   // | with specified text, coordinates and dimensions |
   //+------------------------------------------------------------------+
   CPanel::CPanel(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CLabel(object_name,text,chart_id,wnd,x,y,w,h)
    {
    // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CPanel::Initialization |
   //+------------------------------------------------------------------+
   void CPanel::Init(void)
    {
     // --- Initialize default colors
      this.InitColors();
     // --- Background is transparent, foreground is not      
      this.SetAlphaBG(255); //| Modify m_alpha_bg(0) to m_alpha_bg(255) to meet MT5 5716 version |
      this.SetAlphaFG(255);
     // --- Set the offset and dimensions of the image area
      this.SetImageBound(0,0,this.Width(),this.Height());
     // --- Frame width
      this.SetBorderWidth(2);
    }
   //+------------------------------------------------------------------+
   // | CPanel::Initializing default object colors |
   //+------------------------------------------------------------------+
   void CPanel::InitColors(void)
    {
     // --- Initialize the background colors for normal and activated states and make it the current background color
      this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
      this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
      this.BackColorToDefault();
      
     // --- Initialize the foreground colors for normal and activated states and make it the current text color
      this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
      this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
      this.ForeColorToDefault();
      
     // --- Initialize the border colors for the normal and activated states and make it the current border color
      this.InitBorderColors(clrNULL,clrNULL,clrNULL,clrNULL);
      this.InitBorderColorsAct(clrNULL,clrNULL,clrNULL,clrNULL);
      this.BorderColorToDefault();
      
     // --- Initialize the border color and foreground color for the blocked element
      this.InitBorderColorBlocked(clrNULL);
      this.InitForeColorBlocked(clrSilver);
    }
   //+------------------------------------------------------------------+
   // | CPanel::Comparing two objects |
   //+------------------------------------------------------------------+
   int CPanel::Compare(const CObject *node,const int mode=0) const
    {
      return CLabel::Compare(node,mode);
    }
   //+------------------------------------------------------------------+
   // | CPanel::Draws appearance |
   //+------------------------------------------------------------------+
   void CPanel::Draw(const bool chart_redraw)
    {
     // --- Fill the object with the background color
      this.Fill(this.BackColor(),false);
      
     // --- Clear the drawing area
      this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
     // --- Set the color for the dark and light lines and draw the panel frame
      color clr_dark =(this.BackColor()==clrNULL ? this.BackColor() : this.GetBackColorControl().NewColor(this.BackColor(),-20,-20,-20));
      color clr_light=(this.BackColor()==clrNULL ? this.BackColor() : this.GetBackColorControl().NewColor(this.BackColor(),  6,  6,  6));
      if(this.BorderWidthBottom()+this.BorderWidthLeft()+this.BorderWidthRight()+this.BorderWidthTop()!=0)
         this.m_painter.FrameGroupElements(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),
                                          this.m_painter.Width(),this.m_painter.Height(),this.Text(),
                                          this.ForeColor(),clr_dark,clr_light,this.AlphaFG(),true);
      
     // --- Updating the background canvas without redrawing the graph
      this.m_background.Update(false);      
     // --- Drawing list elements
      for(int i=0;i<this.m_list_elm.Total();i++)
      {
         CElementBase *elm=this.GetAttachedElementAt(i);
         //If not SCROLLBAR then Draw
         if(elm!=NULL && elm.Type()!=ELEMENT_TYPE_SCROLLBAR_H && elm.Type()!=ELEMENT_TYPE_SCROLLBAR_V)
            elm.Draw(false);
         //Print Debug
          if(elm != NULL)
            {
               // ::PrintFormat("DEBUG: [Draw Loop] Element: %s | Type: %d | Pos: (%d, %d)", 
               //             elm.Name(), elm.Type(), elm.X(), elm.Y());               
               elm.Draw(false);
            }
      }
     // --- If indicated, update the schedule
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
      //Print Debug
      ::Print(">>> CPanel::Draw: ", this.Name());
    }
   //+------------------------------------------------------------------+
   // | CPanel::Adds a new element to the list |
   //+------------------------------------------------------------------+
   bool CPanel::AddNewElement(CElementBase *element)
    {
     // --- If an empty pointer is passed, we report this and return false
      if(element==NULL)
      {
         ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
         return false;
      }
     // --- Remember the list sorting method
      int sort_mode=this.m_list_elm.SortMode();
     // --- Set the list to sort by identifier
      this.m_list_elm.Sort(ELEMENT_SORT_BY_ID);
     // --- If such element is not in the list,
      if(this.m_list_elm.Search(element)==NULL)
      {
         // --- return the list to its original sorting and return the result of adding it to the list
         this.m_list_elm.Sort(sort_mode);
         return(this.m_list_elm.Add(element)>-1);
      }
     // --- Return the list to its original sorting
      this.m_list_elm.Sort(sort_mode);
     // --- An element with the same identifier is already in the list - return false
      return false;
    }
   //+------------------------------------------------------------------+
   // | CPanel::Adds the specified element to the list |
   //+------------------------------------------------------------------+
   CElementBase *CPanel::InsertElement(CElementBase *element,const int dx,const int dy)
    {
     // --- If an empty or invalid pointer to an element is passed, return NULL
      if(::CheckPointer(element)==POINTER_INVALID)
      {
         ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
         return NULL;
      }
     // --- If a base element is passed, return NULL
      if(element.Type()==ELEMENT_TYPE_BASE)
      {
         ::PrintFormat("%s: Error. The base element cannot be used",__FUNCTION__);
         return NULL;
      }
     // --- Remember the element identifier and set a new one
      int id=element.ID();
      element.SetID(this.m_list_elm.Total());
      
     // --- Add an element to the list; if it fails, we report this, set the initial identifier and return NULL
      if(!this.AddNewElement(element))
      {
         //::PrintFormat("%s: Error. Failed to add element %s to list",__FUNCTION__,ElementDescription((ENUM_ELEMENT_TYPE)element.Type()));
         ::PrintFormat("%s: Error. Failed to add element to list: %s", __FUNCTION__, element.Description());
         element.SetID(id);
         return NULL;
      }
     // --- Set new coordinates, container and z-order of the element
      int x=this.X()+dx;
      int y=this.Y()+dy;
      element.Move(x,y);
      element.SetContainerObj(&this);
      element.ObjectSetZOrder(this.ObjectZOrder()+1);
      
     // --- Return a pointer to the attached element
      return element;
    }
   //+------------------------------------------------------------------+
   // | CPanel::Returns an element by ID |
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
   // | CPanel::Returns an element by the assigned object name |
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
   // | Creates and adds a new area to the list |
   //+------------------------------------------------------------------+
   CBound *CPanel::InsertNewBound(const string name,const int dx,const int dy,const int w,const int h)
    {
     // --- Check if there is an area with the specified name in the list and, if so, report it and return NULL
      this.m_temp_bound.SetName(name);
     // --- Remember the list sorting method
      int sort_mode=this.m_list_bounds.SortMode();
     // --- Set the list to sort by name
      this.m_list_bounds.Sort(ELEMENT_SORT_BY_NAME);
      if(this.m_list_bounds.Search(&this.m_temp_bound)!=NULL)
      {
         // --- We return the initial sorting to the list, inform that such an object already exists and return NULL
         this.m_list_bounds.Sort(sort_mode);
         ::PrintFormat("%s: Error. An area named \"%s\" is already in the list",__FUNCTION__,name);
         return NULL;
      }
     // --- Return the list to its original sorting
      this.m_list_bounds.Sort(sort_mode);
     // --- Create a new area object; if it fails, we report it and return NULL
      CBound *bound=new CBound(dx,dy,w,h);
      if(bound==NULL)
      {
         ::PrintFormat("%s: Error. Failed to create CBound object",__FUNCTION__);
         return NULL;
      }
     // --- Set the area name and identifier, and return a pointer to the object
      bound.SetName(name);
      bound.SetID(this.m_list_bounds.Total());
     // --- If a new object could not be added to the list, we report this, delete the object and return NULL
      if(this.m_list_bounds.Add(bound)==-1)
      {
         ::PrintFormat("%s: Error. Failed to add CBound object to list",__FUNCTION__);
         delete bound;
         return NULL;
      }
      return bound;
    }
   //+------------------------------------------------------------------+
   // | CPanel::Returns area by ID |
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
   // | CPanel::Returns the area by assigned area name |
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
   // | CPanel::Assigns an object to the specified area |
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
   // | CPanel::Unassigns an object from the specified area |
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
   // | Logs a description of an object |
   //+------------------------------------------------------------------+
   void CPanel::Print(void)
    {
      CBaseObj::Print();
      this.PrintAttached();
    }
   //+------------------------------------------------------------------+
   //| CPanel::Prints a list of attached objects |
   //+------------------------------------------------------------------+
   void CPanel::PrintAttached(const uint tab=3)
    {
     // --- In a loop through all bound elements
      int total=this.m_list_elm.Total();
      for(int i=0;i<total;i++)
      {
         // --- get another element
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm==NULL)
            continue;
         // --- Get the element type and, if it is a scroll bar, skip it
         ENUM_ELEMENT_TYPE type=(ENUM_ELEMENT_TYPE)elm.Type();
         if(type==ELEMENT_TYPE_SCROLLBAR_H || type==ELEMENT_TYPE_SCROLLBAR_V)
            continue;
         // --- Print out the description of the element in the magazine
         ::PrintFormat("%*s[%d]: %s",tab,"",i,elm.Description());
         // --- If the element is a container, print its list of attached elements to the log
         if(type==ELEMENT_TYPE_PANEL || type==ELEMENT_TYPE_GROUPBOX || type==ELEMENT_TYPE_CONTAINER)
         {
            CPanel *obj=elm;
            obj.PrintAttached(tab*2);
         }
      }
    }
   //+------------------------------------------------------------------+
   // | CPanel::Prints a list of areas |
   //+------------------------------------------------------------------+
   void CPanel::PrintBounds(void)
    {
     // --- In a loop through a list of element areas
      int total=this.m_list_bounds.Total();
      for(int i=0;i<total;i++)
      {
         // --- get the next area and print its description into the journal
         CBound *obj=this.GetBoundAt(i);
         if(obj==NULL)
            continue;
         ::PrintFormat("  [%d]: %s",i,obj.Description());
      }
    }
   //+------------------------------------------------------------------+
   // | CPanel::Sets an object to new X and Y coordinates |
   //+------------------------------------------------------------------+
   bool CPanel::Move(const int x,const int y)
    {
     // --- Calculate the distance by which the element will move
      int delta_x=x-this.X();
      int delta_y=y-this.Y();

     // --- Move the element to the specified coordinates
      bool res=this.ObjectMove(x,y);
      if(!res)
         return false;
      this.BoundMove(x,y);
      this.ObjectTrim();
      
     // --- Move all anchored elements to the calculated distance
      int total=this.m_list_elm.Total();
      for(int i=0;i<total;i++)
      {
         // --- Move the anchored element taking into account the offset of the parent element
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            res &=elm.Move(elm.X()+delta_x,elm.Y()+delta_y);
      }
     // --- Return the result of moving all bound elements
      return res;
    }
   //+------------------------------------------------------------------+
   // | CPanel::Shifts an object along the X and Y axes by the specified offset |
   //+------------------------------------------------------------------+
   bool CPanel::Shift(const int dx,const int dy)
    {
     // --- Shift the element by the specified distance
      bool res=this.ObjectShift(dx,dy);
      if(!res)
         return false;
      this.BoundShift(dx,dy);
      this.ObjectTrim();
      
     // --- Move all anchored elements
      int total=this.m_list_elm.Total();
      for(int i=0;i<total;i++)
      {
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            res &=elm.Shift(dx,dy);
      }
     // --- Return the result of the offset of all anchored elements
      return res;
    }
   //+------------------------------------------------------------------+
   // | CPanel::Sets both the coordinates and dimensions of an element |
   //+------------------------------------------------------------------+
   bool CPanel::MoveXYWidthResize(const int x,const int y,const int w,const int h)
    {
     // --- Calculate the distance by which the element will move
      int delta_x=x-this.X();
      int delta_y=y-this.Y();

     // --- Move the element to the specified coordinates with resizing
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
      
     // --- Move all anchored elements to the calculated distance
      bool res=true;
      int total=this.m_list_elm.Total();
      for(int i=0;i<total;i++)
      {
         // --- Move the anchored element taking into account the offset of the parent element
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            res &=elm.Move(elm.X()+delta_x,elm.Y()+delta_y);
      }
     // --- Return the result of moving all bound elements
      return res;
    }
   //+------------------------------------------------------------------+
   // | CPanel::Hides the object on all chart periods |
   //+------------------------------------------------------------------+
   void CPanel::Hide(const bool chart_redraw)
    {
     // --- If the object is already hidden, we leave
      if(this.m_hidden)
         return;
         
     // --- Hide the panel
      CCanvasBase::Hide(false);
     // --- Hiding attached objects
      for(int i=0;i<this.m_list_elm.Total();i++)
      {
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            elm.Hide(false);
      }
     // --- If indicated, redraw the graph
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CPanel::Displays an object on all chart periods |
   //+------------------------------------------------------------------+
   void CPanel::Show(const bool chart_redraw)
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
            if(elm.Type()==ELEMENT_TYPE_SCROLLBAR_H || elm.Type()==ELEMENT_TYPE_SCROLLBAR_V)
               continue;
            elm.Show(false);
         }
      }
     // --- If indicated, redraw the graph
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   //| CPanel::Brings the object to the front |
   //+------------------------------------------------------------------+
   void CPanel::BringToTop(const bool chart_redraw)
    {
     // --- Move the panel to the front
      CCanvasBase::BringToTop(false);
     // --- Place attached objects in the foreground
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
     // --- If indicated, redraw the graph
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   //| CPanel::Blocks element                                           |
   //+------------------------------------------------------------------+
   void CPanel::Block(const bool chart_redraw)
    {
     // --- If the element is already blocked, we leave
      if(this.m_blocked)
         return;
         
     // --- Lock the panel
      CCanvasBase::Block(false);
     // --- Blocking attached objects
      for(int i=0;i<this.m_list_elm.Total();i++)
      {
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            elm.Block(false);
      }
     // --- If indicated, redraw the graph
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CPanel::Unlocks element |
   //+------------------------------------------------------------------+
   void CPanel::Unblock(const bool chart_redraw)
    {
     // --- If the element is already unlocked, we leave
      if(!this.m_blocked)
         return;
         
     // --- Unlock the panel
      CCanvasBase::Unblock(false);
     // --- Unlock attached objects
      for(int i=0;i<this.m_list_elm.Total();i++)
      {
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            elm.Unblock(false);
      }
     // --- If indicated, redraw the graph
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CPanel::Saving to file |
   //+------------------------------------------------------------------+
   bool CPanel::Save(const int file_handle)
    {
     // --- Save the data of the parent object
      if(!CElementBase::Save(file_handle))
         return false;

     // --- Save the list of attached elements
      if(!this.m_list_elm.Save(file_handle))
         return false;
     // --- Save the list of areas
      if(!this.m_list_bounds.Save(file_handle))
         return false;
      
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
   // | CPanel::Loading from file |
   //+------------------------------------------------------------------+
   bool CPanel::Load(const int file_handle)
    {
     // --- Loading the data of the parent object
      if(!CElementBase::Load(file_handle))
         return false;
         
     // --- Loading the list of attached elements
      if(!this.m_list_elm.Load(file_handle))
         return false;
     // --- Loading a list of areas
      if(!this.m_list_bounds.Load(file_handle))
         return false;
      
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
   // | CPanel::Event Handler |
   //+------------------------------------------------------------------+
   void CPanel::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
    {
     // --- Call the event handler of the parent class
      CCanvasBase::OnChartEvent(id,lparam,dparam,sparam);
     // --- In a loop through all bound elements
      int total=this.m_list_elm.Total();
      for(int i=0;i<total;i++)
      {
         // --- get the next element and call its event handler
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            elm.OnChartEvent(id,lparam,dparam,sparam);
      }
    }
   //+------------------------------------------------------------------+
   // | CPanel::Timer event handler |
   //+------------------------------------------------------------------+
   void CPanel::TimerEventHandler(void)
    {
     // --- In a loop through all bound elements
      for(int i=0;i<this.m_list_elm.Total();i++)
      {
         // --- get the next element and call its timer event handler
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            elm.TimerEventHandler();
      }
    }
   #ifndef MOVE_TO_DELIB_MQH
   #define MOVE_TO_DELIB_MQH
      // //+------------------------------------------------------------------+
      // // | CPanel::Creates and adds a new element to the list |
      // //+------------------------------------------------------------------+
      // CElementBase *CPanel::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
      //  {
      //   // --- Create a name for the graphic object
      //    int elm_total=this.m_list_elm.Total();
      //    string obj_name=this.NameFG()+"_"+ElementShortName(type)+(string)elm_total;
      //   // --- Calculate coordinates
      //    int x=this.X()+dx;
      //    int y=this.Y()+dy;
      //   // --- Depending on the type of object, we create a new object
      //    CElementBase *element=NULL;
      //    switch(type)
      //    {
      //       case ELEMENT_TYPE_LABEL                      :  element = new CLabel(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);             break;   // Text label
      //       case ELEMENT_TYPE_BUTTON                     :  element = new CButton(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);            break;   // Simple button
      //       case ELEMENT_TYPE_BUTTON_TRIGGERED           :  element = new CButtonTriggered(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Two-position button
      //       case ELEMENT_TYPE_BUTTON_ARROW_UP            :  element = new CButtonArrowUp(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);     break;   // Up arrow button
      //       case ELEMENT_TYPE_BUTTON_ARROW_DOWN          :  element = new CButtonArrowDown(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Down arrow button
      //       case ELEMENT_TYPE_BUTTON_ARROW_LEFT          :  element = new CButtonArrowLeft(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Left Arrow Button
      //       case ELEMENT_TYPE_BUTTON_ARROW_RIGHT         :  element = new CButtonArrowRight(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);  break;   // Right arrow button
      //       case ELEMENT_TYPE_CHECKBOX                   :  element = new CCheckBox(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);          break;   // CheckBox control
      //       case ELEMENT_TYPE_RADIOBUTTON                :  element = new CRadioButton(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);       break;   // RadioButton control
      //       case ELEMENT_TYPE_SCROLLBAR_THUMB_H          :  element = new CScrollBarThumbH(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Scrollbar horizontal ScrollBar
      //       case ELEMENT_TYPE_SCROLLBAR_THUMB_V          :  element = new CScrollBarThumbV(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Vertical ScrollBar
      //       case ELEMENT_TYPE_SCROLLBAR_H                :  element = new CScrollBarH(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);        break;   // Horizontal ScrollBar control
      //       case ELEMENT_TYPE_SCROLLBAR_V                :  element = new CScrollBarV(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);        break;   // Vertical ScrollBar control
      //       case ELEMENT_TYPE_TABLE_ROW_VIEW             :  element = new CTableRowView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);      break;   // Table row visual object
      //       case ELEMENT_TYPE_TABLE_CAPTION_VIEW         :  element = new CCaptionView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);       break;   // Basic header object (View)
      //       case ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW  :  element = new CColumnCaptionView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h); break;   // Table column header visual representation object
      //       case ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW     :  element = new CRowCaptionView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);    break;   // Table row header visual representation object
      //       case ELEMENT_TYPE_TABLE_HEADER_VIEW          :  element = new CTableHeaderView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Table header visual object
      //       case ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW     :  element = new CTableRowsHeaderView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);break;  // Object for visual representation of table row headers
      //       case ELEMENT_TYPE_TABLE_VIEW                 :  element = new CTableView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);         break;   // Table visual object
      //       case ELEMENT_TYPE_PANEL                      :  element = new CPanel(obj_name,"",this.m_chart_id,this.m_wnd,x,y,w,h);               break;   // Panel control
      //       case ELEMENT_TYPE_GROUPBOX                   :  element = new CGroupBox(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);          break;   // GroupBox control
      //       case ELEMENT_TYPE_CONTAINER                  :  element = new CContainer(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);         break;   // Container control
      //       default                                      :  element = NULL;
      //    }

      //   // --- If a new element is not created, we report this and return NULL
      //    if(element==NULL)
      //    {
      //       ::PrintFormat("%s: Error. Failed to create graphic element %s",__FUNCTION__,ElementDescription(type));
      //       return NULL;
      //    }
      //   // --- Set the identifier, name, container and z-order of the element
      //    element.SetID(elm_total);
      //    element.SetName(user_name);
      //    element.SetContainerObj(&this);
      //    element.ObjectSetZOrder(this.ObjectZOrder()+1);
         
      //   // --- If the created element is not added to the list, we report this, delete the created element and return NULL
      //    if(!this.AddNewElement(element))
      //    {
      //       ::PrintFormat("%s: Error. Failed to add %s element with ID %d to list",__FUNCTION__,ElementDescription(type),element.ID());
      //       delete element;
      //       return NULL;
      //    }
      //   // --- We get the parent element to which the children are attached
      //    CElementBase *elm=this.GetContainer();
      //   // --- If the parent element is of type "Container", then it has scrollbars
      //    if(elm!=NULL && elm.Type()==ELEMENT_TYPE_CONTAINER)
      //    {
      //       // --- Convert CElementBase to CContainer
      //       CContainer *container_obj=elm;
      //       // --- If the horizontal scroll bar is visible,
      //       if(container_obj.ScrollBarHorzIsVisible())
      //       {
      //          // --- get a pointer to the horizontal scrollbar and move it to the front
      //          CScrollBarH *sbh=container_obj.GetScrollBarH();
      //          if(sbh!=NULL)
      //             sbh.BringToTop(false);
      //       }
      //       // --- If the vertical scroll bar is visible,
      //       if(container_obj.ScrollBarVertIsVisible())
      //       {
      //          // --- get the pointer to the vertical scrollbar and move it to the front
      //          CScrollBarV *sbv=container_obj.GetScrollBarV();
      //          if(sbv!=NULL)
      //             sbv.BringToTop(false);
      //       }
      //    }
      //   // --- Return a pointer to the created and attached element
      //    return element;
      //  }       
      //    //+------------------------------------------------------------------+
      // //| CPanel::Changes the width of an object |
      // //+------------------------------------------------------------------+
      // bool CPanel::ResizeW(const int w)
      //  {
      //    if(!this.ObjectResizeW(w))
      //       return false;
      //    this.BoundResizeW(w);
      //    this.SetImageSize(w,this.Height());
      //    if(!this.ObjectTrim())
      //    {
      //       this.Update(false);
      //       this.Draw(false);
      //    }
      //   // --- We get a pointer to the base element and, if it exists, its type - container,
      //   // --- check the ratio of the dimensions of the current element relative to the dimensions of the container
      //   // --- to display scrollbars in the container if necessary
      //   CCanvasBase *container_ptr = this.GetContainer();
      //   if(CheckPointer(container_ptr) != POINTER_INVALID)
      //    {
      //       // Check if the type matches before calling
      //       if(container_ptr.Type() == ELEMENT_TYPE_CONTAINER)
      //       {
      //          // Use dynamic pointer casting
      //          CContainer *base = (CContainer*)container_ptr);
               
      //          if(CheckPointer(base) != POINTER_INVALID)
      //          {
      //             base.CheckElementSizes(GetPointer(this));
      //          }
      //       }
      //    }
      //    /*
      //    if(this.GetContainer()!=NULL && this.GetContainer().Type()==ELEMENT_TYPE_CONTAINER)
      //    {         
      //       CContainer *base=this.GetContainer();
      //       base.CheckElementSizes(&this);
      //    }*/
            
      //   // --- In a loop through attached elements, we cut off each element along the boundaries of the container
      //    int total=this.m_list_elm.Total();
      //    for(int i=0;i<total;i++)
      //    {
      //       CElementBase *elm=this.GetAttachedElementAt(i);
      //       if(elm!=NULL)
      //          elm.ObjectTrim();
      //    }
      //   // --- Everything is successful
      //    return true;
      //  }
      // //+------------------------------------------------------------------+
      // // | CPanel::Changes the height of an object |
      // //+------------------------------------------------------------------+
      // bool CPanel::ResizeH(const int h)
      //  {
      //    if(!this.ObjectResizeH(h))
      //       return false;
      //    this.BoundResizeH(h);
      //    this.SetImageSize(this.Width(),h);
      //    if(!this.ObjectTrim())
      //    {
      //       this.Update(false);
      //       this.Draw(false);
      //    }
      //   // --- We get a pointer to the base element and, if it exists, its type - container,
      //   // --- check the ratio of the dimensions of the current element relative to the dimensions of the container
      //   // --- to display scrollbars in the container if necessary
      //    if(this.GetContainer()!=NULL && this.GetContainer().Type()==ELEMENT_TYPE_CONTAINER)
      //    {
      //       CContainer *base=this.GetContainer();
      //       base.CheckElementSizes(&this);
      //    }
            
      //   // --- In a loop through attached elements, we cut off each element along the boundaries of the container
      //    int total=this.m_list_elm.Total();
      //    for(int i=0;i<total;i++)
      //    {
      //       CElementBase *elm=this.GetAttachedElementAt(i);
      //       if(elm!=NULL)
      //          elm.ObjectTrim();
      //    }
      //   // --- Everything is successful
      //    return true;
      //  }
      // //+------------------------------------------------------------------+
      // // | CPanel::Resizes an object |
      // //+------------------------------------------------------------------+
      // bool CPanel::Resize(const int w,const int h)
      //  {
      //    if(!this.ObjectResize(w,h))
      //       return false;
      //    this.BoundResize(w,h);
      //    this.SetImageSize(w,h);
      //    if(!this.ObjectTrim())
      //    {
      //       this.Update(false);
      //       this.Draw(false);
      //    }
      //   // --- We get a pointer to the base element and, if it exists, its type - container,
      //   // --- check the ratio of the dimensions of the current element relative to the dimensions of the container
      //   // --- to display scrollbars in the container if necessary
      //    CContainer *base=this.GetContainer();
      //    if(base!=NULL && base.Type()==ELEMENT_TYPE_CONTAINER)
      //       base.CheckElementSizes(&this);
            
      //   // --- In a loop through attached elements, we cut off each element along the boundaries of the container
      //    int total=this.m_list_elm.Total();
      //    for(int i=0;i<total;i++)
      //    {
      //       CElementBase *elm=this.GetAttachedElementAt(i);
      //       if(elm!=NULL)
      //          elm.ObjectTrim();
      //    }
      //   // --- Everything is successful
      //    return true;
      //  }
   #endif // MOVE_TO_DELIB_MQH   
   //+------------------------------------------------------------------+
 #endif // CPANEL_IMPLEMENTATION
#endif // __PANEL_MQH__


