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
 #include "..\Entities\Graph\TradingLevelBubble.mqh"
 #ifndef CGRAPHELEMENTSCOLLECTION_MQH_DECLARATION
 #define CGRAPHELEMENTSCOLLECTION_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Root of every canvas element on every chart, owns the ZOrder     |
  //+------------------------------------------------------------------+
  class CGraphElementsCollection : public CBaseObj
    {
     private:
       CArrayObj         m_list_all_canv_elm_obj;   // owned canvas elements
       CArrayObj         m_list_registered_elm;     // registered, not owned
       CArrayObj         m_list_bubble_ctrl;        // owned CTradingLevelBubbles, one per chart
       long              m_watch_chart_id[];        // charts that hold elements
       int               m_objects_total_prev[];    // ObjectsTotal per watched chart at the last check
       bool              m_prev_left;               // left button state at the previous mouse event

       void              WatchChart(const long chart_id);
       void              CheckChartObjectsTotal(void);
       bool              IsPresentCanvElm(CGElement *element);
       bool              IsRegisteredElm(CGElement *element);
       bool              IsBackground(CGElement *element);
       int               CollectElements(CGElement *&elements[]);
       void              RemoveInvalidRegistered(void);
     public:
       CGraphElementsCollection *GetObject(void)                  { return &this;                          }
       CArrayObj        *GetListCanvElm(void)                     { return &this.m_list_all_canv_elm_obj;  }
       CArrayObj        *GetListRegisteredElm(void)               { return &this.m_list_registered_elm;    }
       bool              AddCanvElmToCollection(CGElement *element);
       bool              RegisterElement(CGElement *element);
       bool              DeleteCanvElm(CGElement *element);
       CGElement        *GetCanvElement(const long chart_id,const string name);
       long              GetZOrderMax(void);
       bool              SetZOrderMAX(CGElement *obj);
       void              BringToTopAllCanvElm(void);
       bool              IsCoveredByHigherElement(const int x,const int y,CGElement *element);
       CTradingLevelBubbles *CreateTradingLevelBubbles(const long chart_id,CMarketCollection *market,CTradingControl *trading_control);
       //Life cycle
        void              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
        void              OnTimer(void);
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
     this.m_list_all_canv_elm_obj.FreeMode(true);
     this.m_list_registered_elm.FreeMode(false);
     this.m_list_bubble_ctrl.FreeMode(true);
    }
  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CGraphElementsCollection::~CGraphElementsCollection(void)
    {
     this.m_list_bubble_ctrl.Clear();
     this.m_list_registered_elm.Clear();
     this.m_list_all_canv_elm_obj.Clear();
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
  //| True if the element is in either list                            |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::IsPresentCanvElm(CGElement *element)
    {
     CObject *obj=element;
     for(int i=0;i<this.m_list_all_canv_elm_obj.Total();i++)
        if(this.m_list_all_canv_elm_obj.At(i)==obj)
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
  //| Both lists in one array, sorted by ZOrder ascending              |
  //+------------------------------------------------------------------+
  int CGraphElementsCollection::CollectElements(CGElement *&elements[])
    {
     this.RemoveInvalidRegistered();
     int total=0;
     ::ArrayResize(elements,this.m_list_all_canv_elm_obj.Total()+this.m_list_registered_elm.Total());
     for(int i=0;i<this.m_list_all_canv_elm_obj.Total();i++)
       {
        CGElement *elm=dynamic_cast<CGElement *>(this.m_list_all_canv_elm_obj.At(i));
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
  //| Take ownership of a created element, stacked on top              |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::AddCanvElmToCollection(CGElement *element)
    {
     if(::CheckPointer(element)==POINTER_INVALID)
        return false;
     if(this.IsPresentCanvElm(element))
        return true;
     if(!this.IsBackground(element))
        element.SetZorder(this.GetZOrderMax()+1,false);
     if(!this.m_list_all_canv_elm_obj.Add(element))
        return false;
     this.WatchChart(element.ChartID());
     return true;
    }
  //+------------------------------------------------------------------+
  //| Register an element owned elsewhere, stacked on top              |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::RegisterElement(CGElement *element)
    {
     if(::CheckPointer(element)==POINTER_INVALID)
        return false;
     if(this.IsPresentCanvElm(element))
        return true;
     if(!this.IsBackground(element))
        element.SetZorder(this.GetZOrderMax()+1,false);
     if(!this.m_list_registered_elm.Add(element))
        return false;
     this.WatchChart(element.ChartID());
     return true;
    }
  //+------------------------------------------------------------------+
  //| Owned: delete, registered: detach only                           |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::DeleteCanvElm(CGElement *element)
    {
     CObject *obj=element;
     for(int i=0;i<this.m_list_all_canv_elm_obj.Total();i++)
        if(this.m_list_all_canv_elm_obj.At(i)==obj)
           return this.m_list_all_canv_elm_obj.Delete(i);
     for(int i=0;i<this.m_list_registered_elm.Total();i++)
        if(this.m_list_registered_elm.At(i)==obj)
           return (this.m_list_registered_elm.Detach(i)!=NULL);
     return false;
    }
  //+------------------------------------------------------------------+
  //| Element by chart ID and full object name                         |
  //+------------------------------------------------------------------+
  CGElement *CGraphElementsCollection::GetCanvElement(const long chart_id,const string name)
    {
     CGElement *elements[];
     int total=this.CollectElements(elements);
     for(int i=0;i<total;i++)
        if(elements[i].ChartID()==chart_id && elements[i].Name()==name)
           return elements[i];
     return NULL;
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
  //| Owned elements get the event; a press raises the topmost element |
  //| under the cursor                                                 |
  //+------------------------------------------------------------------+
  void CGraphElementsCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
    {
     long chart_id=::ChartID();
     for(int i=0;i<this.m_list_all_canv_elm_obj.Total();i++)
       {
        CGElement *elm=dynamic_cast<CGElement *>(this.m_list_all_canv_elm_obj.At(i));
        if(elm==NULL || elm.ChartID()!=chart_id)
           continue;
        //--- A bubble under a panel window must not take the mouse
        CTradingLevelBubble *bubble=dynamic_cast<CTradingLevelBubble *>(elm);
        if(bubble!=NULL && id==CHARTEVENT_MOUSE_MOVE)
           bubble.SetCovered(this.IsCoveredByHigherElement((int)lparam,(int)dparam,bubble));
        elm.OnChartEvent(id,lparam,dparam,sparam);
       }
     bool restack=false;
     for(int i=0;i<this.m_list_bubble_ctrl.Total();i++)
       {
        CTradingLevelBubbles *ctrl=this.m_list_bubble_ctrl.At(i);
        if(ctrl==NULL || ctrl.ChartID()!=chart_id)
           continue;
        ctrl.OnChartEvent(id,lparam,dparam,sparam);
        if(ctrl.TakeRestackRequest())
           restack=true;
       }
     if(restack)
        this.BringToTopAllCanvElm();   // a bubble just shown sits on top - put the windows back above it
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
  //| Owned elements get the timer; watched charts are checked         |
  //+------------------------------------------------------------------+
  void CGraphElementsCollection::OnTimer(void)
    {
     for(int i=0;i<this.m_list_all_canv_elm_obj.Total();i++)
       {
        CGElement *elm=dynamic_cast<CGElement *>(this.m_list_all_canv_elm_obj.At(i));
        if(elm!=NULL)
           elm.OnTimerEvent();
       }
     bool restack=false;
     for(int i=0;i<this.m_list_bubble_ctrl.Total();i++)
       {
        CTradingLevelBubbles *ctrl=this.m_list_bubble_ctrl.At(i);
        if(ctrl==NULL)
           continue;
        ctrl.OnTimer();
        if(ctrl.TakeRestackRequest())
           restack=true;
       }
     if(restack)
        this.BringToTopAllCanvElm();
     this.CheckChartObjectsTotal();
    }
  //+------------------------------------------------------------------+
  //| True if a visible, non-background element with a higher ZOrder   |
  //| on the same chart contains x,y                                   |
  //+------------------------------------------------------------------+
  bool CGraphElementsCollection::IsCoveredByHigherElement(const int x,const int y,CGElement *element)
    {
     if(element==NULL)
        return false;
     CGElement *elements[];
     int total=this.CollectElements(elements);
     for(int i=0;i<total;i++)
       {
        CGElement *elm=elements[i];
        if(elm==element || elm.ChartID()!=element.ChartID() || !elm.IsVisible() || this.IsBackground(elm))
           continue;
        if(elm.Zorder()>element.Zorder() && elm.CursorInsideElement(x,y))
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
  //+------------------------------------------------------------------+
  //| SL/TP bubbles of a chart: controller + 4 elements, all owned     |
  //+------------------------------------------------------------------+
  CTradingLevelBubbles *CGraphElementsCollection::CreateTradingLevelBubbles(const long chart_id,CMarketCollection *market,CTradingControl *trading_control)
    {
     for(int i=0;i<this.m_list_bubble_ctrl.Total();i++)
       {
        CTradingLevelBubbles *existing=this.m_list_bubble_ctrl.At(i);
        if(existing!=NULL && existing.ChartID()==chart_id)
           return existing;
       }
     CTradingLevelBubbles *ctrl=new CTradingLevelBubbles();
     if(ctrl==NULL)
        return NULL;
     bool ok=ctrl.Create(chart_id,market,trading_control);
     for(int i=0;i<BUBBLE_TOTAL;i++)
       {
        CTradingLevelBubble *bubble=ctrl.Bubble(i);
        if(bubble==NULL)
           continue;
        if(!this.AddCanvElmToCollection(bubble))
           delete bubble;
       }
     if(!ok || !this.m_list_bubble_ctrl.Add(ctrl))
       {
        ::Print(__FUNCTION__," > failed for chart ",chart_id);
        delete ctrl;
        return NULL;
       }
     ctrl.Refresh();
     return ctrl;
    }
 #endif // CGRAPHELEMENTSCOLLECTION_MQH_IMPLEMENTATION
#endif // __GRAPHELEMENTSCOLLECTION_MQH__
