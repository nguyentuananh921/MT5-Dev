//+------------------------------------------------------------------+
//|                                                  IndicatorDE.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//| Lib link            https://www.mql5.com/en/articles/14710       |
//| Update link          https://www.mql5.com/en/articles/8646       |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\IndicatorDE.mqh: the indicator of a template (Setting_IndicatorTemplate, INDICATOR_PROP_ID) on a pair (Setting_SymbolTF).
//--- INDICATOR_PROP_HANDLE is not a property: the handle is this object's own (m_handle, CopyBuffer and IndicatorRelease only), an indicator is told by its type
//--- + params (IsEqual, IsOf). The group and the name are the catalog's (IndicatorDELib.mqh), given by the classes Standard\Ind<Name>.mqh as in V1.
//--- The name of the timeframe is the table timeframes' (CIndicatorsCollection gives it, and the short name made of it: SetTimeframeDescription, SetShortName).
//--- PrintParameters / GetMqlParamDescription: once here by the schema of the type (IndicatorDELib.mqh, the names the Add form shows), not one for each class Ind<Name>.
//--- MqlParam compared by IsEqualMqlParamArrays of IndicatorDELib.mqh. No buffers to draw (MT5 draws: CChartObj). Its values in RAM: m_series_data
#ifndef __INDICATORDE_MQH__
#define __INDICATORDE_MQH__
 #include "..\Bases\BaseObj.mqh"
 #include "..\..\Services\DELib\IndicatorDELib.mqh"
 #include "IndicatorSeriesDE.mqh"
#ifndef CINDICATORDE_MQH_DECLARATION
#define CINDICATORDE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Abstract indicator class                                         |
 //+------------------------------------------------------------------+
 class CIndicatorDE : public CBaseObj
  {
   protected:
    MqlParam          m_mql_param[];                                              // Array of indicator parameters
    CIndicatorSeriesDE m_series_data;                                             // Timeseries object of indicator buffer data
   private:
    long              m_long_prop[INDICATOR_PROP_INTEGER_TOTAL];                  // Integer properties
    double            m_double_prop[INDICATOR_PROP_DOUBLE_TOTAL];                 // Real properties
    string            m_string_prop[INDICATOR_PROP_STRING_TOTAL];                 // String properties
    int               m_buffers_total;                                            // The buffers the signal of the type reads
    int               m_handle;                                                   // The handle: only this object releases it (one release is the end of it for every user)
    string            m_timeframe_description;                                    // The name of the timeframe (the table timeframes)
   //--- Return the index of the array the indicator's (1) double and (2) string properties are actually located at
    int               IndexProp(ENUM_INDICATOR_PROP_DOUBLE property)        const { return(int)property-INDICATOR_PROP_INTEGER_TOTAL;                            }
    int               IndexProp(ENUM_INDICATOR_PROP_STRING property)        const { return(int)property-INDICATOR_PROP_INTEGER_TOTAL-INDICATOR_PROP_DOUBLE_TOTAL;}
   protected:
   //--- Protected parametric constructor
                      CIndicatorDE(ENUM_INDICATOR ind_type,
                                   string symbol,
                                   ENUM_TIMEFRAMES timeframe,
                                   ENUM_INDICATOR_STATUS status,
                                   ENUM_INDICATOR_GROUP group,
                                   string name,
                                   string shortname,
                                   MqlParam &mql_params[]);
   public:
   //--- Default constructor
                      CIndicatorDE(void) : m_buffers_total(0),m_handle(INVALID_HANDLE) { this.m_type=OBJECT_DE_TYPE_INDICATOR; }
   //--- Destructor
                     ~CIndicatorDE(void);
   //--- Set indicator's (1) integer, (2) real and (3) string property
    void              SetProperty(ENUM_INDICATOR_PROP_INTEGER property,long value)   { this.m_long_prop[property]=value;                                        }
    void              SetProperty(ENUM_INDICATOR_PROP_DOUBLE property,double value)  { this.m_double_prop[this.IndexProp(property)]=value;                      }
    void              SetProperty(ENUM_INDICATOR_PROP_STRING property,string value)  { this.m_string_prop[this.IndexProp(property)]=value;                      }
   //--- Return indicator's (1) integer, (2) real and (3) string property from the properties array
    long              GetProperty(ENUM_INDICATOR_PROP_INTEGER property)        const { return this.m_long_prop[property];                                       }
    double            GetProperty(ENUM_INDICATOR_PROP_DOUBLE property)         const { return this.m_double_prop[this.IndexProp(property)];                     }
    string            GetProperty(ENUM_INDICATOR_PROP_STRING property)         const { return this.m_string_prop[this.IndexProp(property)];                     }
   //--- Return description of indicator's (1) integer, (2) real and (3) string property
    string            GetPropertyDescription(ENUM_INDICATOR_PROP_INTEGER property);
    string            GetPropertyDescription(ENUM_INDICATOR_PROP_DOUBLE property);
    string            GetPropertyDescription(ENUM_INDICATOR_PROP_STRING property);
   //--- Return the flag of the indicator supporting the property
    virtual bool      SupportProperty(ENUM_INDICATOR_PROP_INTEGER property)          { return true;       }
    virtual bool      SupportProperty(ENUM_INDICATOR_PROP_DOUBLE property)           { return true;       }
    virtual bool      SupportProperty(ENUM_INDICATOR_PROP_STRING property)           { return true;       }
   //--- Compare CIndicatorDE objects by all possible properties (for sorting the lists by a specified indicator object property)
    virtual int       Compare(const CObject *node,const int mode=0) const;
   //--- Compare CIndicatorDE objects by all properties but the ID (to search equal indicator objects)
    bool              IsEqual(CIndicatorDE* compared_obj) const;
   //--- Is it the indicator of the type with the parameters on the pair (V4: an indicator is not made to be looked for, its handle would be a new one)
    bool              IsOf(const ENUM_INDICATOR type,const MqlParam &mql_params[],const string symbol,const ENUM_TIMEFRAMES timeframe) const;
   //--- Set indicator's (1) group, (2) empty value of buffers, (3) name, (4) short name, (5) ID
    void              SetGroup(const ENUM_INDICATOR_GROUP group)      { this.SetProperty(INDICATOR_PROP_GROUP,group);                         }
    void              SetEmptyValue(const double value)               { this.SetProperty(INDICATOR_PROP_EMPTY_VALUE,value);                   }
    void              SetName(const string name)                      { this.SetProperty(INDICATOR_PROP_NAME,name);                           }
    void              SetShortName(const string shortname)            { this.SetProperty(INDICATOR_PROP_SHORTNAME,shortname);                 }
    void              SetID(const long id)                            { this.SetProperty(INDICATOR_PROP_ID,id); this.m_series_data.SetIndID(id); }
    void              SetBuffersTotal(const int buffers_total)        { this.m_buffers_total=buffers_total;                                   }
    void              SetTimeframeDescription(const string text)      { this.m_timeframe_description=text; this.m_series_data.SetPeriodDescription(text); }
   //--- Return indicator's (1) status, (2) group, (3) timeframe, (4) type, (5) handle, (6) ID,
   //--- (7) empty value of buffers, (8) name, (9) short name, (10) symbol, (11) number of buffers
    ENUM_INDICATOR_STATUS Status(void)                          const { return (ENUM_INDICATOR_STATUS)this.GetProperty(INDICATOR_PROP_STATUS);}
    ENUM_INDICATOR_GROUP  Group(void)                           const { return (ENUM_INDICATOR_GROUP)this.GetProperty(INDICATOR_PROP_GROUP);  }
    ENUM_TIMEFRAMES   Timeframe(void)                           const { return (ENUM_TIMEFRAMES)this.GetProperty(INDICATOR_PROP_TIMEFRAME);   }
    ENUM_INDICATOR    TypeIndicator(void)                       const { return (ENUM_INDICATOR)this.GetProperty(INDICATOR_PROP_TYPE);         }
    void              GetMqlParams(MqlParam &out_params[])      const;
    int               Handle(void)                              const { return this.m_handle;                                                 }
    long              ID(void)                                  const { return this.GetProperty(INDICATOR_PROP_ID);                           }
    double            EmptyValue(void)                          const { return this.GetProperty(INDICATOR_PROP_EMPTY_VALUE);                  }
    string            Name(void)                                const { return this.GetProperty(INDICATOR_PROP_NAME);                         }
    string            ShortName(void)                           const { return this.GetProperty(INDICATOR_PROP_SHORTNAME);                    }
    string            Symbol(void)                              const { return this.GetProperty(INDICATOR_PROP_SYMBOL);                       }
    int               BuffersTotal(void)                        const { return this.m_buffers_total;                                          }
   //--- Return description of (1) type, (2) status, (3) group, (4) timeframe, (5) empty value of indicator
    string            GetTypeDescription(void)                  const { return ::EnumToString(this.TypeIndicator());                          }
    string            GetStatusDescription(void)                const;
    string            GetGroupDescription(void)                 const;
    string            GetTimeframeDescription(void)             const { return this.m_timeframe_description;                                  }
    string            GetEmptyValueDescription(void)            const;
   //--- Return the description of the parameter of m_mql_param by its index: its name and its value
    string            GetMqlParamDescription(const int index)   const;
   //--- Return indicator data timeseries
    CIndicatorSeriesDE *GetSeriesData(void)                           { return &this.m_series_data;  }
   //--- Display the description of indicator object properties in the journal (full_prop=true - all properties, false - supported ones only)
    virtual void      Print(const bool full_prop=false,const bool dash=false);
   //--- Display (1) a short description, (2) description of indicator object parameters in the journal
    virtual void      PrintShort(const bool dash=false,const bool symbol=false);
    virtual void      PrintParameters(void);
  };
#endif // CINDICATORDE_MQH_DECLARATION
#ifndef CINDICATORDE_MQH_IMPLEMENTATION
#define CINDICATORDE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CIndicatorDE::~CIndicatorDE(void)
  {
   if(this.m_handle!=INVALID_HANDLE)
      ::IndicatorRelease(this.m_handle);
  }
 //+------------------------------------------------------------------+
 //| Closed parametric constructor. Volumes: the handle takes the kind |
 //| of volume only (its period and method are the ones of its moving |
 //| average, CIndVolumes)                                            |
 //+------------------------------------------------------------------+
 CIndicatorDE::CIndicatorDE(ENUM_INDICATOR ind_type,
                            string symbol,
                            ENUM_TIMEFRAMES timeframe,
                            ENUM_INDICATOR_STATUS status,
                            ENUM_INDICATOR_GROUP group,
                            string name,
                            string shortname,
                            MqlParam &mql_params[])
  {
   //--- Set the object type
    this.m_type=OBJECT_DE_TYPE_INDICATOR;
   //--- Fill in the array of object parameters with data from the array passed to constructor
    int count=::ArrayResize(this.m_mql_param,::ArraySize(mql_params));
    for(int i=0;i<count;i++)
       this.m_mql_param[i]=mql_params[i];
   //--- Create indicator handle
    this.m_handle=::IndicatorCreate(symbol,timeframe,ind_type,(ind_type==IND_VOLUMES ? (int)::fmin(count,1) : count),this.m_mql_param);
    if(this.m_handle==INVALID_HANDLE)
       ::Print(__FUNCTION__," > IndicatorCreate failed for ",name," ",symbol," ",::EnumToString(timeframe),", error ",::GetLastError());
   //--- Save integer properties
    this.m_long_prop[INDICATOR_PROP_STATUS]                     = status;
    this.m_long_prop[INDICATOR_PROP_TYPE]                       = ind_type;
    this.m_long_prop[INDICATOR_PROP_GROUP]                      = group;
    this.m_long_prop[INDICATOR_PROP_TIMEFRAME]                  = timeframe;
    this.m_long_prop[INDICATOR_PROP_ID]                         = WRONG_VALUE;
   //--- Save real properties
    this.m_double_prop[this.IndexProp(INDICATOR_PROP_EMPTY_VALUE)]=EMPTY_VALUE;
   //--- Save string properties
    this.m_string_prop[this.IndexProp(INDICATOR_PROP_SYMBOL)]   = (symbol==NULL || symbol=="" ? ::Symbol() : symbol);
    this.m_string_prop[this.IndexProp(INDICATOR_PROP_NAME)]     = name;
    this.m_string_prop[this.IndexProp(INDICATOR_PROP_SHORTNAME)]= shortname;
   //--- V4: the buffers the signal reads and the values in RAM
    this.m_buffers_total=GetIndicatorBuffersForType(ind_type);
    this.m_series_data.SetIndicator(this.Symbol(),timeframe,ind_type,this.m_handle,INVALID_HANDLE,this.m_buffers_total);
  }
 //+------------------------------------------------------------------+
 //| Compare CIndicatorDE objects with each other                     |
 //| by all possible properties                                       |
 //+------------------------------------------------------------------+
 int CIndicatorDE::Compare(const CObject *node,const int mode=0) const
  {
   const CIndicatorDE *compared_obj=node;
   //--- compare integer properties of two indicators
    if(mode<INDICATOR_PROP_INTEGER_TOTAL)
     {
      long value_compared=compared_obj.GetProperty((ENUM_INDICATOR_PROP_INTEGER)mode);
      long value_current=this.GetProperty((ENUM_INDICATOR_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   //--- compare real properties of two indicators
    else if(mode<INDICATOR_PROP_INTEGER_TOTAL+INDICATOR_PROP_DOUBLE_TOTAL)
     {
      double value_compared=compared_obj.GetProperty((ENUM_INDICATOR_PROP_DOUBLE)mode);
      double value_current=this.GetProperty((ENUM_INDICATOR_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   //--- compare string properties of two indicators
    else if(mode<INDICATOR_PROP_INTEGER_TOTAL+INDICATOR_PROP_DOUBLE_TOTAL+INDICATOR_PROP_STRING_TOTAL)
     {
      string value_compared=compared_obj.GetProperty((ENUM_INDICATOR_PROP_STRING)mode);
      string value_current=this.GetProperty((ENUM_INDICATOR_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   return 0;
  }
 //+------------------------------------------------------------------+
 //| Compare CIndicatorDE objects with each other by all properties   |
 //+------------------------------------------------------------------+
 bool CIndicatorDE::IsEqual(CIndicatorDE *compared_obj) const
  {
   if(!IsEqualMqlParamArrays(this.m_mql_param,compared_obj.m_mql_param))
      return false;
   int begin=0, end=INDICATOR_PROP_INTEGER_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_INDICATOR_PROP_INTEGER prop=(ENUM_INDICATOR_PROP_INTEGER)i;
      if(prop==INDICATOR_PROP_ID) continue;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
     }
   begin=end; end+=INDICATOR_PROP_DOUBLE_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_INDICATOR_PROP_DOUBLE prop=(ENUM_INDICATOR_PROP_DOUBLE)i;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
     }
   begin=end; end+=INDICATOR_PROP_STRING_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_INDICATOR_PROP_STRING prop=(ENUM_INDICATOR_PROP_STRING)i;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| The type, the parameters and the pair (what IsEqual compares that |
 //| a template says)                                                 |
 //+------------------------------------------------------------------+
 bool CIndicatorDE::IsOf(const ENUM_INDICATOR type,const MqlParam &mql_params[],const string symbol,const ENUM_TIMEFRAMES timeframe) const
  {
   return (this.TypeIndicator()==type && this.Symbol()==symbol && this.Timeframe()==timeframe && IsEqualMqlParamArrays(this.m_mql_param,mql_params));
  }
 //+------------------------------------------------------------------+
 //| Return description of indicator's integer property               |
 //+------------------------------------------------------------------+
 string CIndicatorDE::GetPropertyDescription(ENUM_INDICATOR_PROP_INTEGER property)
  {
   return
     (
      property==INDICATOR_PROP_STATUS     ?  CMessage::Text(MSG_LIB_TEXT_IND_TEXT_STATUS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetStatusDescription()
         )  :
      property==INDICATOR_PROP_TYPE       ?  CMessage::Text(MSG_LIB_TEXT_IND_TEXT_TYPE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetTypeDescription()
         )  :
      property==INDICATOR_PROP_GROUP      ?  CMessage::Text(MSG_LIB_TEXT_IND_TEXT_GROUP)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetGroupDescription()
         )  :
      property==INDICATOR_PROP_ID         ?  CMessage::Text(MSG_LIB_TEXT_IND_TEXT_ID)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==INDICATOR_PROP_TIMEFRAME  ?  CMessage::Text(MSG_LIB_TEXT_IND_TEXT_TIMEFRAME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetTimeframeDescription()
         )  :
      ""
     );
  }
 //+------------------------------------------------------------------+
 //| Return description of indicator's real property                  |
 //+------------------------------------------------------------------+
 string CIndicatorDE::GetPropertyDescription(ENUM_INDICATOR_PROP_DOUBLE property)
  {
   return
     (
      property==INDICATOR_PROP_EMPTY_VALUE    ?  CMessage::Text(MSG_LIB_TEXT_IND_TEXT_EMPTY_VALUE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetEmptyValueDescription()
         )  :
      ""
     );
  }
 //+------------------------------------------------------------------+
 //| Return description of indicator's string property                |
 //+------------------------------------------------------------------+
 string CIndicatorDE::GetPropertyDescription(ENUM_INDICATOR_PROP_STRING property)
  {
   return
     (
      property==INDICATOR_PROP_SYMBOL     ?  CMessage::Text(MSG_LIB_TEXT_IND_TEXT_SYMBOL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.Symbol()
         )  :
      property==INDICATOR_PROP_NAME       ?  CMessage::Text(MSG_LIB_TEXT_IND_TEXT_NAME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.Name()==NULL || this.Name()=="" ? CMessage::Text(MSG_LIB_PROP_NOT_SET) : "\""+this.Name()+"\"")
         )  :
      property==INDICATOR_PROP_SHORTNAME  ?  CMessage::Text(MSG_LIB_TEXT_IND_TEXT_SHORTNAME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.ShortName()==NULL || this.ShortName()=="" ? CMessage::Text(MSG_LIB_PROP_NOT_SET) : "\""+this.ShortName()+"\"")
         )  :
      ""
     );
  }
 //+------------------------------------------------------------------+
 //| Return indicator status description                              |
 //+------------------------------------------------------------------+
 string CIndicatorDE::GetStatusDescription(void) const
  {
   return
     (
      this.Status()==INDICATOR_STATUS_CUSTOM    ? CMessage::Text(MSG_LIB_TEXT_IND_TEXT_STATUS_CUSTOM)    :
      this.Status()==INDICATOR_STATUS_STANDARD  ? CMessage::Text(MSG_LIB_TEXT_IND_TEXT_STATUS_STANDARD)  :
      "Unknown"
     );
  }
 //+------------------------------------------------------------------+
 //| Return indicator group description                               |
 //+------------------------------------------------------------------+
 string CIndicatorDE::GetGroupDescription(void) const
  {
   return
     (
      this.Group()==INDICATOR_GROUP_TREND       ? CMessage::Text(MSG_LIB_TEXT_IND_TEXT_GROUP_TREND)      :
      this.Group()==INDICATOR_GROUP_OSCILLATOR  ? CMessage::Text(MSG_LIB_TEXT_IND_TEXT_GROUP_OSCILLATOR) :
      this.Group()==INDICATOR_GROUP_VOLUMES     ? CMessage::Text(MSG_LIB_TEXT_IND_TEXT_GROUP_VOLUMES)    :
      this.Group()==INDICATOR_GROUP_ARROWS      ? CMessage::Text(MSG_LIB_TEXT_IND_TEXT_GROUP_ARROWS)     :
      "Any"
     );
  }
 //+------------------------------------------------------------------+
 //| Return description of the set empty value                        |
 //+------------------------------------------------------------------+
 string CIndicatorDE::GetEmptyValueDescription(void) const
  {
   double value=::fabs(this.EmptyValue());
   return(value<EMPTY_VALUE ? ::DoubleToString(this.EmptyValue(),(this.EmptyValue()==0 ? 1 : 8)) : (this.EmptyValue()>0 ? "EMPTY_VALUE" : "-EMPTY_VALUE"));
  }
 //+------------------------------------------------------------------+
 //| Return the description of parameter of m_mql_param array         |
 //+------------------------------------------------------------------+
 string CIndicatorDE::GetMqlParamDescription(const int index) const
  {
   SIndicatorParam schema[];
   GetIndicatorParamSchema(this.TypeIndicator(),schema);
   string name=(index<::ArraySize(schema) && schema[index].name!="" ? schema[index].name : "["+(string)index+"]");
   string choices=(index<::ArraySize(schema) ? schema[index].choices : "");
   return name+": "+MqlParameterDescription(this.m_mql_param[index],choices,2);
  }
 //+------------------------------------------------------------------+
 //| Display parameter description of indicator object in the journal |
 //+------------------------------------------------------------------+
 void CIndicatorDE::PrintParameters(void)
  {
   ::Print(" --- ",CMessage::Text(MSG_LIB_TEXT_IND_TEXT_IND_PARAMETERS)," --- ");
   for(int i=0;i<::ArraySize(this.m_mql_param);i++)
      ::Print(" - ",this.GetMqlParamDescription(i));
  }
 //+------------------------------------------------------------------+
 //| Display indicator properties in the journal                      |
 //+------------------------------------------------------------------+
 void CIndicatorDE::Print(const bool full_prop=false,const bool dash=false)
  {
   ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_BEG),": \"",this.GetStatusDescription(),"\" =============");
   int begin=0, end=INDICATOR_PROP_INTEGER_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_INDICATOR_PROP_INTEGER prop=(ENUM_INDICATOR_PROP_INTEGER)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   begin=end; end+=INDICATOR_PROP_DOUBLE_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_INDICATOR_PROP_DOUBLE prop=(ENUM_INDICATOR_PROP_DOUBLE)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   begin=end; end+=INDICATOR_PROP_STRING_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_INDICATOR_PROP_STRING prop=(ENUM_INDICATOR_PROP_STRING)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   this.PrintParameters();
   ::Print("================== ",CMessage::Text(MSG_LIB_PARAMS_LIST_END),": \"",this.GetStatusDescription(),"\" ==================\n");
  }
 //+------------------------------------------------------------------+
 //| Display a short description of the indicator in the journal (the |
 //| one of the V1 classes Ind<Name>, once here, without the handle)  |
 //+------------------------------------------------------------------+
 void CIndicatorDE::PrintShort(const bool dash=false,const bool symbol=false)
  {
   string id=(this.ID()>WRONG_VALUE ? " [id #"+(string)this.ID()+"]" : "");
   ::Print(this.GetStatusDescription()," ",this.Name()," ",this.Symbol()," ",this.GetTimeframeDescription(),id);
  }
 //--- Clone the stored MqlParam array out for replication purposes
 void CIndicatorDE::GetMqlParams(MqlParam &out_params[]) const
  {
   int n=::ArraySize(this.m_mql_param);
   ::ArrayResize(out_params,n);
   for(int i=0;i<n;i++)
      out_params[i]=this.m_mql_param[i];
  }
#endif // CINDICATORDE_MQH_IMPLEMENTATION
#endif // __INDICATORDE_MQH__
