//+------------------------------------------------------------------------------+
//|                                         IndicatorsCollection.mqh             |
//|                        Copyright 2020, MetaQuotes Software Corp.             |
//| Lib link            https://www.mql5.com/en/articles/14710                   |
//| Update in V4 after implemenation CDatabaseService                            |
//| CIndicatorsCollection no more working with Database only working with RAM    |
//+------------------------------------------------------------------------------+ 
//| The indicators of the templates on the pairs                                 |
//+------------------------------------------------------------------------------+
#ifndef __INDICATORSCOLLECTION_MQH__
#define __INDICATORSCOLLECTION_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Entities\Indicators\IndicatorDE.mqh"
 #include "..\Entities\Indicators\Standard\IndAC.mqh"
 #include "..\Entities\Indicators\Standard\IndAD.mqh"
 #include "..\Entities\Indicators\Standard\IndADX.mqh"
 #include "..\Entities\Indicators\Standard\IndADXW.mqh"
 #include "..\Entities\Indicators\Standard\IndAlligator.mqh"
 #include "..\Entities\Indicators\Standard\IndAMA.mqh"
 #include "..\Entities\Indicators\Standard\IndAO.mqh"
 #include "..\Entities\Indicators\Standard\IndATR.mqh"
 #include "..\Entities\Indicators\Standard\IndBands.mqh"
 #include "..\Entities\Indicators\Standard\IndBears.mqh"
 #include "..\Entities\Indicators\Standard\IndBulls.mqh"
 #include "..\Entities\Indicators\Standard\IndBWMFI.mqh"
 #include "..\Entities\Indicators\Standard\IndCCI.mqh"
 #include "..\Entities\Indicators\Standard\IndChaikin.mqh"
 #include "..\Entities\Indicators\Standard\IndDEMA.mqh"
 #include "..\Entities\Indicators\Standard\IndDeMarker.mqh"
 #include "..\Entities\Indicators\Standard\IndEnvelopes.mqh"
 #include "..\Entities\Indicators\Standard\IndForce.mqh"
 #include "..\Entities\Indicators\Standard\IndFractals.mqh"
 #include "..\Entities\Indicators\Standard\IndFRAMA.mqh"
 #include "..\Entities\Indicators\Standard\IndGator.mqh"
 #include "..\Entities\Indicators\Standard\IndIchimoku.mqh"
 #include "..\Entities\Indicators\Standard\IndMA.mqh"
 #include "..\Entities\Indicators\Standard\IndMACD.mqh"
 #include "..\Entities\Indicators\Standard\IndMFI.mqh"
 #include "..\Entities\Indicators\Standard\IndMomentum.mqh"
 #include "..\Entities\Indicators\Standard\IndOBV.mqh"
 #include "..\Entities\Indicators\Standard\IndOsMA.mqh"
 #include "..\Entities\Indicators\Standard\IndRSI.mqh"
 #include "..\Entities\Indicators\Standard\IndRVI.mqh"
 #include "..\Entities\Indicators\Standard\IndSAR.mqh"
 #include "..\Entities\Indicators\Standard\IndStDev.mqh"
 #include "..\Entities\Indicators\Standard\IndStoch.mqh"
 #include "..\Entities\Indicators\Standard\IndTEMA.mqh"
 #include "..\Entities\Indicators\Standard\IndTRIX.mqh"
 #include "..\Entities\Indicators\Standard\IndVIDYA.mqh"
 #include "..\Entities\Indicators\Standard\IndVolumes.mqh"
 #include "..\Entities\Indicators\Standard\IndWPR.mqh"
 #include "..\Entities\Defines\EventDefines.mqh"
 #include "Settings\SymbolTFManager.mqh"
 #include "Settings\IndicatorTemplateManager.mqh" 
#ifndef CINDICATORSCOLLECTION_MQH_DECLARATION
#define CINDICATORSCOLLECTION_MQH_DECLARATION 
 class CIndicatorsCollection : public CBaseObj
  {
   private:
    CArrayObj         m_list;                                    // The indicators (CIndicatorDE, owned)
    CSymbolTFManager *m_SymbolTFManager;                         // The EA holds it: the pairs
    CIndicatorTemplateManager *m_IndicatorTemplateManager;       // The EA holds it: the templates, their params as MqlParam
   //--- The object of the type (V1: CreateMA, CreateRSI...), NULL for a type that is not a standard indicator
    CIndicatorDE     *CreateIndicator(const ENUM_INDICATOR type,MqlParam &params[],const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The indicator of a template on a pair is made (once)
    bool              AddIndicatorToList(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- (1) every template on a pair, (2) a template on every pair
    void              AddPair(const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              AddTemplate(const ENUM_INDICATOR type,const string params_text);  
   //--- The indicators of (1) a pair, (2) a template go
    void              DeletePair(const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              DeleteTemplate(const ENUM_INDICATOR type,const string params_text);
   //--- New in V5: (1) an indicator another one is made on, (2) the sources no template and no reader needs any more go (one owner, one release)
    bool              IsSourceOfAnother(CIndicatorDE *source) const;
    void              DeleteUnusedSources(void);
   public:
   //--- The indicator of a template on a pair: its type and its params (the column params of the template), never the handle (NULL: none)
    CIndicatorDE      *GetIndicator(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              SetSymbolTFManager(CSymbolTFManager *manager)                   { this.m_SymbolTFManager=manager;          }
    void              SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { this.m_IndicatorTemplateManager=manager; }
    CArrayObj        *GetList(void)                                                   { return &this.m_list;                     }
   //--- Lifecycle: every template on every pair of Setting_SymbolTF (RAM only, the managers own the tables)
    bool              OnInitEvent(void);
   //--- A pair or a template added (made) or deleted (gone): SYMBOLTF_MANAGER_EVENT_ADDED / _DELETE, INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED / _DELETE
   //--- Change in V5: no refresh at SERIES_EVENTS_NEW_BAR any more: the users refresh what they read when they judge (CSignalsCollection::Prepare, CStrategyCollection), the event comes after the tick
    bool              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);   
                      CIndicatorsCollection(void) : m_SymbolTFManager(NULL),m_IndicatorTemplateManager(NULL) { this.m_object_type=COLLECTION_INDICATORS_ID; }
                     ~CIndicatorsCollection(void) {}
  };
#endif // CINDICATORSCOLLECTION_MQH_DECLARATION
#ifndef CINDICATORSCOLLECTION_MQH_IMPLEMENTATION
#define CINDICATORSCOLLECTION_MQH_IMPLEMENTATION 
 bool CIndicatorsCollection::OnInitEvent(void)
  {   
   if(this.m_SymbolTFManager==NULL || this.m_IndicatorTemplateManager==NULL)
      return false;
   if(!this.m_first_start)
      return true;   // a chart change: the pairs and the templates are the same, the indicators stay (a pair or a template is added or deleted by its event)
   this.m_first_start=false;
   this.m_list.Clear();
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   for(int i=0;i<pairs;i++)
      this.AddPair(symbols[i],timeframes[i]);
   int filled=0;
   for(int i=0;i<this.m_list.Total();i++)
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL && indicator.GetSeriesData().DataTotal()>0)
         filled++;
     }
   ::Print("Complete ",__FUNCTION__," > ",this.m_list.Total()," indicators on ",pairs," pairs of Setting_SymbolTF, the values of ",filled," of them in RAM (the others at the first new bar of their pair)");
   return true;
  } 
 bool CIndicatorsCollection::AddIndicatorToList(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   SIndicatorsRow catalog;
   if(this.GetIndicator(type,params_text,symbol,timeframe)!=NULL)
      return true;
   MqlParam params[];
   if(!this.m_IndicatorTemplateManager.ParamsFromText(type,params_text,params))
      return false;
   //--- New in V5: an indicator on indicator: its source first (shared, found by its type and params), its handle in the applied param
   CIndicatorDE *source=NULL;
   ENUM_INDICATOR source_type;
   string source_params;
   int applied=WRONG_VALUE;
   if(this.m_IndicatorTemplateManager.SourceOf(type,params_text,source_type,source_params,applied))
     {
      if(this.AddIndicatorToList(source_type,source_params,symbol,timeframe))
         source=this.GetIndicator(source_type,source_params,symbol,timeframe);
      if(source==NULL || source.Handle()==INVALID_HANDLE)
        {
         ::Print(__FUNCTION__," > no source ",source_params," for ",params_text," on ",symbol);
         return false;
        }
      params[applied].integer_value=source.Handle();
     }
   CIndicatorDE *indicator=this.CreateIndicator(type,params,symbol,timeframe);
   if(indicator==NULL)
      return false;
   indicator.SetIndicatorTemplateManager(this.m_IndicatorTemplateManager);
   indicator.SetParamsText(params_text);   // the column params as it is on RAM
   CIndicatorSetting *setting=this.m_IndicatorTemplateManager.Read_RAM(type,params_text);
   if(setting!=NULL)
      indicator.SetID(setting.ID());   // the key of its rows on RAM: indicators are compared by type and params (IsOf)
   this.m_IndicatorTemplateManager.Read_RAM(type,catalog);
   int buffers_total=catalog.buffers;
   if(buffers_total<1)
     {
      ::Print(__FUNCTION__," > no buffer metadata for indicator ",(int)type);
      delete indicator;
      return false;
     }
   indicator.SetBuffersTotal(buffers_total);
   indicator.SetSource(source,0);   // New in V5: the source is buffer buffers_total (buffer 0 of the source)
   if(indicator.Handle()==INVALID_HANDLE || !this.m_list.Add(indicator))
     {
      delete indicator;
      return false;
     }
   string timeframe_name=this.m_SymbolTFManager.Read_RAM((ENUM_TIMEFRAMES)timeframe);   // the table timeframes
   indicator.SetTimeframeDescription(timeframe_name);
   indicator.SetShortName(indicator.Name()+"("+symbol+","+timeframe_name+")");   // as V1: "MA(EURUSD,H1)"
   indicator.GetSeriesData().Create();   // 0 when MT5 has not calculated it yet: the first Refresh of a user makes it (CIndicatorSeriesDE::Refresh)
   return true;
  }
 //+------------------------------------------------------------------+
 //| The object of the standard indicator of the type                 |
 //+------------------------------------------------------------------+
 CIndicatorDE *CIndicatorsCollection::CreateIndicator(const ENUM_INDICATOR type,MqlParam &params[],const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   switch(type)
     {
      case IND_AC:        return new CIndAC(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_AD:        return new CIndAD(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_ADX:       return new CIndADX(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_ADXW:      return new CIndADXW(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_ALLIGATOR: return new CIndAlligator(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_AMA:       return new CIndAMA(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_AO:        return new CIndAO(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_ATR:       return new CIndATR(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_BANDS:     return new CIndBands(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_BEARS:     return new CIndBears(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_BULLS:     return new CIndBulls(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_BWMFI:     return new CIndBWMFI(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_CCI:       return new CIndCCI(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_CHAIKIN:   return new CIndCHO(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_DEMA:      return new CIndDEMA(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_DEMARKER:  return new CIndDeMarker(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_ENVELOPES: return new CIndEnvelopes(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_FORCE:     return new CIndForce(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_FRACTALS:  return new CIndFractals(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_FRAMA:     return new CIndFRAMA(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_GATOR:     return new CIndGator(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_ICHIMOKU:  return new CIndIchimoku(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_MA:        return new CIndMA(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_MACD:      return new CIndMACD(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_MFI:       return new CIndMFI(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_MOMENTUM:  return new CIndMomentum(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_OBV:       return new CIndOBV(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_OSMA:      return new CIndOsMA(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_RSI:       return new CIndRSI(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_RVI:       return new CIndRVI(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_SAR:       return new CIndSAR(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_STDDEV:    return new CIndStDev(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_STOCHASTIC:return new CIndStoch(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_TEMA:      return new CIndTEMA(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_TRIX:      return new CIndTRIX(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_VIDYA:     return new CIndVIDYA(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_VOLUMES:   return new CIndVolumes(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      case IND_WPR:       return new CIndWPR(symbol,timeframe,params,this.m_IndicatorTemplateManager);
      default:            return NULL;   // not a standard indicator (IND_CUSTOM is not used)
     }
  }
 void CIndicatorsCollection::AddPair(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   ENUM_INDICATOR types[];
   string texts[];
   bool buy[],sell[];
   int templates=this.m_IndicatorTemplateManager.Read_RAM(types,texts,buy,sell);
   for(int t=0;t<templates;t++)
      this.AddIndicatorToList(types[t],texts[t],symbol,timeframe);
  }
 void CIndicatorsCollection::AddTemplate(const ENUM_INDICATOR type,const string params_text)
  {
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Read_RAM(symbols,timeframes);
   for(int i=0;i<pairs;i++)
      this.AddIndicatorToList(type,params_text,symbols[i],timeframes[i]);
  }
 void CIndicatorsCollection::DeletePair(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=this.m_list.Total()-1;i>=0;i--)   // from the end: a reader is after its source (made after it), it goes first
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL && indicator.Symbol()==symbol && indicator.Timeframe()==timeframe)
         this.m_list.Delete(i);   // its handle is released
     }
  }
 void CIndicatorsCollection::DeleteTemplate(const ENUM_INDICATOR type,const string params_text)
  {
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL && indicator.IsOf(type,params_text,indicator.Symbol(),indicator.Timeframe()) && !this.IsSourceOfAnother(indicator))
         this.m_list.Delete(i);   // New in V5: a source another indicator reads stays
     }
   this.DeleteUnusedSources();
  }
 bool CIndicatorsCollection::IsSourceOfAnother(CIndicatorDE *source) const
  {
   for(int i=0;i<this.m_list.Total();i++)
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL && indicator!=source && indicator.SourceIndicator()==source)
         return true;
     }
   return false;
  }
 void CIndicatorsCollection::DeleteUnusedSources(void)
  {
   for(int i=this.m_list.Total()-1;i>=0;i--)   // from the end: the source of a deleted reader is before it, its turn comes after
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL && this.m_IndicatorTemplateManager.Read_RAM(indicator.TypeIndicator(),indicator.ParamsText())==NULL && !this.IsSourceOfAnother(indicator))
         this.m_list.Delete(i);
     }
  }
 CIndicatorDE *CIndicatorsCollection::GetIndicator(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=0;i<this.m_list.Total();i++)
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL && indicator.IsOf(type,params_text,symbol,timeframe))
         return indicator;
     }
   return NULL;
  }
 //+------------------------------------------------------------------+
 //| The settings changed: the indicators follow                      |
 //+------------------------------------------------------------------+
 bool CIndicatorsCollection::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(this.m_SymbolTFManager==NULL || this.m_IndicatorTemplateManager==NULL)
      return false;
   //--- A pair: lparam = its TF, sparam = its symbol
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED)
     {
      this.AddPair(sparam,(ENUM_TIMEFRAMES)lparam);
      return true;
     }
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE)
     {
      this.DeletePair(sparam,(ENUM_TIMEFRAMES)lparam);
      return true;
     }
   //--- A template: lparam = its type, sparam = its params
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
     {
      this.AddTemplate((ENUM_INDICATOR)lparam,sparam);
      return true;
     }
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
     {
      this.DeleteTemplate((ENUM_INDICATOR)lparam,sparam);
      return true;
     }
   return false;
  }
#endif // CINDICATORSCOLLECTION_MQH_IMPLEMENTATION
#endif // __INDICATORSCOLLECTION_MQH__
