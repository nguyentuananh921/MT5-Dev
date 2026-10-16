//+------------------------------------------------------------------+
//|                                          LifecycleCollection.mqh |
//| The lifecycle events Python reports for Trendline / Zone /       |
//| Protected Level. Holds the CLifecycleSeries records, drops the   |
//| ones it already has, and tells the EA about every new one with   |
//| EventChartCustom (ENUM_LIFECYCLE_EVENT). Python decides, this    |
//| class only keeps, folds and announces. Drawing is somebody else's|
//+------------------------------------------------------------------+
#ifndef __LIFECYCLECOLLECTION_MQH__
#define __LIFECYCLECOLLECTION_MQH__
 #include "ListObj.mqh"
 #include "..\Entities\Bases\BaseObj.mqh"
 #include "..\Entities\Defines\EventDefines.mqh"
 #include "..\Entities\Timeseries\SmartMoney\LifecycleSeries.mqh"
#ifndef CLIFECYCLECOLLECTION_MQH_DECLARATION
#define CLIFECYCLECOLLECTION_MQH_DECLARATION
 class CLifecycleCollection : public CBaseObj
  {
   private:
     CListObj           m_list;                       // CLifecycleSeries, sorted by CODE: Search finds a record already held
     void               SendEvent(CLifecycleSeries *record) const;
   //--- true when 'record' is a later step of the same object than 'than': later time, or the later event on the same time
     bool               IsNewer(const CLifecycleSeries *record,const CLifecycleSeries *than) const;
   public:
   //--- Take a record. true = the collection owns it now. false = it was already held (or NULL) and it has been deleted
   //--- send_event = false for the first burst after (re)connecting: those are history, not news
     bool               Add(CLifecycleSeries *record,const bool send_event=true);
   //--- Return (1) itself, (2) the list, (3) the number of records
     CLifecycleCollection *GetObject(void)            { return &this;           }
     CArrayObj         *GetList(void)                 { return &this.m_list;    }
     int                Total(void)             const { return this.m_list.Total(); }
   //--- The newest event of an object (kind + symbol + timeframe + direction + birth time), NULL if there is none
     CLifecycleSeries  *Last(const ENUM_LIFECYCLE_OBJECT_KIND kind,const string symbol,const ENUM_TIMEFRAMES timeframe,
                             const ENUM_SIGNAL_DIR direction,const datetime origin_time) const;
   //--- The newest event of the object that ObjectKey() names, NULL if there is none
     CLifecycleSeries  *LastByKey(const string key) const;
   //--- The newest event of EVERY object of one kind, into 'out' (it only points at the records, it does not own them)
     int                Current(CArrayObj &out,const ENUM_LIFECYCLE_OBJECT_KIND kind) const;
   //--- How many times an object had this event (TOUCHED, BOUNCED, ...)
     int                CountEvents(const ENUM_LIFECYCLE_OBJECT_KIND kind,const string symbol,const ENUM_TIMEFRAMES timeframe,
                                    const ENUM_SIGNAL_DIR direction,const datetime origin_time,const ENUM_LIFECYCLE_EVENT event) const;
   //--- Remove every record
     void               Clear(void)                   { this.m_list.Clear();    }
     virtual void       Print(const bool full_prop=false,const bool dash=false);
                        CLifecycleCollection(void);
  };
#endif // CLIFECYCLECOLLECTION_MQH_DECLARATION
#ifndef CLIFECYCLECOLLECTION_MQH_IMPLEMENTATION
#define CLIFECYCLECOLLECTION_MQH_IMPLEMENTATION
 CLifecycleCollection::CLifecycleCollection(void)
  {
   this.m_type=COLLECTION_LIFECYCLE_ID;
   this.m_list.Type(COLLECTION_LIFECYCLE_ID);
   this.m_list.Sort(SORT_BY_LIFECYCLE_CODE);
  }
 //+------------------------------------------------------------------+
 //| Tell the EA about a record: code = the event, lparam = the kind  |
 //| of object, dparam = the price of its second anchor, sparam =     |
 //| ObjectKey() (the full record is in the collection)               |
 //+------------------------------------------------------------------+
 void CLifecycleCollection::SendEvent(CLifecycleSeries *record) const
  {
   ::EventChartCustom(::ChartID(),(ushort)record.Event(),(long)record.Kind(),record.PriceB(),record.ObjectKey());
  }
 bool CLifecycleCollection::IsNewer(const CLifecycleSeries *record,const CLifecycleSeries *than) const
  {
   return(record.Time()>than.Time() || (record.Time()==than.Time() && record.Event()>than.Event()));
  }
 //+------------------------------------------------------------------+
 //| Add a record, drop it when the collection has it already         |
 //+------------------------------------------------------------------+
 bool CLifecycleCollection::Add(CLifecycleSeries *record,const bool send_event)
  {
   if(record==NULL)
      return false;
   this.m_list.Sort(SORT_BY_LIFECYCLE_CODE);
   if(this.m_list.Search(record)>=0 || !this.m_list.InsertSort(record))
     {
      delete record;
      return false;
     }
   if(send_event)
      this.SendEvent(record);
   return true;
  }
 //+------------------------------------------------------------------+
 //| The newest event of an object                                    |
 //+------------------------------------------------------------------+
 CLifecycleSeries *CLifecycleCollection::Last(const ENUM_LIFECYCLE_OBJECT_KIND kind,const string symbol,const ENUM_TIMEFRAMES timeframe,
                                              const ENUM_SIGNAL_DIR direction,const datetime origin_time) const
  {
   CLifecycleSeries *last=NULL;
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CLifecycleSeries *record=this.m_list.At(i);
      if(record==NULL || record.Kind()!=kind || record.Timeframe()!=timeframe || record.Direction()!=direction ||
         record.OriginTime()!=origin_time || record.Symbol()!=symbol)
         continue;
      if(last==NULL || this.IsNewer(record,last))
         last=record;
     }
   return last;
  }
 //+------------------------------------------------------------------+
 //| The newest event of the object that a key names                  |
 //+------------------------------------------------------------------+
 CLifecycleSeries *CLifecycleCollection::LastByKey(const string key) const
  {
   CLifecycleSeries *last=NULL;
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CLifecycleSeries *record=this.m_list.At(i);
      if(record==NULL || record.ObjectKey()!=key)
         continue;
      if(last==NULL || this.IsNewer(record,last))
         last=record;
     }
   return last;
  }
 //+------------------------------------------------------------------+
 //| The newest event of every object of a kind                       |
 //+------------------------------------------------------------------+
 int CLifecycleCollection::Current(CArrayObj &out,const ENUM_LIFECYCLE_OBJECT_KIND kind) const
  {
   out.FreeMode(false);
   out.Clear();
   string keys[];   // keys[i] is the key of out[i]
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CLifecycleSeries *record=this.m_list.At(i);
      if(record==NULL || record.Kind()!=kind)
         continue;
      string key=record.ObjectKey();
      int at=WRONG_VALUE;
      for(int k=ArraySize(keys)-1;k>=0;k--)
         if(keys[k]==key)
           {
            at=k;
            break;
           }
      if(at==WRONG_VALUE)
        {
         ArrayResize(keys,ArraySize(keys)+1);
         keys[ArraySize(keys)-1]=key;
         out.Add(record);
        }
      else if(this.IsNewer(record,out.At(at)))
         out.Update(at,record);
     }
   return out.Total();
  }
 //+------------------------------------------------------------------+
 //| How many times an object had an event                            |
 //+------------------------------------------------------------------+
 int CLifecycleCollection::CountEvents(const ENUM_LIFECYCLE_OBJECT_KIND kind,const string symbol,const ENUM_TIMEFRAMES timeframe,
                                       const ENUM_SIGNAL_DIR direction,const datetime origin_time,const ENUM_LIFECYCLE_EVENT event) const
  {
   int count=0;
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CLifecycleSeries *record=this.m_list.At(i);
      if(record!=NULL && record.Event()==event && record.Kind()==kind && record.Timeframe()==timeframe &&
         record.Direction()==direction && record.OriginTime()==origin_time && record.Symbol()==symbol)
         count++;
     }
   return count;
  }
 void CLifecycleCollection::Print(const bool full_prop=false,const bool dash=false)
  {
   ::Print("CLifecycleCollection: ",this.m_list.Total()," lifecycle record(s)");
  }
#endif // CLIFECYCLECOLLECTION_MQH_IMPLEMENTATION
#endif // __LIFECYCLECOLLECTION_MQH__
