//+------------------------------------------------------------------+
//|                                      GraphElementsCollection.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                             https://mql5.com/en/users/artmedia70 |
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
//--- The chart objects drawn on the chart itself (the markers of the candles): V3 had here also the ZOrder of the windows, the windows of V4
//--- belong to CGUIPannel, so only the layer and its items come from V3. Methods come from V3 one by one when a class asks for them
#ifndef __GRAPHELEMENTSCOLLECTION_MQH__
#define __GRAPHELEMENTSCOLLECTION_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Entities\Bases\BaseObj.mqh"
 #include "..\Entities\GBases\GBaseObj.mqh"
 #include "..\Entities\GBases\GLayer.mqh"
 #include "..\Entities\GBases\GLayerItem.mqh"
 #define GRAPH_ELEMENTS_FIT_INTERVAL_MS 200   // the size of the layer is compared with the chart at most this often
#ifndef CGRAPHELEMENTSCOLLECTION_MQH_DECLARATION
#define CGRAPHELEMENTSCOLLECTION_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The children (AddChild) are owned. The ones that are CGLayerItem |
 //| have no canvas: the collection owns one canvas over the chart    |
 //| and asks them to paint on it                                     |
 //+------------------------------------------------------------------+
 class CGraphElementsCollection : public CGBaseObj
  {
   private:
    CGLayer           m_layer;                   // shared canvas of the CGLayerItem children
    bool              m_fit_pending;             // the chart changed: the size of the layer is checked at the next timer beat that is GRAPH_ELEMENTS_FIT_INTERVAL_MS after the last check
    ulong             m_fit_last_ms;
   //--- Clear the layer, every CGLayerItem child paints itself, one update for all of them
    void              RedrawLayer(void);
   public:
   //--- Lifecycle: the layer is made before the panel windows, so they stack above it
    void              OnInit(void);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    virtual void      OnTimerEvent(void);
                      CGraphElementsCollection(void) : m_fit_pending(false),m_fit_last_ms(0) { }
  };
#endif // CGRAPHELEMENTSCOLLECTION_MQH_DECLARATION
#ifndef CGRAPHELEMENTSCOLLECTION_MQH_IMPLEMENTATION
#define CGRAPHELEMENTSCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| The layer over the chart, made before the panel windows           |
 //+------------------------------------------------------------------+
 void CGraphElementsCollection::OnInit(void)
  {
   if(!this.m_layer.IsCreated())
      this.m_layer.Create(::ChartID(),"GraphElementsLayer");
   this.m_layer.FitChart();
   CGLayerItem::Invalidate();
   this.m_first_start=false;
  }
 //+------------------------------------------------------------------+
 //| The layer follows the size of the chart; the children get the    |
 //| event (the mouse on a badge, Shift)                              |
 //+------------------------------------------------------------------+
 void CGraphElementsCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   long chart_id=::ChartID();
   if(id==CHARTEVENT_CHART_CHANGE)
      this.m_fit_pending=true;   // the size is asked at the timer: a zoom sends many of these and each ask waits for the chart to be drawn
   for(int i=0;i<this.ChildrenTotal();i++)
     {
      CGBaseObj *child=this.Child(i);
      if(child!=NULL && child.ChartID()==chart_id)
         child.OnChartEvent(id,lparam,dparam,sparam);
     }
  }
 //+------------------------------------------------------------------+
 //| The children get the timer; the layer is painted again when a    |
 //| child asked for it                                               |
 //+------------------------------------------------------------------+
 void CGraphElementsCollection::OnTimerEvent(void)
  {
   if(this.m_fit_pending && ::GetTickCount64()-this.m_fit_last_ms>=GRAPH_ELEMENTS_FIT_INTERVAL_MS)
     {
      this.m_fit_pending=false;
      this.m_fit_last_ms=::GetTickCount64();
      if(this.m_layer.FitChart())
         CGLayerItem::Invalidate();
     }
   for(int i=0;i<this.ChildrenTotal();i++)
     {
      CGBaseObj *child=this.Child(i);
      if(child!=NULL)
         child.OnTimerEvent();
     }
   if(CGLayerItem::ConsumeInvalidated())
      this.RedrawLayer();
  }
 void CGraphElementsCollection::RedrawLayer(void)
  {
   if(!this.m_layer.IsCreated())
      return;
   CCanvas *canvas=this.m_layer.Canvas();
   this.m_layer.Clear();
   for(int i=0;i<this.ChildrenTotal();i++)
     {
      CGLayerItem *item=dynamic_cast<CGLayerItem *>(this.Child(i));
      if(item!=NULL)
         item.Paint(canvas);
     }
   this.m_layer.Commit();
   ::ChartRedraw(this.m_layer.ChartID());
  }
#endif // CGRAPHELEMENTSCOLLECTION_MQH_IMPLEMENTATION
#endif // __GRAPHELEMENTSCOLLECTION_MQH__
