//+------------------------------------------------------------------+
//|                                                BarMarkerSync.mqh |
//+------------------------------------------------------------------+
//--- The View of what the library and Python found on the bars: one CBarMarker for each candle of the chart (and side) that has something, from the table
//--- BarTimeSeriesCollection (the types of information) and from SignalsCollection (the signals of the indicator templates), only what the user wants
//--- to see. A candle has one marker for each side it has (Buy, Sell): the colour says the side, the icon the collection(s) that found it (CSignalsCollection, CBarTimeSeriesCollection). It opens no database and writes no SQL (Sync Everywhere): it asks the
//--- classes that own the rows (the CBarSeriesDE of the chart pair: the table UNION RAM; CSignalsCollection; CBarInformationManager and CIndicatorTemplateManager for what is shown) and draws
//--- again, by events: the library tells a candle that has something new (SERIES_EVENT_PATTERN: that candle only, or all of them when it takes the pair over from Python),
//--- the chart moved or zoomed, or the user changed what is shown
#ifndef __BARMARKERSYNC_MQH__
#define __BARMARKERSYNC_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Graph\Composite\BarMarker.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\GraphElementsCollection.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\BarTimeSeriesCollection.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\SignalsCollection.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\Settings\SyncManager.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\Settings\BarInformationManager.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Collections\Settings\IndicatorTemplateManager.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Defines\BarDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Defines\EventDefines.mqh>
 #define BAR_MARKER_NAME            "BarMarker_"
#ifndef CBARMARKERSYNC_MQH_DECLARATION
#define CBARMARKERSYNC_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Draws what was found on the candles of the chart                 |
 //+------------------------------------------------------------------+
 class CBarMarkerSync : public CBaseObj
  {
   private:
    CGraphElementsCollection  *m_GraphElementsCollection;    // EA owns: the markers are its children
    CBarTimeSeriesCollection  *m_BarTimeSeriesCollection;    // EA owns: the owner of the tables the types are asked to
    CSignalsCollection        *m_SignalsCollection;          // EA owns: the owner of the tables the signals are asked to
    CBarInformationManager    *m_BarInformationManager;      // EA owns: which types, and which side of them, the user wants to see
    CIndicatorTemplateManager *m_IndicatorTemplateManager;   // EA owns: which templates, and which side of them, the user wants to see
    bool                       m_arrange_pending;            // the chart moved or zoomed: the markers are placed again at the next beat of the timer
    datetime                   m_from_time;                  // the oldest and the newest bar of the chart the markers were made for: they follow the chart when it moves or zooms
    datetime                   m_to_time;
    long                       m_keys[];                     // what is to be drawn, sorted: time of the candle * 2 + the side (SIGNAL_DIRECTION_BUY / SIGNAL_DIRECTION_SELL)
    bool                       m_from_signals[];             // CSignalsCollection (COLLECTION_SIGNALS_ID) found each key
    bool                       m_from_series[];              // CBarTimeSeriesCollection (COLLECTION_SERIES_ID) found it
    color                      MarkerColour(const bool is_buy) const;
   //--- A candle and a side are put in the sorted list (the same candle and side again: the collections come together)
    void                       Collect(const datetime time,const bool is_buy,const long collection);   // collection = the m_type of the one that found it
   //--- The oldest and the newest bar the chart shows now (false while the chart has not its bars yet)
    bool                       VisibleRange(datetime &from_time,datetime &to_time) const;
   //--- The rows of the table go to the list: the types of information, then the signals of the indicator templates
    int                        CollectTypes(const long symbol_id,const datetime from_time,const datetime to_time);
    int                        CollectIndicators(const long symbol_id,const datetime from_time,const datetime to_time);
   public:
                               CBarMarkerSync(void) : m_GraphElementsCollection(NULL),m_BarTimeSeriesCollection(NULL),m_SignalsCollection(NULL),m_BarInformationManager(NULL),
                                                      m_IndicatorTemplateManager(NULL),m_arrange_pending(false),m_from_time(0),m_to_time(0) { }
    bool                       OnInitEvent(CGraphElementsCollection *collection,CBarTimeSeriesCollection *series,CSignalsCollection *signals,
                                           CBarInformationManager *information,CIndicatorTemplateManager *templates);   
   //--- The user changed what is shown: the markers are drawn again
    void                       OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

    void                       DeleteMarkers_BarTimeSeriesCollection(void);   
   //--- Every beat of the timer: the markers follow the chart when it moved or zoomed (one Arrange for all the chart events since the last beat)
    void                       ArrangeIfPending(void);
   //--- The markers of the chart: only the types, templates and sides the user wants to see
    void                       SyncMarkers_BarTimeSeriesCollection(const datetime time=0);   // time: only the markers of that candle (an event told it), 0: the whole chart
   
  };
#endif // CBARMARKERSYNC_MQH_DECLARATION
#ifndef CBARMARKERSYNC_MQH_IMPLEMENTATION
#define CBARMARKERSYNC_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| The classes it asks                                              |
 //+------------------------------------------------------------------+
 bool CBarMarkerSync::OnInitEvent(CGraphElementsCollection *collection,CBarTimeSeriesCollection *series,CSignalsCollection *signals,
                                   CBarInformationManager *information,CIndicatorTemplateManager *templates)
  {
   this.m_GraphElementsCollection=collection;
   this.m_BarTimeSeriesCollection=series;
   this.m_SignalsCollection=signals;
   this.m_BarInformationManager=information;
   this.m_IndicatorTemplateManager=templates;
   return (collection!=NULL && series!=NULL && signals!=NULL && information!=NULL && templates!=NULL);
  }
 //--- The colour of a marker: Buy and Sell
 color CBarMarkerSync::MarkerColour(const bool is_buy) const
  {
   return (is_buy ? EA_MARKER_BUY_COLOR : EA_MARKER_SELL_COLOR);
  }
 //+------------------------------------------------------------------+
 //| The list is sorted by candle and side: a binary search says where |
 //| the key is or goes                                                |
 //+------------------------------------------------------------------+
 void CBarMarkerSync::Collect(const datetime time,const bool is_buy,const long collection)
  {
   long key=(long)time*2+(is_buy ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL);
   int total=::ArraySize(m_keys);
   int low=0,high=total;
   while(low<high)
     {
      int mid=(low+high)/2;
      if(m_keys[mid]<key)
         low=mid+1;
      else
         high=mid;
     }
   if(low<total && m_keys[low]==key)
     {
      m_from_signals[low]=(m_from_signals[low] || collection==COLLECTION_SIGNALS_ID);
      m_from_series[low]=(m_from_series[low] || collection==COLLECTION_SERIES_ID);
      return;
     }
   ::ArrayResize(m_keys,total+1);
   ::ArrayResize(m_from_signals,total+1);
   ::ArrayResize(m_from_series,total+1);
   for(int i=total;i>low;i--)
     {
      m_keys[i]=m_keys[i-1];
      m_from_signals[i]=m_from_signals[i-1];
      m_from_series[i]=m_from_series[i-1];
     }
   m_keys[low]=key;
   m_from_signals[low]=(collection==COLLECTION_SIGNALS_ID);
   m_from_series[low]=(collection==COLLECTION_SERIES_ID);
  }
 //+------------------------------------------------------------------+
 //| The types of information: the sides the user wants to see         |
 //+------------------------------------------------------------------+
 int CBarMarkerSync::CollectTypes(const long symbol_id,const datetime from_time,const datetime to_time)
  {
   long buy_types[],sell_types[];
   this.m_BarInformationManager.ShownTypes(buy_types,sell_types);
   long types[],times[],sides[];
   CBarSeriesDE *series=this.m_BarTimeSeriesCollection.GetSeries(::Symbol(),(ENUM_TIMEFRAMES)::Period());   // the chart pair is always a pair of Setting_SymbolTF: its control reads the table UNION RAM
   int rows=(series!=NULL ? series.GetBarControl().ReadTypes(from_time,to_time,buy_types,sell_types,types,times,sides) : 0);
   for(int i=0;i<rows;i++)
      this.Collect((datetime)times[i],sides[i]==SIGNAL_DIRECTION_BUY,COLLECTION_SERIES_ID);
   return rows;
  }
 //+------------------------------------------------------------------+
 //| The signals of the indicator templates: the Buy and the Sell flag |
 //| of a template say which of its signals are shown                  |
 //+------------------------------------------------------------------+
 int CBarMarkerSync::CollectIndicators(const long symbol_id,const datetime from_time,const datetime to_time)
  {
   long buy_templates[],sell_templates[];
   this.m_IndicatorTemplateManager.ShownTemplates(buy_templates,sell_templates);
   long times[],sides[];
   int rows=this.m_SignalsCollection.Read_SignalsCollection(symbol_id,(ENUM_TIMEFRAMES)::Period(),from_time,to_time,buy_templates,sell_templates,times,sides);
   for(int i=0;i<rows;i++)
      this.Collect((datetime)times[i],sides[i]==SIGNAL_DIRECTION_BUY,COLLECTION_SIGNALS_ID);
   return rows;
  }
 //+------------------------------------------------------------------+
 //| The oldest and the newest bar of the chart                       |
 //+------------------------------------------------------------------+
 bool CBarMarkerSync::VisibleRange(datetime &from_time,datetime &to_time) const
  {
   int first=(int)::ChartGetInteger(::ChartID(),CHART_FIRST_VISIBLE_BAR);
   int last=first-(int)::ChartGetInteger(::ChartID(),CHART_VISIBLE_BARS)+1;   // the chart can show room after the newest bar
   if(last<0)
      last=0;
   from_time=::iTime(::Symbol(),(ENUM_TIMEFRAMES)::Period(),first);
   to_time=::iTime(::Symbol(),(ENUM_TIMEFRAMES)::Period(),last);
   return (from_time!=0 && to_time!=0);
  }
 //+------------------------------------------------------------------+
 //| The markers of the bars the chart shows: scrolled or zoomed, the  |
 //| ones that came into view are made, the ones that left go. An event |
 //| tells one candle: only its markers are read and compared           |
 //+------------------------------------------------------------------+
 void CBarMarkerSync::SyncMarkers_BarTimeSeriesCollection(const datetime time=0)
  {
   if(this.m_BarTimeSeriesCollection==NULL || this.m_GraphElementsCollection==NULL)
      return;
   long symbol_id=this.m_BarTimeSeriesCollection.SymbolID(::Symbol());
   if(symbol_id==0)
     {
      this.DeleteMarkers_BarTimeSeriesCollection();
      return;
     }
   datetime from_time=time,to_time=time;
   if(time==0)
     {
      if(!this.VisibleRange(from_time,to_time))
         return;   // the chart has not its bars yet: the markers stay as they are
      m_from_time=from_time;
      m_to_time=to_time;
     }
   ::ArrayResize(m_keys,0);
   ::ArrayResize(m_from_signals,0);
   ::ArrayResize(m_from_series,0);
   this.CollectTypes(symbol_id,from_time,to_time);
   this.CollectIndicators(symbol_id,from_time,to_time);
   int total=::ArraySize(m_keys);
   //--- Only the difference is drawn: a marker that is the same as the table says stays, one that is not wanted any more (or whose collections changed) goes
   bool kept[];
   ::ArrayResize(kept,total);
   ::ArrayInitialize(kept,false);
   bool changed=false;
   for(int i=this.m_GraphElementsCollection.ChildrenTotal()-1;i>=0;i--)
     {
      CGBaseObj *child=this.m_GraphElementsCollection.Child(i);
      CBarMarker *old=dynamic_cast<CBarMarker *>(child);
      if(old==NULL)
         continue;
      long key=::StringToInteger(::StringSubstr(old.Name(),::StringLen(BAR_MARKER_NAME)));
      if(time!=0 && key/2!=(long)time)
         continue;   // an event told one candle: the markers of the others are not looked at
      int low=0,high=total;
      while(low<high)
        {
         int mid=(low+high)/2;
         if(m_keys[mid]<key)
            low=mid+1;
         else
            high=mid;
        }
      if(low<total && m_keys[low]==key && m_from_signals[low]==old.FromSignals() && m_from_series[low]==old.FromSeries() && !kept[low])
        {
         kept[low]=true;
         continue;
        }
      if(!changed)
         CBarMarker::ReleaseBox();
      changed=true;
      this.m_GraphElementsCollection.DeleteChild(child);
      delete child;
     }
   //--- Every marker is made before any is placed: the first geometry query after a new object waits for the chart to rebuild
   CBarMarker *markers[];
   ::ArrayResize(markers,total);
   for(int i=0;i<total;i++)
     {
      markers[i]=NULL;
      if(kept[i])
         continue;
      changed=true;
      CBarMarker *marker=new CBarMarker();
      if(marker==NULL || !marker.Create(::ChartID(),0,BAR_MARKER_NAME+(string)m_keys[i]) || !this.m_GraphElementsCollection.AddChild(marker))
        {
         delete marker;
         continue;
        }
      markers[i]=marker;
     }
   string symbol=::Symbol();
   ENUM_TIMEFRAMES timeframe=(ENUM_TIMEFRAMES)::Period();
   for(int i=0;i<total;i++)
     {
      if(markers[i]==NULL)
         continue;
      datetime time=(datetime)(m_keys[i]/2);
      bool is_buy=(m_keys[i]%2==SIGNAL_DIRECTION_BUY);
      int shift=::iBarShift(symbol,timeframe,time,false);
      if(shift<0)
         continue;
      markers[i].SetMarker(time,::iHigh(symbol,timeframe,shift),::iLow(symbol,timeframe,shift),is_buy,this.MarkerColour(is_buy),m_from_signals[i],m_from_series[i]);
      markers[i].Show();
     }
   if(changed)
     {
      CBarMarker::Arrange(this.m_GraphElementsCollection);
      ::ChartRedraw();
     }
  }
 void CBarMarkerSync::DeleteMarkers_BarTimeSeriesCollection(void)
  {
   CBarMarker::ReleaseBox();
   for(int i=this.m_GraphElementsCollection.ChildrenTotal()-1;i>=0;i--)
     {
      CGBaseObj *child=this.m_GraphElementsCollection.Child(i);
      if(dynamic_cast<CBarMarker *>(child)==NULL)
         continue;
      this.m_GraphElementsCollection.DeleteChild(child);
      delete child;
     }
  }
 void CBarMarkerSync::ArrangeIfPending(void)
  {
   if(!m_arrange_pending || this.m_GraphElementsCollection==NULL)
      return;
   m_arrange_pending=false;
   datetime from_time=0,to_time=0;
   if(this.VisibleRange(from_time,to_time) && (from_time!=m_from_time || to_time!=m_to_time))
      this.SyncMarkers_BarTimeSeriesCollection();   // scrolled or zoomed: what came into view is asked to the table, what left goes
   CBarMarker::Arrange(this.m_GraphElementsCollection);
  }
 void CBarMarkerSync::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
      m_arrange_pending=true;
   if((id==CHARTEVENT_CUSTOM+SERIES_EVENTS_PATTERN || id==CHARTEVENT_CUSTOM+SERIES_EVENTS_SWING || id==CHARTEVENT_CUSTOM+SERIES_EVENTS_BOS ||
       id==CHARTEVENT_CUSTOM+SERIES_EVENTS_CHOCH || id==CHARTEVENT_CUSTOM+SERIES_EVENTS_SIGNAL) && sparam==::Symbol() && (long)dparam==(long)::Period())
      this.SyncMarkers_BarTimeSeriesCollection((datetime)lparam);   // the library found something on a candle of the chart pair (SERIES_EVENT_PATTERN_ALL: on many)
   if(id==CHARTEVENT_CUSTOM+BAR_INFORMATION_MANAGER_EVENT_SHOW_CHANGED ||
      id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED ||
      id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED ||
      id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
      this.SyncMarkers_BarTimeSeriesCollection();
  }
#endif // CBARMARKERSYNC_MQH_IMPLEMENTATION
#endif // __BARMARKERSYNC_MQH__
