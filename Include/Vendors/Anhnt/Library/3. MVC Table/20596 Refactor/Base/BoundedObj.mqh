//+------------------------------------------------------------------+
//|                                                 BoundedObj.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//| MVC Paradigm in MQL5                                             |
//|First See in              https://www.mql5.com/en/articles/17960  |
//|Current                    https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Base class storing object dimensions |
//+------------------------------------------------------------------+
#ifndef __BOUNDEDOBJ_MQH__
#define __BOUNDEDOBJ_MQH__
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+

   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "BaseObj.mqh"
   #include "Bound.mqh"
 class CBoundedObj : public CBaseObj
  {
   protected:
      CBound            m_bound;                                  // Object boundaries
      bool              m_canvas_owner;                           // Canvas ownership flag
   public:
   // --- Returns the coordinates, dimensions and boundaries of an object
      int               X(void)                             const { return this.m_bound.X();                                                          }
      int               Y(void)                             const { return this.m_bound.Y();                                                          }
      int               Width(void)                         const { return this.m_bound.Width();                                                      }
      int               Height(void)                        const { return this.m_bound.Height();                                                     }
      int               Right(void)                         const { return this.m_bound.Right();                                                      }
      int               Bottom(void)                        const { return this.m_bound.Bottom();                                                     }

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
      
   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      //virtual int       Compare(const CObject *node,const int mode=0) const;
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                          const { return(ELEMENT_TYPE_BOUNDED_BASE); }
                        
                        CBoundedObj (void) : m_canvas_owner(true) {}
                        CBoundedObj (const string user_name,const int id,const int x,const int y,const int w,const int h);
                        ~CBoundedObj (void){}
 };
//+------------------------------------------------------------------+
#ifndef CBOUNDEDOBJ_IMPLEMENTATION
#define CBOUNDEDOBJ_IMPLEMENTATION
   // | CBoundedObj::Constructor |
   //+------------------------------------------------------------------+
   CBoundedObj::CBoundedObj(const string user_name,const int id,const int x,const int y,const int w,const int h) : m_canvas_owner(true)
   {
      // --- Get the adjusted graph ID and distance in pixels along the vertical Y axis
         this.m_bound.SetName(user_name);
         this.m_bound.SetID(id);
         this.m_bound.SetXY(x,y);
         this.m_bound.Resize(w,h);
   }
   //+------------------------------------------------------------------+
   //| CBoundedObj::Saving to file                                      |
   //+------------------------------------------------------------------+
   bool CBoundedObj::Save(const int file_handle)
   {
      // --- Save the data of the parent object
         if(!CBaseObj::Save(file_handle))
            return false;
      
      // ---Keeping the canvas ownership flag
         if(::FileWriteInteger(file_handle,this.m_canvas_owner,INT_VALUE)!=INT_VALUE)
            return false;
      // --- Save dimensions
         return this.m_bound.Save(file_handle);
   }
   //+------------------------------------------------------------------+
   //| CBoundedObj::Loading from file                                   |
   //+------------------------------------------------------------------+
   bool CBoundedObj::Load(const int file_handle)
   {
      // --- Loading the data of the parent object
         if(!CBaseObj::Load(file_handle))
            return false;
         
      // --- Loading the canvas ownership flag
         this.m_canvas_owner=::FileReadInteger(file_handle,INT_VALUE);
      // --- Loading dimensions
         return this.m_bound.Load(file_handle);
   }
   //+------------------------------------------------------------------+
#endif // CBOUNDEDOBJ_IMPLEMENTATION
#endif // __BOUNDEDOBJ_MQH__
