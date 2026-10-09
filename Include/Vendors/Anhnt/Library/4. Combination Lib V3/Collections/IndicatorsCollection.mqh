//+------------------------------------------------------------------+
//|                                          IndicatorsCollection.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//| V3: the list of the indicators Python calculates, one object per |
//| (type, symbol, TF, parameters). The typed Create / GetList / Get |
//| methods of V2 and the series are gone: one generic lookup        |
//+------------------------------------------------------------------+
#ifndef __INDICATORSCOLLECTION_MQH__
#define __INDICATORSCOLLECTION_MQH__
 #include "ListObj.mqh"
 #include "..\Entities\Timeseries\Indicators\IndicatorDE.mqh"

#ifndef CINDICATORSCOLLECTION_MQH_DECLARATION
#define CINDICATORSCOLLECTION_MQH_DECLARATION
 class CIndicatorsCollection : public CObject
  {
    private:
     CListObj           m_list;                       // List of indicator objects
     int                m_type;                       // Object type
     int                m_last_id;                    // Last ID given
    public:
   //--- Create an indicator object, add it to the list and give it an ID
     CIndicatorDE      *CreateIndicator(const ENUM_INDICATOR ind_type,MqlParam &mql_param[],const string symbol_name,const ENUM_TIMEFRAMES period);
   //--- Return (1) itself, (2) the indicator list
     CIndicatorsCollection *GetObject(void)           { return &this;           }
     CArrayObj         *GetList(void)                 { return &this.m_list;    }
   //--- Return the indicator by its (type, symbol, timeframe, parameters) identity / by ID, NULL if there is none
     CIndicatorDE      *GetIndicator(const ENUM_INDICATOR ind_type,MqlParam &mql_param[],const string symbol_name,const ENUM_TIMEFRAMES period);
     CIndicatorDE      *GetIndByID(const int id);
   //--- Remove every indicator
     void               Clear(void)                   { this.m_list.Clear();    }
     virtual int        Type(void)               const { return this.m_type;    }
     virtual void       Print(const bool full_prop=false,const bool dash=false);
                        CIndicatorsCollection(void);
  };
#endif // CINDICATORSCOLLECTION_MQH_DECLARATION

#ifndef CINDICATORSCOLLECTION_MQH_IMPLEMENTATION
#define CINDICATORSCOLLECTION_MQH_IMPLEMENTATION
 CIndicatorsCollection::CIndicatorsCollection(void) : m_last_id(0)
  {
   this.m_type=COLLECTION_INDICATORS_ID;
   this.m_list.Type(COLLECTION_INDICATORS_ID);
  }
 CIndicatorDE *CIndicatorsCollection::CreateIndicator(const ENUM_INDICATOR ind_type,MqlParam &mql_param[],const string symbol_name,const ENUM_TIMEFRAMES period)
  {
   CIndicatorDE *indicator=new CIndicatorDE(ind_type,symbol_name,period,mql_param);
   if(indicator==NULL)
      return NULL;
   indicator.SetID(++this.m_last_id);
   if(!this.m_list.Add(indicator))
     {
      delete indicator;
      return NULL;
     }
   return indicator;
  }
 CIndicatorDE *CIndicatorsCollection::GetIndicator(const ENUM_INDICATOR ind_type,MqlParam &mql_param[],const string symbol_name,const ENUM_TIMEFRAMES period)
  {
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL && indicator.IsEqual(ind_type,symbol_name,period,mql_param))
         return indicator;
     }
   return NULL;
  }
 CIndicatorDE *CIndicatorsCollection::GetIndByID(const int id)
  {
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL && indicator.ID()==id)
         return indicator;
     }
   return NULL;
  }
 void CIndicatorsCollection::Print(const bool full_prop=false,const bool dash=false)
  {
   ::Print("CIndicatorsCollection: ",this.m_list.Total()," indicator(s)");
   for(int i=0;i<this.m_list.Total();i++)
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL)
         indicator.Print(full_prop,true);
     }
  }
#endif // CINDICATORSCOLLECTION_MQH_IMPLEMENTATION
#endif // __INDICATORSCOLLECTION_MQH__
