//+------------------------------------------------------------------+
//|                                                  IndicatorDE.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//| V3: no handle, no buffers, no CSeriesDataInd - Python calculates |
//| and reports the state of the newest closed bar. Like CSymbol, the|
//| object follows its properties, so a change of the value or of    |
//| the signal direction is known to it                              |
//+------------------------------------------------------------------+
#ifndef __INDICATORDE_MQH__
#define __INDICATORDE_MQH__
 #include "..\..\Bases\BaseObjExt.mqh"
 #include "..\..\Defines\IndicatorDefines.mqh"
 #include "..\..\..\Services\DELib\TimeseriesDELib.mqh"

#ifndef CINDICATORDE_MQH_DECLARATION
#define CINDICATORDE_MQH_DECLARATION
 class CIndicatorDE : public CBaseObjExt
  {
    private:
     MqlParam           m_mql_param[];                                         // Array of indicator parameters
     long               m_long_prop[INDICATOR_PROP_INTEGER_TOTAL];             // Integer properties
     double             m_double_prop[INDICATOR_PROP_DOUBLE_TOTAL];            // Real properties
     string             m_string_prop[INDICATOR_PROP_STRING_TOTAL];            // String properties
   //--- Return the index of the array the (1) double and (2) string properties are actually located at
     int                IndexProp(ENUM_INDICATOR_PROP_DOUBLE property)   const { return(int)property-INDICATOR_PROP_INTEGER_TOTAL;                                  }
     int                IndexProp(ENUM_INDICATOR_PROP_STRING property)   const { return(int)property-INDICATOR_PROP_INTEGER_TOTAL-INDICATOR_PROP_DOUBLE_TOTAL;   }
    public:
   //--- Constructors: (1) default, (2) parametric
                        CIndicatorDE(void);
                        CIndicatorDE(const ENUM_INDICATOR ind_type,const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_params[]);
   //--- Set (1) integer, (2) real and (3) string property
     void               SetProperty(ENUM_INDICATOR_PROP_INTEGER property,long value)   { this.m_long_prop[property]=value;                           }
     void               SetProperty(ENUM_INDICATOR_PROP_DOUBLE property,double value)  { this.m_double_prop[this.IndexProp(property)]=value;         }
     void               SetProperty(ENUM_INDICATOR_PROP_STRING property,string value)  { this.m_string_prop[this.IndexProp(property)]=value;         }
   //--- Return (1) integer, (2) real and (3) string property
     long               GetProperty(ENUM_INDICATOR_PROP_INTEGER property)        const { return this.m_long_prop[property];                          }
     double             GetProperty(ENUM_INDICATOR_PROP_DOUBLE property)         const { return this.m_double_prop[this.IndexProp(property)];        }
     string             GetProperty(ENUM_INDICATOR_PROP_STRING property)         const { return this.m_string_prop[this.IndexProp(property)];        }
   //--- Return indicator (1) type, (2) symbol, (3) timeframe, (4) parameters, (5) ID
     ENUM_INDICATOR     TypeIndicator(void)           const { return (ENUM_INDICATOR)this.GetProperty(INDICATOR_PROP_TYPE);       }
     string             Symbol(void)                  const { return this.GetProperty(INDICATOR_PROP_SYMBOL);                     }
     ENUM_TIMEFRAMES    Timeframe(void)               const { return (ENUM_TIMEFRAMES)this.GetProperty(INDICATOR_PROP_TIMEFRAME); }
     void               GetMqlParams(MqlParam &out_params[]) const;
     int                ID(void)                      const { return (int)this.GetProperty(INDICATOR_PROP_ID);                    }
     void               SetID(const int id)                 { this.SetProperty(INDICATOR_PROP_ID,id);                             }
   //--- Compare with a (type, symbol, timeframe, parameters) identity
     bool               IsEqual(const ENUM_INDICATOR ind_type,const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_params[]) const;
   //--- What Python reports: set it, then read (1) the value, (2) the value before it and (3) the last signal direction
     void               SetState(const double value,const double previous,const ENUM_SIGNAL_DIR dir);
     double             Value(void)                   const { return this.GetProperty(INDICATOR_PROP_VALUE);                      }
     double             Previous(void)                const { return this.GetProperty(INDICATOR_PROP_PREVIOUS);                   }
     ENUM_SIGNAL_DIR    Dir(void)                     const { return (ENUM_SIGNAL_DIR)this.GetProperty(INDICATOR_PROP_SIGNAL_DIR);}
   //--- Take the properties into the controlled arrays and look for changes
     virtual void       Refresh(void);
     virtual int        Compare(const CObject *node,const int mode=0) const;
     virtual void       Print(const bool full_prop=false,const bool dash=false);
  };
#endif // CINDICATORDE_MQH_DECLARATION

#ifndef CINDICATORDE_MQH_IMPLEMENTATION
#define CINDICATORDE_MQH_IMPLEMENTATION
 CIndicatorDE::CIndicatorDE(void)
  {
   this.m_type=OBJECT_DE_TYPE_INDICATOR;
   this.SetControlDataArraySizeLong(INDICATOR_PROP_INTEGER_TOTAL);
   this.SetControlDataArraySizeDouble(INDICATOR_PROP_DOUBLE_TOTAL);
   this.ResetChangesParams();
   this.ResetControlsParams();
   this.SetProperty(INDICATOR_PROP_TYPE,IND_CUSTOM);
   this.SetProperty(INDICATOR_PROP_TIMEFRAME,PERIOD_CURRENT);
   this.SetProperty(INDICATOR_PROP_ID,WRONG_VALUE);
   this.SetProperty(INDICATOR_PROP_SIGNAL_DIR,SIGNAL_NONE);
   this.SetProperty(INDICATOR_PROP_VALUE,EMPTY_VALUE);
   this.SetProperty(INDICATOR_PROP_PREVIOUS,EMPTY_VALUE);
   this.SetProperty(INDICATOR_PROP_SYMBOL,"");
  }
 CIndicatorDE::CIndicatorDE(const ENUM_INDICATOR ind_type,const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_params[])
  {
   this.m_type=OBJECT_DE_TYPE_INDICATOR;
   this.SetControlDataArraySizeLong(INDICATOR_PROP_INTEGER_TOTAL);
   this.SetControlDataArraySizeDouble(INDICATOR_PROP_DOUBLE_TOTAL);
   this.ResetChangesParams();
   this.ResetControlsParams();
   this.SetProperty(INDICATOR_PROP_TYPE,ind_type);
   this.SetProperty(INDICATOR_PROP_TIMEFRAME,timeframe);
   this.SetProperty(INDICATOR_PROP_ID,WRONG_VALUE);
   this.SetProperty(INDICATOR_PROP_SIGNAL_DIR,SIGNAL_NONE);
   this.SetProperty(INDICATOR_PROP_VALUE,EMPTY_VALUE);
   this.SetProperty(INDICATOR_PROP_PREVIOUS,EMPTY_VALUE);
   this.SetProperty(INDICATOR_PROP_SYMBOL,symbol);
   int total=::ArraySize(mql_params);
   ::ArrayResize(this.m_mql_param,total);
   for(int i=0;i<total;i++)
      this.m_mql_param[i]=mql_params[i];
   this.Refresh();   // the first reading: nothing changed yet
  }
 void CIndicatorDE::GetMqlParams(MqlParam &out_params[]) const
  {
   int total=::ArraySize(this.m_mql_param);
   ::ArrayResize(out_params,total);
   for(int i=0;i<total;i++)
      out_params[i]=this.m_mql_param[i];
  }
 bool CIndicatorDE::IsEqual(const ENUM_INDICATOR ind_type,const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_params[]) const
  {
   if(this.TypeIndicator()!=ind_type || this.Symbol()!=symbol || this.Timeframe()!=timeframe)
      return false;
   MqlParam own[];
   this.GetMqlParams(own);
   return IsEqualMqlParamArrays(own,mql_params);
  }
 void CIndicatorDE::SetState(const double value,const double previous,const ENUM_SIGNAL_DIR dir)
  {
   this.SetProperty(INDICATOR_PROP_VALUE,value);
   this.SetProperty(INDICATOR_PROP_PREVIOUS,previous);
   this.SetProperty(INDICATOR_PROP_SIGNAL_DIR,dir);
   this.Refresh();
  }
 void CIndicatorDE::Refresh(void)
  {
   for(int i=0;i<INDICATOR_PROP_INTEGER_TOTAL;i++)
      this.m_long_prop_event[i][3]=this.m_long_prop[i];
   for(int i=0;i<INDICATOR_PROP_DOUBLE_TOTAL;i++)
      this.m_double_prop_event[i][3]=this.m_double_prop[i];
   CBaseObjExt::Refresh();
  }
 int CIndicatorDE::Compare(const CObject *node,const int mode=0) const
  {
   const CIndicatorDE *compared=node;
   return(this.ID()>compared.ID() ? 1 : this.ID()<compared.ID() ? -1 : 0);
  }
 void CIndicatorDE::Print(const bool full_prop=false,const bool dash=false)
  {
   ::Print((dash ? "- " : ""),"CIndicatorDE ",this.Symbol()," ",TimeframeDescription(this.Timeframe())," type=",(string)this.TypeIndicator(),
           " value=",this.Value()," previous=",this.Previous()," dir=",(string)this.Dir());
  }
#endif // CINDICATORDE_MQH_IMPLEMENTATION
#endif // __INDICATORDE_MQH__
