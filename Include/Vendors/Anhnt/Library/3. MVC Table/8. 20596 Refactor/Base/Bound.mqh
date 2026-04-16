//+------------------------------------------------------------------+
//|                                                      Bound.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in: Base graphical element                             |
//|                           https://www.mql5.com/en/articles/17960 |
//| Update in: Simple controls                                       |
//|                           https://www.mql5.com/en/articles/18221 |
//| Update in                                                        |
//|       Integrating the Model Component into the View Component    |
//|                           https://www.mql5.com/en/articles/19288 | 
//|Current                    https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Rectangular Area Class                                          |
//+------------------------------------------------------------------+
#ifndef __BOUND_MQH__
#define __BOUND_MQH__
 //+------------------------------------------------------------------+
 //| Included Standard Libraries                                      |
 //+------------------------------------------------------------------+
   
 #include <Controls\Rect.mqh>
 //+------------------------------------------------------------------+
 //| Included Custome Libraries                                       |
 //+------------------------------------------------------------------+
 #include "BaseObj.mqh" 
 class CBound : public CBaseObj
 {
   protected:
      //| Update in                                                        |
      //|       Integrating the Model Component into the View Component    |
      //|                           https://www.mql5.com/en/articles/19288 | 
       CBaseObj         *m_assigned_obj;                           // Object assigned to area
      CRect             m_bound;                                  // Rectangular area structure

   public:
   // --- Changes the (1) width, (2) height, (3) size of the bounding box
      void              ResizeW(const int size)                   { this.m_bound.Width(size);                                    }
      void              ResizeH(const int size)                   { this.m_bound.Height(size);                                   }
      void              Resize(const int w,const int h)           { this.m_bound.Width(w); this.m_bound.Height(h);               }
      
   // --- Sets the (1) X, (2) Y, (3) both coordinates of the bounding box
      void              SetX(const int x)                         { this.m_bound.left=x;                                         }
      void              SetY(const int y)                         { this.m_bound.top=y;                                          }
      void              SetXY(const int x,const int y)            { this.m_bound.LeftTop(x,y);                                   }
      
   // --- (1) Sets, (2) offsets the bounding box by the specified coordinates/offset size
      void              Move(const int x,const int y)             { this.m_bound.Move(x,y);                                      }
      void              Shift(const int dx,const int dy)          { this.m_bound.Shift(dx,dy);                                   }
      
   // --- Returns the coordinates, dimensions and boundaries of an object
      int               X(void)                             const { return this.m_bound.left;                                    }
      int               Y(void)                             const { return this.m_bound.top;                                     }
      int               Width(void)                         const { return this.m_bound.Width();                                 }
      int               Height(void)                        const { return this.m_bound.Height();                                }
      int               Right(void)                         const { return this.m_bound.right-(this.m_bound.Width()  >0 ? 1 : 0);}
      int               Bottom(void)                        const { return this.m_bound.bottom-(this.m_bound.Height()>0 ? 1 : 0);}
   //| Update in                                                        |
   //|       Simple controls                                            |
   //|                           https://www.mql5.com/en/articles/18221 |
     // --- Returns the flag that the cursor is inside the area
      bool              Contains(const int x,const int y)   const { return this.m_bound.Contains(x,y);                           }
   //| Update in                                                        |
   //|       Integrating the Model Component into the View Component    |
   //|                           https://www.mql5.com/en/articles/19288 |    
      // --- (1) Assigns, (2) unassigns, (3) returns a pointer to the assigned element
         void              AssignObject(CBaseObj *obj)               { this.m_assigned_obj=obj;                                     }
         void              UnassignObject(void)                      { this.m_assigned_obj=NULL;                                    }           
         CBaseObj         *GetAssignedObj(void)                      { return this.m_assigned_obj;                                  }
      
   // --- Returns a description of the object
         virtual string    Description(void);
      
   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0) const;
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_RECTANGLE_AREA);                         }
      
   // --- Constructors/destructor
                        CBound(void) { ::ZeroMemory(this.m_bound); }
                        CBound(const int x,const int y,const int w,const int h) { this.SetXY(x,y); this.Resize(w,h);             }
                        ~CBound(void) { ::ZeroMemory(this.m_bound); }
  };
 #ifndef CBOUND_IMPLEMENTATION
 #define CBOUND_IMPLEMENTATION
  //+------------------------------------------------------------------+
  // | CBound::Returns the description of an object |
  //+------------------------------------------------------------------+
  string CBound::Description(void)
   {
      //--- 1. Get the basic description from the Parent class (CBaseObj)
      //--- This will return: "TypeName: Name (ID 123)"
      string baseDesc = CBaseObj::Description();
      
      //--- 2. Append the specific boundary information
      return ::StringFormat("%s, X %d, Y %d, W %d, H %d, R %d, B %d",
                           baseDesc,
                           this.X(), this.Y(), this.Width(), this.Height(), 
                           this.Right(), this.Bottom());
   }
  //+------------------------------------------------------------------+
  // | CBound::Comparing two objects |
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
  // | CBound::Saving to file |
  //+------------------------------------------------------------------+
  bool CBound::Save(const int file_handle)
   {
      // --- Save the data of the parent object
         if(!CBaseObj::Save(file_handle))
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
      // --- Loading the data of the parent object
         if(!CBaseObj::Load(file_handle))
            return false;
            
      // --- Loading the area structure
         if(::FileReadStruct(file_handle,this.m_bound)!=sizeof(this.m_bound))
            return(false);
         
      // --- Everything is successful
         return true;
   }
   //+------------------------------------------------------------------+
 #endif // DECLARATION_IMPLEMENTATION
#endif // __BOUND_MQH__
