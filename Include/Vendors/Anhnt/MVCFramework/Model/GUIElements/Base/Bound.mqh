//+------------------------------------------------------------------+
//|                                                       Bound.mqh  |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+
#ifndef __BOUND_MQH__
#define __BOUND_MQH__

//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Controls/Rect.mqh>

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "BaseObj.mqh"

//+------------------------------------------------------------------+
//| Rectangle area class                                             |
//+------------------------------------------------------------------+
class CBound : public CBaseObj
  {
protected:
   CBaseObj         *m_assigned_obj;                          // Object assigned to the area
   CRect             m_bound;                                 // Rectangular area structure

public:
//--- Changes (1) width, (2) height, (3) size of the bounding rectangle
   void              ResizeW(const int size)                   { this.m_bound.Width(size);                                    }
   void              ResizeH(const int size)                   { this.m_bound.Height(size);                                   }
   void              Resize(const int w,const int h)           { this.m_bound.Width(w); this.m_bound.Height(h);               }
   
//--- Sets (1) X coordinate, (2) Y coordinate, (3) both coordinates of the bounding rectangle
   void              SetX(const int x)                         { this.m_bound.left=x;                                         }
   void              SetY(const int y)                         { this.m_bound.top=y;                                          }
   void              SetXY(const int x,const int y)            { this.m_bound.LeftTop(x,y);                                   }
   
//--- (1) Sets, (2) shifts the bounding rectangle by the specified coordinates/offset size
   void              Move(const int x,const int y)             { this.m_bound.Move(x,y);                                      }
   void              Shift(const int dx,const int dy)          { this.m_bound.Shift(dx,dy);                                   }
   
//--- Returns coordinates, sizes, and boundaries of the object
   int               X(void)                             const { return this.m_bound.left;                                    }
   int               Y(void)                             const { return this.m_bound.top;                                     }
   int               Width(void)                         const { return this.m_bound.Width();                                 }
   int               Height(void)                        const { return this.m_bound.Height();                                }
   int               Right(void)                         const { return this.m_bound.right-(this.m_bound.Width()  >0 ? 1 : 0);}
   int               Bottom(void)                        const { return this.m_bound.bottom-(this.m_bound.Height()>0 ? 1 : 0);}

//--- Returns a flag indicating if the cursor is inside the area
   bool              Contains(const int x,const int y)   const { return this.m_bound.Contains(x,y);                           }
   
//--- (1) Assigns, (2) unassigns, (3) returns a pointer to the assigned element
   void              AssignObject(CBaseObj *obj)               { this.m_assigned_obj=obj;                                     }
   void              UnassignObject(void)                      { this.m_assigned_obj=NULL;                                    }           
   CBaseObj         *GetAssignedObj(void)                      { return this.m_assigned_obj;                                  }
   
//--- Returns the object description
   virtual string    Description(void);
   
//--- Virtual methods for (1) comparison, (2) saving to file, (3) loading from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_RECTANGLE_AREA);                         }
   
//--- Constructors/destructor
                     CBound(void) { ::ZeroMemory(this.m_bound); }
                     CBound(const int x,const int y,const int w,const int h) { this.SetXY(x,y); this.Resize(w,h);              }
                    ~CBound(void) { ::ZeroMemory(this.m_bound); }
  };
//+------------------------------------------------------------------+
//| CBound::Returns the object description                           |
//+------------------------------------------------------------------+
string CBound::Description(void)
  {
   string nm=this.Name();
   string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   return ::StringFormat("%s%s: id %d, x %d, y %d, w %d, h %d, right %d, bottom %d",
                         ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.ID(),
                         this.X(),this.Y(),this.Width(),this.Height(),this.Right(),this.Bottom());
  }
//+------------------------------------------------------------------+
//| CBound::Comparison of two objects                                |
//+------------------------------------------------------------------+
int CBound::Compare(const CObject *node,const int mode=0) const
  {
   if(node==NULL)
      return -1;
   const CBound *obj=node;
   switch(mode)
     {
      case BASE_SORT_BY_NAME  :  return(this.Name()   >obj.Name()    ? 1 : this.Name()    <obj.Name()    ? -1 : 0);
      case BASE_SORT_BY_X     :  return(this.X()      >obj.X()       ? 1 : this.X()       <obj.X()       ? -1 : 0);
      case BASE_SORT_BY_Y     :  return(this.Y()      >obj.Y()       ? 1 : this.Y()       <obj.Y()       ? -1 : 0);
      case BASE_SORT_BY_WIDTH :  return(this.Width()  >obj.Width()   ? 1 : this.Width()   <obj.Width()   ? -1 : 0);
      case BASE_SORT_BY_HEIGHT:  return(this.Height() >obj.Height()  ? 1 : this.Height()  <obj.Height()  ? -1 : 0);
      default                 :  return(this.ID()     >obj.ID()      ? 1 : this.ID()      <obj.ID()      ? -1 : 0);
     }
  }
//+------------------------------------------------------------------+
//| CBound::Saving to file                                           |
//+------------------------------------------------------------------+
bool CBound::Save(const int file_handle)
  {
//--- Saving parent object data
   if(!CBaseObj::Save(file_handle))
      return false;
      
//--- Saving the area structure
   if(::FileWriteStruct(file_handle,this.m_bound)!=sizeof(this.m_bound))
      return(false);
   
//--- Success
   return true;
  }
//+------------------------------------------------------------------+
//| CBound::Loading from file                                        |
//+------------------------------------------------------------------+
bool CBound::Load(const int file_handle)
  {
//--- Loading parent object data
   if(!CBaseObj::Load(file_handle))
      return false;
      
//--- Loading the area structure
   if(::FileReadStruct(file_handle,this.m_bound)!=sizeof(this.m_bound))
      return(false);
   
//--- Success
   return true;
  }
//+------------------------------------------------------------------+
#endif