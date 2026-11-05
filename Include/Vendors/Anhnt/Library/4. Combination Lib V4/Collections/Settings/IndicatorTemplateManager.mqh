//+------------------------------------------------------------------+
//|                                     IndicatorTemplateManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Single source of truth for the indicator templates:              |
//|V3: Indicator_Templates JSON)                                     |
//| Create table indicators for standard indicator with default      |
//| Create table timeframes                                          |
//| CRUD table Setting_IndicatorTemplate of the database             |
//| Update in V4: Use CDatabaseService                               |
//+------------------------------------------------------------------+
#ifndef CINDICATORTEMPLATEMANAGER_MQH
#define CINDICATORTEMPLATEMANAGER_MQH
 //#include "..\..\Services\DELib\DatabaseDELib.mqh"
 //#include "..\..\Services\DELib\IndicatorDELib.mqh"
 #include "..\..\Entities\Defines\EventDefines.mqh"
 #include "..\..\Entities\Defines\IndicatorDefines.mqh"
 #include "..\..\Entities\Bases\BaseObj.mqh"
 #include "..\..\Entities\Settings\IndicatorSetting.mqh"
 #include "..\ListObj.mqh"
 #include "..\..\Services\DELib\DatabaseService.mqh"
 //#include "..\..\Entities\Chart\ChartObj.mqh"
 struct STimeframeItem
  {
   ENUM_TIMEFRAMES tf_enum;
   string          name;
  };
 struct SIndicatorTemplateRow
   {
      long   id;
      long   type_enum;
      string params;
      string display;
      long   buy_signal;
      long   sell_signal;
      long   sound_alert;
      long   message_alert;
      long   show_on_chart;
   };
 STimeframeItem timeframe_list[] =
  {
   {PERIOD_M1,  "M1"},
   {PERIOD_M2,  "M2"},
   {PERIOD_M3,  "M3"},
   {PERIOD_M4,  "M4"},
   {PERIOD_M5,  "M5"},
   {PERIOD_M6,  "M6"},
   {PERIOD_M10, "M10"},
   {PERIOD_M12, "M12"},
   {PERIOD_M15, "M15"},
   {PERIOD_M20, "M20"},
   {PERIOD_M30, "M30"},
   {PERIOD_H1,  "H1"},
   {PERIOD_H2,  "H2"},
   {PERIOD_H3,  "H3"},
   {PERIOD_H4,  "H4"},
   {PERIOD_H6,  "H6"},
   {PERIOD_H8,  "H8"},
   {PERIOD_H12, "H12"},
   {PERIOD_D1,  "D1"},
   {PERIOD_W1,  "W1"},
   {PERIOD_MN1, "MN1"}
  }; 
 struct SIndicatorParamRow
  {
   string                               name;
   ENUM_DATATYPE                        data_type;
   double                               default_value;
   ENUM_INDICATOR_PARAM_DOMAIN          domain;
  };
 struct SIndicatorParam
  {
   string        name;
   ENUM_DATATYPE data_type;
   string        default_value;
   string        choices;
  }; 
 struct SIndicatorsRow
  {
    ENUM_INDICATOR        ind_type;  // CIndicatorDE's constructor param name for the same ENUM_INDICATOR
    ENUM_INDICATOR_GROUP  group;
    string                name;
    string                params;    // default params của standard indicator
    string                display;   // default display
    int                   buffers;   // the buffers its signal reads (Volumes: 2, its moving average is buffer 1)
    int                   params_total;
    SIndicatorParamRow    param_schema[INDICATOR_PARAM_SLOTS_MAX];
   };  
 SIndicatorsRow standard_indicator_list[] =
  {
   // --- Trend
    //IND_SAR
     {
      IND_SAR, INDICATOR_GROUP_TREND, "PSAR","0.02,0.2","PSAR(0.02,0.2)",1, 2,
      {
       {"Step",    TYPE_DOUBLE, 0.02, INDICATOR_PARAM_DOMAIN_NONE},
       {"Maximum", TYPE_DOUBLE, 0.2,  INDICATOR_PARAM_DOMAIN_NONE}
      }
     },
    //IND_MA
     {
      IND_MA, INDICATOR_GROUP_TREND, "MA","14,0,EMA,CLOSE","MA(14,0,EMA,CLOSE)",1, 4,
       {
       {"Period",        TYPE_INT, 14,INDICATOR_PARAM_DOMAIN_NONE},
       {"Shift",         TYPE_INT, 0,INDICATOR_PARAM_DOMAIN_NONE},
       {"Method",        TYPE_INT, MODE_EMA,  INDICATOR_PARAM_DOMAIN_MA_METHOD},
       {"Applied Price", TYPE_INT, PRICE_CLOSE,  INDICATOR_PARAM_DOMAIN_APPLIED_PRICE}
       }
     },
    // IND_BANDS
     {
      IND_BANDS, INDICATOR_GROUP_TREND, "BBands","20,0,2.0,CLOSE","BBands(20,0,2.0,CLOSE)",1, 4,
       {
       {"Period",        TYPE_INT,    20,  INDICATOR_PARAM_DOMAIN_NONE},
       {"Shift",         TYPE_INT,    0,   INDICATOR_PARAM_DOMAIN_NONE},
       {"Deviation",     TYPE_DOUBLE, 2.0, INDICATOR_PARAM_DOMAIN_NONE},
       {"Applied Price", TYPE_INT,    PRICE_CLOSE,INDICATOR_PARAM_DOMAIN_APPLIED_PRICE}
       }
     },
    //IND_ALLIGATOR
     {
     IND_ALLIGATOR, INDICATOR_GROUP_TREND, "Alligator","13,8,8,5,5,3,SMMA,MEDIAN","Alligator(13,8,8,5,5,3,SMMA,MEDIAN)",3, 8,
     {
      {"Jaw Period",  TYPE_INT, 13,        INDICATOR_PARAM_DOMAIN_NONE},
      {"Jaw Shift",   TYPE_INT, 8,         INDICATOR_PARAM_DOMAIN_NONE},
      {"Teeth Period",TYPE_INT, 8,         INDICATOR_PARAM_DOMAIN_NONE},
      {"Teeth Shift", TYPE_INT, 5,         INDICATOR_PARAM_DOMAIN_NONE},
      {"Lips Period", TYPE_INT, 5,         INDICATOR_PARAM_DOMAIN_NONE},
      {"Lips Shift",  TYPE_INT, 3,         INDICATOR_PARAM_DOMAIN_NONE},
      {"Method",      TYPE_INT, MODE_SMMA, INDICATOR_PARAM_DOMAIN_MA_METHOD},
      {"Applied Price", TYPE_INT, PRICE_MEDIAN, INDICATOR_PARAM_DOMAIN_APPLIED_PRICE}
     }
     },
    // IND_MACD
     {
     IND_MACD, INDICATOR_GROUP_OSCILLATOR,"MACD","12,26,9,CLOSE", "MACD(12,26,9,CLOSE)",2,4,
     {
      {"Fast EMA Period",TYPE_INT, 12,        INDICATOR_PARAM_DOMAIN_NONE},
      {"Slow EMA Period",TYPE_INT, 26,        INDICATOR_PARAM_DOMAIN_NONE},
      {"Signal Period",  TYPE_INT, 9,         INDICATOR_PARAM_DOMAIN_NONE},
      {"Applied Price",  TYPE_INT, PRICE_CLOSE,INDICATOR_PARAM_DOMAIN_APPLIED_PRICE}
     }
     },
   // IND_STOCHASTIC
    {
      IND_STOCHASTIC, INDICATOR_GROUP_OSCILLATOR, "Stochastic Oscillator",
      "5,3,3,SMA,LOW/HIGH", "Stochastic Oscillator(5,3,3,SMA,LOW/HIGH)",2,5,
      {
         {"%K Period",  TYPE_INT, 5,        INDICATOR_PARAM_DOMAIN_NONE},
         {"%D Period",  TYPE_INT, 3,        INDICATOR_PARAM_DOMAIN_NONE},
         {"Slowing",    TYPE_INT, 3,        INDICATOR_PARAM_DOMAIN_NONE},
         {"Method",     TYPE_INT, MODE_SMA, INDICATOR_PARAM_DOMAIN_MA_METHOD},
         {"Price Field",TYPE_INT, STO_LOWHIGH,INDICATOR_PARAM_DOMAIN_STOCH_PRICE}
      }
    },
   //IND_CCI
    {
      IND_CCI, INDICATOR_GROUP_OSCILLATOR, "CCI","14,TYPICAL","CCI(14,TYPICAL)", 1, 2,
      {
         {"Period",       TYPE_INT, 14,          INDICATOR_PARAM_DOMAIN_NONE},
         {"Applied Price",TYPE_INT, PRICE_TYPICAL,INDICATOR_PARAM_DOMAIN_APPLIED_PRICE}
      }
    },
   // IND_MOMENTUM
    {
      IND_MOMENTUM, INDICATOR_GROUP_OSCILLATOR, "Momentum","14,CLOSE","Momentum(14,CLOSE)", 1, 2,
      {
         {"Period",       TYPE_INT, 14,        INDICATOR_PARAM_DOMAIN_NONE},
         {"Applied Price",TYPE_INT, PRICE_CLOSE,INDICATOR_PARAM_DOMAIN_APPLIED_PRICE}
      }
    },
   // IND_DEMARKER
    {
      IND_DEMARKER, INDICATOR_GROUP_OSCILLATOR, "DeMarker","14","DeMarker(14)", 1, 1,
      {{"Period", TYPE_INT, 14, INDICATOR_PARAM_DOMAIN_NONE}}
    },
   // IND_RVI
    {
      IND_RVI, INDICATOR_GROUP_OSCILLATOR, "Relative Vigor Index","10","Relative Vigor Index(10)", 2, 1,
      {{"Period", TYPE_INT, 10, INDICATOR_PARAM_DOMAIN_NONE}}
    },
   // IND_WPR
    {
      IND_WPR, INDICATOR_GROUP_OSCILLATOR, "Williams' Percent Range",
      "14", "Williams' Percent Range (14)", 1, 1,
      {{"Period", TYPE_INT, 14, INDICATOR_PARAM_DOMAIN_NONE}}
    },
   // IND_OSMA
    {
      IND_OSMA, INDICATOR_GROUP_OSCILLATOR, "OsMA","12,26,9,CLOSE", "OsMA(12,26,9,CLOSE)", 1, 4,
      {
         {"Fast EMA Period",TYPE_INT, 12,        INDICATOR_PARAM_DOMAIN_NONE},
         {"Slow EMA Period",TYPE_INT, 26,        INDICATOR_PARAM_DOMAIN_NONE},
         {"Signal Period",  TYPE_INT, 9,         INDICATOR_PARAM_DOMAIN_NONE},
         {"Applied Price",  TYPE_INT, PRICE_CLOSE,INDICATOR_PARAM_DOMAIN_APPLIED_PRICE}
      }
    },
   // IND_TRIX
    {
     IND_TRIX, INDICATOR_GROUP_OSCILLATOR, "Triple Exponential Average","14", "Triple Exponential Average (14)", 1, 1,
     {{"Period", TYPE_INT, 14, INDICATOR_PARAM_DOMAIN_NONE}}
    },
   // IND_ATR
    {
      IND_ATR, INDICATOR_GROUP_OSCILLATOR,"ATR",
      "14", "ATR(14)", 1, 1,
      {{"Period", TYPE_INT, 14, INDICATOR_PARAM_DOMAIN_NONE}}
    },
   // IND_FORCE
    {
      IND_FORCE, INDICATOR_GROUP_OSCILLATOR, "Force Index",
      "13,EMA,TICK", "Force Index(13,EMA,TICK)", 1, 3,
      {
         {"Period",         TYPE_INT, 13,         INDICATOR_PARAM_DOMAIN_NONE},
         {"Method",         TYPE_INT, MODE_EMA,   INDICATOR_PARAM_DOMAIN_MA_METHOD},
         {"Applied Volume", TYPE_INT, VOLUME_TICK,INDICATOR_PARAM_DOMAIN_APPLIED_VOLUME}
      }
    },
   //IND_AO
    {IND_AO, INDICATOR_GROUP_OSCILLATOR, "Awesome Oscillator", "", "Awesome Oscillator", 1, 0, {}},
   // IND_AC
    {IND_AC, INDICATOR_GROUP_OSCILLATOR, "Accelerator Oscillator", "", "Accelerator Oscillator", 1, 0, {}},
    {
     IND_GATOR, INDICATOR_GROUP_OSCILLATOR, "Gator Oscillator","13,8,8,5,5,3,SMMA,MEDIAN", "Gator Oscillator(13,8,8,5,5,3,SMMA,MEDIAN)", 1, 8,
     {
      {"Jaw Period",  TYPE_INT, 13,        INDICATOR_PARAM_DOMAIN_NONE},
      {"Jaw Shift",   TYPE_INT, 8,         INDICATOR_PARAM_DOMAIN_NONE},
      {"Teeth Period",TYPE_INT, 8,         INDICATOR_PARAM_DOMAIN_NONE},
      {"Teeth Shift", TYPE_INT, 5,         INDICATOR_PARAM_DOMAIN_NONE},
      {"Lips Period", TYPE_INT, 5,         INDICATOR_PARAM_DOMAIN_NONE},
      {"Lips Shift", TYPE_INT, 3,         INDICATOR_PARAM_DOMAIN_NONE},
      {"Method",      TYPE_INT, MODE_SMMA, INDICATOR_PARAM_DOMAIN_MA_METHOD},
      {"Applied Price",TYPE_INT,PRICE_MEDIAN,INDICATOR_PARAM_DOMAIN_APPLIED_PRICE}
     }
    },
   // IND_BEARS
    {
      IND_BEARS, INDICATOR_GROUP_OSCILLATOR, "Bears Power",
      "13", "Bears Power(13)", 1, 1,
      {{"Period", TYPE_INT, 13, INDICATOR_PARAM_DOMAIN_NONE}}
    },
   // IND_BULLS
    {
      IND_BULLS, INDICATOR_GROUP_OSCILLATOR,"Bulls Power",
      "13", "Bulls Power (13)", 1, 1,
      {{"Period", TYPE_INT, 13, INDICATOR_PARAM_DOMAIN_NONE}}
    },
   // IND_CHAIKIN
    {
      IND_CHAIKIN, INDICATOR_GROUP_OSCILLATOR,"Chaikin Oscillator",
      "3,10,EMA,TICK", "Chaikin Oscillator(3,10,EMA,TICK)", 1, 4,
      {
         {"Fast MA Period",TYPE_INT, 3,         INDICATOR_PARAM_DOMAIN_NONE},
         {"Slow MA Period",TYPE_INT, 10,        INDICATOR_PARAM_DOMAIN_NONE},
         {"Method",        TYPE_INT, MODE_EMA,  INDICATOR_PARAM_DOMAIN_MA_METHOD},
         {"Applied Volume",TYPE_INT, VOLUME_TICK,INDICATOR_PARAM_DOMAIN_APPLIED_VOLUME}
      }
    },

   // --- Volumes
    {
      IND_OBV, INDICATOR_GROUP_VOLUMES, "On Balance Volume","TICK", "On Balance Volume (TICK)", 1, 1,
      {{"Applied Volume", TYPE_INT, VOLUME_TICK, INDICATOR_PARAM_DOMAIN_APPLIED_VOLUME}}
    },
    {
      IND_AD, INDICATOR_GROUP_VOLUMES, "Accumulation/Distribution","TICK", "Accumulation/Distribution (TICK)", 1, 1,
      {{"Applied Volume", TYPE_INT, VOLUME_TICK, INDICATOR_PARAM_DOMAIN_APPLIED_VOLUME}}
    },
    {
      IND_MFI, INDICATOR_GROUP_VOLUMES, "Money Flow Index","14", "Money Flow Index(14)", 1, 1,
      {{"Period", TYPE_INT, 14, INDICATOR_PARAM_DOMAIN_NONE}}
    },
    {
      IND_VOLUMES, INDICATOR_GROUP_VOLUMES, "Volumes","TICK,20,SMA", "Volumes(TICK,20,SMA)", 2, 3,
      {
         {"Applied Volume",TYPE_INT, VOLUME_TICK,INDICATOR_PARAM_DOMAIN_APPLIED_VOLUME},
         {"MA period",     TYPE_INT, 20,         INDICATOR_PARAM_DOMAIN_NONE},
         {"MA method",     TYPE_INT, MODE_SMA,   INDICATOR_PARAM_DOMAIN_MA_METHOD}
      }
    },
    {IND_BWMFI, INDICATOR_GROUP_VOLUMES, "Market Facilitation Index", "", "Market Facilitation Index", 1, 0, {}},
   // --- Arrows
    {IND_FRACTALS, INDICATOR_GROUP_ARROWS, "Fractals", "", "Fractals", 2, 0, {}},      
      
  };
#ifndef CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
#define CINDICATORTEMPLATEMANAGER_MQH_DECLARATION 
 class CIndicatorTemplateManager : public CBaseObj
  {
    private:    
     CListObj           m_list_indicator;          // the templates (CIndicatorSetting), in the order of the table     
     CDatabaseService   *m_CDatabaseService;       // The EA holds it
     //Private Method
     //bool               Open(void);
     
     //bool               MakeTimeframes(void);
     //bool               MakeTemplates(void);
     string             Where(const ENUM_INDICATOR type, const string params_text) const;
     bool               GetFlag(const ENUM_INDICATOR type, const string params_text, const string column) const;
     //Update Database
      //bool               SyncDataToDB(void);
      bool               UpdateDataToDB(void);
      bool               UpdateDataToDB(const ENUM_INDICATOR type, MqlParam &params[], long &insert_id);
      bool               UpdateDataToDB(const ENUM_INDICATOR type, const string params_text);
      bool               UpdateDataToDB(const ENUM_INDICATOR_GROUP group,const string first,const string second,const bool on);
      bool               UpdateDataToDB(const ENUM_INDICATOR type,const string params_text,const string column,const bool on);      
     //bool                 ChangeGroup(const ENUM_INDICATOR_GROUP group, const string first, const string second, const bool on, const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event);       
     //bool               SyncDataFromDB(void);
      bool               ReadDataFromDB(void);      
     //bool               ChangeFlag(const ENUM_INDICATOR type, const string params_text, const string column, const bool on, const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event);
     void               ParamTexts(const ENUM_INDICATOR type, MqlParam &params[], const int decimals, string &out[]) const;
      string             ParamDescription(const MqlParam &param,const string choices,const int decimals) const;
      long               ParamValueByDescription(const string description,const string choices) const;
    public:
                        //CIndicatorTemplateManager(void) : m_db(INVALID_HANDLE),m_CDatabaseService(NULL) { this.m_list.Type(OBJECT_DE_TYPE_INDICATOR_SETTING); }
                        CIndicatorTemplateManager(void) : m_CDatabaseService(NULL) { this.m_list_indicator.Type(OBJECT_DE_TYPE_INDICATOR_SETTING); }
                        //~CIndicatorTemplateManager(void) { if(m_db != INVALID_HANDLE) ::DatabaseClose(m_db); }
                        ~CIndicatorTemplateManager(void) {}
     //--- Lifecycle: create the catalog and template table, then load templates into RAM
        bool                 OnInitEvent(void);
     void                SetDatabaseService    (CDatabaseService   *databaseService)    {this.m_CDatabaseService=databaseService;}
     bool                CompleteVolumesParams(MqlParam &params[]) const;
     bool                UpdateTemplate(const ENUM_INDICATOR type, MqlParam &params[]);
     bool                UpdateTemplate(const ENUM_INDICATOR type, const string params_text);
     bool                UpdateTemplate(const ENUM_INDICATOR_GROUP group,const string first,const string second,const bool on,const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event);
     bool                UpdateTemplate(const ENUM_INDICATOR type,const string params_text,const string column,const bool on,const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event);     
     //Working with DB
     //--Add, Remove a template: written to the database at once, then the event (false if the template exists / does not exist)
      //bool               AddToDB(const ENUM_INDICATOR type, MqlParam &params[]);
      //bool               RemoveFromDB(const ENUM_INDICATOR type, const string params_text);
     //Woring in RAM
      //--- The index of a template in m_list_indicator (WRONG_VALUE: none), the template itself (NULL: none)
       int                IndexSetting(const ENUM_INDICATOR type, const string params_text) const;
       CIndicatorSetting *GetSetting(const ENUM_INDICATOR type, const string params_text) const;
      
   //--- The params of a template as the one text of the table, and back (false when the text does not fit the schema of the type)
     string             ParamsText(const ENUM_INDICATOR type, MqlParam &params[]) const;
     string             StandardIndicatorName(const ENUM_INDICATOR type) const;
     ENUM_INDICATOR_GROUP StandardIndicatorGroup(const ENUM_INDICATOR type) const;
     string             StandardIndicatorGroupName(const ENUM_INDICATOR_GROUP group) const;
     int                StandardIndicatorCatalog(ENUM_INDICATOR &types[],ENUM_INDICATOR_GROUP &groups[],string &names[]) const;
     int                StandardIndicatorBuffers(const ENUM_INDICATOR type) const;
     long               StandardIndicatorParamValue(const string description,const string choices) const;
     string             StandardIndicatorParamDescription(const ENUM_INDICATOR type,const int index,const MqlParam &param) const;
   // Plan to replace GetIndicatorParamSchema() after implemenation CDatabaseService     
     int                GetStandardIndicatorParamSchema(const ENUM_INDICATOR type, SIndicatorParam &out[]) const;     
     bool               ParamsFromText(const ENUM_INDICATOR type, const string text, MqlParam &out_params[]) const;
     bool               ParamsFromTextByStandardSchema(const ENUM_INDICATOR type, const string text, MqlParam &out_params[]) const;
   //--- The short text of the column display of a template: the catalog name and the params, "MA  (14, 0, SMA, Close)"
     string             DisplayLabel(const ENUM_INDICATOR type, const string params_text) const;
   //--- The templates (m_list), in the order of the table (the View sorts them as it likes). params = the saved text, display = the short text the user reads
     int                Templates(long &ids[], ENUM_INDICATOR &types[], string &params[], string &display[], bool &buy[], bool &sell[], bool &sound[], bool &message[], bool &show[]) const;
     int                TemplateIds(long &ids[], ENUM_INDICATOR &types[], string &params[], bool &buy[], bool &sell[]) const;   // the id of every template (the key of its signals), its type and saved params, its Buy / Sell flag
     int                AlertTemplates(long &ids[], string &display[], bool &sound[], bool &message[]) const;   // the templates that have a sound or a message alert on: id, label and the two flags of each. Returns how many
     int                ShownTemplates(long &buy_templates[], long &sell_templates[]) const;   // the templates whose Buy (Sell) signal the user wants: their ids. Returns how many templates there are
   //--- A template is told by its type and the saved text of its params (the column params): the same text Templates() gives
     bool               Exists(const ENUM_INDICATOR type, const string params_text) const;
     bool               Exists(const ENUM_INDICATOR type) const;   // the type has at least one template
   //--- The switch of the tab (the markers of the signals): ON when the Buy or the Sell flag of any template is on. Setting it writes both flags of every template at once
   // Not in here, in View
     bool               ShowGroup(const ENUM_INDICATOR_GROUP group, const bool on);     // show_on_chart of every template of the group (the chart follows each one)
     //bool               SignalGroup(const ENUM_INDICATOR_GROUP group, const bool on);   // buy_signal and sell_signal of every template of the group (one event)
     //bool               AlertGroup(const ENUM_INDICATOR_GROUP group, const bool on);    // sound_alert and message_alert of every template of the group
   //--- The five flags of a template (Buy / Sell signal, sound alert, message alert, shown on the chart): written at once, the event only when the flag changed
     //bool               BuySignal(const ENUM_INDICATOR type, const string params_text, const bool on)    { return this.ChangeFlag(type, params_text, "buy_signal", on, INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED); }
     //bool               SellSignal(const ENUM_INDICATOR type, const string params_text, const bool on)   { return this.ChangeFlag(type, params_text, "sell_signal", on, INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED); }
     //bool               SoundAlert(const ENUM_INDICATOR type, const string params_text, const bool on)   { return this.ChangeFlag(type, params_text, "sound_alert", on, INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT); }
     //bool               MessageAlert(const ENUM_INDICATOR type, const string params_text, const bool on) { return this.ChangeFlag(type, params_text, "message_alert", on, INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT); }
     //bool               ShowOnChart(const ENUM_INDICATOR type, const string params_text, const bool on)  { return this.ChangeFlag(type, params_text, "show_on_chart", on, INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED); }
   
  };
#endif // CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
#ifndef CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
#define CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Lifecycle - same convention as the other managers. EA.mq5 calls   |
 //| this from its own OnInit().                                       |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::OnInitEvent()
  {      
   // New In V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService == NULL)
      {
       ::Print(__FUNCTION__, " > DatabaseService is not set");
       return false;
      }
    else
     {
      string sql_createTimeframe = "CREATE TABLE IF NOT EXISTS timeframes (tf_enum INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL UNIQUE)";
      if(!this.m_CDatabaseService.Create("Common", sql_createTimeframe))
        {
           ::Print(__FUNCTION__, " > DatabaseService can't create table timeframes");
           return false;
        }
       for(int i = 0; i < ArraySize(timeframe_list); i++)
        {
            STimeframeItem row = timeframe_list[i];
            string sql_timeframes = "INSERT OR IGNORE INTO timeframes (tf_enum, name) VALUES (" +
                        (string)(int)row.tf_enum + ", '" +
                        this.m_CDatabaseService.QuoteSQLText(row.name) + "')";

            if(!this.m_CDatabaseService.Create("Common", sql_timeframes))
            {
               ::Print(__FUNCTION__, " > timeframe not written: ", row.name);
               return false;
            }
        } 
      string sql_create_table_indicators = "CREATE TABLE IF NOT EXISTS indicators (""type_enum INTEGER NOT NULL PRIMARY KEY,""type_name TEXT NOT NULL UNIQUE,""name TEXT NOT NULL UNIQUE, ""group_enum INTEGER NOT NULL, ""params TEXT NOT NULL, ""display TEXT NOT NULL, ""buffers INTEGER NOT NULL, ""params_total INTEGER NOT NULL)";
      if(!this.m_CDatabaseService.Create("Common", sql_create_table_indicators))      
       {
           ::Print(__FUNCTION__, " > DatabaseService can't create table indicators");
           return false;
       }
       for(int i = 0; i < ArraySize(standard_indicator_list); i++)
        {
         SIndicatorsRow row = standard_indicator_list[i];

         string type_name = StringSubstr(EnumToString(row.ind_type), 4);
         string sql_standard = "INSERT OR REPLACE INTO indicators "
             "(type_enum, type_name, name, group_enum, params, display, buffers, params_total) VALUES (" +
             (string)(int)row.ind_type + ", '" +
             this.m_CDatabaseService.QuoteSQLText(type_name) + "', '" +
             this.m_CDatabaseService.QuoteSQLText(row.name) + "', " +
             (string)(int)row.group + ", '" +
             this.m_CDatabaseService.QuoteSQLText(row.params) + "', '" +
             this.m_CDatabaseService.QuoteSQLText(row.display) + "', " +
             (string)row.buffers + ", " +
             (string)row.params_total + ")";
         if(!this.m_CDatabaseService.Create("Common", sql_standard))
         {
            ::Print(__FUNCTION__, " > indicator catalog row not written: ", row.name);
            return false;
         }
        }         
      string sql_createIndicatorTemplate = "CREATE TABLE IF NOT EXISTS Setting_IndicatorTemplate (id INTEGER PRIMARY KEY AUTOINCREMENT, "
                                          "type_enum INTEGER NOT NULL, params TEXT NOT NULL, display TEXT NOT NULL, "
                                          "buy_signal INTEGER NOT NULL DEFAULT 1, sell_signal INTEGER NOT NULL DEFAULT 1, "
                                          "sound_alert INTEGER NOT NULL DEFAULT 1, message_alert INTEGER NOT NULL DEFAULT 1, "
                                          "show_on_chart INTEGER NOT NULL DEFAULT 1, UNIQUE (type_enum, params))";
      if(!this.m_CDatabaseService.Create("Common", sql_createIndicatorTemplate))      
       {
           ::Print(__FUNCTION__, " > DatabaseService can't create table Setting_IndicatorTemplate");
           return false;
       }
      if(!this.m_CDatabaseService.Create("Common", sql_createIndicatorTemplate))
       {
         ::Print(__FUNCTION__, " > DatabaseService can't create table Setting_IndicatorTemplate");
         return false;
       }
      if(!this.ReadDataFromDB())
            return false;
     } 
   ::Print(__FUNCTION__, " > CIndicatorTemplateManager complete");
   return true;
  } 
 bool CIndicatorTemplateManager::UpdateDataToDB(void)
  {
   if(this.m_CDatabaseService == NULL)
      return false;

   bool result = true;
   for(int i = 0; i < this.m_list_indicator.Total(); i++)
     {
      CIndicatorSetting *row = this.m_list_indicator.At(i);
      if(row == NULL)
         continue;

      string sql =
         "INSERT INTO Setting_IndicatorTemplate "
         "(id, type_enum, params, display, buy_signal, sell_signal, sound_alert, message_alert, show_on_chart) VALUES (" +
         (string)row.ID() + ", " + (string)(int)row.TypeEnum() + ", '" +
         this.m_CDatabaseService.QuoteSQLText(row.Params()) + "', '" + this.m_CDatabaseService.QuoteSQLText(row.Display()) + "', " +
         (string)(int)row.BuySignal() + ", " + (string)(int)row.SellSignal() + ", " +
         (string)(int)row.SoundAlert() + ", " + (string)(int)row.MessageAlert() + ", " +
         (string)(int)row.ShowOnChart() + ") "
         "ON CONFLICT(type_enum, params) DO UPDATE SET "
         "id=excluded.id, display=excluded.display, buy_signal=excluded.buy_signal, "
         "sell_signal=excluded.sell_signal, sound_alert=excluded.sound_alert, "
         "message_alert=excluded.message_alert, show_on_chart=excluded.show_on_chart";

      if(!this.m_CDatabaseService.Create("Common", sql))
        {
         ::Print(__FUNCTION__, " > template ", row.ID(), " not synced to Common DB");
         result = false;
        }
     }
   return result;
  }
 //+------------------------------------------------------------------+
 //| Open the database once: it stays open while the EA runs, the     |
 //| table is made when it is not there                                |
 //+------------------------------------------------------------------+
   //  bool CIndicatorTemplateManager::Open(void)
   //   {
   //    m_db = LibDatabase_Open(DATABASE_OPEN_READWRITE);
   //    if(m_db == INVALID_HANDLE)
   //     {
   //      ::Print(__FUNCTION__, " > the database ", LIB_DATABASE_FILE, " is not opened, error ", ::GetLastError());
   //      return false;
   //     }
   //    ::DatabaseExecute(m_db, "PRAGMA busy_timeout=5000");
   //    if(!this.MakeTimeframes())
   //       return false;
   //    if(!this.MakeTemplates())
   //       return false;
   //    if(!this.SyncDataFromDB())
   //       return false;
   //    ::Print("Complete ", __FUNCTION__, " > ", LIB_DATABASE_FILE, " opened");
   //    return true;
   //   }
 //+------------------------------------------------------------------+
 //| One row = one indicator template. The key is the type and the     |
 //| params, the text saved (a type with no params has an empty text);  |
 //| display is the short text the user reads. id is a short name of   |
 //| the template for the tables that point to it (the signals of the   |
 //| indicator): AUTOINCREMENT, so it is never given to another template|
 //| after this one is deleted. A table made before the id has it now   |
 //+------------------------------------------------------------------+
   //  bool CIndicatorTemplateManager::MakeTemplates(void)
   //   {
   //    const string columns = "type_enum INTEGER NOT NULL, params TEXT NOT NULL, display TEXT NOT NULL, buy_signal INTEGER NOT NULL DEFAULT 1, "
   //                           "sell_signal INTEGER NOT NULL DEFAULT 1, sound_alert INTEGER NOT NULL DEFAULT 1, message_alert INTEGER NOT NULL DEFAULT 1, "
   //                           "show_on_chart INTEGER NOT NULL DEFAULT 1";
   //    const string create = "CREATE TABLE Setting_IndicatorTemplate (id INTEGER PRIMARY KEY AUTOINCREMENT, " + columns + ", UNIQUE (type_enum, params))";
   //    long exists = 0, has_id = 0;
   //    int request = LibDatabase_Prepare(m_db, "SELECT COUNT(*), COALESCE(SUM(name = 'id'), 0) FROM pragma_table_info('Setting_IndicatorTemplate')");
   //    if(request != INVALID_HANDLE)
   //     {
   //      if(::DatabaseRead(request))
   //       {
   //        ::DatabaseColumnLong(request, 0, exists);
   //        ::DatabaseColumnLong(request, 1, has_id);
   //       }
   //      ::DatabaseFinalize(request);
   //     }
   //    if(exists == 0)
   //     {
   //      if(::DatabaseExecute(m_db, create))
   //         return true;
   //      ::Print(__FUNCTION__, " > the table Setting_IndicatorTemplate is not made, error ", ::GetLastError());
   //      return false;
   //     }
   //    if(has_id != 0)
   //       return true;
   //    //--- The table of a program before the id: the rows go to the new table in the order they were, the old one is dropped
   //    const string names = "type_enum, params, display, buy_signal, sell_signal, sound_alert, message_alert, show_on_chart";
   //    if(!::DatabaseTransactionBegin(m_db))
   //       return false;
   //    if(!::DatabaseExecute(m_db, "ALTER TABLE Setting_IndicatorTemplate RENAME TO Setting_IndicatorTemplate_old") || !::DatabaseExecute(m_db, create) ||
   //       !::DatabaseExecute(m_db, "INSERT INTO Setting_IndicatorTemplate (" + names + ") SELECT " + names + " FROM Setting_IndicatorTemplate_old ORDER BY rowid") ||
   //       !::DatabaseExecute(m_db, "DROP TABLE Setting_IndicatorTemplate_old"))
   //     {
   //      ::Print(__FUNCTION__, " > the table Setting_IndicatorTemplate is not changed to have an id, error ", ::GetLastError());
   //      ::DatabaseTransactionRollback(m_db);
   //      return false;
   //     }
   //    ::DatabaseTransactionCommit(m_db);
   //    return true;
   //   }
 //+------------------------------------------------------------------+
 //| The table timeframes: the 21 timeframes of MT5, fixed, small. The |
 //| key tf_enum keeps them in increasing order of duration; a row     |
 //| already there is left as it is                                    |
 //+------------------------------------------------------------------+
   //  bool CIndicatorTemplateManager::MakeTimeframes(void)
   //   {
   //    if(!::DatabaseExecute(m_db, "CREATE TABLE IF NOT EXISTS timeframes (tf_enum INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL UNIQUE)"))
   //     {
   //      ::Print(__FUNCTION__, " > the table timeframes is not made, error ", ::GetLastError());
   //      return false;
   //     }
   //    for(int i = 0; i < LIB_TIMEFRAMES_TOTAL; i++)
   //       if(!::DatabaseExecute(m_db, "INSERT OR IGNORE INTO timeframes (tf_enum, name) VALUES (" + (string)(int)LIB_TIMEFRAMES[i] + ", '" + ::StringSubstr(::EnumToString(LIB_TIMEFRAMES[i]), 7) + "')"))
   //        {
   //         ::Print(__FUNCTION__, " > ", ::EnumToString(LIB_TIMEFRAMES[i]), " not written, error ", ::GetLastError());
   //         return false;
   //        }
   //    return true;
   //   }
 //+------------------------------------------------------------------+
 //| The chart holds the Volumes alone: its MA period and method are   |
 //| of the row that has the same Applied Volume. False when no row    |
 //| has it (the Add form makes the Volumes with its MA)               |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::CompleteVolumesParams(MqlParam &params[]) const
  {
   long ids[];
   ENUM_INDICATOR types[];
   string texts[], display[];
   bool buy[], sell[], sound[], message[], show[];
   int total = this.Templates(ids, types, texts, display, buy, sell, sound, message, show);
   for(int i = 0; i < total; i++)
    {
     MqlParam row_params[];
     if(types[i] != IND_VOLUMES || !this.ParamsFromText(types[i], texts[i], row_params))
        continue;
     if(::ArraySize(row_params) > 1 && row_params[0].integer_value == params[0].integer_value)
      {
       ::ArrayResize(params, ::ArraySize(row_params));
       for(int p = 1; p < ::ArraySize(row_params); p++)
          params[p] = row_params[p];
       return true;
      }
    }
   return false;
  }
 //--- The WHERE of one template: its type and the text of its params
 string CIndicatorTemplateManager::Where(const ENUM_INDICATOR type, const string params_text) const
  {
   //return "type_enum = " + (string)(int)type + " AND params = '" + LibDatabase_Quoted(params_text) + "'";
   string safe = (this.m_CDatabaseService != NULL) ? this.m_CDatabaseService.QuoteSQLText(params_text) : params_text;
   return "type_enum = " + (string)(int)type + " AND params = '" + safe + "'";
  }
 string CIndicatorTemplateManager::StandardIndicatorName(const ENUM_INDICATOR type) const
  {
   for(int i = 0; i < ArraySize(standard_indicator_list); i++)
      if(standard_indicator_list[i].ind_type == type)
         return standard_indicator_list[i].name;
   return "";
  }
 string CIndicatorTemplateManager::ParamDescription(const MqlParam &param,const string choices,const int decimals) const
  {
   if(choices == PRICE_CHOICES)
      return StringSubstr(EnumToString((ENUM_APPLIED_PRICE)param.integer_value),6);
   if(choices == CALCULATION_METHOD_CHOICES)
      return StringSubstr(EnumToString((ENUM_MA_METHOD)param.integer_value),5);
   if(choices == VOLUME_CHOICES)
      return StringSubstr(EnumToString((ENUM_APPLIED_VOLUME)param.integer_value),7);
   if(choices == STOCH_PRICE_CHOICES)
      return StringSubstr(EnumToString((ENUM_STO_PRICE)param.integer_value),4);
   if(param.type == TYPE_DOUBLE)
      return DoubleToString(param.double_value,decimals);
   return IntegerToString((int)param.integer_value);
  }
 long CIndicatorTemplateManager::ParamValueByDescription(const string description,const string choices) const
  {
   string value=description;
   StringToUpper(value);
   if(choices == PRICE_CHOICES)
      return (value=="OPEN" ? PRICE_OPEN :
              value=="HIGH" ? PRICE_HIGH :
              value=="LOW" ? PRICE_LOW :
              value=="MEDIAN" ? PRICE_MEDIAN :
              value=="TYPICAL" ? PRICE_TYPICAL :
              (value=="WEIGHTED" || value=="WCLOSE") ? PRICE_WEIGHTED : PRICE_CLOSE);
   if(choices == CALCULATION_METHOD_CHOICES)
      return (value=="EMA" ? MODE_EMA :
              value=="SMMA" ? MODE_SMMA :
              value=="LWMA" ? MODE_LWMA : MODE_SMA);
   if(choices == VOLUME_CHOICES)
      return (value=="REAL" ? VOLUME_REAL : VOLUME_TICK);
   if(choices == STOCH_PRICE_CHOICES)
      return ((value=="CLOSECLOSE" || value=="CLOSE/CLOSE") ? STO_CLOSECLOSE : STO_LOWHIGH);
   return (long)StringToInteger(value);
  }
 ENUM_INDICATOR_GROUP CIndicatorTemplateManager::StandardIndicatorGroup(const ENUM_INDICATOR type) const
  {
   for(int i = 0; i < ArraySize(standard_indicator_list); i++)
      if(standard_indicator_list[i].ind_type == type)
         return standard_indicator_list[i].group;
   return INDICATOR_GROUP_ANY;
  }
 string CIndicatorTemplateManager::StandardIndicatorGroupName(const ENUM_INDICATOR_GROUP group) const
  {
   switch(group)
     {
      case INDICATOR_GROUP_TREND:      return "Trend";
      case INDICATOR_GROUP_OSCILLATOR: return "Oscillator";
      case INDICATOR_GROUP_VOLUMES:    return "Volumes";
      case INDICATOR_GROUP_ARROWS:     return "Arrows";
      default:                         return "Other";
     }
  }
 long CIndicatorTemplateManager::StandardIndicatorParamValue(const string description,const string choices) const
  {
   return this.ParamValueByDescription(description,choices);
  }
 int CIndicatorTemplateManager::StandardIndicatorCatalog(ENUM_INDICATOR &types[],ENUM_INDICATOR_GROUP &groups[],string &names[]) const
  {
   int total=::ArraySize(standard_indicator_list);
   if(::ArrayResize(types,total)!=total || ::ArrayResize(groups,total)!=total || ::ArrayResize(names,total)!=total)
     {
      ::Print(__FUNCTION__," > failed to resize output catalog");
      return 0;
     }
   for(int i=0;i<total;i++)
     {
      types[i]=standard_indicator_list[i].ind_type;
      groups[i]=standard_indicator_list[i].group;
      names[i]=standard_indicator_list[i].name;
     }
   return total;
  }
 int CIndicatorTemplateManager::StandardIndicatorBuffers(const ENUM_INDICATOR type) const
  {
   for(int i = 0; i < ArraySize(standard_indicator_list); i++)
      if(standard_indicator_list[i].ind_type == type)
         return standard_indicator_list[i].buffers;
   return 0;
  }
 string CIndicatorTemplateManager::StandardIndicatorParamDescription(const ENUM_INDICATOR type,const int index,const MqlParam &param) const
  {
   SIndicatorParam schema[];
   int total=this.GetStandardIndicatorParamSchema(type,schema);
   if(index<0 || index>=total)
     {
      ::Print(__FUNCTION__," > invalid parameter index ",index," for indicator ",(int)type);
      return "";
     }
   return schema[index].name+": "+this.ParamDescription(param,schema[index].choices,2);
  }
 //+------------------------------------------------------------------+
 //| Every param as text: Applied Price / Method / Volume / Stoch     |
 //| price by description, numbers with `decimals`                     |
 //+------------------------------------------------------------------+
 void CIndicatorTemplateManager::ParamTexts(const ENUM_INDICATOR type, MqlParam &params[], const int decimals, string &out[]) const
  {
   SIndicatorParam schema[];
   this.GetStandardIndicatorParamSchema(type, schema);
   int total = ::ArraySize(params);
   ::ArrayResize(out, total);
   for(int p = 0; p < total; p++)
     out[p] = this.ParamDescription(params[p], (p < ::ArraySize(schema)) ? schema[p].choices : "", decimals);
  }
 //+------------------------------------------------------------------+
 //| The params as the one text of the table: a number stays bare,    |
 //| anything else (Applied Price, Method...) is quoted               |
 //+------------------------------------------------------------------+
 string CIndicatorTemplateManager::ParamsText(const ENUM_INDICATOR type, MqlParam &params[]) const
  {
   string params_text[];
   this.ParamTexts(type, params, 8, params_text);
   string result = "";
   for(int p = 0; p < ::ArraySize(params_text); p++)
    {
     if(p > 0)
        result += ", ";
     string raw = params_text[p];
     bool is_number = (::StringLen(raw) > 0);
     for(int c = 0; c < ::StringLen(raw) && is_number; c++)
      {
       ushort ch = ::StringGetCharacter(raw, c);
       is_number = ((ch >= '0' && ch <= '9') || ch == '-' || ch == '+' || ch == '.' || ch == 'e' || ch == 'E');
      }
     result += is_number ? raw : ("\"" + raw + "\"");
    }
   return result;
  }
 //+------------------------------------------------------------------+
 //| The text of the table back to the params of the type: split at   |
 //| the commas, the quotes taken off, every value read by the schema |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::ParamsFromText(const ENUM_INDICATOR type, const string text, MqlParam &out_params[]) const
  {
   SIndicatorParam schema[];
   int schema_total = this.GetStandardIndicatorParamSchema(type, schema);
   string params_text[];
   int found = (text == "") ? 0 : ::StringSplit(text, ',', params_text);
   if(found < schema_total)   // a type without parameters (AO, AC, BW MFI, Fractals) has none to read
      return false;
   ::ArrayResize(out_params, schema_total);
   for(int p = 0; p < schema_total; p++)
    {
     out_params[p].type = schema[p].data_type;
     string raw = params_text[p];
     ::StringTrimLeft(raw);
     ::StringTrimRight(raw);
     ::StringReplace(raw, "\"", "");
     if(schema[p].choices != "")
      {
       if(schema[p].choices == PRICE_CHOICES)
          out_params[p].integer_value = this.ParamValueByDescription(raw,schema[p].choices);
       else if(schema[p].choices == CALCULATION_METHOD_CHOICES)
          out_params[p].integer_value = this.ParamValueByDescription(raw,schema[p].choices);
       else if(schema[p].choices == VOLUME_CHOICES)
          out_params[p].integer_value = this.ParamValueByDescription(raw,schema[p].choices);
       else if(schema[p].choices == STOCH_PRICE_CHOICES)
          out_params[p].integer_value = this.ParamValueByDescription(raw,schema[p].choices);
       else
          out_params[p].integer_value = (long)::StringToInteger(raw);
      }
     else if(schema[p].data_type == TYPE_DOUBLE)
        out_params[p].double_value = ::StringToDouble(raw);
     else
        out_params[p].integer_value = ::StringToInteger(raw);
    }
   return true;
  }
 string CIndicatorTemplateManager::DisplayLabel(const ENUM_INDICATOR type, const string params_text) const
  {
   string name = this.StandardIndicatorName(type);
   MqlParam params[];
   string values[];
   string joined = "";
   if(this.ParamsFromText(type, params_text, params))
    {
     this.ParamTexts(type, params, 2, values);
     for(int i = 0; i < ::ArraySize(values); i++)
        joined += (i > 0 ? ", " : "") + values[i];
    }
   return name + (joined != "" ? "  (" + joined + ")" : "");
  }
 //+------------------------------------------------------------------+
 //| The rows of the table to m_list, in the order of the table: once, |
 //| the table is not asked again                                      |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::ReadDataFromDB(void)
  {
   this.m_list_indicator.Clear();   
   // New In V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService == NULL)
      return false;
   SIndicatorTemplateRow rows[];
   string sql = "SELECT id, type_enum, params, display, buy_signal, sell_signal, sound_alert, message_alert, show_on_chart "
                "FROM Setting_IndicatorTemplate ORDER BY rowid";
   if(!this.m_CDatabaseService.Read("Common", sql, rows))
      return false;
   for(int i = 0; i < ::ArraySize(rows); i++)
    {
      CIndicatorSetting *row = new CIndicatorSetting(rows[i].id, (ENUM_INDICATOR)(int)rows[i].type_enum, rows[i].params, rows[i].display);
      if(row == NULL)
         continue;
      row.BuySignal(rows[i].buy_signal != 0, false);
      row.SellSignal(rows[i].sell_signal != 0, false);
      row.SoundAlert(rows[i].sound_alert != 0);
      row.MessageAlert(rows[i].message_alert != 0);
      row.ShowOnChart(rows[i].show_on_chart != 0, false);
      if(!this.m_list_indicator.Add(row))
         delete row;
    }
   ::Print("Complete ", __FUNCTION__, " > ", this.m_list_indicator.Total(), " templates of Setting_IndicatorTemplate read to RAM");
   return true;
  }
 int CIndicatorTemplateManager::IndexSetting(const ENUM_INDICATOR type, const string params_text) const
  {
   for(int i = 0; i < this.m_list_indicator.Total(); i++)
    {
     CIndicatorSetting *row = this.m_list_indicator.At(i);
     if(row != NULL && row.TypeEnum() == type && row.Params() == params_text)
        return i;
    }
   return WRONG_VALUE;
  }
 CIndicatorSetting *CIndicatorTemplateManager::GetSetting(const ENUM_INDICATOR type, const string params_text) const
  {
   int index = this.IndexSetting(type, params_text);
   return (index > WRONG_VALUE ? this.m_list_indicator.At(index) : NULL);
  }
 //+------------------------------------------------------------------+
 //| The templates in the order of the table: how to show them is the  |
 //| business of the View                                              |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::Templates(long &ids[], ENUM_INDICATOR &types[], string &params[], string &display[], bool &buy[], bool &sell[], bool &sound[], bool &message[], bool &show[]) const
  {
   int total = this.m_list_indicator.Total();
   ::ArrayResize(ids, total);
   ::ArrayResize(types, total);
   ::ArrayResize(params, total);
   ::ArrayResize(display, total);
   ::ArrayResize(buy, total);
   ::ArrayResize(sell, total);
   ::ArrayResize(sound, total);
   ::ArrayResize(message, total);
   ::ArrayResize(show, total);
   for(int i = 0; i < total; i++)
    {
     CIndicatorSetting *row = this.m_list_indicator.At(i);
     ids[i]     = row.ID();
     types[i]   = row.TypeEnum();
     params[i]  = row.Params();
     display[i] = row.Display();
     buy[i]     = row.BuySignal();
     sell[i]    = row.SellSignal();
     sound[i]   = row.SoundAlert();
     message[i] = row.MessageAlert();
     show[i]    = row.ShowOnChart();
    }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The id of every template (the key of its signals in               |
 //| IndicatorSignalSeries) with its Buy and Sell flag                 |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::TemplateIds(long &ids[], ENUM_INDICATOR &types[], string &params[], bool &buy[], bool &sell[]) const
  {
   int total = this.m_list_indicator.Total();
   ::ArrayResize(ids, total);
   ::ArrayResize(types, total);
   ::ArrayResize(params, total);
   ::ArrayResize(buy, total);
   ::ArrayResize(sell, total);
   for(int i = 0; i < total; i++)
    {
     CIndicatorSetting *row = this.m_list_indicator.At(i);
     ids[i]    = row.ID();
     types[i]  = row.TypeEnum();
     params[i] = row.Params();
     buy[i]    = row.BuySignal();
     sell[i]   = row.SellSignal();
    }
   return total;
  }
 bool CIndicatorTemplateManager::Exists(const ENUM_INDICATOR type, const string params_text) const
  {
   return (this.IndexSetting(type, params_text) > WRONG_VALUE);
  }
 bool CIndicatorTemplateManager::Exists(const ENUM_INDICATOR type) const
  {
   for(int i = 0; i < this.m_list_indicator.Total(); i++)
    {
     CIndicatorSetting *row = this.m_list_indicator.At(i);
     if(row != NULL && row.TypeEnum() == type)
        return true;
    }
   return false;
  }
 //+------------------------------------------------------------------+
 //| Two flags of every template of a group at once; the event says     |
 //| several templates changed (lparam = WRONG_VALUE, dparam = group)   |
 //+------------------------------------------------------------------+
 // New In V4 after implemenation CDatabaseService
 //bool CIndicatorTemplateManager::ChangeGroup(const ENUM_INDICATOR_GROUP group, const string first, const string second, const bool on, const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event)
 bool CIndicatorTemplateManager::UpdateDataToDB(const ENUM_INDICATOR_GROUP group,const string first,const string second,const bool on)
  {    
   if(this.m_CDatabaseService == NULL)
     {
      ::Print(__FUNCTION__, " > DatabaseService is not set");
      return false;
     }
   string in_group = "";
   for(int i = 0; i < this.m_list_indicator.Total(); i++)
     {
      CIndicatorSetting *row = this.m_list_indicator.At(i);
      if(row != NULL && this.StandardIndicatorGroup(row.TypeEnum()) == group)
         in_group += (in_group == "" ? "" : ",") + (string)row.ID();
     }
   if(in_group == "")
      return true;
   string sql_update_group = "UPDATE Setting_IndicatorTemplate SET " +
                first + " = " + (on ? "1" : "0") + ", " +
                second + " = " + (on ? "1" : "0") +
                " WHERE id IN (" + in_group + ")";               
   return this.m_CDatabaseService.Update("Common", sql_update_group);    
  }
 bool CIndicatorTemplateManager::UpdateTemplate(const ENUM_INDICATOR_GROUP group,const string first,const string second,const bool on,const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event)
  {
   bool signal_pair = (first == "buy_signal" && second == "sell_signal");
   bool alert_pair  = (first == "sound_alert" && second == "message_alert");
   if(!signal_pair && !alert_pair)
     {
      ::Print(__FUNCTION__, " > rejected: invalid column pair");
      return false;
     }
   if(!this.UpdateDataToDB(group, first, second, on))
      return false;
   bool has_rows = false;
   for(int i = 0; i < this.m_list_indicator.Total(); i++)
     {
      CIndicatorSetting *row = this.m_list_indicator.At(i);
      if(row == NULL || this.StandardIndicatorGroup(row.TypeEnum()) != group)
         continue;

      has_rows = true;
      if(signal_pair)
        {
         row.BuySignal(on, false);
         row.SellSignal(on, false);
        }
      else
        {
         row.SoundAlert(on);
         row.MessageAlert(on);
        }
     }

   if(has_rows && event != INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT)
      ::EventChartCustom(::ChartID(), (ushort)event, (long)WRONG_VALUE, (double)(int)group, "");
   return true;

  }
 bool CIndicatorTemplateManager::UpdateDataToDB(const ENUM_INDICATOR type,MqlParam &params[],long &insert_id)
  {
   insert_id = 0;
   if(this.m_CDatabaseService == NULL)
     {
      ::Print(__FUNCTION__, " > DatabaseService is not set");
      return false;
     }

   string name = this.StandardIndicatorName(type);
   if(type == IND_CUSTOM || name == "")
     {
      ::Print(__FUNCTION__, " > rejected: indicator is not in the standard catalog");
      return false;
     }

   SIndicatorParam schema[];
   int schema_total = this.GetStandardIndicatorParamSchema(type, schema);
   if(::ArraySize(params) != schema_total)
     {
      ::Print(__FUNCTION__, " > rejected: invalid parameter count for ", name);
      return false;
     }

   string text = this.ParamsText(type, params);
   string display = this.DisplayLabel(type, text);
   string sql =
      "INSERT INTO Setting_IndicatorTemplate (type_enum, params, display) VALUES (" +
      (string)(int)type + ", '" +
      this.m_CDatabaseService.QuoteSQLText(text) + "', '" +
      this.m_CDatabaseService.QuoteSQLText(display) + "')";

   if(!this.m_CDatabaseService.Create("Common", sql, insert_id))
     {
      ::Print(__FUNCTION__, " > ", name, " (", text, ") not written");
      return false;
     }
   return true;
  }

 bool CIndicatorTemplateManager::UpdateDataToDB(const ENUM_INDICATOR type,const string params_text)
  {
   if(this.m_CDatabaseService == NULL)
     {
      ::Print(__FUNCTION__, " > DatabaseService is not set");
      return false;
     }

   string sql = "DELETE FROM Setting_IndicatorTemplate WHERE " +
                this.Where(type, params_text);
   if(!this.m_CDatabaseService.Delete("Common", sql))
     {
      ::Print(__FUNCTION__, " > ", this.StandardIndicatorName(type),
              " (", params_text, ") not removed");
      return false;
     }
   return true;
  }

 bool CIndicatorTemplateManager::UpdateTemplate(const ENUM_INDICATOR type,MqlParam &params[])
  {
   string text = this.ParamsText(type, params);
   if(this.Exists(type, text))
     {
      ::Print(__FUNCTION__, " > rejected: template already exists");
      return false;
     }

   string name = this.StandardIndicatorName(type);
   if(name == "" || type == IND_CUSTOM)
      return false;

   long id = 0;
   if(!this.UpdateDataToDB(type, params, id))
      return false;

   CIndicatorSetting *row =
      new CIndicatorSetting(id, type, text, this.DisplayLabel(type, text));
   if(row == NULL || !this.m_list_indicator.Add(row))
     {
      delete row;
      if(!this.UpdateDataToDB(type, text))
         ::Print(__FUNCTION__, " > failed to roll back DB insert for ", name, " (", text, ")");
      return false;
     }

   ::EventChartCustom(::ChartID(),
                      (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED,
                      (long)type, 0.0, text);
   return true;
  }

 bool CIndicatorTemplateManager::UpdateTemplate(const ENUM_INDICATOR type,const string params_text)
  {
   int index = this.IndexSetting(type, params_text);
   CIndicatorSetting *row =
      (index > WRONG_VALUE ? this.m_list_indicator.At(index) : NULL);
   if(row == NULL)
     {
      ::Print(__FUNCTION__, " > rejected: no row for this identity");
      return false;
     }

   long template_id = row.ID();
   if(!this.UpdateDataToDB(type, params_text))
      return false;

   if(!this.m_list_indicator.Delete(index))
     {
      ::Print(__FUNCTION__, " > DB row removed but RAM row could not be deleted: ",
              this.StandardIndicatorName(type), " (", params_text, ")");
      return false;
     }

   ::EventChartCustom(::ChartID(),
                      (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE,
                      (long)type, (double)template_id, params_text);
   return true;
  }
 bool CIndicatorTemplateManager::ShowGroup(const ENUM_INDICATOR_GROUP group, const bool on)
  {
   long ids[];
   ENUM_INDICATOR types[];
   string params[], display[];
   bool buy[], sell[], sound[], message[], show[];
   int total = this.Templates(ids, types, params, display, buy, sell, sound, message, show);
   bool done = true;
   for(int i = 0; i < total; i++)
      if(this.StandardIndicatorGroup(types[i]) == group)
         //done = (this.ShowOnChart(types[i], params[i], on) && done);   // a template at a time: the chart follows the event of each
      done = (this.UpdateTemplate(types[i], params[i], "show_on_chart", on,INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED) && done);
   return done;
  }
//  bool CIndicatorTemplateManager::SignalGroup(const ENUM_INDICATOR_GROUP group, const bool on)
//   {
//    return this.UpdateDataToDB(group, "buy_signal", "sell_signal", on, INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED);
//   }
//  bool CIndicatorTemplateManager::AlertGroup(const ENUM_INDICATOR_GROUP group, const bool on)
//   {
//    return this.UpdateDataToDB(group, "sound_alert", "message_alert", on, INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT);
//   }
 bool CIndicatorTemplateManager::GetFlag(const ENUM_INDICATOR type, const string params_text, const string column) const
  {
   CIndicatorSetting *row = this.GetSetting(type, params_text);
   if(row == NULL)
      return false;
   if(column == "buy_signal")
      return row.BuySignal();
   if(column == "sell_signal")
      return row.SellSignal();
   if(column == "sound_alert")
      return row.SoundAlert();
   if(column == "message_alert")
      return row.MessageAlert();
   return row.ShowOnChart();
  }
 //+------------------------------------------------------------------+
 //| Persist one flag of one template                                 |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::UpdateDataToDB(const ENUM_INDICATOR type,const string params_text,const string column,const bool on)
  {
   bool valid_column = (column == "buy_signal" || column == "sell_signal" ||
                        column == "sound_alert" || column == "message_alert" ||
                        column == "show_on_chart");
   if(!valid_column)
     {
      ::Print(__FUNCTION__, " > rejected: invalid column ", column);
      return false;
     }
   if(this.m_CDatabaseService == NULL)
     {
      ::Print(__FUNCTION__, " > DatabaseService is not set");
      return false;
     }
   CIndicatorSetting *row = this.GetSetting(type, params_text);
   if(row == NULL)
     {
      ::Print(__FUNCTION__, " > rejected: no template for type ", EnumToString(type), " (", params_text, ")");
      return false;
     }
   if(this.GetFlag(type, params_text, column) == on)
      return true;

   string sql = "UPDATE Setting_IndicatorTemplate SET " + column + " = " +
                (on ? "1" : "0") + " WHERE id = " + (string)row.ID();
   return this.m_CDatabaseService.Update("Common", sql);
  }
 //+------------------------------------------------------------------+
 //| Change one flag of one template: persist, update RAM, then notify |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::UpdateTemplate(const ENUM_INDICATOR type,const string params_text,const string column,const bool on,const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event)
  {
   bool signal_flag = (column == "buy_signal" || column == "sell_signal");
   bool alert_flag  = (column == "sound_alert" || column == "message_alert");
   bool show_flag   = (column == "show_on_chart");
   if(!signal_flag && !alert_flag && !show_flag)
     {
      ::Print(__FUNCTION__, " > rejected: invalid column ", column);
      return false;
     }
   bool valid_event = (event == INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT) ||
                      (signal_flag && event == INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED) ||
                      (show_flag && event == INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED);
   if(!valid_event)
     {
      ::Print(__FUNCTION__, " > rejected: event does not match column ", column);
      return false;
     }
   CIndicatorSetting *row = this.GetSetting(type, params_text);
   if(row == NULL)
     {
      ::Print(__FUNCTION__, " > rejected: no template for type ", EnumToString(type), " (", params_text, ")");
      return false;
     }
   if(!this.UpdateDataToDB(type, params_text, column, on))
      return false;

   bool notify = (event != INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT);
   if(column == "buy_signal")
      row.BuySignal(on, notify);
   else if(column == "sell_signal")
      row.SellSignal(on, notify);
   else if(column == "sound_alert")
      row.SoundAlert(on);
   else if(column == "message_alert")
      row.MessageAlert(on);
   else
      row.ShowOnChart(on, notify);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Add a template: the table and m_list at once (the id the table    |
 //| gives it), then the event. False when it exists or the type is    |
 //| not in the catalog                                                 |
 //+------------------------------------------------------------------+
   //  bool CIndicatorTemplateManager::AddToDB(const ENUM_INDICATOR type, MqlParam &params[])
   //   {
   //    string text = this.ParamsText(type, params);
   //    string name = this.StandardIndicatorName(type);
   //    //if(m_db == INVALID_HANDLE || type == IND_CUSTOM || name == "" || this.Exists(type, text))
   //    if(this.m_CDatabaseService == NULL || type == IND_CUSTOM || name == "" || this.Exists(type, text))
   //       return false;
   //    SIndicatorParam schema[];
   //    const int schema_total = this.GetStandardIndicatorParamSchema(type, schema);
   //    if(::ArraySize(params) != schema_total)
   //     {
   //      ::Print(__FUNCTION__, " > ", name, " (", text, ") not written: ", ::ArraySize(params), " params, the schema has ", schema_total);
   //      return false;
   //     }
   //    string display = this.DisplayLabel(type, text);
      
   //    // if(!::DatabaseExecute(m_db, "INSERT INTO Setting_IndicatorTemplate (type_enum, params, display) VALUES (" + (string)(int)type + ", '" + LibDatabase_Quoted(text) + "', '" +
   //    //                             LibDatabase_Quoted(display) + "')"))
   //    //  {
   //    //   ::Print(__FUNCTION__, " > ", GetIndicatorNameForType(type), " (", text, ") not written, error ", ::GetLastError());
   //    //   return false;
   //    //  }
   //    string sql = "INSERT INTO Setting_IndicatorTemplate (type_enum, params, display) VALUES (" + 
   //                (string)(int)type + ", '" + 
   //                this.m_CDatabaseService.QuoteSQLText(text) + "', '" +
   //                this.m_CDatabaseService.QuoteSQLText(display) + "')";
   //    long id = 0;
   //    //int request = LibDatabase_Prepare(m_db, "SELECT id FROM Setting_IndicatorTemplate WHERE " + this.Where(type, text));
   //    // if(request != INVALID_HANDLE)
   //    //   {
   //    //    if(::DatabaseRead(request))
   //    //       ::DatabaseColumnLong(request, 0, id);
   //    //    ::DatabaseFinalize(request);
   //    //   }
   //    if(!this.m_CDatabaseService.Create("Common", sql, id))
   //     {
   //      ::Print(__FUNCTION__, " > ", name, " (", text, ") not written");
   //      return false;
   //     }
   //    CIndicatorSetting *row = new CIndicatorSetting(id, type, text, display);
   //    if(row == NULL || !this.m_list_indicator.Add(row))
   //      {
   //       delete row;
   //       return false;
   //      }
   //    // --- Identity (type via lparam, params via sparam), NOT a position - EventChartCustom is queued/async, a position captured now can go stale
   //    ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED, (long)type, 0.0, text);
   //    return true;
   //   }
   //+------------------------------------------------------------------+
   //| Remove a template: the table and m_list at once, then the event   |
   //+------------------------------------------------------------------+
   //  bool CIndicatorTemplateManager::RemoveFromDB(const ENUM_INDICATOR type, const string params_text)
   //   {
   //    int index = this.IndexSetting(type, params_text);
   //    CIndicatorSetting *row = (index > WRONG_VALUE ? this.m_list_indicator.At(index) : NULL);
   //    // if(m_db == INVALID_HANDLE || row == NULL)
   //    if(this.m_CDatabaseService == NULL || row == NULL)
   //     {
   //      ::Print(__FUNCTION__, " > rejected: no row for this identity");
   //      return false;
   //     }      
   //    //--- The id of the template (the key of its signals): the event carries it (dparam)
   //    long template_id = row.ID();
   //    //if(!::DatabaseExecute(m_db, "DELETE FROM Setting_IndicatorTemplate WHERE id = " + (string)template_id))
   //    string sql = "DELETE FROM Setting_IndicatorTemplate WHERE id = " + (string)template_id;
   //    if(!this.m_CDatabaseService.Delete("Common", sql))
   //     {
   //      ::Print(__FUNCTION__, " > ", this.StandardIndicatorName(type), " (", params_text, ") not removed, error ", ::GetLastError());
   //      return false;
   //     }
   //    this.m_list_indicator.Delete(index);
   //    ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE, (long)type, (double)template_id, params_text);
   //    return true;
   //   }
 
 //+------------------------------------------------------------------+
 //| The templates whose signal the user shows (the markers and the    |
 //| window of a candle show the same)                                 |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::ShownTemplates(long &buy_templates[], long &sell_templates[]) const
  {
   ::ArrayResize(buy_templates, 0);
   ::ArrayResize(sell_templates, 0);
   long ids[];
   ENUM_INDICATOR types[];
   string params[];
   bool buy[], sell[];
   int total = this.TemplateIds(ids, types, params, buy, sell);
   for(int i = 0; i < total; i++)
     {
      if(buy[i])
        {
         ::ArrayResize(buy_templates, ::ArraySize(buy_templates) + 1);
         buy_templates[::ArraySize(buy_templates) - 1] = ids[i];
        }
      if(sell[i])
        {
         ::ArrayResize(sell_templates, ::ArraySize(sell_templates) + 1);
         sell_templates[::ArraySize(sell_templates) - 1] = ids[i];
        }
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The templates that have an alert on (the alert is the one of the  |
 //| signal of the template: the indicator itself has only values)     |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::AlertTemplates(long &ids[], string &display[], bool &sound[], bool &message[]) const
  {
   ::ArrayResize(ids, 0);
   ::ArrayResize(display, 0);
   ::ArrayResize(sound, 0);
   ::ArrayResize(message, 0);
   long all_ids[];
   ENUM_INDICATOR types[];
   string params[], all_display[];
   bool buy[], sell[], all_sound[], all_message[], show[];
   int total = this.Templates(all_ids, types, params, all_display, buy, sell, all_sound, all_message, show);
   for(int i = 0; i < total; i++)
     {
      if(!all_sound[i] && !all_message[i])
         continue;
      int n = ::ArraySize(ids);
      ::ArrayResize(ids, n + 1);
      ::ArrayResize(display, n + 1);
      ::ArrayResize(sound, n + 1);
      ::ArrayResize(message, n + 1);
      ids[n] = all_ids[i];
      display[n] = all_display[i];
      sound[n] = all_sound[i];
      message[n] = all_message[i];
     }
   return ::ArraySize(ids);
  }
 // Plan to replace GetIndicatorParamSchema after implemenation CDatabaseService 
   //  int CIndicatorTemplateManager::GetStandardIndicatorParamSchema(const ENUM_INDICATOR type, SIndicatorParam &out[])
   //   {
   //     ArrayResize(out, INDICATOR_PARAM_SLOTS_MAX);
   //     for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
   //       {
   //         out[i].name = "";
   //         out[i].data_type = TYPE_DOUBLE;
   //         out[i].default_value = "";
   //         out[i].choices = "";
   //       }
   //     // --- I = plain numeric field (text edit box). E = enum field (combo box;
   //     // --- dv is the DEFAULT SELECTED ROW in ch, purely a UI preselect concern -
   //     // --- unrelated to what value actually gets stored, see the note above
   //     // --- SIndicatorParam for how enum-choice values are resolved).
   //       #define I(idx,nm,tp,dv)     out[idx].name=nm; out[idx].data_type=tp;      out[idx].default_value=dv;
   //       #define E(idx,nm,dv,ch)     out[idx].name=nm; out[idx].data_type=TYPE_INT; out[idx].default_value=dv; out[idx].choices=ch;
   //       switch(type)
   //       {
   //         // --- Trend ---------------------------------------------------------
   //         case IND_SAR:
   //           I(0,"Step",TYPE_DOUBLE,"0.02") I(1,"Maximum",TYPE_DOUBLE,"0.2")
   //           return 2;
   //         case IND_MA:
   //           I(0,"Period",TYPE_INT,"14") I(1,"Shift",TYPE_INT,"0")
   //           E(2,"Method","1",CALCULATION_METHOD_CHOICES) E(3,"Applied Price","0",PRICE_CHOICES)
   //           return 4;
   //         case IND_BANDS:
   //           I(0,"Period",TYPE_INT,"20") I(1,"Shift",TYPE_INT,"0")
   //           I(2,"Deviation",TYPE_DOUBLE,"2.0")
   //           E(3,"Applied Price","0",PRICE_CHOICES)
   //           return 4;
   //         case IND_ALLIGATOR:
   //           I(0,"Jaw Period",TYPE_INT,"13")  I(1,"Jaw Shift",TYPE_INT,"8")
   //           I(2,"Teeth Period",TYPE_INT,"8") I(3,"Teeth Shift",TYPE_INT,"5")
   //           I(4,"Lips Period",TYPE_INT,"5")  I(5,"Lips Shift",TYPE_INT,"3")
   //           E(6,"Method","2",CALCULATION_METHOD_CHOICES) E(7,"Applied Price","4",PRICE_CHOICES)
   //           return 8;
   //         case IND_ICHIMOKU:
   //           I(0,"Tenkan-sen",TYPE_INT,"9") I(1,"Kijun-sen",TYPE_INT,"26")
   //           I(2,"Senkou Span B",TYPE_INT,"52")
   //           return 3;
   //         case IND_ENVELOPES:
   //           I(0,"Period",TYPE_INT,"14") I(1,"Shift",TYPE_INT,"0")
   //           E(2,"Method","0",CALCULATION_METHOD_CHOICES) E(3,"Applied Price","0",PRICE_CHOICES)
   //           I(4,"Deviation %",TYPE_DOUBLE,"0.1")
   //           return 5;
   //         case IND_FRAMA:
   //           I(0,"Period",TYPE_INT,"14") 
   //           I(1,"Shift",TYPE_INT,"0")
   //           E(2,"Applied Price","0",PRICE_CHOICES)
   //           return 3;
   //         case IND_AMA:
   //           I(0,"AMA Period",TYPE_INT,"9") 
   //           I(1,"Fast EMA Period",TYPE_INT,"2")
   //           I(2,"Slow EMA Period",TYPE_INT,"30") 
   //           I(3,"Shift",TYPE_INT,"0")
   //           E(4,"Applied Price","0",PRICE_CHOICES)
   //           return 5;
   //         case IND_DEMA:
   //           I(0,"Period",TYPE_INT,"14") I(1,"Shift",TYPE_INT,"0")
   //           E(2,"Applied Price","0",PRICE_CHOICES)
   //           return 3;
   //         case IND_TEMA:
   //           I(0,"Period",TYPE_INT,"14") I(1,"Shift",TYPE_INT,"0")
   //           E(2,"Applied Price","0",PRICE_CHOICES)
   //           return 3;
   //         case IND_VIDYA:
   //           I(0,"CMO Period",TYPE_INT,"9") I(1,"EMA Period",TYPE_INT,"12")
   //           I(2,"Shift",TYPE_INT,"0") E(3,"Applied Price","0",PRICE_CHOICES)
   //           return 4;
   //         case IND_ADX:
   //           I(0,"Period",TYPE_INT,"14")
   //           return 1;
   //         case IND_ADXW:
   //           I(0,"Period",TYPE_INT,"14")
   //           return 1;
   //         case IND_STDDEV:
   //           I(0,"Period",TYPE_INT,"20") 
   //           I(1,"Shift",TYPE_INT,"0")
   //           E(2,"Method","0",CALCULATION_METHOD_CHOICES) 
   //           E(3,"Applied Price","0",PRICE_CHOICES)
   //           return 4;
   //         // --- Oscillator ------------------------------------------------------
   //         case IND_RSI:
   //           I(0,"Period",TYPE_INT,"14") E(1,"Applied Price","0",PRICE_CHOICES)
   //           return 2;
   //         case IND_MACD:
   //           I(0,"Fast EMA Period",TYPE_INT,"12") I(1,"Slow EMA Period",TYPE_INT,"26")
   //           I(2,"Signal Period",TYPE_INT,"9") E(3,"Applied Price","0",PRICE_CHOICES)
   //           return 4;
   //         case IND_STOCHASTIC:
   //           I(0,"%K Period",TYPE_INT,"5") 
   //           I(1,"%D Period",TYPE_INT,"3")
   //           I(2,"Slowing",TYPE_INT,"3") 
   //           E(3,"Method","0",CALCULATION_METHOD_CHOICES)
   //           E(4,"Price Field","0",STOCH_PRICE_CHOICES)
   //           return 5;
   //         case IND_CCI:
   //           I(0,"Period",TYPE_INT,"14") 
   //           E(1,"Applied Price","5",PRICE_CHOICES)
   //           return 2;
   //         case IND_MOMENTUM:
   //           I(0,"Period",TYPE_INT,"14") 
   //           E(1,"Applied Price","0",PRICE_CHOICES)
   //           return 2;
   //         case IND_DEMARKER:
   //           I(0,"Period",TYPE_INT,"14")
   //           return 1;
   //         case IND_RVI:
   //           I(0,"Period",TYPE_INT,"10")
   //           return 1;
   //         case IND_WPR:
   //           I(0,"Period",TYPE_INT,"14")
   //           return 1;
   //         case IND_OSMA:
   //           I(0,"Fast EMA Period",TYPE_INT,"12") 
   //           I(1,"Slow EMA Period",TYPE_INT,"26")
   //           I(2,"Signal Period",TYPE_INT,"9") 
   //           E(3,"Applied Price","0",PRICE_CHOICES)
   //           return 4;
   //         case IND_TRIX:
   //           I(0,"Period",TYPE_INT,"14")
   //           return 1;
   //         case IND_ATR:
   //           I(0,"Period",TYPE_INT,"14")
   //           return 1;
   //         case IND_FORCE:
   //           I(0,"Period",TYPE_INT,"13") 
   //           E(1,"Method","1",CALCULATION_METHOD_CHOICES)
   //           E(2,"Applied Volume","0",VOLUME_CHOICES)
   //           return 3;
   //         case IND_AO:
   //           return 0;
   //         case IND_AC:
   //           return 0;
   //         case IND_GATOR:
   //           I(0,"Jaw Period",TYPE_INT,"13")  
   //           I(1,"Jaw Shift",TYPE_INT,"8")
   //           I(2,"Teeth Period",TYPE_INT,"8") 
   //           I(3,"Teeth Shift",TYPE_INT,"5")
   //           I(4,"Lips Period",TYPE_INT,"5")  
   //           I(5,"Lips Shift",TYPE_INT,"3")
   //           E(6,"Method","2",CALCULATION_METHOD_CHOICES) 
   //           E(7,"Applied Price","4",PRICE_CHOICES)
   //           return 8;
   //         case IND_BEARS:
   //           I(0,"Period",TYPE_INT,"13")
   //           return 1;
   //         case IND_BULLS:
   //           I(0,"Period",TYPE_INT,"13")
   //           return 1;
   //         case IND_CHAIKIN:
   //           I(0,"Fast MA Period",TYPE_INT,"3") 
   //           I(1,"Slow MA Period",TYPE_INT,"10")
   //           E(2,"Method","1",CALCULATION_METHOD_CHOICES) 
   //           E(3,"Applied Volume","0",VOLUME_CHOICES)
   //           return 4;

   //         // --- Volumes ---------------------------------------------------------
   //         case IND_OBV:
   //           E(0,"Applied Volume","0",VOLUME_CHOICES)
   //           return 1;
   //         case IND_AD:
   //           E(0,"Applied Volume","0",VOLUME_CHOICES)
   //           return 1;
   //         case IND_MFI:
   //           I(0,"Period",TYPE_INT,"14")
   //           return 1;
   //         case IND_VOLUMES:
   //           E(0,"Applied Volume","0",VOLUME_CHOICES)
   //           I(1,"MA period",TYPE_INT,"20")   // the moving average drawn with it, and the signal is the volume against it
   //           E(2,"MA method","0",CALCULATION_METHOD_CHOICES)
   //           return 3;
   //         case IND_BWMFI:
   //           return 0;

   //         // --- Arrows ----------------------------------------------------------
   //         case IND_FRACTALS:
   //           return 0;

   //         default:
   //           return 0;
   //       }
   //     #undef I
   //     #undef E
   //    }
 int CIndicatorTemplateManager::GetStandardIndicatorParamSchema(const ENUM_INDICATOR type,SIndicatorParam &out[]) const
  {
   ArrayResize(out, INDICATOR_PARAM_SLOTS_MAX);
   for(int p = 0; p < INDICATOR_PARAM_SLOTS_MAX; p++)
     {
      out[p].name = "";
      out[p].data_type = TYPE_DOUBLE;
      out[p].default_value = "";
      out[p].choices = "";
     }
   for(int i = 0; i < ArraySize(standard_indicator_list); i++)
     {
      if(standard_indicator_list[i].ind_type != type)
         continue;

      int total = standard_indicator_list[i].params_total;
      if(total < 0 || total > INDICATOR_PARAM_SLOTS_MAX)
        {
         ::Print(__FUNCTION__, " > invalid params_total for indicator ", (int)type);
         return 0;
        }

      for(int p = 0; p < total; p++)
        {
         out[p].name          = standard_indicator_list[i].param_schema[p].name;
         out[p].data_type     = standard_indicator_list[i].param_schema[p].data_type;
         if(out[p].data_type == TYPE_INT)
            out[p].default_value = IntegerToString((int)standard_indicator_list[i].param_schema[p].default_value);
         else
            out[p].default_value = DoubleToString(standard_indicator_list[i].param_schema[p].default_value, 8);
          switch(standard_indicator_list[i].param_schema[p].domain)
            {
             case INDICATOR_PARAM_DOMAIN_NONE:
                out[p].choices = "";
                break;
             case INDICATOR_PARAM_DOMAIN_MA_METHOD:
                out[p].choices = CALCULATION_METHOD_CHOICES;
                break;
             case INDICATOR_PARAM_DOMAIN_APPLIED_PRICE:
                out[p].choices = PRICE_CHOICES;
                break;
             case INDICATOR_PARAM_DOMAIN_STOCH_PRICE:
                out[p].choices = STOCH_PRICE_CHOICES;
                break;
             case INDICATOR_PARAM_DOMAIN_APPLIED_VOLUME:
                out[p].choices = VOLUME_CHOICES;
                break;
             default:
                ::Print(__FUNCTION__, " > invalid parameter domain at index ", p, " for indicator ", (int)type);
                return 0;
            }
        }

      return total;
     }

   return 0;
  }
 bool CIndicatorTemplateManager::ParamsFromTextByStandardSchema(const ENUM_INDICATOR type,const string text,MqlParam &out_params[]) const
  {
   int row = WRONG_VALUE;
   for(int i = 0; i < ArraySize(standard_indicator_list); i++)
     {
      if(standard_indicator_list[i].ind_type == type)
        {
         row = i;
         break;
        }
     }
   if(row == WRONG_VALUE)
      return false;

   SIndicatorParam schema[];
   const int schema_total = this.GetStandardIndicatorParamSchema(type, schema);
   if(schema_total < 0 || schema_total > INDICATOR_PARAM_SLOTS_MAX)
      return false;

   // An unmigrated catalog row can appear to have no params because it
   // still uses the old short initializer.
   if(schema_total == 0 && standard_indicator_list[row].params != "")
      return false;

   string params_text[];
   const int found = (text == "") ? 0 : StringSplit(text, ',', params_text);
   if(found != schema_total)
      return false;

   for(int p = 0; p < schema_total; p++)
     {
      if(schema[p].name == "")
         return false;
     }

   if(ArrayResize(out_params, schema_total) != schema_total)
      return false;

   for(int p = 0; p < schema_total; p++)
     {
      string raw = params_text[p];
      StringTrimLeft(raw);
      StringTrimRight(raw);
      StringReplace(raw, "\"", "");

      out_params[p].type = schema[p].data_type;
      if(schema[p].choices == PRICE_CHOICES)
         out_params[p].integer_value = this.ParamValueByDescription(raw,schema[p].choices);
      else if(schema[p].choices == CALCULATION_METHOD_CHOICES)
         out_params[p].integer_value = this.ParamValueByDescription(raw,schema[p].choices);
      else if(schema[p].choices == VOLUME_CHOICES)
         out_params[p].integer_value = this.ParamValueByDescription(raw,schema[p].choices);
      else if(schema[p].choices == STOCH_PRICE_CHOICES)
         out_params[p].integer_value = this.ParamValueByDescription(raw,schema[p].choices);
      else if(schema[p].data_type == TYPE_DOUBLE)
         out_params[p].double_value = StringToDouble(raw);
      else
         out_params[p].integer_value = (long)StringToInteger(raw);
     }

   return true;
  }
#endif // CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
#endif // CINDICATORTEMPLATEMANAGER_MQH
