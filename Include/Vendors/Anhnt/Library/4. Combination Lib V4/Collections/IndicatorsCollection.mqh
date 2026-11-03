//+------------------------------------------------------------------+
//|                                         IndicatorsCollection.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//| Lib link            https://www.mql5.com/en/articles/14710       |
//! CRUD Table: indicators                                           |
//+------------------------------------------------------------------+
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
 #include "..\Services\DELib\DatabaseDELib.mqh"
 #include "Settings\SymbolTFManager.mqh"
 #include "Settings\IndicatorTemplateManager.mqh"
 #include "..\Services\DELib\DatabaseService.mqh"
#ifndef CINDICATORSCOLLECTION_MQH_DECLARATION
#define CINDICATORSCOLLECTION_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The indicators of the templates on the pairs                     |
 //+------------------------------------------------------------------+
 class CIndicatorsCollection : public CBaseObj
  {
   private:
    CArrayObj         m_list;                                    // The indicators (CIndicatorDE, owned)
    CSymbolTFManager *m_SymbolTFManager;                         // The EA holds it: the pairs
    CIndicatorTemplateManager *m_IndicatorTemplateManager;       // The EA holds it: the templates, their params as MqlParam   
    //Plan to replaced by CDatabaseService
     int               m_db;                                      // Common DB: the table indicators is this class's, the others only read it
    
    CDatabaseService   *m_CDatabaseService;                       // The EA holds it
   //--- The object of the type (V1: CreateMA, CreateRSI...), NULL for a type that is not a standard indicator
    CIndicatorDE     *CreateIndicator(const ENUM_INDICATOR type,MqlParam &params[],const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- The indicator of a template on a pair is made (once)
    bool              AddIndicatorToList(const long id,const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe);
   //--- (1) every template on a pair, (2) a template on every pair
    void              AddPair(const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              AddTemplate(const ENUM_INDICATOR type,const string params_text);
   //--- The indicators of (1) a pair, (2) a template go
    void              DeletePair(const string symbol,const ENUM_TIMEFRAMES timeframe);
    void              DeleteTemplate(const ENUM_INDICATOR type,const string params_text);
   public:
    void              SetSymbolTFManager(CSymbolTFManager *manager)                   { this.m_SymbolTFManager=manager;          }
    void              SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { this.m_IndicatorTemplateManager=manager; }
    void              SetDatabaseService    (CDatabaseService   *databaseService)    {this.m_CDatabaseService=databaseService;}
    CArrayObj        *GetList(void)                                                   { return &this.m_list;                     }
   //--- Lifecycle: opens Common DB, makes the table indicators, writes the catalog to it (SyncDataToDB), then every template on every pair
    bool              OnInitEvent(void);
   //--- The catalog of IndicatorDELib.mqh to the table indicators (written again at each OnInit: the table follows the code)
    bool              SyncDataToDB(void);
   //--- A pair or a template added (made) or deleted (gone): SYMBOLTF_MANAGER_EVENT_ADDED / _DELETE, INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED / _DELETE; a new bar: SERIES_EVENTS_NEW_BAR
    bool              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- The indicator of a template on a pair: its type and its params (the text of the template as MqlParam), never the handle (NULL: none)
    CIndicatorDE     *GetIndicator(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe);
                      CIndicatorsCollection(void) : m_SymbolTFManager(NULL),m_IndicatorTemplateManager(NULL),m_CDatabaseService(NULL),m_db(INVALID_HANDLE) { this.m_object_type=COLLECTION_INDICATORS_ID; }
                     ~CIndicatorsCollection(void) { if(this.m_db!=INVALID_HANDLE) ::DatabaseClose(this.m_db); }
  };
#endif // CINDICATORSCOLLECTION_MQH_DECLARATION
#ifndef CINDICATORSCOLLECTION_MQH_IMPLEMENTATION
#define CINDICATORSCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| The table indicators is this class's: made when it is not there,  |
 //| the catalog written to it; then every template on every pair of   |
 //| Setting_SymbolTF                                                  |
 //+------------------------------------------------------------------+
 bool CIndicatorsCollection::OnInitEvent(void)
  {
   //Old Plan to remove
    if(this.m_db==INVALID_HANDLE)
     {
      this.m_db=LibDatabase_Open(DATABASE_OPEN_READWRITE);
      if(this.m_db==INVALID_HANDLE)
        {
         ::Print(__FUNCTION__," > the database ",LIB_DATABASE_FILE," is not opened, error ",::GetLastError());
         return false;
        }
      ::DatabaseExecute(this.m_db,"PRAGMA busy_timeout=5000");
     }   
    string sql = "CREATE TABLE IF NOT EXISTS indicators (type_enum INTEGER NOT NULL PRIMARY KEY, type_name TEXT NOT NULL UNIQUE, name TEXT NOT NULL UNIQUE, "
                  "group_enum INTEGER NOT NULL, buffers INTEGER NOT NULL, params_total INTEGER NOT NULL)";
   // Old Plan to remove after implemenation CDatabaseService
    if(!::DatabaseExecute(this.m_db, sql))
     {
      ::Print(__FUNCTION__, " > legacy indicators table is not created, error ", ::GetLastError());
      return false;
     }
   // New In V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService == NULL)
     {
      ::Print(__FUNCTION__, " > DatabaseService is not set");
      return false;
     }
    if(!this.m_CDatabaseService.ExecuteCommon(sql))
      return false;
       
   //-----------------------
   if(!this.SyncDataToDB())
      return false;
   if(this.m_SymbolTFManager==NULL || this.m_IndicatorTemplateManager==NULL)
      return false;
   this.m_list.Clear();
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Pairs(symbols,timeframes);
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
 //+------------------------------------------------------------------+
 //| The table indicators: the catalog of IndicatorDELib.mqh (the      |
 //| standard indicators of MT5), written again at each OnInit so the  |
 //| table follows the code. Python only reads it: type_name is the    |
 //| ENUM_INDICATOR without IND_ (its key of a calculation)            |
 //+------------------------------------------------------------------+
 bool CIndicatorsCollection::SyncDataToDB(void)
  {
   //Old Plan to remove 
    if(this.m_db==INVALID_HANDLE)
      return false;
   //New Plan to Replace
    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);
    for(int i=0;i<::ArraySize(catalog);i++)
     {
      SIndicatorParam schema[];
      int params_total=GetIndicatorParamSchema(catalog[i].ind_type,schema);
      // Old
       if(!::DatabaseExecute(this.m_db,"INSERT OR REPLACE INTO indicators (type_enum, type_name, name, group_enum, buffers, params_total) VALUES ("+(string)(int)catalog[i].ind_type+", '"+
                               ::StringSubstr(::EnumToString(catalog[i].ind_type),4)+"', '"+LibDatabase_Quoted(catalog[i].name)+"', "+(string)(int)catalog[i].group+", "+
                               (string)catalog[i].buffers+", "+(string)params_total+")"))
        {
         ::Print(__FUNCTION__," > ",catalog[i].name," not written, error ",::GetLastError());
         return false;
        }
      //New Create Standard Indicator list
       if(!this.m_CDatabaseService.ExecuteCommon("INSERT OR REPLACE INTO indicators (type_enum, type_name, name, group_enum, buffers, params_total) VALUES ("+(string)(int)catalog[i].ind_type+", '"+
                               ::StringSubstr(::EnumToString(catalog[i].ind_type),4)+"', '"+LibDatabase_Quoted(catalog[i].name)+"', "+(string)(int)catalog[i].group+", "+
                               (string)catalog[i].buffers+", "+(string)params_total+")"))       
        {
         ::Print(__FUNCTION__," > ",catalog[i].name," not written, error ",::GetLastError());
         return false;
        }
     }
   return true;
  }
 bool CIndicatorsCollection::AddIndicatorToList(const long id,const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   if(this.GetIndicator(type,params_text,symbol,timeframe)!=NULL)
      return true;
   MqlParam params[];
   if(!this.m_IndicatorTemplateManager.ParamsFromText(type,params_text,params))
      return false;
   CIndicatorDE *indicator=this.CreateIndicator(type,params,symbol,timeframe);
   if(indicator==NULL)
      return false;
   if(indicator.Handle()==INVALID_HANDLE || !this.m_list.Add(indicator))
     {
      delete indicator;
      return false;
     }
   indicator.SetID(id);
   string timeframe_name=this.m_SymbolTFManager.TimeframeName(timeframe);   // the table timeframes
   indicator.SetTimeframeDescription(timeframe_name);
   indicator.SetShortName(indicator.Name()+"("+symbol+","+timeframe_name+")");   // as V1: "MA(EURUSD,H1)"
   indicator.GetSeriesData().Create();   // 0 when MT5 has not calculated it yet: the first new bar of the pair makes it
   return true;
  }
 //+------------------------------------------------------------------+
 //| The object of the standard indicator of the type                 |
 //+------------------------------------------------------------------+
 CIndicatorDE *CIndicatorsCollection::CreateIndicator(const ENUM_INDICATOR type,MqlParam &params[],const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   switch(type)
     {
      case IND_AC:        return new CIndAC(symbol,timeframe,params);
      case IND_AD:        return new CIndAD(symbol,timeframe,params);
      case IND_ADX:       return new CIndADX(symbol,timeframe,params);
      case IND_ADXW:      return new CIndADXW(symbol,timeframe,params);
      case IND_ALLIGATOR: return new CIndAlligator(symbol,timeframe,params);
      case IND_AMA:       return new CIndAMA(symbol,timeframe,params);
      case IND_AO:        return new CIndAO(symbol,timeframe,params);
      case IND_ATR:       return new CIndATR(symbol,timeframe,params);
      case IND_BANDS:     return new CIndBands(symbol,timeframe,params);
      case IND_BEARS:     return new CIndBears(symbol,timeframe,params);
      case IND_BULLS:     return new CIndBulls(symbol,timeframe,params);
      case IND_BWMFI:     return new CIndBWMFI(symbol,timeframe,params);
      case IND_CCI:       return new CIndCCI(symbol,timeframe,params);
      case IND_CHAIKIN:   return new CIndCHO(symbol,timeframe,params);
      case IND_DEMA:      return new CIndDEMA(symbol,timeframe,params);
      case IND_DEMARKER:  return new CIndDeMarker(symbol,timeframe,params);
      case IND_ENVELOPES: return new CIndEnvelopes(symbol,timeframe,params);
      case IND_FORCE:     return new CIndForce(symbol,timeframe,params);
      case IND_FRACTALS:  return new CIndFractals(symbol,timeframe,params);
      case IND_FRAMA:     return new CIndFRAMA(symbol,timeframe,params);
      case IND_GATOR:     return new CIndGator(symbol,timeframe,params);
      case IND_ICHIMOKU:  return new CIndIchimoku(symbol,timeframe,params);
      case IND_MA:        return new CIndMA(symbol,timeframe,params);
      case IND_MACD:      return new CIndMACD(symbol,timeframe,params);
      case IND_MFI:       return new CIndMFI(symbol,timeframe,params);
      case IND_MOMENTUM:  return new CIndMomentum(symbol,timeframe,params);
      case IND_OBV:       return new CIndOBV(symbol,timeframe,params);
      case IND_OSMA:      return new CIndOsMA(symbol,timeframe,params);
      case IND_RSI:       return new CIndRSI(symbol,timeframe,params);
      case IND_RVI:       return new CIndRVI(symbol,timeframe,params);
      case IND_SAR:       return new CIndSAR(symbol,timeframe,params);
      case IND_STDDEV:    return new CIndStDev(symbol,timeframe,params);
      case IND_STOCHASTIC:return new CIndStoch(symbol,timeframe,params);
      case IND_TEMA:      return new CIndTEMA(symbol,timeframe,params);
      case IND_TRIX:      return new CIndTRIX(symbol,timeframe,params);
      case IND_VIDYA:     return new CIndVIDYA(symbol,timeframe,params);
      case IND_VOLUMES:   return new CIndVolumes(symbol,timeframe,params);
      case IND_WPR:       return new CIndWPR(symbol,timeframe,params);
      default:            return NULL;   // not a standard indicator (IND_CUSTOM is not used)
     }
  }
 void CIndicatorsCollection::AddPair(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   long ids[];
   ENUM_INDICATOR types[];
   string texts[];
   bool buy[],sell[];
   int templates=this.m_IndicatorTemplateManager.TemplateIds(ids,types,texts,buy,sell);
   for(int t=0;t<templates;t++)
      this.AddIndicatorToList(ids[t],types[t],texts[t],symbol,timeframe);
  }
 void CIndicatorsCollection::AddTemplate(const ENUM_INDICATOR type,const string params_text)
  {
   long ids[];
   ENUM_INDICATOR types[];
   string texts[];
   bool buy[],sell[];
   int templates=this.m_IndicatorTemplateManager.TemplateIds(ids,types,texts,buy,sell);
   long id=0;
   for(int t=0;t<templates;t++)
      if(types[t]==type && texts[t]==params_text)
         id=ids[t];
   string symbols[];
   ENUM_TIMEFRAMES timeframes[];
   int pairs=this.m_SymbolTFManager.Pairs(symbols,timeframes);
   for(int i=0;i<pairs;i++)
      this.AddIndicatorToList(id,type,params_text,symbols[i],timeframes[i]);
  }
 void CIndicatorsCollection::DeletePair(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL && indicator.Symbol()==symbol && indicator.Timeframe()==timeframe)
         this.m_list.Delete(i);   // its handle is released
     }
  }
 void CIndicatorsCollection::DeleteTemplate(const ENUM_INDICATOR type,const string params_text)
  {
   MqlParam params[];
   if(!this.m_IndicatorTemplateManager.ParamsFromText(type,params_text,params))
      return;
   for(int i=this.m_list.Total()-1;i>=0;i--)
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL && indicator.IsOf(type,params,indicator.Symbol(),indicator.Timeframe()))
         this.m_list.Delete(i);
     }
  }
 CIndicatorDE *CIndicatorsCollection::GetIndicator(const ENUM_INDICATOR type,const string params_text,const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   MqlParam params[];
   if(this.m_IndicatorTemplateManager==NULL || !this.m_IndicatorTemplateManager.ParamsFromText(type,params_text,params))
      return NULL;
   for(int i=0;i<this.m_list.Total();i++)
     {
      CIndicatorDE *indicator=this.m_list.At(i);
      if(indicator!=NULL && indicator.IsOf(type,params,symbol,timeframe))
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
   //--- A new bar of a pair (dparam = its TF, sparam = its symbol): the values of its indicators in RAM follow
   if(id==CHARTEVENT_CUSTOM+SERIES_EVENTS_NEW_BAR)
     {
      for(int i=0;i<this.m_list.Total();i++)
        {
         CIndicatorDE *indicator=this.m_list.At(i);
         if(indicator!=NULL && indicator.Symbol()==sparam && indicator.Timeframe()==(ENUM_TIMEFRAMES)(long)dparam)
            indicator.GetSeriesData().Refresh();
        }
      return true;
     }
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
