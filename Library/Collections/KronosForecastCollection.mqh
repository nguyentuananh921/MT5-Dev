//+------------------------------------------------------------------+
//|                                     KronosForecastCollection.mqh |
//+------------------------------------------------------------------+
#ifndef __KRONOSFORECASTCOLLECTION_MQH__
#define __KRONOSFORECASTCOLLECTION_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Entities\Bases\BaseObj.mqh"
 #include "..\Entities\Graph\Composite\KronosForecastBar.mqh"
 #include "..\Entities\Defines\EventDefines.mqh"
 #define KRONOS_FORECAST_NAME       "KronosForecast_"
#ifndef CKRONOSFORECASTCOLLECTION_MQH_DECLARATION
#define CKRONOSFORECASTCOLLECTION_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The forecast of Kronos for the pair of the chart: CPythonBridge   |
 //| gives it the lines of that pair (the socket, V3), a bar of the    |
 //| list for each, drawn after the newest bar. RAM only: a forecast   |
 //| changes at every new bar, it is not kept in the database         |
 //+------------------------------------------------------------------+
 class CKronosForecastCollection : public CBaseObj
  {
   private:
    CArrayObj                  m_list_KronosForecast;   // CKronosForecastBar, the first bar foretold first
    long                       m_from_time;             // the closed bar the forecast starts after (forecast|...|<from_time>|...)
    int                        m_received;              // the bars of that forecast given so far
    ulong                      m_made;                  // the bars made so far: each gets a name of its own (the first bars go at a new bar, the others stay)
   public:
                               CKronosForecastCollection(void) : m_from_time(0),m_received(0),m_made(0) { }
   //--- A line forecast|... of the pair of the chart: the next bar of the list is set (a line of a newer forecast starts the list again)
    void                       AddBar(const long from_time,const datetime time,const double open,const double high,const double low,const double close);
   //--- forecast_end|...: the forecast is whole, a bar left over from a longer one goes, the chart is drawn
    void                       Apply(const long from_time);
   //--- The chart shows another pair, or the EA goes: the bars go
    void                       DeleteBars(void);
   //--- A new bar of the chart pair (SERIES_EVENTS_NEW_BAR): the bars foretold it has reached go, only the future is shown
    void                       OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
  };
#endif // CKRONOSFORECASTCOLLECTION_MQH_DECLARATION
#ifndef CKRONOSFORECASTCOLLECTION_MQH_IMPLEMENTATION
#define CKRONOSFORECASTCOLLECTION_MQH_IMPLEMENTATION
 void CKronosForecastCollection::AddBar(const long from_time,const datetime time,const double open,const double high,const double low,const double close)
  {
   if(from_time!=this.m_from_time)
     {
      this.m_from_time=from_time;
      this.m_received=0;
     }
   //--- V5: server.py sends the future only (forecast_lines); a bar passed later goes at SERIES_EVENTS_NEW_BAR
   CKronosForecastBar *bar=this.m_list_KronosForecast.At(this.m_received);
   if(bar==NULL)
     {
      bar=new CKronosForecastBar();
      if(!bar.Create(0,0,KRONOS_FORECAST_NAME+(string)(this.m_made++)) || !this.m_list_KronosForecast.Add(bar))
        {
         delete bar;
         ::Print(__FUNCTION__," > the bar ",this.m_received," of the forecast is not made");
         return;
        }
     }
   bar.SetBar(time,open,high,low,close,::PeriodSeconds());
   this.m_received++;
  }
 void CKronosForecastCollection::Apply(const long from_time)
  {
   if(from_time!=this.m_from_time)
      return;   // the end of a forecast whose lines were not all here
   while(this.m_list_KronosForecast.Total()>this.m_received)
      this.m_list_KronosForecast.Delete(this.m_list_KronosForecast.Total()-1);   // CArrayObj deletes the bar: its native objects go with it
   ::ChartSetInteger(0,CHART_SHIFT,true);   // room after the newest bar for the bars foretold
   ::ChartRedraw();
  }
 void CKronosForecastCollection::DeleteBars(void)
  {
   this.m_list_KronosForecast.Clear();   // the native objects go with each bar (CGStdBaseObj)
   this.m_from_time=0;
   this.m_received=0;
  }
 void CKronosForecastCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_CUSTOM+SERIES_EVENTS_NEW_BAR || sparam!=::Symbol() || (ENUM_TIMEFRAMES)(int)dparam!=::Period())
      return;
   const datetime forming=(datetime)lparam;   // CNewBarObj of the series: the open time of the new bar
   bool gone=false;
   while(this.m_list_KronosForecast.Total()>0)
     {
      CKronosForecastBar *bar=this.m_list_KronosForecast.At(0);
      if(bar==NULL || bar.Time()>forming)
         break;   // the first bar still in the future: the ones after it are too
      this.m_list_KronosForecast.Delete(0);   // its native objects go with it
      gone=true;
     }
   if(gone)
     {
      this.m_received=this.m_list_KronosForecast.Total();   // a line of the same forecast coming later sets the bar after the ones left
      ::ChartRedraw();
     }
  }
#endif // CKRONOSFORECASTCOLLECTION_MQH_IMPLEMENTATION
#endif // __KRONOSFORECASTCOLLECTION_MQH__
