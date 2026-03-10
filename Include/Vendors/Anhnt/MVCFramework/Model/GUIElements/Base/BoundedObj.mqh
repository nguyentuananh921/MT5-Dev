//+------------------------------------------------------------------+
//|                                                 BoundedObj.mqh   |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __BOUNDEDOBJ_MQH__
#define __BOUNDEDOBJ_MQH__
//+------------------------------------------------------------------+
//| Base class storing object size and bounds                        |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Bound.mqh"


class CBoundedObj : public CBaseObj
  {
protected:
   CBound m_bound;          // Object bounds
   bool   m_canvas_owner;   // Canvas ownership flag

public:

//--- Return coordinates and dimensions
   int X(void) const { return this.m_bound.X(); }
   int Y(void) const { return this.m_bound.Y(); }
   int Width(void) const { return this.m_bound.Width(); }
   int Height(void) const { return this.m_bound.Height(); }
   int Right(void) const { return this.m_bound.Right(); }
   int Bottom(void) const { return this.m_bound.Bottom(); }

//--- Resize bounding rectangle
   void BoundResizeW(const int size){ this.m_bound.ResizeW(size); }
   void BoundResizeH(const int size){ this.m_bound.ResizeH(size); }
   void BoundResize(const int w,const int h){ this.m_bound.Resize(w,h); }

//--- Set coordinates
   void BoundSetX(const int x){ this.m_bound.SetX(x); }
   void BoundSetY(const int y){ this.m_bound.SetY(y); }
   void BoundSetXY(const int x,const int y){ this.m_bound.SetXY(x,y); }

//--- Move rectangle
   void BoundMove(const int x,const int y){ this.m_bound.Move(x,y); }
   void BoundShift(const int dx,const int dy){ this.m_bound.Shift(dx,dy); }

//--- Virtual methods
   virtual bool Save(const int file_handle);
   virtual bool Load(const int file_handle);
   virtual int Type(void) const { return(ELEMENT_TYPE_BOUNDED_BASE); }

//--- Constructors
   CBoundedObj(void):m_canvas_owner(true){}

   CBoundedObj(const string user_name,const int id,const int x,const int y,const int w,const int h);

   ~CBoundedObj(void){}
  };

//+------------------------------------------------------------------+
//| CBoundedObj constructor                                          |
//+------------------------------------------------------------------+
CBoundedObj::CBoundedObj(const string user_name,const int id,const int x,const int y,const int w,const int h) : m_canvas_owner(true)
  {
   this.m_bound.SetName(user_name);
   this.m_bound.SetID(id);
   this.m_bound.SetXY(x,y);
   this.m_bound.Resize(w,h);
  }

//+------------------------------------------------------------------+
//| Save to file                                                     |
//+------------------------------------------------------------------+
bool CBoundedObj::Save(const int file_handle)
  {
   if(!CBaseObj::Save(file_handle))
      return false;

   if(::FileWriteInteger(file_handle,this.m_canvas_owner,INT_VALUE)!=INT_VALUE)
      return false;

   return this.m_bound.Save(file_handle);
  }

//+------------------------------------------------------------------+
//| Load from file                                                   |
//+------------------------------------------------------------------+
bool CBoundedObj::Load(const int file_handle)
  {
   if(!CBaseObj::Load(file_handle))
      return false;

   this.m_canvas_owner=::FileReadInteger(file_handle,INT_VALUE);

   return this.m_bound.Load(file_handle);
  }

#endif