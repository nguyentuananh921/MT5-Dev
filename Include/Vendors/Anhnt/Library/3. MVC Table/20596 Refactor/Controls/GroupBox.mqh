//+------------------------------------------------------------------+
//|                                                   GroupBox.mqh   |
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

#ifndef __GROUPBOX_MQH__
#define __GROUPBOX_MQH__
       //+------------------------------------------------------------------+
   // | Object Group Class |
   //+------------------------------------------------------------------+
   class CGroupBox : public CPanel
   {
      public:
      // ---Object type
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_GROUPBOX); }
      
      // --- Initializing a class object
         void              Init(void);
         
      // --- Sets a group of elements
         virtual void      SetGroup(const int group);
         
      // --- Creates and adds (1) a new, (2) a previously created element to the list
         virtual CElementBase *InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h);
         virtual CElementBase *InsertElement(CElementBase *element,const int dx,const int dy);

      // --- Constructors/destructor
                           CGroupBox(void);
                           CGroupBox(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                        ~CGroupBox(void) {}
   };
   #ifndef CGROUPBOX_IMPLEMENTATION
   #define CGROUPBOX_IMPLEMENTATION
      //+------------------------------------------------------------------+
      // | CGroupBox::Default constructor.                             |
      // | Plots an element in the main window of the current chart |
      // | at coordinates 0,0 with default dimensions |
      //+------------------------------------------------------------------+
      CGroupBox::CGroupBox(void) : CPanel("GroupBox","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H)
      {
      // ---Initialization
         this.Init();
      }
      //+------------------------------------------------------------------+
      // | CGroupBox::Parametric constructor.                          |
      // | Plots an element in the specified window of the specified chart |
      // | with specified text, coordinates and dimensions |
      //+------------------------------------------------------------------+
      CGroupBox::CGroupBox(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
         CPanel(object_name,text,chart_id,wnd,x,y,w,h)
      {
      // ---Initialization
         this.Init();
      }
      //+------------------------------------------------------------------+
      // | CGroupBox::Initialization |
      //+------------------------------------------------------------------+
      void CGroupBox::Init(void)
      {
      // ---Initialization using parent class
         CPanel::Init();
      }
      //+------------------------------------------------------------------+
      // | CGroupBox::Sets a group of elements |
      //+------------------------------------------------------------------+
      void CGroupBox::SetGroup(const int group)
      {
      // --- Set the group to this element using the parent class method
         CElementBase::SetGroup(group);
      // --- In a loop through a list of bound elements
         for(int i=0;i<this.m_list_elm.Total();i++)
         {
            // --- get the next element and assign a group to it
            CElementBase *elm=this.GetAttachedElementAt(i);
            if(elm!=NULL)
               elm.SetGroup(group);
         }
      }
      //+------------------------------------------------------------------+
      // | CGroupBox::Creates and adds a new element to the list |
      //+------------------------------------------------------------------+
      CElementBase *CGroupBox::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
      {
      // --- Create and add a new element to the list of elements
         CElementBase *element=CPanel::InsertNewElement(type,text,user_name,dx,dy,w,h);
         if(element==NULL)
            return NULL;
      // --- Set the created element to a group equal to the group of this object
         element.SetGroup(this.Group());
         return element;
      }
      //+------------------------------------------------------------------+
      // | CGroupBox::Adds the specified element to the list |
      //+------------------------------------------------------------------+
      CElementBase *CGroupBox::InsertElement(CElementBase *element,const int dx,const int dy)
      {
      // --- Add a new element to the list of elements
         if(CPanel::InsertElement(element,dx,dy)==NULL)
            return NULL;
      // --- Set the added element to a group equal to the group of this object
         element.SetGroup(this.Group());
         return element;
      }
      //+------------------------------------------------------------------+
   #endif // CGROUPBOX_IMPLEMENTATION
#endif // __GROUPBOX_MQH__


