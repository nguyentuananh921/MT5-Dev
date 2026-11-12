//+------------------------------------------------------------------+
//|                                          BarMarkerCollection.mqh |
//| Change from V4 4. Combination EA V4\Services\BarMarkerSync.mqh   |
//| moved to Library, renamed CBarMarkerSync -> CBarMarkerCollection|
//+------------------------------------------------------------------+

#ifndef __BARMARKERCOLLECTION_MQH__
#define __BARMARKERCOLLECTION_MQH__
 #include "..\Entities\Bases\BaseObj.mqh"
 #include "..\Entities\Graph\Composite\BarMarker.mqh"
 #include "..\Entities\Chart\ChartObj.mqh"
 #include "GraphElementsCollection.mqh"
 #include "BarTimeSeriesCollection.mqh"
 #include "SignalsCollection.mqh"
 #include "Settings\SymbolTFManager.mqh"
 #include "Settings\BarInformationManager.mqh"
 #include "..\Entities\Defines\BarDefines.mqh"
 #include "..\Entities\Defines\EventDefines.mqh"
 #define BAR_MARKER_NAME            "BarMarker_"
#ifndef CBARMARKERCOLLECTION_MQH_DECLARATION
#define CBARMARKERCOLLECTION_MQH_DECLARATION
 //--- A row on RAM the views read (the markers, the popup of a candle): the pair, what found it, the bar and the side
 struct SBarMarkerRow
  {
   long              tf;            // the TF of the pair
   long              collection;    // COLLECTION_SERIES_ID (a type of information) or COLLECTION_SIGNALS_ID (an indicator template)
   long              type;          // ENUM_BAR_INFOR_TYPE or ENUM_INDICATOR
   string            params;        // the params of the template ("" for a type)
   long              time;          // the open time of the bar
   long              side;          // SIGNAL_DIRECTION_BUY or SIGNAL_DIRECTION_SELL
  };
 //+------------------------------------------------------------------+
 //| Draws what was found on the candles of the chart                 |
 //+------------------------------------------------------------------+
 class CBarMarkerCollection : public CBaseObj
  {
   private:
    CChartObj                 *m_ChartObj;                   // EA owns: the chart, the bars it shows
    CGraphElementsCollection  *m_GraphElementsCollection;    // EA owns: the markers are its children
    CBarTimeSeriesCollection  *m_BarTimeSeriesCollection;    // EA owns: the owner of the tables the types are asked to
    CSignalsCollection        *m_SignalsCollection;          // EA owns: the owner of the tables the signals are asked to
    CSymbolTFManager          *m_SymbolTFManager;            // EA owns: what is shown (the sides of the chart pair), given to CBarMarker::Arrange
    CBarInformationManager    *m_BarInformationManager;      // EA owns: what is shown (the types of each side), given to CBarMarker::Arrange
    CIndicatorTemplateManager *m_IndicatorTemplateManager;   // EA owns: what is shown (the templates of each side), given to CBarMarker::Arrange
   //--- The candles and sides of the rows, sorted and once each: time of the candle * 2 + the side
    void                       Collect(const SBarMarkerRow &rows[],long &keys[]);
   //--- The rows on RAM from_time to to_time of (1) the series of a pair (the types of information, CBarControl), (2) the series of a template on a pair, after the ones in the list.
   //--- Nothing is filtered: the view decides what it shows
    void                       CollectTypes(CBarSeriesDE *series,const datetime from_time,const datetime to_time,SBarMarkerRow &rows[]);
    void                       CollectIndicators(CSignalSeriesDE *series,const datetime from_time,const datetime to_time,SBarMarkerRow &rows[]);
   public:
                               CBarMarkerCollection(void) : m_ChartObj(NULL),m_GraphElementsCollection(NULL),m_BarTimeSeriesCollection(NULL),m_SignalsCollection(NULL),m_SymbolTFManager(NULL),
                                                            m_BarInformationManager(NULL),m_IndicatorTemplateManager(NULL) { }
   //--- The classes it asks (the EA owns them)
    void                       SetChartObj(CChartObj *chart)                                  { this.m_ChartObj=chart;                   }
    void                       SetGraphElementsCollection(CGraphElementsCollection *collection) { this.m_GraphElementsCollection=collection; }
    void                       SetBarTimeSeriesCollection(CBarTimeSeriesCollection *collection) { this.m_BarTimeSeriesCollection=collection; }
    void                       SetSignalsCollection(CSignalsCollection *collection)           { this.m_SignalsCollection=collection;     }
    void                       SetSymbolTFManager(CSymbolTFManager *manager)                  { this.m_SymbolTFManager=manager;          }
    void                       SetBarInformationManager(CBarInformationManager *manager)      { this.m_BarInformationManager=manager;    }
    void                       SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { this.m_IndicatorTemplateManager=manager; }
   //--- The rows of the TFs asked of a symbol from_time to to_time (both in), joined on RAM; what RAM has not is loaded first (load on demand).
   //--- The markers of the chart and the popup of a candle read it. Returns how many
    int                        Read_RAM(const string symbol,const long &asked_tfs[],const datetime from_time,const datetime to_time,SBarMarkerRow &rows[]);
   //--- The user changed what is shown: the markers are drawn again
    void                       OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- The markers and the box on the candle go (OnDeinit)
    void                       DeleteMarkers(void);
   //--- The markers of the chart: a marker for each candle and side found, with its sources (CBarMarker decides what it shows)
    void                       SyncMarkers(const datetime time=0);   // time: only the markers of that candle (an event told it), 0: the whole chart
  };
#endif // CBARMARKERCOLLECTION_MQH_DECLARATION
#ifndef CBARMARKERCOLLECTION_MQH_IMPLEMENTATION
#define CBARMARKERCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| The candles and sides of the rows, sorted, once each            |
 //+------------------------------------------------------------------+
 void CBarMarkerCollection::Collect(const SBarMarkerRow &rows[],long &keys[])
  {
   const int total=::ArraySize(rows);
   long all[];
   ::ArrayResize(all,total);
   for(int r=0;r<total;r++)
      all[r]=rows[r].time*2+rows[r].side;
   ::ArraySort(all);
   ::ArrayResize(keys,0,total);
   for(int r=0;r<total;r++)
     {
      const int n=::ArraySize(keys);
      if(n>0 && keys[n-1]==all[r])
         continue;   // the same candle and side again: the sources come together in one marker
      ::ArrayResize(keys,n+1,total);
      keys[n]=all[r];
     }
  }
 //+------------------------------------------------------------------+
 //| The rows of the types of information of a series on RAM         |
 //+------------------------------------------------------------------+
 void CBarMarkerCollection::CollectTypes(CBarSeriesDE *series,const datetime from_time,const datetime to_time,SBarMarkerRow &rows[])
  {
   if(series==NULL)
      return;
   CArrayObj *list=series.GetBarControl().GetList();   // sorted by the time of the bar: the first row of from_time is searched
   int low=0,high=list.Total();
   while(low<high)
     {
      int mid=(low+high)/2;
      CBar *row=list.At(mid);
      if(row!=NULL && row.Time()<from_time)
         low=mid+1;
      else
         high=mid;
     }
   for(int i=low;i<list.Total();i++)
     {
      CBar *row=list.At(i);
      if(row==NULL)
         continue;
      if(row.Time()>to_time)
         break;
      const long side=row.GetProperty(BAR_PROP_SIGNAL_DIRECTION);
      if(side!=(long)SIGNAL_DIRECTION_BUY && side!=(long)SIGNAL_DIRECTION_SELL)
         continue;
      const int n=::ArraySize(rows);
      ::ArrayResize(rows,n+1,1000);
      rows[n].tf=(long)series.Timeframe();
      rows[n].collection=COLLECTION_SERIES_ID;
      rows[n].type=row.GetProperty(BAR_PROP_INFOR_TYPE);
      rows[n].params="";
      rows[n].time=(long)row.Time();
      rows[n].side=side;
     }
  }
 //+------------------------------------------------------------------+
 //| The rows of the signals of a template on a pair on RAM          |
 //+------------------------------------------------------------------+
 void CBarMarkerCollection::CollectIndicators(CSignalSeriesDE *series,const datetime from_time,const datetime to_time,SBarMarkerRow &rows[])
  {
   if(series==NULL)
      return;
   CArrayObj *list=series.GetList();   // sorted by the time of the bar: the first row of from_time is searched
   int low=0,high=list.Total();
   while(low<high)
     {
      int mid=(low+high)/2;
      CSignal *row=list.At(mid);
      if(row!=NULL && row.Time()<from_time)
         low=mid+1;
      else
         high=mid;
     }
   for(int i=low;i<list.Total();i++)
     {
      CSignal *row=list.At(i);
      if(row==NULL)
         continue;
      if(row.Time()>to_time)
         break;
      const long side=(long)row.SignalDirection();
      if(side!=(long)SIGNAL_DIRECTION_BUY && side!=(long)SIGNAL_DIRECTION_SELL)
         continue;
      const int n=::ArraySize(rows);
      ::ArrayResize(rows,n+1,1000);
      rows[n].tf=(long)series.Timeframe();
      rows[n].collection=COLLECTION_SIGNALS_ID;
      rows[n].type=(long)series.TypeIndicator();
      rows[n].params=series.ParamsText();
      rows[n].time=(long)row.Time();
      rows[n].side=side;
     }
  }
 //+------------------------------------------------------------------+
 //| The rows of the TFs asked, joined on RAM. Load on demand: what is |
 //| asked before the 1000 bars of a series is read, nothing between   |
 //+------------------------------------------------------------------+
 int CBarMarkerCollection::Read_RAM(const string symbol,const long &asked_tfs[],const datetime from_time,const datetime to_time,SBarMarkerRow &rows[])
  {
   ::ArrayResize(rows,0);
   if(this.m_BarTimeSeriesCollection==NULL || this.m_SignalsCollection==NULL)
      return 0;
   for(int t=0;t<::ArraySize(asked_tfs);t++)
     {
      const ENUM_TIMEFRAMES timeframe=(ENUM_TIMEFRAMES)asked_tfs[t];
      CBarSeriesDE *series=this.m_BarTimeSeriesCollection.GetSeries(symbol,timeframe);
      CBar *oldest=(series!=NULL && series.GetList().Total()>0 ? series.GetList().At(0) : NULL);
      if(oldest==NULL)
         continue;   // not a pair of Setting_SymbolTF
      const datetime known=oldest.Time();   // RAM has the rows of the 1000 bars of the series
      if(from_time<known)   // the view asks before them: only what it asks is read (a row RAM has already is not read twice)
        {
         const datetime load_to=(datetime)::MathMin((long)to_time,(long)known-1);
         const ulong debug_t0=::GetMicrosecondCount();
         const int debug_types=series.GetBarControl().ReadDataFromDB(from_time,load_to);
         const int debug_signals=this.m_SignalsCollection.ReadDataFromDB(symbol,timeframe,from_time,load_to);
         string debug_text="MY DEBUG CBarMarkerCollection::Read_RAM "+symbol+" "+::EnumToString(timeframe)+": "+::TimeToString(from_time)+" .. "+::TimeToString(load_to)+
                           " is before RAM (oldest bar "+::TimeToString(known)+"), read from DB "+(string)debug_types+" rows of types and "+(string)debug_signals+
                           " rows of signals in "+(string)((::GetMicrosecondCount()-debug_t0)/1000)+" ms";
         ::Print(debug_text);
        }
      this.CollectTypes(series,from_time,to_time,rows);
      CArrayObj *series_list=this.m_SignalsCollection.GetList();   // a series for each template on each pair (a deleted template has no series any more)
      for(int s=0;s<series_list.Total();s++)
        {
         CSignalSeriesDE *signals=series_list.At(s);
         if(signals!=NULL && signals.Symbol()==symbol && signals.Timeframe()==timeframe)
            this.CollectIndicators(signals,from_time,to_time,rows);
        }
     }
   return ::ArraySize(rows);
  }
 //+------------------------------------------------------------------+
 //| The markers of the bars the chart shows: scrolled or zoomed, the  |
 //| ones that came into view are made, the ones that left go. An event |
 //| tells one candle: only its markers are read and compared           |
 //+------------------------------------------------------------------+
 void CBarMarkerCollection::SyncMarkers(const datetime time=0)
  {
   if(this.m_ChartObj==NULL || this.m_GraphElementsCollection==NULL)
      return;
   datetime from_time=time,to_time=time;
   if(time==0 && !this.m_ChartObj.VisibleRange(from_time,to_time))
      return;   // the chart has not its bars yet: the markers stay as they are
   const string symbol=this.m_ChartObj.Symbol();
   const ENUM_TIMEFRAMES timeframe=this.m_ChartObj.Timeframe();
   long asked_tfs[1];
   asked_tfs[0]=(long)timeframe;
   const ulong debug_t0=::GetMicrosecondCount();
   SBarMarkerRow rows[];
   this.Read_RAM(symbol,asked_tfs,from_time,to_time,rows);
   const ulong debug_t1=::GetMicrosecondCount();
   int debug_created=0;
   long keys[];            // what is to be drawn, sorted: time of the candle * 2 + the side (SIGNAL_DIRECTION_BUY / SIGNAL_DIRECTION_SELL)
   this.Collect(rows,keys);
   int total=::ArraySize(keys);
   //--- The rows in the order of the keys (key * rows + the row): the sources of a marker come one after the other
   const int rows_total=::ArraySize(rows);
   long order[];
   ::ArrayResize(order,rows_total);
   for(int r=0;r<rows_total;r++)
      order[r]=(rows[r].time*2+rows[r].side)*rows_total+r;
   ::ArraySort(order);
   int next=0;
   //--- A marker whose candle and side are still found stays (it gets its sources again), one that is not found any more goes
   CBarMarker *markers[];
   ::ArrayResize(markers,total);
   for(int i=0;i<total;i++)
      markers[i]=NULL;
   bool released=false;
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
         if(keys[mid]<key)
            low=mid+1;
         else
            high=mid;
        }
      if(low<total && keys[low]==key && markers[low]==NULL)
        {
         markers[low]=old;
         continue;
        }
      if(!released)
         CBarMarker::ReleaseBox();
      released=true;
      this.m_GraphElementsCollection.DeleteChild(child);
      delete child;
     }
   //--- Every marker is made before any is placed: the first geometry query after a new object waits for the chart to rebuild
   for(int i=0;i<total;i++)
     {
      if(markers[i]!=NULL)
         continue;
      CBarMarker *marker=new CBarMarker();
      if(marker==NULL || !marker.Create(this.m_ChartObj.ID(),0,BAR_MARKER_NAME+(string)keys[i]) || !this.m_GraphElementsCollection.AddChild(marker))
        {
         delete marker;
         continue;
        }
      markers[i]=marker;
      debug_created++;
     }
   const ulong debug_t2=::GetMicrosecondCount();
   //--- Each marker gets its candle and its sources
   for(int i=0;i<total;i++)
     {
      if(markers[i]==NULL)
         continue;
      long types[],ind_types[];
      string ind_params[];
      for(;next<rows_total && order[next]/rows_total<=keys[i];next++)
        {
         const int r=(int)(order[next]%rows_total);
         if(order[next]/rows_total<keys[i])
            continue;
         if(rows[r].collection==COLLECTION_SERIES_ID)
           {
            const int n=::ArraySize(types);
            ::ArrayResize(types,n+1,8);
            types[n]=rows[r].type;
           }
         else
           {
            const int n=::ArraySize(ind_types);
            ::ArrayResize(ind_types,n+1,8);
            ::ArrayResize(ind_params,n+1,8);
            ind_types[n]=rows[r].type;
            ind_params[n]=rows[r].params;
           }
        }
      datetime bar_time=(datetime)(keys[i]/2);
      bool is_buy=(keys[i]%2==SIGNAL_DIRECTION_BUY);
      int shift=::iBarShift(symbol,timeframe,bar_time,false);
      if(shift<0)
         continue;
      markers[i].SetMarker(bar_time,::iHigh(symbol,timeframe,shift),::iLow(symbol,timeframe,shift),is_buy,types,ind_types,ind_params);
     }
   const ulong debug_t3=::GetMicrosecondCount();
   //--- The markers decide what they show, then the badges are placed: an event told one candle, the badges from it (the ones before it stay)
   CBarMarker::Arrange(this.m_GraphElementsCollection,this.m_ChartObj,this.m_SymbolTFManager,this.m_BarInformationManager,this.m_IndicatorTemplateManager,time);
   const ulong debug_t4=::GetMicrosecondCount();
   ::ChartRedraw(this.m_ChartObj.ID());
   const ulong debug_t5=::GetMicrosecondCount();
   string debug_candle="all in view";
   if(time!=0)
      debug_candle=::TimeToString(time);
   string debug_text="MY DEBUG CBarMarkerCollection::SyncMarkers "+symbol+" "+::EnumToString(timeframe)+" candle "+debug_candle+", "+
                     (string)rows_total+" rows, "+(string)total+" markers ("+(string)debug_created+" new). Read_RAM "+(string)((debug_t1-debug_t0)/1000)+
                     " ms, create "+(string)((debug_t2-debug_t1)/1000)+" ms, SetMarker "+(string)((debug_t3-debug_t2)/1000)+" ms, Arrange "+(string)((debug_t4-debug_t3)/1000)+
                     " ms, ChartRedraw "+(string)((debug_t5-debug_t4)/1000)+" ms";
   ::Print(debug_text);
  }
 //+------------------------------------------------------------------+
 //| The markers and the box on the candle go                         |
 //+------------------------------------------------------------------+
 void CBarMarkerCollection::DeleteMarkers(void)
  {
   if(this.m_GraphElementsCollection==NULL)
      return;   // OnInit stopped before OnInitEvent: no marker was made
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
 //+------------------------------------------------------------------+
 //| What changed what the markers show                               |
 //+------------------------------------------------------------------+
 void CBarMarkerCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(this.m_ChartObj==NULL)
      return;   // OnInit stopped before the setters
   const string chart_symbol=this.m_ChartObj.Symbol();
   const ENUM_TIMEFRAMES chart_tf=this.m_ChartObj.Timeframe();
   //--- CChartObj: the chart shows other bars or prices: the rows of the bars in view (Read_RAM loads what RAM has not)
   if(id==CHARTEVENT_CUSTOM+CHART_OBJ_EVENT_VISIBLE_CHANGE && (long)dparam==(long)chart_tf)
     {
      this.SyncMarkers();
      return;
     }
   //--- The data changed: the rows are read again
   if((id==CHARTEVENT_CUSTOM+SERIES_EVENTS_PATTERN || id==CHARTEVENT_CUSTOM+SERIES_EVENTS_SWING || id==CHARTEVENT_CUSTOM+SERIES_EVENTS_BOS ||
       id==CHARTEVENT_CUSTOM+SERIES_EVENTS_CHOCH || id==CHARTEVENT_CUSTOM+SERIES_EVENTS_SIGNAL) && (long)dparam==(long)chart_tf)
     {
      datetime bar;
      long key;
      ENUM_SIGNAL_DIRECTION side;
      bool is_new;
      string symbol,extra;
      this.EventUnpack(lparam,bar,key,side,is_new);
      this.EventUnpackText(sparam,symbol,extra);
      if(symbol==chart_symbol)
         this.SyncMarkers(bar);   // the library found something on a candle of the chart pair
     }
   //--- Python wrote its part and the collections read it to RAM (they hear it before), a template went, the rows of a type went (its parameter changed): drawn once
   if(id==CHARTEVENT_CUSTOM+PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE ||
      id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE ||
      id==CHARTEVENT_CUSTOM+BAR_INFORMATION_MANAGER_EVENT_SETUP_CHANGED)
      this.SyncMarkers();
   //--- The view: a switch of what is shown changed, the data did not. The markers decide again (CBarMarker::Arrange)
   if((id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED && sparam==chart_symbol && (ENUM_TIMEFRAMES)lparam==chart_tf) ||
      id==CHARTEVENT_CUSTOM+BAR_INFORMATION_MANAGER_EVENT_SHOW_CHANGED ||
      id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED)
     {
      CBarMarker::Arrange(this.m_GraphElementsCollection,this.m_ChartObj,this.m_SymbolTFManager,this.m_BarInformationManager,this.m_IndicatorTemplateManager);
      ::ChartRedraw(this.m_ChartObj.ID());
     }
  }
#endif // CBARMARKERCOLLECTION_MQH_IMPLEMENTATION
#endif // __BARMARKERCOLLECTION_MQH__
