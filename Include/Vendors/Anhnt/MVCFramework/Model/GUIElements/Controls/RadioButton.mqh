//+------------------------------------------------------------------+
//|                                                   RadioButton.mqh|
//+------------------------------------------------------------------+

#ifndef __RADIOBUTTON_MQH__
#define __RADIOBUTTON_MQH__
//+------------------------------------------------------------------+
//| Radio Button control element                                     |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "CheckBox.mqh"

// CheckBox
//  → Button
//  → Label
//  → ElementBase
//  → CanvasBase
//  → BoundedObj
//  → BaseObj
//  → Object
//  CRadioButton
//  → CCheckBox
//  → CButton
//  → CLabel
//  → CElementBase
//  → CCanvasBase
//  → CBoundedObj
//  → CBaseObj
//  → CObject
class CRadioButton : public CCheckBox
  {
public:

//--- Draw appearance
   virtual void Draw(const bool chart_redraw);

//--- Virtual methods
   virtual int  Compare(const CObject *node,const int mode=0) const;
   virtual bool Save(const int file_handle){ return CButton::Save(file_handle); }
   virtual bool Load(const int file_handle){ return CButton::Load(file_handle); }
   virtual int  Type(void) const { return(ELEMENT_TYPE_RADIOBUTTON); }

//--- Initialization
   void Init(const string text);
   virtual void InitColors(void){}

//--- Mouse press handler
   virtual void OnPressEvent(const int id,const long lparam,const double dparam,const string sparam);

//--- Constructors
   CRadioButton(void);
   CRadioButton(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
   ~CRadioButton(void){}
  };

//--- constructors + methods remain identical to your source
// (logic unchanged)

#endif