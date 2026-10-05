//+------------------------------------------------------------------+
//|                                      GraphElementsCollection.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __GRAPHELEMENTSCOLLECTION_MQH__
#define __GRAPHELEMENTSCOLLECTION_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Entities\Bases\BaseObj.mqh"
 #include "..\Entities\GBases\GElement.mqh"
 #ifndef CGRAPHELEMENTSCOLLECTION_MQH_DECLARATION
 #define CGRAPHELEMENTSCOLLECTION_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Root of every chart object and canvas element, owns the ZOrder.  |
  //| Its children (AddChild) are owned and told nothing about their   |
  //| kind: events, timer and "covered by a window" go through the     |
  //| CGBaseObj hooks                                                  |
  //+------------------------------------------------------------------+
  class CGraphElementsCollection : public CGBaseObj
    {
     private:
       CArrayObj         m_list_registered_elm;     // registered windows, not owned
       long              m_watch_chart_id[];        // charts that hold elements
       int               m_objects_total_prev[];    // ObjectsTotal per watched chart at the last check
       bool              m_prev_left;               // left button state at the previous mouse event

       void              WatchChart(const long chart_id);
       void              CheckChartObjectsTotal(void);
       bool              IsPresentElm(CGElement *element);
       bool              IsRegisteredElm(CGElement *element);
       bool              IsBackground(CGElement *element);
       int               CollectElements(CGElement *&elements[]);
       void              RemoveInvalidRegistered(void);
     public:
       //--- A CGElement child also gets the top ZOrder
       virtual bool      AddChild(CGBaseObj *child);
       bool              RegisterElement(CGElement *element);
       long              GetZOrderMax(void);
       bool              SetZOrderMAX(CGElement *obj);
       void              BringToTopAllCanvElm(void);
       bool              IsCoveredAt(const long chart_id,const int x,const int y);
       //Life cycle
        virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
        virtual void      OnTimerEvent(void);
                          CGraphElementsCollection(void);
                         ~CGraphElementsCollection(void);
    };
 #endif // CGRAPHELEMENTSCOLLECTION_MQH_DECLARATION
 #ifndef CGRAPHELEMENTSCOLLECTION_MQH_IMPLEMENTATION
 #define CGRAPHELEMENTSCOLLECTION_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CGraphElementsCollection::CGraphElementsCollection(void) : m_prev_left(false)
    {
     this.m_list_registered_elm.FreeMode(false);
    }
  //+------------------------------------------------------------------+
  //| Destructor: the children are freed by CGBaseObj                  |
  //+------------------------------------------------------------------+
  CGraphElementsCollection::~CGraphElementsCollection(void)
    {
     this.m_list_registered_elm.Clear();
    }
  //+------------------------------------------------------------------+
  //| Start tracking ObjectsTotal of a chart                           |
  //+------------------------------------------------------------------+
  void CGraphElementsCollection::WatchChart(const long chart_id)
    {
     int total=::ArraySize(this.m_watch_chart_id);
     for(int i=0;i<total;i++)
        if(this.m_watch_chart_id[i]==chart_id)
           return;
     ::ArrayResize(this.m_watch_chart_id,total+1);
     ::ArrayResize(this.m_objects_total_prev,total+1);
     this.m_watch_chart_id[total]=chart_id;
     this.m_objects_total_prev[total]=::ObjectsTotal(chart_id);
    }
  //+------------------------------------------------------------------+
  //| A new object on a watched chart may cover the canvases           |
  //+------------------------------------------------------------------+
  void CGraphElementsCollection::CheckChartObjectsTotal(void)
    {
     bool changed=false;
     for(int i=0;i<::ArraySize(this.m_watch_chart_id);i++)
       {
        int total=::ObjectsTotal(this.m_watch_chart_id[i]);
        if(total==this.m_objects_total_prev[i])
           continue;
        this.m_objects_total_prev[i]=total;
        changed=true;
       }
     if(changed)
        this.BringToTopAllCanvElm();
    }
  //+------------------------------------------------------------------+
  //| True if the element is a child or registered                     |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::IsPresentElm(CGElement *element)
    {
     CObject *obj=element;
     for(int i=0;i<this.ChildrenTotal();i++)
        if(this.Child(i)==obj)
           return true;
     for(int i=0;i<this.m_list_registered_elm.Total();i++)
        if(this.m_list_registered_elm.At(i)==obj)
           return true;
     return false;
    }
  //+------------------------------------------------------------------+
  //| Background layer (behind the candles): never re-raised           |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::IsBackground(CGElement *element)
    {
     return (bool)::ObjectGetInteger(element.ChartID(),element.Name(),OBJPROP_BACK);
    }
  //+------------------------------------------------------------------+
  //| Drop registered elements whose owner is already gone             |
  //+------------------------------------------------------------------+
  void CGraphElementsCollection::RemoveInvalidRegistered(void)
    {
     for(int i=this.m_list_registered_elm.Total()-1;i>=0;i--)
        if(::CheckPointer(this.m_list_registered_elm.At(i))==POINTER_INVALID)
           this.m_list_registered_elm.Detach(i);
    }
  //+------------------------------------------------------------------+
  //| Child elements and registered elements in one array, sorted by   |
  //| ZOrder ascending                                                 |
  //+------------------------------------------------------------------+
  int CGraphElementsCollection::CollectElements(CGElement *&elements[])
    {
     this.RemoveInvalidRegistered();
     int total=0;
     ::ArrayResize(elements,this.ChildrenTotal()+this.m_list_registered_elm.Total());
     for(int i=0;i<this.ChildrenTotal();i++)
       {
        CGElement *elm=dynamic_cast<CGElement *>(this.Child(i));
        if(elm!=NULL)
           elements[total++]=elm;
       }
     for(int i=0;i<this.m_list_registered_elm.Total();i++)
       {
        CGElement *elm=dynamic_cast<CGElement *>(this.m_list_registered_elm.At(i));
        if(elm!=NULL)
           elements[total++]=elm;
       }
     ::ArrayResize(elements,total);
     for(int i=1;i<total;i++)
       {
        CGElement *key=elements[i];
        int j=i-1;
        while(j>=0 && elements[j].Zorder()>key.Zorder())
          {
           elements[j+1]=elements[j];
           j--;
          }
        elements[j+1]=key;
       }
     return total;
    }
  //+------------------------------------------------------------------+
  //| Take ownership of a child; a canvas element is stacked on top    |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::AddChild(CGBaseObj *child)
    {
     if(::CheckPointer(child)==POINTER_INVALID)
        return false;
     CGElement *element=dynamic_cast<CGElement *>(child);
     if(element!=NULL && !this.IsPresentElm(element) && !this.IsBackground(element))
        element.SetZorder(this.GetZOrderMax()+1,false);
     if(!CGBaseObj::AddChild(child))
        return false;
     this.WatchChart(child.ChartID()==0 ? ::ChartID() : child.ChartID());
     return true;
    }
  //+------------------------------------------------------------------+
  //| Register an element owned elsewhere, stacked on top              |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::RegisterElement(CGElement *element)
    {
     if(::CheckPointer(element)==POINTER_INVALID)
        return false;
     if(this.IsPresentElm(element))
        return true;
     if(!this.IsBackground(element))
        element.SetZorder(this.GetZOrderMax()+1,false);
     if(!this.m_list_registered_elm.Add(element))
        return false;
     this.WatchChart(element.ChartID());
     return true;
    }
  //+------------------------------------------------------------------+
  //| Maximum ZOrder of all elements                                   |
  //+------------------------------------------------------------------+
  long CGraphElementsCollection::GetZOrderMax(void)
    {
     CGElement *elements[];
     int total=this.CollectElements(elements);
     return (total>0 ? elements[total-1].Zorder() : 0);
    }
  //+------------------------------------------------------------------+
  //| DoEasy SetZOrderMAX: obj on top, the others one step down        |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::SetZOrderMAX(CGElement *obj)
    {
     if(obj==NULL || this.IsBackground(obj))
        return false;
     CGElement *elements[];
     int  total=this.CollectElements(elements);
     long max  =(total>0 ? elements[total-1].Zorder() : 0);
     long value=(max==0 ? 1 : max<total-1 ? max+1 : total-1);
     if(!obj.SetZorder(value,false))
        return false;
     bool res=true;
     for(int i=0;i<total;i++)
       {
        CGElement *elm=elements[i];
        if(elm==obj || elm.Zorder()==0 || this.IsBackground(elm))
           continue;
        if(!elm.SetZorder(elm.Zorder()-1,false))
           res&=false;
       }
     return res;
    }
  //+------------------------------------------------------------------+
  //| DoEasy BringToTopAllCanvElm: re-raise in ZOrder order            |
  //+------------------------------------------------------------------+
  void CGraphElementsCollection::BringToTopAllCanvElm(void)
    {
     CGElement *elements[];
     int total=this.CollectElements(elements);
     for(int i=0;i<total;i++)
        if(!this.IsBackground(elements[i]))
           elements[i].BringToTop();
     for(int i=0;i<::ArraySize(this.m_watch_chart_id);i++)
        ::ChartRedraw(this.m_watch_chart_id[i]);
    }
  //+------------------------------------------------------------------+
  //| Children get the event and, on a mouse move, whether a window    |
  //| covers the cursor; a press raises the topmost element under it   |
  //+------------------------------------------------------------------+
  void CGraphElementsCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
    {
     long chart_id=::ChartID();
     bool covered=(id==CHARTEVENT_MOUSE_MOVE && this.IsCoveredAt(chart_id,(int)lparam,(int)dparam));
     for(int i=0;i<this.ChildrenTotal();i++)
       {
        CGBaseObj *child=this.Child(i);
        if(child==NULL || child.ChartID()!=chart_id)
           continue;
        if(id==CHARTEVENT_MOUSE_MOVE)
           child.SetCovered(covered);
        child.OnChartEvent(id,lparam,dparam,sparam);
       }
     //--- A child was just shown on top of the windows: put the windows back above it
     if(id==CHARTEVENT_CUSTOM+ON_BRING_TO_TOP)
       {
        this.BringToTopAllCanvElm();
        return;
       }
     //--- A window just opened: it goes on top of the ZOrder too, not only visually
     if(id==CHARTEVENT_CUSTOM+ON_OPEN_DIALOG_BOX)
       {
        CGElement *opened[];
        int opened_total=this.CollectElements(opened);
        for(int i=0;i<opened_total;i++)
           if(opened[i].ObjectID()==lparam)
             {
              this.SetZOrderMAX(opened[i]);
              this.BringToTopAllCanvElm();
              break;
             }
        return;
       }
     if(id!=CHARTEVENT_MOUSE_MOVE)
        return;
     bool left=((((uint)::StringToInteger(sparam)) & 1)==1);
     bool pressed_now=(left && !this.m_prev_left);
     this.m_prev_left=left;
     if(!pressed_now)
        return;
     CGElement *elements[];
     int total=this.CollectElements(elements);
     for(int i=total-1;i>=0;i--)
       {
        CGElement *elm=elements[i];
        if(elm.ChartID()!=chart_id || !elm.IsVisible() || this.IsBackground(elm) || !elm.CursorInsideElement((int)lparam,(int)dparam))
           continue;
        if(elm.IsLocked() || !this.IsRegisteredElm(elm))   // only panel windows are raised by a press
           return;
        if(elm.Zorder()<elements[total-1].Zorder())
          {
           this.SetZOrderMAX(elm);
           this.BringToTopAllCanvElm();
          }
        return;
       }
    }
  //+------------------------------------------------------------------+
  //| Children get the timer; watched charts are checked               |
  //+------------------------------------------------------------------+
  void CGraphElementsCollection::OnTimerEvent(void)
    {
     for(int i=0;i<this.ChildrenTotal();i++)
       {
        CGBaseObj *child=this.Child(i);
        if(child!=NULL)
           child.OnTimerEvent();
       }
     this.CheckChartObjectsTotal();
    }
  //+------------------------------------------------------------------+
  //| True if any visible, non-background element of the chart         |
  //| contains x,y (for objects that are not elements themselves)      |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::IsCoveredAt(const long chart_id,const int x,const int y)
    {
     CGElement *elements[];
     int total=this.CollectElements(elements);
     for(int i=0;i<total;i++)
       {
        CGElement *elm=elements[i];
        if(elm.ChartID()==chart_id && elm.IsVisible() && !this.IsBackground(elm) && elm.CursorInsideElement(x,y))
           return true;
       }
     return false;
    }
  //+------------------------------------------------------------------+
  //| True if the element is in the registered (not owned) list        |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::IsRegisteredElm(CGElement *element)
    {
     CObject *obj=element;
     for(int i=0;i<this.m_list_registered_elm.Total();i++)
        if(this.m_list_registered_elm.At(i)==obj)
           return true;
     return false;
    }
 #endif // CGRAPHELEMENTSCOLLECTION_MQH_IMPLEMENTATION
#endif // __GRAPHELEMENTSCOLLECTION_MQH__
