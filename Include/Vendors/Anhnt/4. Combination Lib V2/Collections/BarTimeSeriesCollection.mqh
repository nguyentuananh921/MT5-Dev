//+------------------------------------------------------------------+
//+                                     CBarTimeSeriesCollection.mqh +
//|  Change from TimeSeriesCollection.mqh                            |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Symbol timeseries collection                                     |
//+------------------------------------------------------------------+
#ifndef CCBARTIMESERIESCOLLECTION_MQH
#define CCBARTIMESERIESCOLLECTION_MQH
 //+------------------------------------------------------------------+
 //| Include Custom files                                             |
 //+------------------------------------------------------------------+
 #include "ListObj.mqh"
 #include "..\Timeseries\BarSeries\BarTimeSeriesDE.mqh"
 #include "..\Trading\Symbols\Symbol.mqh"
 #ifndef CCBARTIMESERIESCOLLECTION_MQH_DECLARATION
 #define CCBARTIMESERIESCOLLECTION_MQH_DECLARATION
  class CBarTimeSeriesCollection : public CBaseObjExt
   {
    private:
      CListObj                m_list;                    // List of applied symbol timeseries
      CListObj                m_list_all_patterns;       // List of all patterns of all used symbol timeseries
      CListObj                m_list_all_swings;         // List of all swings of all used symbol timeseries
      CListObj                m_list_all_market_structures; // List of all market structure events (BOS/CHoCH) of all used symbol timeseries
      
    //--- Return the timeseries index by symbol name
      int                     IndexTimeSeries(const string symbol);
    public:
    //--- Return (1) oneself, (2) the timeseries list and (3) the list of patterns
      CBarTimeSeriesCollection  *GetObject(void)            { return &this;                     }
      CArrayObj              *GetList(void)              { return &this.m_list;              }
      CArrayObj              *GetListAllPatterns(void)   { return &this.m_list_all_patterns; }
      CArrayObj              *GetListAllSwings(void)     { return &this.m_list_all_swings;   }
      CArrayObj              *GetListAllMarketStructures(void) { return &this.m_list_all_market_structures; }
    //--- Return (1) the timeseries object of the specified symbol and (2) the timeseries object of the specified symbol/period
      CBarTimeSeriesDE          *GetTimeseries(const string symbol);
      CBarSeriesDE              *GetSeries(const string symbol,const ENUM_TIMEFRAMES timeframe);

    //--- Create the symbol timeseries list collection
      bool                    CreateCollection(const CArrayObj *list_symbols);
    //--- Set the flag of using (1) the specified timeseries of the specified symbol, (2) the specified timeseries of all symbols
    //--- (3) all timeseries of the specified symbol and (4) all timeseries of all symbols
      void                    SetAvailable(const string symbol,const ENUM_TIMEFRAMES timeframe,const bool flag=true);
      void                    SetAvailable(const ENUM_TIMEFRAMES timeframe,const bool flag=true);
      void                    SetAvailable(const string symbol,const bool flag=true);
      void                    SetAvailable(const bool flag=true);
    //--- Get the flag of using (1) the specified timeseries of the specified symbol, (2) the specified timeseries of all symbols
    //--- (3) all timeseries of the specified symbol and (4) all timeseries of all symbols
      bool                    IsAvailable(const string symbol,const ENUM_TIMEFRAMES timeframe);
      bool                    IsAvailable(const ENUM_TIMEFRAMES timeframe);
      bool                    IsAvailable(const string symbol);
      bool                    IsAvailable(void);

    //--- Set the history depth of (1) the specified timeseries of the specified symbol, (2) the specified timeseries of all symbols
    //--- (3) all timeseries of the specified symbol and (4) all timeseries of all symbols
      bool                    SetRequiredUsedData(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0);
      bool                    SetRequiredUsedData(const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0);
      bool                    SetRequiredUsedData(const string symbol,const uint required=0,const int rates_total=0);
      bool                    SetRequiredUsedData(const uint required=0,const int rates_total=0);
    //--- Return the flag of data synchronization with the server data of the (1) specified timeseries of the specified symbol,
    //--- (2) the specified timeseries of all symbols, (3) all timeseries of the specified symbol and (4) all timeseries of all symbols
      bool                    SyncData(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0);
      bool                    SyncData(const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0);
      bool                    SyncData(const string symbol,const uint required=0,const int rates_total=0);
      bool                    SyncData(const uint required=0,const int rates_total=0);

    //--- Return the bar object of the specified timeseries of the specified symbol of the specified position (1) by index, (2) by time
    //--- bar object of the first timeseries corresponding to the bar open time on the second timeseries (3) by index, (4) by time
      CBar                   *GetBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const int index,const bool from_series=true);
      CBar                   *GetBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar_time);
      CBar                   *GetBarSeriesFirstFromSeriesSecond(const string symbol_first,const ENUM_TIMEFRAMES timeframe_first,const int index,
                                                               const string symbol_second=NULL,const ENUM_TIMEFRAMES timeframe_second=PERIOD_CURRENT);
      CBar                   *GetBarSeriesFirstFromSeriesSecond(const string symbol_first,const ENUM_TIMEFRAMES timeframe_first,const datetime first_bar_time,
                                                               const string symbol_second=NULL,const ENUM_TIMEFRAMES timeframe_second=PERIOD_CURRENT);

    //--- Return the bar index on the specified timeframe chart by the current chart's bar index
      //|Update link          https://www.mql5.com/en/articles/8115        |                                 |
      int                     IndexBarPeriodByBarCurrent(const int series_index,const string symbol,const ENUM_TIMEFRAMES timeframe);

    //--- Return the flag of opening a new bar of the specified timeseries of the specified symbol      
      bool                    IsNewBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime time=0);
      bool                    IsNewBar(const string symbol, const datetime time=0);
      bool                    IsNewBar(const datetime time=0);

    //--- (1) Create, (2) re-create a specified timeseries of a specified symbol, (3) re-create all timeseries
      bool                    CreateSeries(const string symbol,const ENUM_TIMEFRAMES timeframe,const int rates_total=0,const uint required=0);
      bool                    ReCreateSeries(const string symbol,const ENUM_TIMEFRAMES timeframe,const int rates_total=0,const uint required=0);
      bool                    ReCreateSeriesAll(const int rates_total=0,const uint required=0);
    //--- Delete a specified timeseries with its patterns and swings; the symbol object is kept for re-adding
      bool                    RemoveSeries(const string symbol,const ENUM_TIMEFRAMES timeframe);
    //--- Return (1) an empty, (2) partially filled timeseries
      CBarSeriesDE              *GetSeriesEmpty(void);
      CBarSeriesDE              *GetSeriesIncompleted(void);
    //--- Update (1) the specified timeseries of the specified symbol, (2) all timeseries of a specified symbol,
    //--- (3) all timeseries of all symbols, (4) all timeseries except the current one
      void                    Refresh(const string symbol,const ENUM_TIMEFRAMES timeframe,SDataCalculate &data_calculate);
      void                    Refresh(const string symbol,SDataCalculate &data_calculate);
      void                    Refresh(SDataCalculate &data_calculate);
      void                    RefreshAllExceptCurrent(SDataCalculate &data_calculate);

    //--- Get events from the timeseries object and add them to the list
      bool                    SetEvents(CBarTimeSeriesDE *timeseries);

    //--- Display (1) the complete and (2) short collection description in the journal
      void                    Print(const bool created=true);
      void                    PrintShort(const bool created=true);
      
    //--- Copy the specified double property of the specified timeseries of the specified symbol to the array
    //--- Regardless of the array indexing direction, copying is performed the same way as copying to a timeseries array
      bool                    CopyToBufferAsSeries(const string symbol,const ENUM_TIMEFRAMES timeframe,
                                                   const ENUM_BAR_PROP_DOUBLE property,
                                                   double &array[],
                                                   const double empty=EMPTY_VALUE);
      
    //+------------------------------------------------------------------+
    //| Handling timeseries patterns                                     |
    //+------------------------------------------------------------------+
    //--- Set the flag of using the specified pattern
      void                    SetUsedPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[],const string symbol,const ENUM_TIMEFRAMES timeframe,const bool flag);
    //--- Return the flag of using the specified pattern
      bool                    IsUsedPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[],const string symbol,const ENUM_TIMEFRAMES timeframe);
    //--- Draw marks of the specified pattern on the chart
    //--- Redraw the bitmap objects of the specified pattern on the chart
    //--- Set chart parameters for pattern management objects on the specified symbol and timeframe

    //--- Initialization

    //--- Event handler

    //--- Constructor
                              CBarTimeSeriesCollection(void);
   };
 #endif // CCBARTIMESERIESCOLLECTION_MQH_DECLARATION
 #ifndef CCBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
 #define CCBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CBarTimeSeriesCollection::CBarTimeSeriesCollection(void)
   {
     this.m_type=COLLECTION_SERIES_ID;
     this.m_list.Clear();
     this.m_list.Sort();
     //https://www.mql5.com/en/articles/6211
     //--- Collection list IDs COLLECTION_SERIES_ID in CommonDefines.mqh
      this.m_list.Type(COLLECTION_SERIES_ID);
     this.m_list_all_patterns.Clear();
     this.m_list_all_patterns.Sort();
     this.m_list_all_patterns.Type(COLLECTION_SERIES_PATTERNS_ID);
     this.m_list_all_swings.Clear();
     this.m_list_all_swings.Sort();
     this.m_list_all_swings.Type(COLLECTION_SERIES_SWINGS_ID);
     this.m_list_all_market_structures.Clear();
     this.m_list_all_market_structures.Sort();
     this.m_list_all_market_structures.Type(COLLECTION_SERIES_MARKET_STRUCTURES_ID);
   }
  //+------------------------------------------------------------------+
  //| Return the timeseries index by symbol name                       |
  //+------------------------------------------------------------------+
  int CBarTimeSeriesCollection::IndexTimeSeries(const string symbol)
   {
      CArrayObj *list=NULL;
      const CBarTimeSeriesDE *obj=new CBarTimeSeriesDE(list,list,list,symbol==NULL || symbol=="" ? ::Symbol() : symbol);
      if(obj==NULL)
         return WRONG_VALUE;
      this.m_list.Sort();
      int index=this.m_list.Search(obj);
      delete obj;
      return index;
   }
  //+------------------------------------------------------------------+
  //| Create the symbol timeseries collection list                     |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::CreateCollection(const CArrayObj *list_symbols)
   {
    //--- If an empty list of symbol objects is passed, exit
      if(list_symbols==NULL)
         return false;
    //--- Get the number of symbol objects in the passed list
      int total=list_symbols.Total();
    //--- Clear the timeseries collection list
      this.m_list.Clear();
    //--- In a loop by all symbol objects
      for(int i=0;i<total;i++)
      {
         //--- get the next symbol object
         CSymbol *symbol_obj=list_symbols.At(i);
         //--- if failed to get a symbol object, move on to the next one in the list
         if(symbol_obj==NULL)
            continue;
         //--- Create a new timeseries object with the current symbol name
         CBarTimeSeriesDE *timeseries=new CBarTimeSeriesDE(this.GetListAllPatterns(),this.GetListAllSwings(),this.GetListAllMarketStructures(),symbol_obj.Name());
         //--- If failed to create the timeseries object, move on to the next symbol in the list
         if(timeseries==NULL)
            continue;
         //--- Set the sorted list flag for the timeseries collection list
         this.m_list.Sort();
         //--- If the object with the same symbol name is already present in the timeseries collection list, remove the timeseries object
         if(this.m_list.Search(timeseries)>WRONG_VALUE)
            delete timeseries;
         //--- if failed to add the timeseries object to the collection list, remove the timeseries object
         else 
            if(!this.m_list.Add(timeseries))
               delete timeseries;
      }
    //--- Return the flag indicating that the created collection list has a size greater than zero
      return this.m_list.Total()>0;
   }
  //+------------------------------------------------------------------+
  //| Return the timeseries object of the specified symbol             |
  //+------------------------------------------------------------------+
  CBarTimeSeriesDE *CBarTimeSeriesCollection::GetTimeseries(const string symbol)
   {
      int index=this.IndexTimeSeries(symbol);
      if(index==WRONG_VALUE)
         return NULL;
      CBarTimeSeriesDE *timeseries=this.m_list.At(index);
      return timeseries;
   }
  //+------------------------------------------------------------------+
  //| Return the timeseries object of the specified symbol/period      |
  //+------------------------------------------------------------------+
  CBarSeriesDE *CBarTimeSeriesCollection::GetSeries(const string symbol,const ENUM_TIMEFRAMES timeframe)
   {
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries==NULL)
         return NULL;
      CBarSeriesDE *series=timeseries.GetSeries(timeframe);
      return series;
   }
  //+-----------------------------------------------------------------------+
  //|Set the flag of using the specified timeseries of the specified symbol |
  //+-----------------------------------------------------------------------+
  void CBarTimeSeriesCollection::SetAvailable(const string symbol,const ENUM_TIMEFRAMES timeframe,const bool flag=true)
   {
      CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
      if(series==NULL)
         return;
      series.SetAvailable(flag);
   }
  //+------------------------------------------------------------------+
  //|Set the flag of using the specified timeseries of all symbols     |
  //+------------------------------------------------------------------+
  void CBarTimeSeriesCollection::SetAvailable(const ENUM_TIMEFRAMES timeframe,const bool flag=true)
   {
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         CBarSeriesDE *series=timeseries.GetSeries(timeframe);
         if(series==NULL)
            continue;
         series.SetAvailable(flag);
      }
   }
  //+------------------------------------------------------------------+
  //|Set the flag of using all timeseries of the specified symbol      |
  //+------------------------------------------------------------------+
  void CBarTimeSeriesCollection::SetAvailable(const string symbol,const bool flag=true)
   {
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries==NULL)
         return;
      CArrayObj *list=timeseries.GetListSeries();
      if(list==NULL)
         return;
      int total=list.Total();
      for(int i=0;i<total;i++)
      {
         CBarSeriesDE *series=list.At(i);
         if(series==NULL)
            continue;
         series.SetAvailable(flag);
      }
   }
  //+------------------------------------------------------------------+
  //| Set the flag of using all timeseries of all symbols              |
  //+------------------------------------------------------------------+
  void CBarTimeSeriesCollection::SetAvailable(const bool flag=true)
   {
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         CArrayObj *list=timeseries.GetListSeries();
         if(list==NULL)
            continue;
         int total_series=list.Total();
         for(int j=0;j<total_series;j++)
         {
            CBarSeriesDE *series=list.At(j);
            if(series==NULL)
               continue;
            series.SetAvailable(flag);
         }
      }
   }
  //+-------------------------------------------------------------------------+
  //|Return the flag of using the specified timeseries of the specified symbol|
  //+-------------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::IsAvailable(const string symbol,const ENUM_TIMEFRAMES timeframe)
   {
      CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
      if(series==NULL)
         return false;
      return series.IsAvailable();
   }
  //+------------------------------------------------------------------+
  //| Return the flag of using the specified timeseries of all symbols |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::IsAvailable(const ENUM_TIMEFRAMES timeframe)
   {
      bool res=true;
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         CBarSeriesDE *series=timeseries.GetSeries(timeframe);
         if(series==NULL)
            continue;
         res &=series.IsAvailable();
      }
      return res;
   }
  //+------------------------------------------------------------------+
  //| Return the flag of using all timeseries of the specified symbol  |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::IsAvailable(const string symbol)
   {
      bool res=true;
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries==NULL)
         return false;
      CArrayObj *list=timeseries.GetListSeries();
      if(list==NULL)
         return false;
      int total=list.Total();
      for(int i=0;i<total;i++)
      {
         CBarSeriesDE *series=list.At(i);
         if(series==NULL)
            continue;
         res &=series.IsAvailable();
      }
      return res;
   }
  //+------------------------------------------------------------------+
  //| Return the flag of using all timeseries of all symbols           |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::IsAvailable(void)
   {
      bool res=true;
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         CArrayObj *list=timeseries.GetListSeries();
         if(list==NULL)
            continue;
         int total_series=list.Total();
         for(int j=0;j<total_series;j++)
         {
            CBarSeriesDE *series=list.At(j);
            if(series==NULL)
               continue;
            res &=series.IsAvailable();
         }
      }
      return res;
   }
  //+--------------------------------------------------------------------------+
  //|Set the history depth for the specified timeseries of the specified symbol|
  //+--------------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SetRequiredUsedData(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0)
   {
      CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
      if(series==NULL)
         return false;
      return series.SetRequiredUsedData(required,rates_total);
   }
  //+------------------------------------------------------------------+
  //| Set the history depth of the specified timeseries of all symbols |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SetRequiredUsedData(const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0)
   {
      bool res=true;
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         CBarSeriesDE *series=timeseries.GetSeries(timeframe);
         if(series==NULL)
            continue;
         res &=series.SetRequiredUsedData(required,rates_total);
      }
      return res;
   }
  //+------------------------------------------------------------------+
  //| Set the history depth for all timeseries of the specified symbol |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SetRequiredUsedData(const string symbol,const uint required=0,const int rates_total=0)
   {
      bool res=true;
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries==NULL)
         return false;
      CArrayObj *list=timeseries.GetListSeries();
      if(list==NULL)
         return false;
      int total=list.Total();
      for(int i=0;i<total;i++)
      {
         CBarSeriesDE *series=list.At(i);
         if(series==NULL)
            continue;
         res &=series.SetRequiredUsedData(required,rates_total);
      }
      return res;
   }
   //+------------------------------------------------------------------+
   //| Set the history depth for all timeseries of all symbols          |
   //+------------------------------------------------------------------+
   bool CBarTimeSeriesCollection::SetRequiredUsedData(const uint required=0,const int rates_total=0)
    {
      bool res=true;
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         CArrayObj *list=timeseries.GetListSeries();
         if(list==NULL)
            continue;
         int total_series=list.Total();
         for(int j=0;j<total_series;j++)
         {
            CBarSeriesDE *series=list.At(j);
            if(series==NULL)
               continue;
            res &=series.SetRequiredUsedData(required,rates_total);
         }
      }
      return res;
    }
  //+-----------------------------------------------------------------------+
  //| Return the bar object of the specified timeseries by index            |
  //| of the specified symbol of the specified position                     |
  //| from_series=true - by the timeseries index, false - by the list index |
  //+-----------------------------------------------------------------------+
  CBar *CBarTimeSeriesCollection::GetBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const int index,const bool from_series=true)
   {
      CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
      if(series==NULL)
         return NULL;
    //--- Depending on the from_series flag, return the pointer to the bar
    //--- either by the chart timeseries index or by the bar index in the timeseries list
      return(from_series ? series.GetBar(index) : series.GetBarByListIndex(index));
   }
  //+------------------------------------------------------------------+
  //| Return the bar object of the specified timeseries                |
  //| of the specified symbol of the specified position by time        |
  //+------------------------------------------------------------------+
  CBar *CBarTimeSeriesCollection::GetBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime bar_time)
   {
      CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
      if(series==NULL)
         return NULL;
      return series.GetBar(bar_time);
   }
  //+------------------------------------------------------------------+
  //| Return the bar object of the first timeseries by index           |
  //| corresponding to the bar open time on the second timeseries      |
  //+------------------------------------------------------------------+
  CBar *CBarTimeSeriesCollection::GetBarSeriesFirstFromSeriesSecond(const string symbol_first,const ENUM_TIMEFRAMES timeframe_first,const int index,
                                                                  const string symbol_second=NULL,const ENUM_TIMEFRAMES timeframe_second=PERIOD_CURRENT)
   {
      CBar *bar_first=this.GetBar(symbol_first,timeframe_first,index);
      if(bar_first==NULL)
         return NULL;
      CBar *bar_second=this.GetBar(symbol_second,timeframe_second,bar_first.Time());
      return bar_second;
   }
  //+------------------------------------------------------------------+
  //| Return the bar object of the first timeseries by time            |
  //| corresponding to the bar open time on the second timeseries      |
  //+------------------------------------------------------------------+
  CBar *CBarTimeSeriesCollection::GetBarSeriesFirstFromSeriesSecond(const string symbol_first,const ENUM_TIMEFRAMES timeframe_first,const datetime first_bar_time,
                                                                  const string symbol_second=NULL,const ENUM_TIMEFRAMES timeframe_second=PERIOD_CURRENT)
   {
      CBar *bar_first=this.GetBar(symbol_first,timeframe_first,first_bar_time);
      if(bar_first==NULL)
         return NULL;
      CBar *bar_second=this.GetBar(symbol_second,timeframe_second,bar_first.Time());
      return bar_second;
   }  
  //+------------------------------------------------------------------+
  //| Return new bar opening flag                                      |
  //| for a specified timeseries of a specified symbol                 |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::IsNewBar(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime time=0)
   {
    // IsAvailable checks for NULL and the series' own IsAvailable flag
     if(!this.IsAvailable(symbol, timeframe))
       return false;
    CBarSeriesDE *series = this.GetSeries(symbol, timeframe);
    return series.IsNewBar(time);
   }
  //+------------------------------------------------------------------+
  //| Return new bar opening flag                                      |
  //| for all timeseries of a specified symbol                 |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::IsNewBar(const string symbol, const datetime time=0)
   {
    if(!this.IsAvailable(symbol))
         return false;
      CBarTimeSeriesDE *bts = this.GetTimeseries(symbol);
      if(bts == NULL)
         return false;
      CArrayObj *series_list = bts.GetListSeries();
      int total = (series_list != NULL) ? series_list.Total() : 0;
      for(int i = 0; i < total; i++)
       {
        CBarSeriesDE *series = series_list.At(i);
        if(series != NULL && series.IsAvailable() && series.IsNewBar(time))
           return true;
       }
      return false;
   }
  //+------------------------------------------------------------------+
  //| Return new bar opening flag                                      |
  //| for any timeseries of any symbol                                 |
  //+------------------------------------------------------------------+  
  bool CBarTimeSeriesCollection::IsNewBar(const datetime time=0)
   {
      if(!this.IsAvailable())
         return false;
      int total = this.m_list.Total();
      for(int i = 0; i < total; i++)
       {
        CBarTimeSeriesDE *bts = this.m_list.At(i);
        if(bts != NULL && this.IsNewBar(bts.Symbol(), time))
           return true;
       }
      return false;
   }
  //+------------------------------------------------------------------+
  //| Return the flag of data synchronization with the server data     |
  //| for a specified timeseries of a specified symbol                 |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SyncData(const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0)
   {
      CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
      if(series==NULL)
         return false;
      return series.SyncData(required,rates_total);
   }
  //+------------------------------------------------------------------+
  //| Return the flag of data synchronization with the server data     |
  //| for a specified timeseries of all symbols                        |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SyncData(const ENUM_TIMEFRAMES timeframe,const uint required=0,const int rates_total=0)
   {
      bool res=true;
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         CBarSeriesDE *series=timeseries.GetSeries(timeframe);
         if(series==NULL)
            continue;
         res &=series.SyncData(required,rates_total);
      }
      return res;
   }
  //+------------------------------------------------------------------+
  //| Return the flag of data synchronization with the server data     |
  //| for all timeseries of a specified symbol                         |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SyncData(const string symbol,const uint required=0,const int rates_total=0)
   {
      bool res=true;
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries==NULL)
         return false;
      CArrayObj *list=timeseries.GetListSeries();
      if(list==NULL)
         return false;
      int total=list.Total();
      for(int i=0;i<total;i++)
      {
         CBarSeriesDE *series=list.At(i);
         if(series==NULL)
            continue;
         res &=series.SyncData(required,rates_total);
      }
      return res;
   }
  //+------------------------------------------------------------------+
  //| Return the flag of data synchronization with the server data     |
  //| for all timeseries of all symbols                                |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SyncData(const uint required=0,const int rates_total=0)
   {
      bool res=true;
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         CArrayObj *list=timeseries.GetListSeries();
         if(list==NULL)
            continue;
         int total_series=list.Total();
         for(int j=0;j<total_series;j++)
         {
            CBarSeriesDE *series=list.At(j);
            if(series==NULL)
               continue;
            res &=series.SyncData(required,rates_total);
         }
      }
      return res;
   }
  //+------------------------------------------------------------------+
  //|Return the empty (created but not filled with data) timeseries    |
  //+------------------------------------------------------------------+
  CBarSeriesDE *CBarTimeSeriesCollection::GetSeriesEmpty(void)
   {
    //--- In the loop by the timeseries object list
      int total_timeseries=this.m_list.Total();
      for(int i=0;i<total_timeseries;i++)
      {
         //--- get the next object of all symbol timeseries by the loop index
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL || !timeseries.IsAvailable())
            continue;
         //--- get the list of timeseries objects from the object of all symbol timeseries
         CArrayObj *list_series=timeseries.GetListSeries();
         if(list_series==NULL)
            continue;
         //--- in the loop by the symbol timeseries list
         int total_series=list_series.Total();
         for(int j=0;j<total_series;j++)
         {
            //--- get the next timeseries
            CBarSeriesDE *series=list_series.At(j);
            if(series==NULL || !series.IsAvailable())
               continue;
            //--- if the timeseries has no bar objects,
            //--- return the pointer to the timeseries
            if(series.DataTotal()==0)
               return series;
         }
      }
      return NULL;
   }
  //+------------------------------------------------------------------+
  //| Return partially filled timeseries                               |
  //+------------------------------------------------------------------+
  CBarSeriesDE *CBarTimeSeriesCollection::GetSeriesIncompleted(void)
   {
    //--- In the loop by the timeseries object list
      int total_timeseries=this.m_list.Total();
      for(int i=0;i<total_timeseries;i++)
      {
         //--- get the next object of all symbol timeseries by the loop index
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL || !timeseries.IsAvailable())
            continue;
         //--- get the list of timeseries objects from the object of all symbol timeseries
         CArrayObj *list_series=timeseries.GetListSeries();
         if(list_series==NULL)
            continue;
         //--- in the loop by the symbol timeseries list
         int total_series=list_series.Total();
         for(int j=0;j<total_series;j++)
         {
            //--- get the next timeseries
            CBarSeriesDE *series=list_series.At(j);
            if(series==NULL || !series.IsAvailable())
               continue;
            //--- if the timeseries has bar objects,
            //--- but their number is not equal to the requested and available one for the symbol,
            //--- return the pointer to the timeseries
            if(series.DataTotal()>0 && series.AvailableUsedData()!=series.DataTotal())
               return series;
         }
      }
      return NULL;
   }
  //+------------------------------------------------------------------+
  //| Create the specified timeseries of the specified symbol          |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::CreateSeries(const string symbol,const ENUM_TIMEFRAMES timeframe,const int rates_total=0,const uint required=0)
   {
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
    //--- Symbol dropped by RemoveSeries() (or never listed): recreate its timeseries object
         if(timeseries==NULL)
           {
            if(!::SymbolInfoInteger(symbol,SYMBOL_EXIST))
               return false;
            timeseries=new CBarTimeSeriesDE(this.GetListAllPatterns(),this.GetListAllSwings(),this.GetListAllMarketStructures(),symbol);
            if(timeseries==NULL)
               return false;
            this.m_list.Sort();
            if(!this.m_list.InsertSort(timeseries))
              {
               delete timeseries;
               return false;
              }
           }
      //Original version
         if(!timeseries.AddSeries(timeframe,required))
            return false;
         if(!timeseries.SyncData(timeframe,required,rates_total))
            return false;
         return timeseries.CreateSeries(timeframe,required);      
      return true;
   }
  //+------------------------------------------------------------------+
  //| Re-create a specified timeseries of a specified symbol           |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::ReCreateSeries(const string symbol,const ENUM_TIMEFRAMES timeframe,const int rates_total=0,const uint required=0)
   {
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries==NULL)
         return false;
      if(!timeseries.SyncData(timeframe,rates_total,required))
         return false;
      return timeseries.CreateSeries(timeframe,required);
   }
  //+------------------------------------------------------------------+
  //| Delete a specified timeseries of a specified symbol              |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::RemoveSeries(const string symbol,const ENUM_TIMEFRAMES timeframe)
   {
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries==NULL)
         return false;
    //--- Patterns and swings point into this series' bars - delete them before the bars
      for(int i=this.m_list_all_patterns.Total()-1;i>=0;i--)
        {
         CBarPattern *pattern=this.m_list_all_patterns.At(i);
         if(pattern!=NULL && pattern.Symbol()==symbol && pattern.Timeframe()==timeframe)
            this.m_list_all_patterns.Delete(i);
        }
      for(int i=this.m_list_all_swings.Total()-1;i>=0;i--)
        {
         CBarSwingSeries *swing=this.m_list_all_swings.At(i);
         if(swing!=NULL && swing.Symbol()==symbol && swing.Timeframe()==timeframe)
            this.m_list_all_swings.Delete(i);
        }
      for(int i=this.m_list_all_market_structures.Total()-1;i>=0;i--)
        {
         CMarketStructureSeries *structure=this.m_list_all_market_structures.At(i);
         if(structure!=NULL && structure.Symbol()==symbol && structure.Timeframe()==timeframe)
            this.m_list_all_market_structures.Delete(i);
        }
    //--- ~CBarSeriesDE deletes its bars and its pattern/swing/market structure controls
      CArrayObj *list_series=timeseries.GetListSeries();
      bool removed=false;
      for(int i=list_series.Total()-1;i>=0 && !removed;i--)
        {
         CBarSeriesDE *series=list_series.At(i);
         if(series!=NULL && series.Timeframe()==timeframe)
            removed=list_series.Delete(i);
        }
    //--- No timeframe left: drop the symbol too, CreateSeries() recreates it on demand
      if(list_series.Total()==0)
        {
         int index=this.IndexTimeSeries(symbol);
         if(index>WRONG_VALUE)
            this.m_list.Delete(index);
        }
      return removed;
   }
  //+------------------------------------------------------------------+
  //| Re-create all timeseries                                         |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::ReCreateSeriesAll(const int rates_total=0,const uint required=0)
   {
    //--- In the loop by all symbol timeseries objects in the collection,
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         //--- get the next symbol timeseries object
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         //--- Get the list of all symbol timeseries
         CArrayObj *list=timeseries.GetListSeries();
         if(list==NULL)
            continue;
         //--- In a loop by all symbol timeseries
         int total_series=list.Total();
         for(int j=0;j<total_series;j++)
         {
            //--- Get the next timeseries
            CBarSeriesDE *series=list.At(j);
            if(series==NULL)
               continue;
            //--- check timeseries synchronization and re-create it
            if(!series.SyncData(required,rates_total))
               return false;
            if(series.Create(required)==0)
               return false;
         }
      }
      return true;
   }
  //+------------------------------------------------------------------+
  //| Update the specified timeseries of the specified symbol          |
  //+------------------------------------------------------------------+
  void CBarTimeSeriesCollection::Refresh(const string symbol,const ENUM_TIMEFRAMES timeframe,SDataCalculate &data_calculate)
   {
     //--- Reset the flag of an event in the timeseries collection and clear the event list
      this.m_is_event=false;
      this.m_list_events.Clear();
     //--- Get the object of all symbol timeseries by a symbol name
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries==NULL)
         return;
     //--- If there is no new tick on the timeseries object symbol, exit
      if(!timeseries.IsNewTick())
         return;
     //--- Update the required object timeseries of all symbol timeseries
      timeseries.Refresh(timeframe,data_calculate);
     //--- If the timeseries has the enabled event flag,
     //--- get events from symbol timeseries, write them to the collection event list
     //--- and set the event flag in the collection
      if(timeseries.IsEvent())
         this.m_is_event=this.SetEvents(timeseries);
   }
  //+------------------------------------------------------------------+
  //| Update all timeseries of the specified symbol                    |
  //+------------------------------------------------------------------+
  void CBarTimeSeriesCollection::Refresh(const string symbol,SDataCalculate &data_calculate)
   {
     //--- Reset the flag of an event in the timeseries collection and clear the event list
      this.m_is_event=false;
      this.m_list_events.Clear();
     //--- Get the object of all symbol timeseries by a symbol name
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries==NULL)
         return;
     //--- If there is no new tick on the timeseries object symbol, exit
      if(!timeseries.IsNewTick())
         return;
     //--- Update all object timeseries of all symbol timeseries
      timeseries.RefreshAll(data_calculate);
     //--- If the timeseries has the enabled event flag,
     //--- get events from symbol timeseries, write them to the collection event list
     //--- and set the event flag in the collection
      if(timeseries.IsEvent())
         this.m_is_event=this.SetEvents(timeseries);
   }
  //+------------------------------------------------------------------+
  //| Update all timeseries of all symbols                             |
  //+------------------------------------------------------------------+
  void CBarTimeSeriesCollection::Refresh(SDataCalculate &data_calculate)
   {
     //--- Reset the flag of an event in the timeseries collection and clear the event list
      this.m_is_event=false;
      this.m_list_events.Clear();
     //--- In the loop by all symbol timeseries objects in the collection,
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         //--- get the next symbol timeseries object
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         //--- if there is no new tick on a timeseries symbol, move to the next object in the list
         if(!timeseries.IsNewTick())
            continue;
         //--- Update all symbol timeseries
         timeseries.RefreshAll(data_calculate); 
         //--- If the event flag enabled for the symbol timeseries object,
         //--- get events from symbol timeseries, write them to the collection event list
         //--- and set the event flag in the collection
         if(timeseries.IsEvent())
            this.m_is_event=this.SetEvents(timeseries);
      }
   }
  //+------------------------------------------------------------------+
  //| Update all timeseries except the current one                     |
  //+------------------------------------------------------------------+
  void CBarTimeSeriesCollection::RefreshAllExceptCurrent(SDataCalculate &data_calculate)
   {
     //--- Reset the flag of an event in the timeseries collection and clear the event list
      this.m_is_event=false;
      this.m_list_events.Clear();
     //--- In the loop by all symbol timeseries objects in the collection,
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         //--- get the next symbol timeseries object
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         //--- if the timeseries symbol is equal to the current chart symbol or
         //--- if there is no new tick on a timeseries symbol, move to the next object in the list
         if(timeseries.Symbol()==::Symbol() || !timeseries.IsNewTick())
            continue;
         //--- Update all symbol timeseries
         timeseries.RefreshAll(data_calculate);
         //--- If the event flag enabled for the symbol timeseries object,
         //--- get events from symbol timeseries, write them to the collection event list
         //--- and set the event flag in the collection
         if(timeseries.IsEvent())
            this.m_is_event=this.SetEvents(timeseries);
      }
   }
  //+------------------------------------------------------------------+
  //| Get events from the timeseries object and add them to the list   |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::SetEvents(CBarTimeSeriesDE *timeseries)
   {
    //--- Set the flag of successfully adding an event to the list and
    //--- get the list of symbol timeseries object events
      bool res=true;
      CArrayObj *list=timeseries.GetListEvents();
      if(list==NULL)
         return false;
    //--- In the loop by the obtained list of events,
      int total=list.Total();
      for(int i=0;i<total;i++)
      {
         //--- get the next event by the loop index and
         CEventBaseObj *event=timeseries.GetEvent(i);
         if(event==NULL)
            continue;
         //--- add the result of adding the obtained event to the flag value
         //--- from the symbol timeseries list to the timeseries collection list
         res &=this.EventAdd(event.ID(),event.LParam(),event.DParam(),event.SParam());
      }
    //--- Return the result of adding events to the list
      return res;
   }
  //+------------------------------------------------------------------+
  //| Display complete collection description in the journal           |
  //+------------------------------------------------------------------+
  void CBarTimeSeriesCollection::Print(const bool created=true)
   {
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         timeseries.Print(false,created);
      }
   }
  //+------------------------------------------------------------------+
  //| Display the short collection description in the journal          |
  //+------------------------------------------------------------------+
  void CBarTimeSeriesCollection::PrintShort(const bool created=true)
   {
      int total=this.m_list.Total();
      for(int i=0;i<total;i++)
      {
         CBarTimeSeriesDE *timeseries=this.m_list.At(i);
         if(timeseries==NULL)
            continue;
         timeseries.PrintShort(false,created);
      }
   }
  //+------------------------------------------------------------------+
  //| Copy the specified double property to the array                  |
  //| for a specified timeseries of a specified symbol                 |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::CopyToBufferAsSeries(const string symbol,const ENUM_TIMEFRAMES timeframe,
                                                   const ENUM_BAR_PROP_DOUBLE property,
                                                   double &array[],
                                                   const double empty=EMPTY_VALUE)
   {
      CBarSeriesDE *series=this.GetSeries(symbol,timeframe);
      if(series==NULL)
         return false;
      return series.CopyToBufferAsSeries(property,array,empty);
   }
  //+------------------------------------------------------------------+
  //| Return the bar index on the specified timeframe chart            |
  //| by the current chart's bar index                                 |
  //+------------------------------------------------------------------+
  int CBarTimeSeriesCollection::IndexBarPeriodByBarCurrent(const int series_index,const string symbol,const ENUM_TIMEFRAMES timeframe)
   {
      CBarSeriesDE *series=this.GetSeries(::Symbol(),(ENUM_TIMEFRAMES)::Period());
      if(series==NULL)
         return WRONG_VALUE;
      CBar *bar=series.GetBar(series_index);
      if(bar==NULL)
         return WRONG_VALUE;
      return ::iBarShift(symbol,timeframe,bar.Time());
   }
  //+------------------------------------------------------------------+
  //+------------------------------------------------------------------+
  //| Handling timeseries patterns                                     |
  //+------------------------------------------------------------------+
  //+------------------------------------------------------------------+
  //| Set the flag of using the specified pattern                      |
  //| and create a control object if it does not exist yet             |
  //+------------------------------------------------------------------+
  void CBarTimeSeriesCollection::SetUsedPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[],const string symbol,const ENUM_TIMEFRAMES timeframe,const bool flag)
   {
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      if(timeseries!=NULL)
         timeseries.SetUsedPattern(pattern,param,timeframe,flag);
   }
  //+------------------------------------------------------------------+
  //| Return the flag of using the specified pattern                   |
  //+------------------------------------------------------------------+
  bool CBarTimeSeriesCollection::IsUsedPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[],const string symbol,const ENUM_TIMEFRAMES timeframe)
   {
      CBarTimeSeriesDE *timeseries=this.GetTimeseries(symbol);
      return(timeseries!=NULL ? timeseries.IsUsedPattern(pattern,param,timeframe) : false);
   }
   //+------------------------------------------------------------------+
 #endif // CCBARTIMESERIESCOLLECTION_MQH_IMPLEMENTATION
#endif // CCBARTIMESERIESCOLLECTION_MQH




