//+------------------------------------------------------------------+
//|                                            IndicatorSeriesDE.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//| Lib link            https://www.mql5.com/en/articles/14710       |
//| Update link          https://www.mql5.com/en/articles/8787       |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\SeriesDataInd.mqh: renamed CSeriesDataInd -> CIndicatorSeriesDE (the name of the layer as CBarSeriesDE).
//--- RAM only (MT5 gives it again at any time): no CNewBarObj (CIndicatorsCollection refreshes it on SERIES_EVENTS_NEW_BAR of its pair), Refresh() puts
//--- the bar that just closed again (its last value, not the one of the last tick). Volumes: buffer 1 is its moving average (the second handle)
#ifndef __INDICATORSERIESDE_MQH__
#define __INDICATORSERIESDE_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "IndicatorData.mqh"
#ifndef CINDICATORSERIESDE_MQH_DECLARATION
#define CINDICATORSERIESDE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The values of the buffers of an indicator over the bars of its   |
 //| symbol and timeframe                                             |
 //+------------------------------------------------------------------+
 class CIndicatorSeriesDE : public CBaseObj
  {
   private:
    string            m_symbol;
    ENUM_TIMEFRAMES   m_timeframe;
    ENUM_INDICATOR    m_ind_type;                     // Indicator type
    long              m_ind_id;                       // Indicator ID (the template)
    int               m_ind_handle;                   // Not owned: CIndicatorDE releases it
    int               m_ind_handle_average;           // Volumes: the handle of buffer 1 (INVALID_HANDLE for the others)
    int               m_buffers_total;                // The buffers the signals read
    uint              m_amount;                       // The bars kept
    CArrayObj         m_list_data;                    // Indicator data list (CIndicatorData), sorted by the time (SORT_BY_IND_DATA_TIME)
   //--- Create a new indicator data object, return pointer to it
    CIndicatorData   *CreateNewDataInd(const int buffer_num,const datetime time,const double value);
   //--- (1) The handle and (2) the buffer of it a buffer of the indicator is copied from
    int               Source(const int buffer_num) const { return (buffer_num==1 && this.m_ind_handle_average!=INVALID_HANDLE ? this.m_ind_handle_average : this.m_ind_handle); }
    int               SourceBuffer(const int buffer_num) const { return (buffer_num==1 && this.m_ind_handle_average!=INVALID_HANDLE ? 0 : buffer_num); }
   //--- The value of a buffer at a bar is written (added when it is not in the list)
    bool              SetData(const int buffer_num,const datetime time,const double value);
   public:
    CArrayObj        *GetList(void)                       { return &this.m_list_data;        }
    int               DataTotal(void)               const { return this.m_list_data.Total(); }
    string            Symbol(void)                  const { return this.m_symbol;            }
    ENUM_TIMEFRAMES   Timeframe(void)               const { return this.m_timeframe;         }
    int               IndBuffersTotal(void)         const { return this.m_buffers_total;     }
    long              IndID(void)                   const { return this.m_ind_id;            }
    void              SetIndID(const long id)             { this.m_ind_id=id;                }
    void              SetIndicator(const string symbol,const ENUM_TIMEFRAMES timeframe,const ENUM_INDICATOR ind_type,const int handle,const int handle_average,const int buffers_total);
   //--- (1) Create the list (0: the indicator is not calculated yet), (2) update it: the forming bar and the bar that just closed
    int               Create(const uint required=0);
    void              Refresh(void);
   //--- The value object of a buffer by (1) open time, (2) bar index
    CIndicatorData   *GetIndDataByTime(const int buffer_num,const datetime time);
    CIndicatorData   *GetIndDataByBar(const int buffer_num,const uint shift);
   //--- The value of a buffer by (1) open time, (2) bar index (EMPTY_VALUE: none)
    double            BufferValue(const int buffer_num,const datetime time);
    double            BufferValue(const int buffer_num,const uint shift);
                      CIndicatorSeriesDE(void) : m_timeframe(PERIOD_CURRENT),m_ind_type(IND_AC),m_ind_id(WRONG_VALUE),m_ind_handle(INVALID_HANDLE),m_ind_handle_average(INVALID_HANDLE),
                                                 m_buffers_total(0),m_amount(0)
                         { this.m_object_type=OBJECT_DE_TYPE_IND_DATA_LIST; this.m_list_data.Sort(SORT_BY_IND_DATA_TIME); }
  };
#endif // CINDICATORSERIESDE_MQH_DECLARATION
#ifndef CINDICATORSERIESDE_MQH_IMPLEMENTATION
#define CINDICATORSERIESDE_MQH_IMPLEMENTATION
 void CIndicatorSeriesDE::SetIndicator(const string symbol,const ENUM_TIMEFRAMES timeframe,const ENUM_INDICATOR ind_type,const int handle,const int handle_average,const int buffers_total)
  {
   this.m_symbol=symbol;
   this.m_timeframe=timeframe;
   this.m_ind_type=ind_type;
   this.m_ind_handle=handle;
   this.m_ind_handle_average=handle_average;
   this.m_buffers_total=buffers_total;
   this.m_list_data.Clear();
  }
 //+------------------------------------------------------------------+
 //| Every buffer over the newest bars (as V1: SERIES_DEFAULT_BARS_   |
 //| COUNT when 0 is asked, never more than the bars of the history)   |
 //+------------------------------------------------------------------+
 int CIndicatorSeriesDE::Create(const uint required=0)
  {
   this.m_list_data.Clear();
   if(this.m_ind_handle==INVALID_HANDLE)
      return 0;
   int bars=::Bars(this.m_symbol,this.m_timeframe);
   if(bars<1)
      return 0;
   this.m_amount=(uint)::fmin(required<1 ? SERIES_DEFAULT_BARS_COUNT : required,bars);
   datetime times[];
   ::ArraySetAsSeries(times,true);
   if(::CopyTime(this.m_symbol,this.m_timeframe,0,this.m_amount,times)!=(int)this.m_amount)
      return 0;
   for(int b=0;b<this.m_buffers_total;b++)
     {
      int source=this.Source(b);
      if(::BarsCalculated(source)<(int)this.m_amount)
        {
         this.m_list_data.Clear();
         return 0;   // not calculated yet: the next Refresh() asks again
        }
      double data[];
      ::ArraySetAsSeries(data,true);
      ::ResetLastError();
      if(::CopyBuffer(source,this.SourceBuffer(b),0,this.m_amount,data)!=(int)this.m_amount)
        {
         int err=::GetLastError();
         ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_IND_DATA_FAILED_GET_SERIES_DATA)," ",this.m_symbol," ",::EnumToString(this.m_timeframe),", buffer ",b,": ",CMessage::Text(err)," (",err,")");
         this.m_list_data.Clear();
         return 0;
        }
      for(int j=0;j<(int)this.m_amount;j++)
        {
         CIndicatorData *data_ind=this.CreateNewDataInd(b,times[j],data[j]);
         if(data_ind==NULL)
           {
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_IND_DATA_OBJ)," ",::TimeToString(times[j]));
            continue;
           }
         if(!this.m_list_data.Add(data_ind))
           {
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_IND_DATA_FAILED_ADD_TO_LIST)," ",::TimeToString(times[j]));
            delete data_ind;
           }
        }
     }
   this.m_list_data.Sort(SORT_BY_IND_DATA_TIME);
   return this.m_list_data.Total();
  }
 //+------------------------------------------------------------------+
 //| The bars from the newest one in the list (its last value: it was  |
 //| the forming one) to the forming one are written; the oldest bars  |
 //| go when the list is longer than its amount                        |
 //+------------------------------------------------------------------+
 void CIndicatorSeriesDE::Refresh(void)
  {
   CIndicatorData *newest=(this.m_list_data.Total()>0 ? this.m_list_data.At(this.m_list_data.Total()-1) : NULL);
   int from_shift=(newest!=NULL ? ::iBarShift(this.m_symbol,this.m_timeframe,newest.Time(),true) : -1);
   if(from_shift<0 || from_shift>=(int)this.m_amount)
     {
      this.Create();   // nothing yet, or more bars missed than the list keeps
      return;
     }
   for(int shift=from_shift;shift>=0;shift--)
     {
      datetime time=::iTime(this.m_symbol,this.m_timeframe,shift);
      if(time==0)
         return;
      for(int b=0;b<this.m_buffers_total;b++)
        {
         double data[1];
         ::ResetLastError();
         if(::CopyBuffer(this.Source(b),this.SourceBuffer(b),shift,1,data)!=1)
           {
            int err=::GetLastError();
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_IND_DATA_FAILED_GET_CURRENT_DATA)," ",this.m_symbol," ",::EnumToString(this.m_timeframe),", buffer ",b,": ",CMessage::Text(err)," (",err,")");
            return;
           }
         this.SetData(b,time,data[0]);
        }
     }
   while(this.m_list_data.Total()>(int)this.m_amount*this.m_buffers_total)
      this.m_list_data.Delete(0);
  }
 bool CIndicatorSeriesDE::SetData(const int buffer_num,const datetime time,const double value)
  {
   CIndicatorData *data_ind=this.GetIndDataByTime(buffer_num,time);
   if(data_ind!=NULL)
     {
      data_ind.SetBufferValue(value);
      return true;
     }
   data_ind=this.CreateNewDataInd(buffer_num,time,value);
   if(data_ind==NULL)
     {
      ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_IND_DATA_OBJ)," ",::TimeToString(time));
      return false;
     }
   if(!this.m_list_data.InsertSort(data_ind))
     {
      ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_IND_DATA_FAILED_ADD_TO_LIST)," ",::TimeToString(time));
      delete data_ind;
      return false;
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Create a new indicator data object, return the pointer           |
 //+------------------------------------------------------------------+
 CIndicatorData *CIndicatorSeriesDE::CreateNewDataInd(const int buffer_num,const datetime time,const double value)
  {
   return new CIndicatorData(this.m_ind_type,this.m_ind_id,buffer_num,this.m_symbol,this.m_timeframe,time,value);
  }
 //+------------------------------------------------------------------+
 //| Return indicator data object by time and buffer number: the list |
 //| is sorted by the time, the buffers of a bar are next to it        |
 //+------------------------------------------------------------------+
 CIndicatorData *CIndicatorSeriesDE::GetIndDataByTime(const int buffer_num,const datetime time)
  {
   CIndicatorData key;
   key.SetProperty(IND_DATA_PROP_TIME,time);
   int index=this.m_list_data.Search(&key);
   if(index<0)
      return NULL;
   for(int i=index;i>=0;i--)
     {
      CIndicatorData *data_ind=this.m_list_data.At(i);
      if(data_ind==NULL || data_ind.Time()!=time)
         break;
      if(data_ind.BufferNum()==buffer_num)
         return data_ind;
     }
   for(int i=index+1;i<this.m_list_data.Total();i++)
     {
      CIndicatorData *data_ind=this.m_list_data.At(i);
      if(data_ind==NULL || data_ind.Time()!=time)
         break;
      if(data_ind.BufferNum()==buffer_num)
         return data_ind;
     }
   return NULL;
  }
 CIndicatorData *CIndicatorSeriesDE::GetIndDataByBar(const int buffer_num,const uint shift)
  {
   datetime time=::iTime(this.m_symbol,this.m_timeframe,(int)shift);
   return (time==0 ? NULL : this.GetIndDataByTime(buffer_num,time));
  }
 double CIndicatorSeriesDE::BufferValue(const int buffer_num,const datetime time)
  {
   CIndicatorData *data_ind=this.GetIndDataByTime(buffer_num,time);
   return (data_ind==NULL ? EMPTY_VALUE : data_ind.BufferValue());
  }
 double CIndicatorSeriesDE::BufferValue(const int buffer_num,const uint shift)
  {
   CIndicatorData *data_ind=this.GetIndDataByBar(buffer_num,shift);
   return (data_ind==NULL ? EMPTY_VALUE : data_ind.BufferValue());
  }
#endif // CINDICATORSERIESDE_MQH_IMPLEMENTATION
#endif // __INDICATORSERIESDE_MQH__
