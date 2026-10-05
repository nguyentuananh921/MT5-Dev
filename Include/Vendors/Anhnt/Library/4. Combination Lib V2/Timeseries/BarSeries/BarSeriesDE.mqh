//+------------------------------------------------------------------+
//|                                                  BarSeriesDE.mqh |
//|Change from SeriesDE.mqh                                          |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
//+------------------------------------------------------------------+
//| Timeseries class                                                 |
//+------------------------------------------------------------------+
#property version   "1.00"
#ifndef __BARSERIESDE_MQH__
#define __BARSERIESDE_MQH__
#ifndef CBARSERIESDE_MQH_DECLARATION
#define CBARSERIESDE_MQH_DECLARATION
 #include <Arrays\ArrayObj.mqh>
 //+------------------------------------------------------------------+
 //| Include Custom files                                             |
 //+------------------------------------------------------------------+
 #include "NewBarObj.mqh"
 #include "..\..\Entities\Bar.mqh"
  #include "..\BarPatternsControl\BarPatternsControl.mqh"
  #include "..\BarSwingControl\BarSwingControl.mqh"
  #include "..\..\Services\Pause.mqh"
class CBarSeriesDE : public CBaseObj
 {
  private://Private Properties
    CBar              m_bar_tmp;                                         // Bar object for search
    ENUM_TIMEFRAMES   m_timeframe;                                       // Timeframe
    string            m_symbol;                                          // Symbol
    string            m_period_description;                              // Timeframe string description
    datetime          m_firstdate;                                       // The very first date by a period symbol at the moment
    datetime          m_lastbar_date;                                    // Time of opening the last bar by period symbol
    uint              m_amount;                                          // Amount of applied timeseries data
    uint              m_required;                                        // Required amount of applied timeseries data
    uint              m_bars;                                            // Number of bars in history by symbol and timeframe
    bool              m_sync;                                            // Synchronized data flag
    CArrayObj         m_list_series;                                     // Timeseries list
    CNewBarObj        m_new_bar_obj;                                     // "New bar" object
    
    CBarPatternsControl *m_patterns_control;                             // Pointer to pattern control object
    CBarSwingControl *m_swing_control;                                   // Pointer to swing control object
   //--- Set the very first date by a period symbol at the moment and the new time of opening the last bar by a period symbol
    void              SetServerDate(void);
  protected:
    CArrayObj        *m_list_all_patterns;                               // Pointer to the list of all patterns of all timeseries of all symbols
    CArrayObj        *m_list_all_swings;                                 // Pointer to the list of all swings of all timeseries of all symbols
  public:
   //--- Return (1) itself, (2) timeseries list, (3) timeseries "New bar" object and (4) pattern management object
    CBarSeriesDE        *GetObject(void)                                    { return &this;                  }
    CArrayObj           *GetList(void)                                      { return &m_list_series;         }
    CNewBarObj          *GetNewBarObj(void)                                 { return &this.m_new_bar_obj;    }
    CBarPatternsControl *GetPatternsCtrlObj(void)                           { return this.m_patterns_control;}
    CBarSwingControl    *GetSwingCtrlObj(void)                            { return this.m_swing_control;   }

   //--- Return the list of bars by selected (1) double, (2) integer and (3) string property fitting a compared condition
    CArrayObj        *GetList(ENUM_BAR_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode=EQUAL){ return CTimeseriesSelect::ByBarProperty(this.GetList(),property,value,mode); }
    CArrayObj        *GetList(ENUM_BAR_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode=EQUAL) { return CTimeseriesSelect::ByBarProperty(this.GetList(),property,value,mode); }
    CArrayObj        *GetList(ENUM_BAR_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode=EQUAL){ return CTimeseriesSelect::ByBarProperty(this.GetList(),property,value,mode); }

   //--- Set (1) symbol, (2) timeframe, (3) symbol and timeframe, (4) amount of applied timeseries data
    void              SetSymbol(const string symbol,const bool set_server_date=false);
    void              SetTimeframe(const ENUM_TIMEFRAMES timeframe,const bool set_server_date=false);
    void              SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe);
    bool              SetRequiredUsedData(const uint required,const uint rates_total);

   //--- Return (1) symbol, (2) timeframe, number of (3) used and (4) requested timeseries data,
   //--- (5) number of bars in the timeseries, (6) the very first date, (7) time of opening the last bar by a symbol period,
   //--- new bar flag with (8) automatic and (9) manual time management
    string            Symbol(void)                                          const { return this.m_symbol;                            }
    ENUM_TIMEFRAMES   Timeframe(void)                                       const { return this.m_timeframe;                         }
    ulong             AvailableUsedData(void)                               const { return this.m_amount;                            }
    ulong             RequiredUsedData(void)                                const { return this.m_required;                          }
    ulong             Bars(void)                                            const { return this.m_bars;                              }
    datetime          FirstDate(void)                                       const { return this.m_firstdate;                         }
    datetime          LastBarDate(void)                                     const { return this.m_lastbar_date;                      }
    bool              IsNewBar(const datetime time)                               { return this.m_new_bar_obj.IsNewBar(time);        }
    bool              IsNewBarManual(const datetime time)                         { return this.m_new_bar_obj.IsNewBarManual(time);  }
   //--- Return the bar object by (1) a real index in the list, (2) an index as in the timeseries, (3) time and (4) the real list size
    CBar             *GetBarByListIndex(const uint index);
    CBar             *GetBar(const uint index);
    CBar             *GetBar(const datetime time); 
    int               DataTotal(void)                                       const { return this.m_list_series.Total();               }
   //--- Return (1) Open, (2) High, (3) Low, (4) Close, (5) time, (6) tick volume, (7) real volume, (8) bar spread by index
    double            Open(const uint index,const bool from_series=true);
    double            High(const uint index,const bool from_series=true);
    double            Low(const uint index,const bool from_series=true);
    double            Close(const uint index,const bool from_series=true);
    datetime          Time(const uint index,const bool from_series=true);
    long              TickVolume(const uint index,const bool from_series=true);
    long              RealVolume(const uint index,const bool from_series=true);
    int               Spread(const uint index,const bool from_series=true);

   //--- Return (1) Open, (2) High, (3) Low, (4) Close, (5) time, (6) tick volume, (7) real volume, (8) bar spread by bar open time
    double            Open(const datetime time);
    double            High(const datetime time);
    double            Low(const datetime time);
    double            Close(const datetime time);
    datetime          Time(const datetime time);
    long              TickVolume(const datetime time);
    long              RealVolume(const datetime time);
    int               Spread(const datetime time);

   //--- (1) Set and (2) return the sound of a sound file of the "New bar" timeseries event
    void              SetNewBarSoundName(const string name)                       { this.m_new_bar_obj.SetSoundName(name);           }
    string            NewBarSoundName(void)                                 const { return this.m_new_bar_obj.GetSoundName();        }

   //--- Save the new bar time during the manual time management
    void              SaveNewBarTime(const datetime time)                         { this.m_new_bar_obj.SaveNewBarTime(time);         }
   //--- Synchronize symbol and timeframe data with server data
    bool              SyncData(const uint required,const uint rates_total);
   //--- (1) Create and (2) update the timeseries list
    int               Create(const uint required=0);
    void              Refresh(SDataCalculate &data_calculate);
   //--- Copy the specified double property of the timeseries to the array
   //--- Regardless of the array indexing direction, copying is performed the same way as copying to a timeseries array
    bool              CopyToBufferAsSeries(const ENUM_BAR_PROP_DOUBLE property,double &array[],const double empty=EMPTY_VALUE);

   //--- Create and send the timeseries event to the control program chart
    void              SendEvent(ENUM_SERIES_EVENT event);

   //--- Return the timeseries name
    string            Header(void);
   //--- Display (1) the timeseries description and (2) the brief timeseries description in the journal
    virtual void      Print(const bool full_prop=false,const bool dash=false);
    virtual void      PrintShort(const bool dash=false,const bool symbol=false);

   //--- Comparison method to search for identical timeseries objects by timeframe
    virtual int       Compare(const CObject *node,const int mode=0);
   //--- Constructors
                      CBarSeriesDE(CArrayObj *list);
                      CBarSeriesDE(CArrayObj *list,CArrayObj *list_swings,const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0);
                      ~CBarSeriesDE(void);
   //+------------------------------------------------------------------+
   //| Working with patterns                                            |
   //+------------------------------------------------------------------+
   //--- Set the flag for using the specified pattern and create a control object if it does not already exist
    void SetUsedPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[],const bool flag);
   //--- Return the flag of using the specified pattern
    bool IsUsedPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[]);
 };
#endif // CBARSERIESDE_MQH_DECLARATION
#ifndef CBARSERIESDE_MQH_IMPLEMENTATION
#define CBARSERIESDE_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor 1 (current symbol and period timeseries)             |
  //+------------------------------------------------------------------+
  CBarSeriesDE::CBarSeriesDE(CArrayObj *list) : m_bars(0),m_amount(0),m_required(0),m_sync(false)
    {
    this.m_type=OBJECT_DE_TYPE_SERIES_PERIOD; 
    this.m_list_series.Clear();
    this.m_list_series.Sort(SORT_BY_BAR_TIME);
    this.SetSymbolPeriod(NULL,(ENUM_TIMEFRAMES)::Period());
    this.m_period_description=TimeframeDescription(this.m_timeframe);
    this.m_list_all_patterns=list;
    this.m_patterns_control=new CBarPatternsControl(this.m_symbol,this.m_timeframe,this.GetList(),this.m_list_all_patterns);
    this.m_list_all_swings=NULL;
    this.m_swing_control=new CBarSwingControl(this.m_symbol,this.m_timeframe,this.GetList(),this.m_list_all_swings);
    }
  //+------------------------------------------------------------------+
  //| Constructor 2 (specified symbol and period timeseries)           |
  //+------------------------------------------------------------------+
  CBarSeriesDE::CBarSeriesDE(CArrayObj *list,CArrayObj *list_swings,const string symbol,const ENUM_TIMEFRAMES timeframe,const uint required=0) : m_bars(0), m_amount(0),m_required(0),m_sync(false)
    {
    this.m_type=OBJECT_DE_TYPE_SERIES_PERIOD; 
    this.m_list_series.Clear();
    this.m_list_series.Sort(SORT_BY_BAR_TIME);
    this.SetSymbolPeriod(symbol,timeframe);
    this.m_sync=this.SetRequiredUsedData(required,0);
    this.m_period_description=TimeframeDescription(this.m_timeframe);
    this.m_list_all_patterns=list;
    this.m_patterns_control=new CBarPatternsControl(this.m_symbol,this.m_timeframe,this.GetList(),this.m_list_all_patterns);
    this.m_list_all_swings=list_swings;
    this.m_swing_control=new CBarSwingControl(this.m_symbol,this.m_timeframe,this.GetList(),this.m_list_all_swings);
    }
  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CBarSeriesDE::~CBarSeriesDE(void)
    {
    if(this.m_patterns_control!=NULL)
        delete this.m_patterns_control;
    if(this.m_swing_control!=NULL)
        delete this.m_swing_control;
    }
  int CBarSeriesDE::Compare(const CObject *node,const int mode=0) 
    {   
      const CBarSeriesDE *compared_obj=node;
      return(this.Timeframe()>compared_obj.Timeframe() ? 1 : this.Timeframe()<compared_obj.Timeframe() ? -1 : 0);
    } 
  void CBarSeriesDE::SetServerDate(void)
    {
      this.m_firstdate=(datetime)::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_FIRSTDATE);
      this.m_lastbar_date=(datetime)::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_LASTBAR_DATE);
    }
  //+------------------------------------------------------------------+
  //| Set a symbol                                                     |
  //+------------------------------------------------------------------+
  void CBarSeriesDE::SetSymbol(const string symbol,const bool set_server_date=false)
    {
    if(this.m_symbol==symbol)
        return;
    this.m_symbol=(symbol==NULL || symbol=="" ? ::Symbol() : symbol);
    this.m_new_bar_obj.SetSymbol(this.m_symbol);
    if(set_server_date)
        this.SetServerDate();
    }
  //+------------------------------------------------------------------+
  //| Set a timeframe                                                  |
  //+------------------------------------------------------------------+
  void CBarSeriesDE::SetTimeframe(const ENUM_TIMEFRAMES timeframe,const bool set_server_date=false)
    {
    if(this.m_timeframe==timeframe)
        return;
    this.m_timeframe=(timeframe==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)::Period() : timeframe);
    this.m_new_bar_obj.SetTimeframe(this.m_timeframe);
    this.m_period_description=TimeframeDescription(this.m_timeframe);
    if(set_server_date)
        this.SetServerDate();
    }
  //+------------------------------------------------------------------+
  //| Set a symbol and timeframe                                       |
  //+------------------------------------------------------------------+
  void CBarSeriesDE::SetSymbolPeriod(const string symbol,const ENUM_TIMEFRAMES timeframe)
    {
    if(this.m_symbol==symbol && this.m_timeframe==timeframe)
        return;
    this.SetSymbol(symbol);
    this.SetTimeframe(timeframe,true);
    }
  void CBarSeriesDE::SetUsedPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[],const bool flag)
    {
      if(this.m_patterns_control!=NULL)
        this.m_patterns_control.SetUsedPattern(pattern,param,flag);
    }
  bool CBarSeriesDE::IsUsedPattern(const ENUM_PATTERN_TYPE pattern,MqlParam &param[])
    {
      return(this.m_patterns_control!=NULL ? this.m_patterns_control.IsUsedPattern(pattern,param) : false);
    }

  //+------------------------------------------------------------------+
  //| Set the number of required data                                  |
  //+------------------------------------------------------------------+
  bool CBarSeriesDE::SetRequiredUsedData(const uint required,const uint rates_total)
    {
    this.m_required=(required<1 ? SERIES_DEFAULT_BARS_COUNT : required);
  //--- Launch downloading historical data
    if(this.m_program!=PROGRAM_INDICATOR || (this.m_program==PROGRAM_INDICATOR && (this.m_symbol!=::Symbol() || this.m_timeframe!=::Period())))
      {
        datetime array[1];
        ::CopyTime(this.m_symbol,this.m_timeframe,0,1,array);
      }
  //--- Set the number of available timeseries bars
    this.m_bars=(uint)
      (
        //--- If this is an indicator and the work is performed on the current symbol and timeframe,
        //--- add the rates_total value passed to the method,
        //--- otherwise, get the number from the environment
        this.m_program==PROGRAM_INDICATOR && 
        this.m_symbol==::Symbol() && this.m_timeframe==::Period() ? rates_total : 
        ::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_BARS_COUNT)
      );
  //--- If succeeded to set the number of available history bars, set the amount of data in the list:
    if(this.m_bars>0)
      {
        //--- if zero 'required' value is passed,
        //--- use either the default value (1000 bars) or the number of available history bars - the least one of them
        //--- if non-zero 'required' value is passed,
        //--- use either the 'required' value or the number of available history bars - the least one of them
        this.m_amount=(required==0 ? ::fmin(SERIES_DEFAULT_BARS_COUNT,this.m_bars) : ::fmin(required,this.m_bars));
        return true;
      }
    return false;
    }
  //+------------------------------------------------------------------+
  //|Synchronize symbol and timeframe data with server data            |
  //+------------------------------------------------------------------+
  bool CBarSeriesDE::SyncData(const uint required,const uint rates_total)
    {
  //--- If the timeseries is not used, notify of that and exit
    if(!this.m_available)
      {
        ::Print(DFUN,this.m_symbol," ",TimeframeDescription(this.m_timeframe),": ",CMessage::Text(MSG_LIB_TEXT_TS_TEXT_IS_NOT_USE));
        return false;
      }
  //--- If managed to obtain the available number of bars in the timeseries
  //--- and return the size of the bar object list, return 'true'
    this.m_sync=this.SetRequiredUsedData(required,rates_total);
    if(this.m_sync)
        return true;

  //--- Data is not yet synchronized with the server
  //--- Create a pause object
    CPause *pause=new CPause();
    if(pause==NULL)
      {
        ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_PAUSE_OBJ));
        return false;
      }
  //--- Set the pause duration of 16 milliseconds (PAUSE_FOR_SYNC_ATTEMPTS) and initialize the tick counter
    pause.SetWaitingMSC(PAUSE_FOR_SYNC_ATTEMPTS);
    pause.SetTimeBegin(0);
  //--- Make five (ATTEMPTS_FOR_SYNC) attempts to obtain the available number of bars in the timeseries
  //--- and set the bar object list size
    int attempts=0;
    while(attempts<ATTEMPTS_FOR_SYNC && !::IsStopped())
      {
        //--- If data is currently synchronized with the server
        if(::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_SYNCHRONIZED))
          {
          //--- if managed to obtain the available number of bars in the timeseries
          //--- and set the size of the bar object list, break the loop
          this.m_sync=this.SetRequiredUsedData(required,rates_total);
          if(this.m_sync)
              break;
          }
        //--- Data is not yet synchronized.
        //--- If the pause of 16 ms is over
        if(pause.IsCompleted())
          {
          //--- set the new start of the next waiting for the pause object
          //--- and increase the attempt counter
          pause.SetTimeBegin(0);
          attempts++;
          }
      }
  //--- Remove the pause object and return the m_sync value
    delete pause;
    return this.m_sync;
    }
  //+------------------------------------------------------------------+
  //| Create the timeseries list                                       |
  //+------------------------------------------------------------------+
  int CBarSeriesDE::Create(const uint required=0)
    {
  //--- If the required history depth is not set for the list yet,
  //--- display the appropriate message and return zero,
    if(this.m_amount==0)
      {
        ::Print(DFUN,this.m_symbol," ",TimeframeDescription(this.m_timeframe),": ",CMessage::Text(MSG_LIB_TEXT_BAR_TEXT_FIRS_SET_AMOUNT_DATA));
        return 0;
      }
  //--- otherwise, if the passed 'required' value exceeds zero and is not equal to the one already set, 
  //--- while the passed ‘required’ value is less than the available bar number,
  //--- set the new value of the required history depth for the list
    else if(required>0 && this.m_amount!=required && required<this.m_bars)
      {
        //--- If failed to set a new value, return zero
        if(!this.SetRequiredUsedData(required,0))
          return 0;
      }
  //--- For the rates[] array we are to receive historical data to,
  //--- set the flag of direction like in the timeseries,
  //--- clear the bar object list and set the flag of sorting by bar index
    MqlRates rates[];
    ::ArraySetAsSeries(rates,true);
    this.m_list_series.Clear();
    this.m_list_series.Sort(SORT_BY_BAR_TIME);
    ::ResetLastError();
  //--- Get historical data of the MqlRates structure to the rates[] array starting from the current bar in the amount of m_amount,
  //--- if failed to get data, display the appropriate message and return zero
    int copied=::CopyRates(this.m_symbol,this.m_timeframe,0,(uint)this.m_amount,rates),err=ERR_SUCCESS;
    if(copied<1)
      {
        err=::GetLastError();
        ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_BAR_FAILED_GET_SERIES_DATA)," ",this.m_symbol," ",TimeframeDescription(this.m_timeframe),". ",
                    CMessage::Text(MSG_LIB_SYS_ERROR),": ",CMessage::Text(err),CMessage::Retcode(err));
        return 0;
      }
  //--- Historical data is received in the rates[] array
    const int digits=(int)::SymbolInfoInteger(this.m_symbol,SYMBOL_DIGITS);
  //--- In the rates[] array loop,
    for(int i=0; i<copied; i++)
      {
        //--- create a new bar object out of the current MqlRates structure by the loop index
        ::ResetLastError();
        CBar* bar=new CBar(this.m_symbol,this.m_timeframe,rates[i],digits);
        if(bar==NULL)
          {
          ::Print
            (
              DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_BAR_OBJ)," ",this.Header()," ",::TimeToString(rates[i].time),". ",
              CMessage::Text(MSG_LIB_SYS_ERROR),": ",CMessage::Text(::GetLastError())
            );
          continue;
          }
        //--- If failed to add bar object to the list,
        //--- display the appropriate message with the error description in the journal
        //--- and remove the newly created object
        if(!this.m_list_series.Add(bar))
          {
          err=::GetLastError();
          ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_BAR_FAILED_ADD_TO_LIST)," ",BarHeader(bar)," ",::TimeToString(rates[i].time),". ",
                        CMessage::Text(MSG_LIB_SYS_ERROR),": ",CMessage::Text(err),CMessage::Retcode(err));
          delete bar;
          }
      }
  //--- Return the size of the created bar object list
    return this.m_list_series.Total();
    }
  //+------------------------------------------------------------------+
  //| Update timeseries list and data                                  |
  //+------------------------------------------------------------------+
  void CBarSeriesDE::Refresh(SDataCalculate &data_calculate)
   {
    //--- If the timeseries is not used, exit
      if(!this.m_available)
          return;
    //--- Fix here If history for this symbol/timeframe isn't synchronized with the server yet,
    //--- skip this refresh cycle instead of letting CopyRates() block waiting for it;
    //--- the next throttled OnTimerEvent call will retry once SERIES_SYNCHRONIZED becomes true
    if(!::SeriesInfoInteger(this.m_symbol, this.m_timeframe, SERIES_SYNCHRONIZED))
        return;
      MqlRates rates[1];
    //--- Set the flag of sorting the list of bars by time
      this.m_list_series.Sort(SORT_BY_BAR_TIME);
    //--- If a new bar is present on a symbol and period
    //--- New bar = THIS series' own bar 0 moved on (iTime), not the chart TF's bar time; every bar
    //--- between the newest held one and bar 0 is backfilled so the list has no gaps
    datetime own_bar0=::iTime(this.m_symbol,this.m_timeframe,0);
    if(own_bar0>0 && this.IsNewBarManual(own_bar0))
      {
       int      period_sec=::PeriodSeconds(this.m_timeframe);
       int      last_idx=CTimeseriesSelect::FindBarMax(this.GetList(),BAR_PROP_TIME);
       CBar    *last_bar=this.m_list_series.At(last_idx);
       // Re-read the just-closed bar via CopyRates(...,1,1,...): its last snapshot came from the
       // forming bar and can miss the final price moves
       if(last_bar!=NULL)
         {
          MqlRates fresh_check[1];
          if(::CopyRates(this.m_symbol,this.m_timeframe,1,1,fresh_check)==1 && fresh_check[0].time==last_bar.Time())
             last_bar.SetProperties(fresh_check[0]);
         }
       datetime t=(last_bar!=NULL ? last_bar.Time() : own_bar0-period_sec);
       for(t=t+period_sec; t<=own_bar0; t+=period_sec)
         {
          if(::iBarShift(this.m_symbol,this.m_timeframe,t,true)<0)
             continue;   // no bar opened at this time (market closed) - nothing to backfill
          MqlRates bar_rates[1];
          if(::CopyRates(this.m_symbol,this.m_timeframe,t,1,bar_rates)!=1 || bar_rates[0].time!=t)
             continue;
          CBar *new_bar=new CBar(this.m_symbol,this.m_timeframe,bar_rates[0],(int)::SymbolInfoInteger(this.m_symbol,SYMBOL_DIGITS));
          if(new_bar==NULL)
             continue;
          if(!this.m_list_series.InsertSort(new_bar))
            {
             delete new_bar;
             continue;
            }
          //--- if the timeseries exceeds the requested number of bars, remove the earliest bar
          if(this.m_list_series.Total()>(int)this.m_required)
             this.m_list_series.Delete(0);
         }
       //--- Write the very first date by a period symbol at the moment and the new time of opening the last bar by a period symbol
       this.SetServerDate();      
          //--- Update data of all timeseries patterns
          if(this.m_patterns_control==NULL)
            return;
          //this.m_patterns_control.RefreshAll();
          this.m_patterns_control.UpdateAll();
          if(this.m_swing_control!=NULL)
            this.m_swing_control.UpdateSwingList();
          //--- save the new bar time as the previous one for the subsequent new bar check
          this.SaveNewBarTime(own_bar0);
        }
        
    //--- Get the bar index with the maximum time (zero bar) and bar object from the list by the obtained index
      int index=CTimeseriesSelect::FindBarMax(this.GetList(),BAR_PROP_TIME);
      CBar *bar=this.m_list_series.At(index);
      if(bar==NULL)
          return;
    //--- if the work is performed in an indicator and the timeseries belongs to the current symbol and timeframe,
    //--- copy price parameters (passed to the method from the outside) to the bar price structure
      int copied=1;
      if(this.m_program==PROGRAM_INDICATOR && this.m_symbol==::Symbol() && this.m_timeframe==(ENUM_TIMEFRAMES)::Period())
        {
          rates[0].time=data_calculate.rates.time;
          rates[0].open=data_calculate.rates.open;
          rates[0].high=data_calculate.rates.high;
          rates[0].low=data_calculate.rates.low;
          rates[0].close=data_calculate.rates.close;
          rates[0].tick_volume=data_calculate.rates.tick_volume;
          rates[0].real_volume=data_calculate.rates.real_volume;
          rates[0].spread=data_calculate.rates.spread;
        }
    //--- otherwise, get data to the bar price structure from the environment
      else
          copied=::CopyRates(this.m_symbol,this.m_timeframe,0,1,rates);
    //--- If the prices are obtained, set the new properties from the price structure for the bar object
      if(copied==1)
          bar.SetProperties(rates[0]);
   }
  //+------------------------------------------------------------------+
  //| Return the bar object by a real index in the list                |
  //+------------------------------------------------------------------+
  CBar *CBarSeriesDE::GetBarByListIndex(const uint index)
    {
    return this.m_list_series.At(index);
    }
  //+------------------------------------------------------------------+
  //| Return the bar object by index as in the timeseries              |
  //+------------------------------------------------------------------+
  CBar *CBarSeriesDE::GetBar(const uint index)
    {
    datetime time=::iTime(this.m_symbol,this.m_timeframe,index);
    if(time==0)
        return NULL;
    return this.GetBar(time);
    }
  //+------------------------------------------------------------------+
  //| Return the bar object by time in the timeseries                  |
  //+------------------------------------------------------------------+
  CBar *CBarSeriesDE::GetBar(const datetime time)
    {
    this.m_bar_tmp.SetSymbolPeriod(this.m_symbol,this.m_timeframe,time);
    this.m_list_series.Sort(SORT_BY_BAR_TIME);
    int index=this.m_list_series.Search(&this.m_bar_tmp);
    return this.m_list_series.At(index);
    }
  //+------------------------------------------------------------------+
  //| Return bar's Open by the index                                   |
  //+------------------------------------------------------------------+
  double CBarSeriesDE::Open(const uint index,const bool from_series=true)
    {
    CBar *bar=(from_series ? this.GetBar(index) : this.GetBarByListIndex(index));
    return(bar!=NULL ? bar.Open() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar's High by the timeseries index or the list of bars    |
  //+------------------------------------------------------------------+
  double CBarSeriesDE::High(const uint index,const bool from_series=true)
    {
    CBar *bar=(from_series ? this.GetBar(index) : this.GetBarByListIndex(index));
    return(bar!=NULL ? bar.High() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar's Low by the timeseries index or the list of bars     |
  //+------------------------------------------------------------------+
  double CBarSeriesDE::Low(const uint index,const bool from_series=true)
    {
    CBar *bar=(from_series ? this.GetBar(index) : this.GetBarByListIndex(index));
    return(bar!=NULL ? bar.Low() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar's Close by the timeseries index or the list of bars   |
  //+------------------------------------------------------------------+
  double CBarSeriesDE::Close(const uint index,const bool from_series=true)
    {
    CBar *bar=(from_series ? this.GetBar(index) : this.GetBarByListIndex(index));
    return(bar!=NULL ? bar.Close() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar time by the timeseries index or the list of bars      |
  //+------------------------------------------------------------------+
  datetime CBarSeriesDE::Time(const uint index,const bool from_series=true)
    {
    CBar *bar=(from_series ? this.GetBar(index) : this.GetBarByListIndex(index));
    return(bar!=NULL ? bar.Time() : 0);
    }
  //+-------------------------------------------------------------------+
  //|Return bar tick volume by the timeseries index or the list of bars |
  //+-------------------------------------------------------------------+
  long CBarSeriesDE::TickVolume(const uint index,const bool from_series=true)
    {
    CBar *bar=(from_series ? this.GetBar(index) : this.GetBarByListIndex(index));
    return(bar!=NULL ? bar.VolumeTick() : WRONG_VALUE);
    }
  //+--------------------------------------------------------------------+
  //|Return bar real volume by the timeseries index or the list of bars  |
  //+--------------------------------------------------------------------+
  long CBarSeriesDE::RealVolume(const uint index,const bool from_series=true)
    {
    CBar *bar=(from_series ? this.GetBar(index) : this.GetBarByListIndex(index));
    return(bar!=NULL ? bar.VolumeReal() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar spread by the timeseries index or the list of bars    |
  //+------------------------------------------------------------------+
  int CBarSeriesDE::Spread(const uint index,const bool from_series=true)
    {
    CBar *bar=(from_series ? this.GetBar(index) : this.GetBarByListIndex(index));
    return(bar!=NULL ? bar.Spread() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar's Open by time                                        |
  //+------------------------------------------------------------------+
  double CBarSeriesDE::Open(const datetime time)
    {
    CBar *bar=this.GetBar(time);
    return(bar!=NULL ? bar.Open() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar's High by time                                        |
  //+------------------------------------------------------------------+
  double CBarSeriesDE::High(const datetime time)
    {
    CBar *bar=this.GetBar(time);
    return(bar!=NULL ? bar.High() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar's Low by time                                         |
  //+------------------------------------------------------------------+
  double CBarSeriesDE::Low(const datetime time)
    {
    CBar *bar=this.GetBar(time);
    return(bar!=NULL ? bar.Low() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar's Close by time                                       |
  //+------------------------------------------------------------------+
  double CBarSeriesDE::Close(const datetime time)
    {
    CBar *bar=this.GetBar(time);
    return(bar!=NULL ? bar.Close() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar time by time                                          |
  //+------------------------------------------------------------------+
  datetime CBarSeriesDE::Time(const datetime time)
    {
    CBar *bar=this.GetBar(time);
    return(bar!=NULL ? bar.Time() : 0);
    }
  //+------------------------------------------------------------------+
  //| Return bar tick volume by time                                   |
  //+------------------------------------------------------------------+
  long CBarSeriesDE::TickVolume(const datetime time)
    {
    CBar *bar=this.GetBar(time);
    return(bar!=NULL ? bar.VolumeTick() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar real volume by time                                   |
  //+------------------------------------------------------------------+
  long CBarSeriesDE::RealVolume(const datetime time)
    {
    CBar *bar=this.GetBar(time);
    return(bar!=NULL ? bar.VolumeReal() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return bar spread by time                                        |
  //+------------------------------------------------------------------+
  int CBarSeriesDE::Spread(const datetime time)
    {
    CBar *bar=this.GetBar(time);
    return(bar!=NULL ? bar.Spread() : WRONG_VALUE);
    }
  //+------------------------------------------------------------------+
  //| Return the timeseries name                                       |
  //+------------------------------------------------------------------+
  string CBarSeriesDE::Header(void)
    {
    return CMessage::Text(MSG_LIB_TEXT_TS_TEXT_TIMESERIES)+" \""+this.m_symbol+"\" "+this.m_period_description;
    }
  //+------------------------------------------------------------------+
  //| Display the timeseries description in the journal                |
  //+------------------------------------------------------------------+
  void CBarSeriesDE::Print(const bool full_prop=false,const bool dash=false)
    {
    string txt=
      (
        CMessage::Text(MSG_LIB_TEXT_TS_REQUIRED_HISTORY_DEPTH)+(string)this.RequiredUsedData()+", "+
        CMessage::Text(MSG_LIB_TEXT_TS_ACTUAL_DEPTH)+(string)this.AvailableUsedData()+", "+
        CMessage::Text(MSG_LIB_TEXT_TS_AMOUNT_HISTORY_DATA)+(string)this.DataTotal()+", "+
        CMessage::Text(MSG_LIB_TEXT_TS_HISTORY_BARS)+(string)this.Bars()
      );
    ::Print(this.Header(),": ",txt);
    }
  //+------------------------------------------------------------------+
  //| Display a short timeseries description in the journal            |
  //+------------------------------------------------------------------+
  void CBarSeriesDE::PrintShort(const bool dash=false,const bool symbol=false)
    {
    string txt=
      (
        CMessage::Text(MSG_LIB_TEXT_TS_TEXT_REQUIRED)+": "+(string)this.RequiredUsedData()+", "+
        CMessage::Text(MSG_LIB_TEXT_TS_TEXT_ACTUAL)+": "+(string)this.AvailableUsedData()+", "+
        CMessage::Text(MSG_LIB_TEXT_TS_TEXT_CREATED)+": "+(string)this.DataTotal()+", "+
        CMessage::Text(MSG_LIB_TEXT_TS_TEXT_HISTORY_BARS)+": "+(string)this.Bars()
      );
    ::Print("- ",this.Header(),": ",txt);
    }
  //+------------------------------------------------------------------+
  //| Create and send the timeseries event                             |
  //| to the control program chart                                     |
  //+------------------------------------------------------------------+
  void CBarSeriesDE::SendEvent(ENUM_SERIES_EVENT event)
    {
    if(event==SERIES_EVENTS_NEW_BAR)
      {
        int index=CTimeseriesSelect::FindBarMax(this.GetList(),BAR_PROP_TIME);
        CBar *bar=this.m_list_series.At(index);
        if(bar==NULL)
          return;
        ::EventChartCustom(::ChartID(),SERIES_EVENTS_NEW_BAR,bar.Time(),this.Timeframe(),this.Symbol());
      }
    else if(event==SERIES_EVENTS_MISSING_BARS)
      {
        ::EventChartCustom(::ChartID(),SERIES_EVENTS_MISSING_BARS,this.m_new_bar_obj.BarsBetweenNewBars(),this.Timeframe(),this.Symbol());
      }
    }
  //+------------------------------------------------------------------+
  //| Copy the specified double property of the timeseries to the array|
  //+------------------------------------------------------------------+
  bool CBarSeriesDE::CopyToBufferAsSeries(const ENUM_BAR_PROP_DOUBLE property,double &array[],const double empty=EMPTY_VALUE)
    {
  //--- Get the number of bars in the timeseries list
    int total=this.m_list_series.Total();
    if(total==0)
        return false;
  //--- If a dynamic array is passed to the method and its size is not equal to that of the timeseries list,
  //--- set the new size of the passed array equal to that of the timeseries list
    if(::ArrayIsDynamic(array) && ::ArraySize(array)!=total)
        if(::ArrayResize(array,total,this.m_required)==WRONG_VALUE)
          return false;
  //--- In the loop from the very last timeseries list element (from the current bar)
    int n=0;
    for(int i=total-1;i>WRONG_VALUE && !::IsStopped();i--)
      {
        //--- get the next bar object by the loop index,
        CBar *bar=this.m_list_series.At(i);
        //--- calculate the index, based on which the bar property is saved to the passed array
        n=total-1-i;
        //--- write the value of the obtained bar property using the calculated index
        //--- if the bar is not received or the property is equal to zero, write the value passed to the method as "empty" to the array
        array[n]=(bar==NULL ? empty : (bar.GetProperty(property)>0 && bar.GetProperty(property)<EMPTY_VALUE ? bar.GetProperty(property) : empty));
      }
    return true;
    }
#endif // CBARSERIESDE_MQH_IMPLEMENTATION
#endif // __BARSERIESDE_MQH__
