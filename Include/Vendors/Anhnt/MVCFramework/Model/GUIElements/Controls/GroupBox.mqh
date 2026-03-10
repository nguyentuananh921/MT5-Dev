//+------------------------------------------------------------------+
//|                                                      GroupBox.mqh|
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                   https://www.mql5.com/en/articles/19979         |
//+------------------------------------------------------------------+

#ifndef __GROUPBOX_MQH__
#define __GROUPBOX_MQH__
//+------------------------------------------------------------------+
//| Group container class                                            |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "ElementBase.mqh"
#include "Panel.mqh"
#include "..\Base\BaseEnums.mqh"
   //   Panel.mqh
   //   → Label.mqh
   //   → ElementBase.mqh
   //   → CanvasBase.mqh
   //   → BoundedObj.mqh
   //   → BaseObj.mqh
   //   → Object.mqh

class CGroupBox : public CPanel
  {
public:

//--- Object type
   virtual int Type(void) const { return(ELEMENT_TYPE_GROUPBOX); }

//--- Class initialization
   void Init(void);

//--- Set element group
   virtual void SetGroup(const int group);

//--- Create and insert (1) new, (2) existing element into list
   virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
   virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);

//--- Constructors / destructor
   CGroupBox(void);
   CGroupBox(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
   ~CGroupBox(void){}
  };

//+------------------------------------------------------------------+
//| Default constructor                                              |
//| Builds element in main chart window at 0,0                       |
//| using default size                                               |
//+------------------------------------------------------------------+
CGroupBox::CGroupBox(void) :
CPanel("GroupBox","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H)
  {
   this.Init();
  }

//+------------------------------------------------------------------+
//| Parameterized constructor                                        |
//| Builds element in specified chart window with given parameters   |
//+------------------------------------------------------------------+
CGroupBox::CGroupBox(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
CPanel(object_name,text,chart_id,wnd,x,y,w,h)
  {
   this.Init();
  }

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CGroupBox::Init(void)
  {
   CPanel::Init();
  }

//+------------------------------------------------------------------+
//| Set group for element and all attached elements                  |
//+------------------------------------------------------------------+
void CGroupBox::SetGroup(const int group)
  {
   CElementBase::SetGroup(group);

   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         //elm.SetGroup(group);
         elm->SetGroup(group);
     }
  }

//+------------------------------------------------------------------+
CElementBase *CGroupBox::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
  {
   CElementBase *element=CPanel::InsertNewElement(type,text,user_name,dx,dy,w,h);
   if(element==NULL)
      return NULL;

   //element.SetGroup(this.Group());
   element->SetGroup(this.Group());
   return element;
  }

//+------------------------------------------------------------------+
CElementBase *CGroupBox::InsertElement(CElementBase *element,const int dx,const int dy)
  {
   if(CPanel::InsertElement(element,dx,dy)==NULL)
      return NULL;

   //element.SetGroup(this.Group());
   element->SetGroup(this.Group());
   return element;
  }

#endif