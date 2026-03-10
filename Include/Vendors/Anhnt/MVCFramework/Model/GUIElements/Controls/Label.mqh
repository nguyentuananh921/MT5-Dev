//+------------------------------------------------------------------+
//|                                                        Label.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                   https://www.mql5.com/en/articles/19979         |
//+------------------------------------------------------------------+

#ifndef __LABEL_MQH__
#define __LABEL_MQH__
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Object.mqh>  
//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "..\Base\BaseEnums.mqh"
#include "ElementBase.mqh"
// ElementBase
// → CanvasBase
// → BoundedObj
// → BaseObj
// → Object
//+------------------------------------------------------------------+
//| Text label class                                                 |
//+------------------------------------------------------------------+
class CLabel : public CElementBase
  {
protected:
   ushort m_text[];        // Text
   ushort m_text_prev[];   // Previous text
   int m_text_x;           // Text X coordinate (offset from left border)
   int m_text_y;           // Text Y coordinate (offset from top border)

   //--- (1) Set, (2) get previous text
   void   SetTextPrev(const string text) { ::StringToShortArray(text,this.m_text_prev); }
   string TextPrev(void) const { return ::ShortArrayToString(this.m_text_prev); }

   //--- Clears text
   void ClearText(void);

public:

   //--- (1) Set, (2) get text
   void   SetText(const string text) { ::StringToShortArray(text,this.m_text); }
   string Text(void) const { return ::ShortArrayToString(this.m_text); }

   //--- Get text coordinates
   int TextX(void) const { return this.m_text_x; }
   int TextY(void) const { return this.m_text_y; }

   //--- Set text coordinates
   void SetTextShiftH(const int x){ this.ClearText(); this.m_text_x=x; }
   void SetTextShiftV(const int y){ this.ClearText(); this.m_text_y=y; }

   //--- Draw text
   virtual void DrawText(const int dx,const int dy,const string text,const bool chart_redraw);

   //--- Draw appearance
   virtual void Draw(const bool chart_redraw);

   //--- Virtual methods
   virtual int  Compare(const CObject *node,const int mode=0) const;
   virtual bool Save(const int file_handle);
   virtual bool Load(const int file_handle);
   virtual int  Type(void) const { return(ELEMENT_TYPE_LABEL); }

   //--- Initialization
   void Init(const string text);
   virtual void InitColors(void){}

   //--- Constructors / destructor
   CLabel(void);
   CLabel(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
   ~CLabel(void){}
  };

#endif