//+------------------------------------------------------------------+
//|                                              BarTimeSeriesDE.mqh |
//|Change from TimeSeriesDE.mqh                                      |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __BARTIMESERIESDE_MQH__
#define __BARTIMESERIESDE_MQH__
 #include "BarSeriesDE.mqh"
 #include "..\Ticks\NewTickObj.mqh"
#ifndef CBARTIMESERIESDE_MQH_DECLARATION
#define CBARTIMESERIESDE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Symbol timeseries class                                          |
 //+------------------------------------------------------------------+
 //class CBarTimeSeriesDE : public CBaseObj
 class CBarTimeSeriesDE : public CBaseObjExt
  {
   private:
    string            m_symbol;                // Timeseries symbol
    CArrayObj         m_list_series;           // List of timeseries by timeframes
    CNewTickObj       m_new_tick;              // "New tick" object (DoEasy CTimeSeriesDE): no tick for TICK_PAUSE_SECONDS, the symbol rests
    //--- Return (1) the timeframe index in the list and (2) the timeframe by the list index
     int IndexTimeframe(const ENUM_TIMEFRAMES timeframe);
   public:
    CArrayObj        *GetListSeries(void)                       { return &this.m_list_series; }
   //--- Return the timeseries of a timeframe (NULL when it is not added)
    CBarSeriesDE     *GetSeries(const ENUM_TIMEFRAMES timeframe);
   //--- Set (1) symbol, (2) timeframe, (3) symbol and timeframe, (4) amount of applied timeseries data
    void              SetSymbol(const string symbol,const bool set_server_date=false);
    void              SetTimeframe(const ENUM_TIMEFRAMES timeframe,const bool set_server_date=false);
    void              SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe);
    bool              SetRequiredUsedData(const ENUM_TIMEFRAMES timeframe, const uint required = 0, const int rates_total = 0);
    string            Symbol(void)                        const { return this.m_symbol; }
   //--- (1) The new tick flag (DoEasy CTimeSeriesDE): it reads the tick and keeps it, so a second call before the next tick returns false.
   //--- (2) The symbol rests (no tick for TICK_PAUSE_SECONDS: a closed market)
    bool              IsNewTick(void);
    bool              IsPaused(void)                      const { return this.m_new_tick.IsPaused(); }
   //--- Add the timeseries of a timeframe to the list (true when it is there), synchronize it with the server and create its bars
    bool              AddSeries(const ENUM_TIMEFRAMES timeframe,const uint required=0);
    bool              SyncData(const ENUM_TIMEFRAMES timeframe,const uint required=0);
    bool              CreateSeries(const ENUM_TIMEFRAMES timeframe,const uint required=0);
   //--- The rows of the table between RAM and the database, as SyncData: (1) one timeframe, (2) every timeframe. Each CBarSeriesDE does its own
    bool              ReadDataFromDB(const ENUM_TIMEFRAMES timeframe);
    bool              ReadDataFromDB(void);
   //--- The series of a timeframe goes (its pair left Setting_SymbolTF: Python Live judges it from now): what waits is written first. True when it is gone
    bool              DeleteSeries(const ENUM_TIMEFRAMES timeframe);
    int               SeriesTotal(void)                   const { return this.m_list_series.Total(); }
   //--- Update the timeseries of a timeframe: true when a new bar was added
    bool              RefreshSeries(const ENUM_TIMEFRAMES timeframe);
   //--- Compare the CBarTimeSeriesDE objects (by symbol)
    virtual int       Compare(const CObject *node,const int mode=0) const;
                      CBarTimeSeriesDE(const string symbol);
  };
#endif // CBARTIMESERIESDE_MQH_DECLARATION
#ifndef CBARTIMESERIESDE_MQH_IMPLEMENTATION
#define CBARTIMESERIESDE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CBarTimeSeriesDE::CBarTimeSeriesDE(const string symbol) : m_symbol(symbol==NULL || symbol=="" ? ::Symbol() : symbol)
  {
   this.m_object_type=OBJECT_DE_TYPE_SERIES_SYMBOL;
   this.m_list_series.Clear();
   this.m_new_tick.SetSymbol(this.m_symbol);
   this.m_new_tick.Refresh();
  }
 //+------------------------------------------------------------------+
 //| Return the timeframe index in the list                           |
 //+------------------------------------------------------------------+
 int CBarTimeSeriesDE::IndexTimeframe(const ENUM_TIMEFRAMES timeframe)
  {
   ENUM_TIMEFRAMES tf=(timeframe==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)::Period() : timeframe);
   for(int i=0; i<this.m_list_series.Total(); i++)
     {
      CBarSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.Timeframe()==tf)
         return i;
     }
   return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Set a history depth of a specified timeseries                    |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::SetRequiredUsedData(const ENUM_TIMEFRAMES timeframe, const uint required = 0, const int rates_total = 0)
  {
   if (this.m_symbol == NULL)
   {
      ::Print(DFUN, CMessage::Text(MSG_LIB_TEXT_TS_TEXT_FIRST_SET_SYMBOL));
      return false;
   }
   CBarSeriesDE* series_obj = this.m_list_series.At(this.IndexTimeframe(timeframe));
   return series_obj.SetRequiredUsedData(required, rates_total);
  }
 int CBarTimeSeriesDE::Compare(const CObject *node,const int mode=0) const
  {
   const CBarTimeSeriesDE *compared_obj=node;
   return(this.Symbol()>compared_obj.Symbol() ? 1 : this.Symbol()<compared_obj.Symbol() ? -1 : 0);
  }
 //+------------------------------------------------------------------+
 //| Return the timeseries of a timeframe                             |
 //+------------------------------------------------------------------+
 CBarSeriesDE *CBarTimeSeriesDE::GetSeries(const ENUM_TIMEFRAMES timeframe)
  {
   ENUM_TIMEFRAMES tf=(timeframe==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)::Period() : timeframe);
   for(int i=0; i<this.m_list_series.Total(); i++)
     {
      CBarSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL && series.Timeframe()==tf)
         return series;
     }
   return NULL;
  }
 //+------------------------------------------------------------------+
 //| Add the timeseries of a timeframe to the list                    |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::AddSeries(const ENUM_TIMEFRAMES timeframe,const uint required=0)
  {
   if(this.GetSeries(timeframe)!=NULL)
      return true;   // it is there already
   CBarSeriesDE *series=new CBarSeriesDE(this.m_symbol,timeframe,required);
   if(series==NULL)
      return false;
   if(!this.m_list_series.Add(series))
     {
      delete series;
      return false;
     }
   series.SetAvailable(true);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Synchronize the timeseries of a timeframe with the server        |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::SyncData(const ENUM_TIMEFRAMES timeframe,const uint required=0)
  {
   CBarSeriesDE *series=this.GetSeries(timeframe);
   if(series==NULL)
     {
      ::Print(DFUN,"no timeseries ",this.m_symbol," ",EnumToString(timeframe));
      return false;
     }
   return series.SyncData(required);
  }
 //+------------------------------------------------------------------+
 //| The rows of the table of one timeframe, of every timeframe        |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::ReadDataFromDB(const ENUM_TIMEFRAMES timeframe)
  {
   CBarSeriesDE *series=this.GetSeries(timeframe);
   return (series!=NULL && series.ReadDataFromDB());
  }
 bool CBarTimeSeriesDE::ReadDataFromDB(void)
  {
   bool done=true;
   for(int i=0;i<this.m_list_series.Total();i++)
     {
      CBarSeriesDE *series=this.m_list_series.At(i);
      if(series!=NULL)
         done=series.ReadDataFromDB() && done;
     }
   return done;
  }
 //+------------------------------------------------------------------+
 //| Create the bars of the timeseries of a timeframe                 |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::CreateSeries(const ENUM_TIMEFRAMES timeframe,const uint required=0)
  {
   CBarSeriesDE *series=this.GetSeries(timeframe);
   if(series==NULL)
     {
      ::Print(DFUN,"no timeseries ",this.m_symbol," ",EnumToString(timeframe));
      return false;
     }
   if(series.RequiredUsedData()==0)
     {
      ::Print(DFUN,"set the amount of data of ",this.m_symbol," ",EnumToString(timeframe)," first");
      return false;
     }
   if(series.Create(required)<=0)
      return false;
   //--- As Create takes the bars from MT5 once, ReadDataFromDB takes the rows of the table of those bars once: a pair added after Python did its part. Before it
   //--- (OnInit) nothing is read: PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE reads every pair
   series.ReadDataFromDB();
   return true;
  }
 bool CBarTimeSeriesDE::RefreshSeries(const ENUM_TIMEFRAMES timeframe)
  {
   CBarSeriesDE *series=this.GetSeries(timeframe);
   if(series==NULL || series.DataTotal()==0 || !series.IsAvailable())
      return false;
   return series.RefreshSeries();
  }
 //+------------------------------------------------------------------+
 //| The series of a timeframe goes: what waits is written first       |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::DeleteSeries(const ENUM_TIMEFRAMES timeframe)
  {
   int index=this.IndexTimeframe(timeframe);
   CBarSeriesDE *series=this.m_list_series.At(index);
   if(series==NULL)
      return false;
   return this.m_list_series.Delete(index);
  }
 //+------------------------------------------------------------------+
 //| A new tick of the symbol                                         |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::IsNewTick(void)
  {
   return this.m_new_tick.IsNewTick();
  }

#endif // CBARTIMESERIESDE_MQH_IMPLEMENTATION
#endif // __BARTIMESERIESDE_MQH__
