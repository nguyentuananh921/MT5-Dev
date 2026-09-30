//+------------------------------------------------------------------+
//|                                              BarTimeSeriesDE.mqh |
//|Change from TimeSeriesDE.mqh                                      |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link "https://mql5.com/en/users/artmedia70"
#property version "1.00"
#ifndef CBAR_TIME_SERIES_DE_MQH
#define CBAR_TIME_SERIES_DE_MQH
#property strict  // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "..\Ticks\NewTickObj.mqh"
#include "BarSeriesDE.mqh"
//#include "..\..\..\Services\DELib\CommonDELib.mqh"
//+------------------------------------------------------------------+
//| Symbol timeseries class                                          |
//+------------------------------------------------------------------+
#ifndef CBAR_TIME_SERIES_DE_MQH_DECLARATION
#define CBAR_TIME_SERIES_DE_MQH_DECLARATION
class CBarTimeSeriesDE : public CBaseObjExt
 {
   private:
      string                       m_symbol;                // Timeseries symbol
      CNewTickObj                  m_new_tick;              // "New tick" object
      CArrayObj                    m_list_series;           // List of timeseries by timeframes
      datetime                     m_server_firstdate;      // The very first date in history by a server symbol
      datetime                     m_terminal_firstdate;    // The very first date in history by a symbol in the client terminal
      //--- Return (1) the timeframe index in the list and (2) the timeframe by the list index
        int IndexTimeframe(const ENUM_TIMEFRAMES timeframe);
        ENUM_TIMEFRAMES TimeframeByIndex(const uchar index) const { return TimeframeByEnumIndex(uchar(index + 1)); }
      //--- Set the very first date in history by symbol on the server and in the client terminal
        void SetTerminalServerDate(void);
   protected:
    // Pointer to the list of all patterns of all timeseries of all symbols
      CArrayObj*                   m_list_all_patterns;  
      CArrayObj*                   m_list_all_swings;    // Pointer to the list of all swings of all timeseries of all symbols

   public:
      //--- Return (1) itself, full list of (2) timeseries, (3) patterns, (4) specified timeseries object and (5) timeseries object by index
         CBarTimeSeriesDE* GetObject(void) { return &this; }
         CArrayObj* GetListSeries(void) { return &this.m_list_series; }
         CArrayObj* GetListPatterns(void) { return this.m_list_all_patterns; }
         CArrayObj* GetListSwings(void) { return this.m_list_all_swings; }
         // Modify GetSeries method
            // Original version
             // CBarSeriesDE* GetSeries(const ENUM_TIMEFRAMES timeframe) { return this.m_list_series.At(this.IndexTimeframe(timeframe)); }
         CBarSeriesDE* GetSeries(const ENUM_TIMEFRAMES timeframe);
         CBarSeriesDE* GetSeriesByIndex(const uchar index) { return this.m_list_series.At(index); }
      //--- Set/return timeseries symbol
         void SetSymbol(const string symbol) { this.m_symbol = (symbol == NULL || symbol == "" ? ::Symbol() : symbol); }
         string Symbol(void) const { return this.m_symbol; }
      //--- Set the history depth (1) of a specified timeseries and (2) of all applied symbol timeseries
         bool SetRequiredUsedData(const ENUM_TIMEFRAMES timeframe, const uint required = 0, const int rates_total = 0);
         bool SetRequiredAllUsedData(const uint required = 0, const int rates_total = 0);
      //--- Return the flag of data synchronization with the server data of the (1) specified timeseries, (2) all timeseries
         bool SyncData(const ENUM_TIMEFRAMES timeframe, const int rates_total = 0, const uint required = 0);
         bool SyncAllData(const int rates_total = 0, const uint required = 0);
      //--- Return the very first date in history by symbol (1) on the server, (2) in the client terminal and (3) the new tick flag
         datetime ServerFirstDate(void) const { return this.m_server_firstdate; }
         datetime TerminalFirstDate(void) const { return this.m_terminal_firstdate; }
         bool IsNewTick(void) { return this.m_new_tick.IsNewTick(); }
      //--- (1) Add the specified timeseries list to the list and create (2) the specified timeseries list
         bool AddSeries(const ENUM_TIMEFRAMES timeframe, const uint required = 0);
         bool CreateSeries(const ENUM_TIMEFRAMES timeframe, const uint required = 0);
      //--- Update (1) the specified timeseries list and (2) all timeseries lists
         void Refresh(const ENUM_TIMEFRAMES timeframe, SDataCalculate& data_calculate);
         void RefreshAll(SDataCalculate& data_calculate);

      //--- Copy the specified double property of the specified timeseries to the array
      //--- Regardless of the array indexing direction, copying is performed the same way as copying to a timeseries array
         bool CopyToBufferAsSeries(const ENUM_TIMEFRAMES timeframe,
                                  const ENUM_BAR_PROP_DOUBLE property,
                                  double& array[],
                                  const double empty = EMPTY_VALUE);

      //--- Compare CBarTimeSeriesDE objects (by symbol)
      virtual int Compare(const CObject* node, const int mode = 0) const;
      //--- Display (1) description and (2) short symbol timeseries description in the journal
      virtual void Print(const bool full_prop = false, const bool created = false);
      virtual void PrintShort(const bool dash = false, const bool created = false);

      //--- Constructors
      CBarTimeSeriesDE(CArrayObj* list_all_patterns)
      {
         this.m_type = OBJECT_DE_TYPE_SERIES_SYMBOL;
         this.m_list_all_patterns = list_all_patterns;
         this.m_list_all_swings = NULL;
      }
      CBarTimeSeriesDE(CArrayObj* list_all_patterns, CArrayObj* list_all_swings, const string symbol);

      //+------------------------------------------------------------------+
      //| Methods for handling patterns                                    |
      //+------------------------------------------------------------------+
      //--- Set the flag for using the specified pattern and create a control object if it does not already exist
         void SetUsedPattern(const ENUM_PATTERN_TYPE pattern, MqlParam& param[], const ENUM_TIMEFRAMES timeframe, const bool flag);
      //--- Return the flag of using the specified Harami pattern
         bool IsUsedPattern(const ENUM_PATTERN_TYPE pattern, MqlParam& param[], const ENUM_TIMEFRAMES timeframe);      
      void SetChartPropertiesToPattCtrl(const ENUM_TIMEFRAMES timeframe, const double price_max, const double price_min, const int scale, const int height_px, const int width_px);
 };
#endif  // CBAR_TIME_SERIES_DE_MQH_DECLARATION
#ifndef CBAR_TIME_SERIES_DE_MQH_IMPLEMENTATION
#define CBAR_TIME_SERIES_DE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CBarTimeSeriesDE::CBarTimeSeriesDE(CArrayObj* list_all_patterns, CArrayObj* list_all_swings, const string symbol) : m_symbol(symbol)
  {
   this.m_type = OBJECT_DE_TYPE_SERIES_SYMBOL;
   this.m_list_series.Clear();
   this.m_list_series.Sort();
   this.SetTerminalServerDate();
   this.m_new_tick.SetSymbol(this.m_symbol);
   this.m_new_tick.Refresh();
   this.m_list_all_patterns = list_all_patterns;
   this.m_list_all_swings = list_all_swings;
  }
 //+------------------------------------------------------------------+
 //| Compare CBarTimeSeriesDE objects by symbol                          |
 //+------------------------------------------------------------------+
 int CBarTimeSeriesDE::Compare(const CObject* node, const int mode = 0) const
  {
   const CBarTimeSeriesDE* compared_obj = node;
   return (this.Symbol() > compared_obj.Symbol() ? 1 : this.Symbol() < compared_obj.Symbol() ? -1
                                                                                             : 0);
  }
 //Modify GetSeries method
 CBarSeriesDE* CBarTimeSeriesDE::GetSeries(const ENUM_TIMEFRAMES timeframe)
  {
      ENUM_TIMEFRAMES tf = (timeframe == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)::Period() : timeframe);
      for(int i = 0; i < this.m_list_series.Total(); i++)
      {
         CBarSeriesDE* s = (CBarSeriesDE*)this.m_list_series.At(i);
         if(s != NULL && s.Timeframe() == tf)
               return s;
      }
      return NULL;
  }
 //+------------------------------------------------------------------+
 //| Return the timeframe index in the list                           |
 //+------------------------------------------------------------------+
 int CBarTimeSeriesDE::IndexTimeframe(const ENUM_TIMEFRAMES timeframe)
  {
      CArrayObj* list = NULL;
      const CBarSeriesDE* obj = new CBarSeriesDE(list, list, this.m_symbol, (timeframe == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)::Period() : timeframe));
      if (obj == NULL)
         return WRONG_VALUE;
      this.m_list_series.Sort();
         //Debug:         
            ::Print("My Debug CBarTimeSeriesDE::IndexTimeframe [IndexTimeframe] TF=", EnumToString(timeframe), 
                  " Total=", m_list_series.Total(),
                  " IsSorted=", m_list_series.IsSorted(0),
                  " obj.TF=", EnumToString(obj.Timeframe()));
            for(int _di=0; _di<m_list_series.Total(); _di++) 
               {
                  CBarSeriesDE* _ds = (CBarSeriesDE*)m_list_series.At(_di);
                  if(_ds!=NULL) ::Print("My Debug CBarTimeSeriesDE::IndexTimeframe  [",_di,"] TF=", EnumToString(_ds.Timeframe()));
               }


      int index = this.m_list_series.Search(obj);
      // Search may return insertion point (lo=0), not WRONG_VALUE, when not found
      // Must verify the found element actually has the requested TF
         if(index < 0) return WRONG_VALUE;
         CBarSeriesDE* found = this.m_list_series.At(index);
         if(found == NULL || found.Timeframe() != timeframe) return WRONG_VALUE;
      return index;
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
 //+------------------------------------------------------------------+
 //| Set the history depth of all applied symbol timeseries           |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::SetRequiredAllUsedData(const uint required = 0, const int rates_total = 0)
  {
   if (this.m_symbol == NULL)
   {
      ::Print(DFUN, CMessage::Text(MSG_LIB_TEXT_TS_TEXT_FIRST_SET_SYMBOL));
      return false;
   }
   bool res = true;
   int total = this.m_list_series.Total();
   for (int i = 0; i < total; i++)
   {
      CBarSeriesDE* series_obj = this.m_list_series.At(i);
      if (series_obj == NULL)
         continue;
      res &= series_obj.SetRequiredUsedData(required, rates_total);
   }
   return res;
  }
 void CBarTimeSeriesDE::SetTerminalServerDate(void)
   {
      this.m_server_firstdate = (datetime)::SeriesInfoInteger(this.m_symbol, ::Period(), SERIES_SERVER_FIRSTDATE);
      this.m_terminal_firstdate = (datetime)::SeriesInfoInteger(this.m_symbol, ::Period(), SERIES_TERMINAL_FIRSTDATE);
   }
 //+------------------------------------------------------------------+
 //| Return the flag of data synchronization                          |
 //| with the server data                                             |
 //|Update user new vertion of GetSeries
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::SyncData(const ENUM_TIMEFRAMES timeframe, const int rates_total = 0, const uint required = 0)
   {
      if (this.m_symbol == NULL)
      {
         ::Print(DFUN, CMessage::Text(MSG_LIB_TEXT_TS_TEXT_FIRST_SET_SYMBOL));
         return false;
      }
      // CBarSeriesDE* series_obj = this.m_list_series.At(this.IndexTimeframe(timeframe));
      //Update user new vertion of GetSeries
      CBarSeriesDE* series_obj = this.GetSeries(timeframe);
      if (series_obj == NULL)
      {
         ::Print(DFUN, CMessage::Text(MSG_LIB_TEXT_TS_FAILED_GET_SERIES_OBJ), this.m_symbol, " ", TimeframeDescription(timeframe));
         return false;
      }
      return series_obj.SyncData(required, rates_total);
   }
 //+------------------------------------------------------------------+
 //| Return the flag of data synchronization                          |
 //| of all timeseries with the server data                           |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::SyncAllData(const int rates_total = 0, const uint required = 0)
   {
      if (this.m_symbol == NULL)
      {
         ::Print(DFUN, CMessage::Text(MSG_LIB_TEXT_TS_TEXT_FIRST_SET_SYMBOL));
         return false;
      }
      bool res = true;
      int total = this.m_list_series.Total();
      for (int i = 0; i < total; i++)
      {
         CBarSeriesDE* series_obj = this.m_list_series.At(i);
         if (series_obj == NULL || !series_obj.IsAvailable())
            continue;
         res &= series_obj.SyncData(required, rates_total);
      }
      return res;
   }
 //+------------------------------------------------------------------+
 //| Add the specified timeseries list to the list                    |
 //|Update user new vertion of GetSeries
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::AddSeries(const ENUM_TIMEFRAMES timeframe, const uint required = 0)
   {   
      bool res = false;
      CBarSeriesDE* series = new CBarSeriesDE(this.m_list_all_patterns, this.m_list_all_swings, this.m_symbol, timeframe, required);
      if (series == NULL)
         return res;
      this.m_list_series.Sort();
      //Original Version
         // if (this.m_list_series.Search(series) == WRONG_VALUE)
         //    {
         //       res = this.m_list_series.Add(series);
         //       //::Print("DEBUG: Search=WRONG_VALUE, Add=", res, " Total=", this.m_list_series.Total());
         //    }
         // else
         //    {
         //       //::Print("DEBUG: Search found existing, skip Add. Total=", this.m_list_series.Total());
         //    } 
      //if(this.IndexTimeframe(timeframe) == WRONG_VALUE)
      //Update user new vertion of GetSeries
      if(this.GetSeries(timeframe) == NULL)
       {
            res = m_list_series.Add(series);
            series.SetAvailable(true); //Set once time only
            if(!res) delete series;
       }
      else
       {
            delete series;   // bỏ dup, existing series stays
            res = true;      // đã có = không phải lỗi
       }        
      return res;
   }
 //+------------------------------------------------------------------+
 //| Create a specified timeseries list                               |
 //|Update user new vertion of GetSeries
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::CreateSeries(const ENUM_TIMEFRAMES timeframe, const uint required = 0)
   {
      //CBarSeriesDE* series_obj = this.m_list_series.At(this.IndexTimeframe(timeframe));
      //Update user new vertion of GetSeries
      CBarSeriesDE* series_obj = this.GetSeries(timeframe);
      if (series_obj == NULL)
      {
         ::Print(DFUN, CMessage::Text(MSG_LIB_TEXT_TS_FAILED_GET_SERIES_OBJ), this.m_symbol, " ", TimeframeDescription(timeframe));
         return false;
      }
      if (series_obj.RequiredUsedData() == 0)
      {
         ::Print(DFUN, CMessage::Text(MSG_LIB_TEXT_BAR_TEXT_FIRS_SET_AMOUNT_DATA));
         return false;
      }
      return (series_obj.Create(required) > 0);
   }
 //+------------------------------------------------------------------+
 //| Update a specified timeseries list                               |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesDE::Refresh(const ENUM_TIMEFRAMES timeframe, SDataCalculate& data_calculate)
   {
      //--- Reset the timeseries event flag and clear the list of all timeseries events
      this.m_is_event = false;
      this.m_list_events.Clear();
      //--- Get the timeseries from the list by its timeframe
      CBarSeriesDE* series_obj = this.m_list_series.At(this.IndexTimeframe(timeframe));
      if (series_obj == NULL || series_obj.DataTotal() == 0 || !series_obj.IsAvailable())
         return;
      //--- Update the timeseries list
      series_obj.Refresh(data_calculate);
      datetime time =
         (this.m_program == PROGRAM_INDICATOR && series_obj.Symbol() == ::Symbol() && series_obj.Timeframe() == (ENUM_TIMEFRAMES)::Period() ? data_calculate.rates.time : series_obj.LastBarDate());
      //--- If the timeseries object features the New bar event
      if (series_obj.IsNewBar(time))
      {
         //--- send the "New bar" event to the control program chart
         series_obj.SendEvent(SERIES_EVENTS_NEW_BAR);
         //--- set the values of the first date in history on the server and in the terminal
         this.SetTerminalServerDate();
         //--- add the "New bar" event to the list of timeseries events
         //--- in case of successful addition, set the event flag for the timeseries
         if (this.EventAdd(SERIES_EVENTS_NEW_BAR, time, series_obj.Timeframe(), series_obj.Symbol()))
            this.m_is_event = true;

         //--- Check skipped bars
         int missing = series_obj.GetNewBarObj().BarsBetweenNewBars();
         if (missing > 1)
         {
            //--- send the "Bars skipped" event to the control program chart
            series_obj.SendEvent(SERIES_EVENTS_MISSING_BARS);
            //--- add the "Bars skipped" event to the list of timeseries events
            this.EventAdd(SERIES_EVENTS_MISSING_BARS, missing, series_obj.Timeframe(), series_obj.Symbol());
         }
      }
   }
 //+------------------------------------------------------------------+
 //| Update all timeseries lists                                      |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesDE::RefreshAll(SDataCalculate& data_calculate)
   {
      //--- Reset the flags indicating the necessity to set the first date in history on the server and in the terminal
      //--- and the timeseries event flag, and clear the list of all timeseries events
      bool upd = false;
      this.m_is_event = false;
      this.m_list_events.Clear();
      //--- In the loop by the list of all used timeseries,
      int total = this.m_list_series.Total();
      for (int i = 0; i < total; i++)
      {
         //--- get the next timeseries object by the loop index
         CBarSeriesDE* series_obj = this.m_list_series.At(i);
         if (series_obj == NULL || !series_obj.IsAvailable() || series_obj.DataTotal() == 0)
            continue;
         //--- update the timeseries list
         series_obj.Refresh(data_calculate);
         datetime time =
            (this.m_program == PROGRAM_INDICATOR && series_obj.Symbol() == ::Symbol() && series_obj.Timeframe() == (ENUM_TIMEFRAMES)::Period() ? data_calculate.rates.time : series_obj.LastBarDate());
         //--- If the timeseries object features the New bar event
         if (series_obj.IsNewBar(time))
         {
            //--- send the "New bar" event to the control program chart,
            series_obj.SendEvent(SERIES_EVENTS_NEW_BAR);
            //--- set the flag indicating the necessity to set the first date in history on the server and in the terminal
            upd = true;
            //--- add the "New bar" event to the list of timeseries events
            //--- in case of successful addition, set the event flag for the timeseries
            if (this.EventAdd(SERIES_EVENTS_NEW_BAR, time, series_obj.Timeframe(), series_obj.Symbol()))
               this.m_is_event = true;

            //--- Check skipped bars
            int missing = series_obj.GetNewBarObj().BarsBetweenNewBars();
            if (missing > 1)
            {
               //--- send the "Bars skipped" event to the control program chart
               series_obj.SendEvent(SERIES_EVENTS_MISSING_BARS);
               //--- add the "Bars skipped" event to the list of timeseries events
               this.EventAdd(SERIES_EVENTS_MISSING_BARS, missing, series_obj.Timeframe(), series_obj.Symbol());
            }
         }
      }
      //--- if the flag indicating the necessity to set the first date in history on the server and in the terminal is enabled,
      //--- set the values of the first date in history on the server and in the terminal
      if (upd)
         this.SetTerminalServerDate();
   }
 //+------------------------------------------------------------------+
 //| Copy the specified double property of the specified timeseries   |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::CopyToBufferAsSeries(const ENUM_TIMEFRAMES timeframe,
                                          const ENUM_BAR_PROP_DOUBLE property,
                                          double& array[],
                                          const double empty = EMPTY_VALUE)
  {
      CBarSeriesDE* series = this.GetSeries(timeframe);
      if (series == NULL)
         return false;
      return series.CopyToBufferAsSeries(property, array, empty);
  }
 //+------------------------------------------------------------------+
 //| Display descriptions of all symbol timeseries in the journal     |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesDE::Print(const bool full_prop = false, const bool created = false)
   {
      ::Print(CMessage::Text(MSG_LIB_TEXT_TS_TEXT_SYMBOL_TIMESERIES), " ", this.m_symbol, ": ");
      for (int i = 0; i < this.m_list_series.Total(); i++)
      {
         CBarSeriesDE* series = this.m_list_series.At(i);
         if (series == NULL || (created && series.DataTotal() == 0))
            continue;
         series.Print();
      }
   }
 //+--------------------------------------------------------------------+
 //| Display short descriptions of all symbol timeseries in the journal |
 //+--------------------------------------------------------------------+
 void CBarTimeSeriesDE::PrintShort(const bool dash = false, const bool created = false)
   {
      ::Print(CMessage::Text(MSG_LIB_TEXT_TS_TEXT_SYMBOL_TIMESERIES), " ", this.m_symbol, ": ");
      for (int i = 0; i < this.m_list_series.Total(); i++)
      {
         CBarSeriesDE* series = this.m_list_series.At(i);
         if (series == NULL || (created && series.DataTotal() == 0))
            continue;
         series.PrintShort();
      }
   }
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| Handling timeseries patterns                                     |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| Set the flag of using the specified pattern                      |
 //| and create a control object if it does not exist yet             |
 //+------------------------------------------------------------------+
 void CBarTimeSeriesDE::SetUsedPattern(const ENUM_PATTERN_TYPE pattern, MqlParam& param[], const ENUM_TIMEFRAMES timeframe, const bool flag)
   {
      CBarSeriesDE* series = this.GetSeries(timeframe);
      if (series != NULL)
         series.SetUsedPattern(pattern, param, flag);
   }
 //+------------------------------------------------------------------+
 //| Return the flag of using the specified pattern                   |
 //+------------------------------------------------------------------+
 bool CBarTimeSeriesDE::IsUsedPattern(const ENUM_PATTERN_TYPE pattern, MqlParam& param[], const ENUM_TIMEFRAMES timeframe)
   {
      CBarSeriesDE* series = this.GetSeries(timeframe);
      return (series != NULL ? series.IsUsedPattern(pattern, param) : false);
   }
 //+------------------------------------------------------------------+
 //| Draw marks of the specified pattern on the chart                 |
 //+------------------------------------------------------------------+
//  void CBarTimeSeriesDE::DrawPattern(const ENUM_PATTERN_TYPE pattern, MqlParam& param[], const ENUM_TIMEFRAMES timeframe, const bool redraw = false)
//    {
//       CBarSeriesDE* series = this.GetSeries(timeframe);
//       if (series != NULL)
//          series.DrawPattern(pattern, param, redraw);
//    }
//  //+------------------------------------------------------------------+
//  //| Redraw the bitmap objects of the specified pattern on the chart  |
//  //+------------------------------------------------------------------+
//  void CBarTimeSeriesDE::RedrawPattern(const ENUM_PATTERN_TYPE pattern, MqlParam& param[], const ENUM_TIMEFRAMES timeframe, const bool redraw = false)
//    {
//       CBarSeriesDE* series = this.GetSeries(timeframe);
//       if (series != NULL)
//          series.RedrawPattern(pattern, param, redraw);
//    }
 //+------------------------------------------------------------------+
 //| Set chart parameters for pattern management objects              |
 //| on the specified timeframe                                       |
 //+------------------------------------------------------------------+
//  void CBarTimeSeriesDE::SetChartPropertiesToPattCtrl(const ENUM_TIMEFRAMES timeframe, const double price_max, const double price_min, const int scale, const int height_px, const int width_px)
//    {
//       CBarSeriesDE* series = this.GetSeries(timeframe);
//       if (series != NULL)
//          series.SetChartPropertiesToPattCtrl(price_max, price_min, scale, height_px, width_px);
//    }
#endif  // CBAR_TIME_SERIES_DE_MQH_IMPLEMENTATION
#endif  // CTIMESERIESDE_MQH
