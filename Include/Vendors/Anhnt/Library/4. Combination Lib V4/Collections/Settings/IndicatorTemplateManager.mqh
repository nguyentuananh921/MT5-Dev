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
 #include "..\..\Entities\Defines\EventDefines.mqh"
 #include "..\..\Entities\Defines\IndicatorDefines.mqh"
 #include "..\..\Entities\Bases\BaseObj.mqh"
 #include "..\..\Entities\Settings\IndicatorSetting.mqh"
 #include "..\ListObj.mqh"
 #include "..\..\Services\DELib\DatabaseService.mqh"
 //--- Rows of the table SignalsCollection of the account, as CDatabaseService::Read binds them (the order of the SELECT)
 struct SSignalResultRow
  {
   long   bar_time;
   long   signal_direction;
  };
 struct SSignalPairRow
  {
   long   template_id;
   long   bar_time;
   long   signal_direction;
  };
 struct SSignalCandleRow
  {
   long   tf_enum;
   long   template_id;
   long   bar_time;
   long   signal_direction;
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
     int                IndexSetting(const ENUM_INDICATOR type, const string params_text) const;
     //Working with Database      
      bool               UpdateDataToDB(void);
      bool               UpdateDataToDB(const ENUM_INDICATOR type, MqlParam &params[], long &insert_id);
      bool               UpdateDataToDB(const long template_id);   // the row of a template goes
      bool               UpdateDataToDB(const ENUM_INDICATOR_GROUP group,const string first,const string second,const bool on);
      bool               UpdateDataToDB(const ENUM_INDICATOR type,const string params_text,const string column,const bool on);
      bool               ReadDataFromDB(void);      
     void               ParamTexts(const ENUM_INDICATOR type, MqlParam &params[], const int decimals, string &out[]) const;
      string             ParamDescription(const MqlParam &param,const string choices,const int decimals) const;
    public:
                        CIndicatorTemplateManager(void) : m_CDatabaseService(NULL) { this.m_list_indicator.Type(OBJECT_DE_TYPE_INDICATOR_SETTING); }
                        ~CIndicatorTemplateManager(void) {}
     //--- Lifecycle: create the catalog and template table, then load templates into RAM
        bool                 OnInitEvent(void);
     void                SetDatabaseService    (CDatabaseService   *databaseService)    {this.m_CDatabaseService=databaseService;}
     bool                CompleteVolumesParams(MqlParam &params[]) const;
     bool                Update_IndicatorTemplate_Setting(const ENUM_INDICATOR type, MqlParam &params[]);
     bool                Update_IndicatorTemplate_Setting(const ENUM_INDICATOR type, const string params_text);
     bool                Update_IndicatorTemplate_Setting(const ENUM_INDICATOR_GROUP group,const string first,const string second,const bool on,const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event);
     bool                Update_IndicatorTemplate_Setting(const ENUM_INDICATOR type,const string params_text,const string column,const bool on,const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event);
     //--- The table SignalsCollection of the account: (1) the rows of every template on a pair (WRONG_VALUE: not read), (2) the rows of the sides asked, (3) the rows of the TFs asked in a candle
     int                 ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time,long &templates[],long &times[],long &sides[]);
     int                 ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time,const long &buy_templates[],const long &sell_templates[],long &times[],long &sides[]);
     int                 ReadDataFromDB(const string symbol,const long &asked_tfs[],const datetime from_time,const datetime to_time,const long &asked_templates[],const int limit,long &tfs[],long &templates[],long &times[],long &sides[]);
     //--- The rows of a template on a pair go to SignalsCollection
     bool                UpdateDataToDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const long template_id,const long &times[],const long &sides[]);     
     //Working with DB
     //Woring in RAM
      //--- The index of a template in m_list_indicator (WRONG_VALUE: none), the template itself (NULL: none)
       CIndicatorSetting *Read_RAM(const ENUM_INDICATOR type, const string params_text) const;
       bool               Read_RAM(const ENUM_INDICATOR type, const string params_text, const string column) const;   // a flag of a template, by its column
      
   //--- The params of a template as the one text of the table, and back (false when the text does not fit the schema of the type)
     string             ParamsText(const ENUM_INDICATOR type, MqlParam &params[]) const;
     bool               Read_RAM(const ENUM_INDICATOR type, SIndicatorsRow &row) const;   // the catalog row of a type: name, group, buffers (false: not in the catalog)
     string             Read_RAM(const ENUM_INDICATOR_GROUP group) const;   // the name of a group
     int                Read_RAM(ENUM_INDICATOR &types[],ENUM_INDICATOR_GROUP &groups[],string &names[]) const;
     long               ParamValueByDescription(const string description,const string choices) const;
     string             Read_RAM(const ENUM_INDICATOR type,const int index,const MqlParam &param) const;
     int                Read_RAM(const ENUM_INDICATOR type, SIndicatorParam &out[]) const;     
     bool               ParamsFromText(const ENUM_INDICATOR type, const string text, MqlParam &out_params[]) const;
   //--- The short text of the column display of a template: the catalog name and the params, "MA  (14, 0, SMA, Close)"
     string             DisplayLabel(const ENUM_INDICATOR type, const string params_text) const;
   //--- The templates (m_list), in the order of the table (the View sorts them as it likes). params = the saved text, display = the short text the user reads
     int                Read_RAM(long &ids[], ENUM_INDICATOR &types[], string &params[], string &display[], bool &buy[], bool &sell[], bool &sound[], bool &message[], bool &show[]) const;
     int                Read_RAM(long &ids[], ENUM_INDICATOR &types[], string &params[], bool &buy[], bool &sell[]) const;   // the id of every template (the key of its signals), its type and saved params, its Buy / Sell flag
     int                Read_RAM(long &ids[], string &display[], bool &sound[], bool &message[]) const;   // the templates that have a sound or a message alert on: id, label and the two flags of each. Returns how many
     int                Read_RAM(long &buy_templates[], long &sell_templates[]) const;   // the templates whose Buy (Sell) signal the user wants: their ids. Returns how many templates there are
   //--- A template is told by its type and the saved text of its params (the column params): the same text Templates() gives
     bool               Read_RAM(const ENUM_INDICATOR type) const;   // the type has at least one template
   //--- The switch of the tab (the markers of the signals): ON when the Buy or the Sell flag of any template is on. Setting it writes both flags of every template at once
   // Not in here, in View
     bool               Update_IndicatorTemplate_Setting(const ENUM_INDICATOR_GROUP group, const bool on);     // show_on_chart of every template of the group (the chart follows each one)
   //--- The five flags of a template (Buy / Sell signal, sound alert, message alert, shown on the chart): written at once, the event only when the flag changed
   
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
      //--- The table of the account: the signals found (from CSignalsCollection::OnInitEvent, same schema)
      string sql_create_table_SignalsCollection = "CREATE TABLE IF NOT EXISTS SignalsCollection (name TEXT NOT NULL, tf_enum INTEGER NOT NULL, "
                                                  "template_id INTEGER NOT NULL, bar_time INTEGER NOT NULL, signal_direction INTEGER NOT NULL, "
                                                  "PRIMARY KEY (name, tf_enum, template_id, bar_time, signal_direction)) WITHOUT ROWID";
      if(!this.m_CDatabaseService.Create("Account", sql_create_table_SignalsCollection))
       {
         ::Print(__FUNCTION__, " > DatabaseService can't create table SignalsCollection");
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
   int total = this.Read_RAM(ids, types, texts, display, buy, sell, sound, message, show);
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
 bool CIndicatorTemplateManager::Read_RAM(const ENUM_INDICATOR type, SIndicatorsRow &row) const
  {
   for(int i = 0; i < ArraySize(standard_indicator_list); i++)
      if(standard_indicator_list[i].ind_type == type)
        {
         row = standard_indicator_list[i];
         return true;
        }
   row.name = "";
   row.group = INDICATOR_GROUP_ANY;
   row.buffers = 0;
   return false;
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
 string CIndicatorTemplateManager::Read_RAM(const ENUM_INDICATOR_GROUP group) const
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
 int CIndicatorTemplateManager::Read_RAM(ENUM_INDICATOR &types[],ENUM_INDICATOR_GROUP &groups[],string &names[]) const
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
 string CIndicatorTemplateManager::Read_RAM(const ENUM_INDICATOR type,const int index,const MqlParam &param) const
  {
   SIndicatorParam schema[];
   int total=this.Read_RAM(type,schema);
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
   this.Read_RAM(type, schema);
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
   int schema_total = this.Read_RAM(type, schema);
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
   SIndicatorsRow catalog;
   this.Read_RAM(type, catalog);
   string name = catalog.name;
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
 //+------------------------------------------------------------------+
 //| The rows of every template on a pair between two bars             |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time,long &templates[],long &times[],long &sides[])
  {
   ::ArrayResize(templates, 0);
   ::ArrayResize(times, 0);
   ::ArrayResize(sides, 0);
   SSignalPairRow rows[];
   if(this.m_CDatabaseService == NULL ||
      !this.m_CDatabaseService.Read("Account", "SELECT template_id, bar_time, signal_direction FROM SignalsCollection WHERE name = '" + this.m_CDatabaseService.QuoteSQLText(symbol) + "' AND tf_enum = " + (string)(int)timeframe +
                                               " AND bar_time >= " + (string)(long)from_time + " AND bar_time <= " + (string)(long)to_time, rows))
      return WRONG_VALUE;
   int total = ::ArraySize(rows);
   ::ArrayResize(templates, total);
   ::ArrayResize(times, total);
   ::ArrayResize(sides, total);
   for(int i = 0; i < total; i++)
     {
      templates[i] = rows[i].template_id;
      times[i]     = rows[i].bar_time;
      sides[i]     = rows[i].signal_direction;
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The rows of a pair the markers show: the sides asked              |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::ReadDataFromDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime from_time,const datetime to_time,const long &buy_templates[],const long &sell_templates[],long &times[],long &sides[])
  {
   ::ArrayResize(times, 0);
   ::ArrayResize(sides, 0);
   SSignalResultRow rows[];
   if(this.m_CDatabaseService == NULL ||
      !this.m_CDatabaseService.Read("Account", "SELECT bar_time, signal_direction FROM SignalsCollection WHERE name = '" + this.m_CDatabaseService.QuoteSQLText(symbol) + "' AND tf_enum = " + (string)(int)timeframe +
                                               " AND bar_time >= " + (string)(long)from_time + " AND bar_time <= " + (string)(long)to_time + " AND ((signal_direction = " + (string)(int)SIGNAL_DIRECTION_BUY +
                                               " AND template_id IN (" + this.m_CDatabaseService.InList(buy_templates) + ")) OR (signal_direction = " + (string)(int)SIGNAL_DIRECTION_SELL +
                                               " AND template_id IN (" + this.m_CDatabaseService.InList(sell_templates) + ")))", rows))
      return 0;
   int total = ::ArraySize(rows);
   ::ArrayResize(times, total);
   ::ArrayResize(sides, total);
   for(int i = 0; i < total; i++)
     {
      times[i] = rows[i].bar_time;
      sides[i] = rows[i].signal_direction;
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The signals found in a candle, the TFs asked                      |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::ReadDataFromDB(const string symbol,const long &asked_tfs[],const datetime from_time,const datetime to_time,const long &asked_templates[],const int limit,long &tfs[],long &templates[],long &times[],long &sides[])
  {
   ::ArrayResize(tfs, 0);
   ::ArrayResize(templates, 0);
   ::ArrayResize(times, 0);
   ::ArrayResize(sides, 0);
   SSignalCandleRow rows[];
   if(this.m_CDatabaseService == NULL ||
      !this.m_CDatabaseService.Read("Account", "SELECT tf_enum, template_id, bar_time, signal_direction FROM SignalsCollection WHERE name = '" + this.m_CDatabaseService.QuoteSQLText(symbol) + "' AND tf_enum IN (" +
                                               this.m_CDatabaseService.InList(asked_tfs) + ") AND template_id IN (" + this.m_CDatabaseService.InList(asked_templates) + ") AND bar_time >= " + (string)(long)from_time +
                                               " AND bar_time < " + (string)(long)to_time + " ORDER BY tf_enum DESC, bar_time LIMIT " + (string)limit, rows))
      return 0;
   int total = ::ArraySize(rows);
   ::ArrayResize(tfs, total);
   ::ArrayResize(templates, total);
   ::ArrayResize(times, total);
   ::ArrayResize(sides, total);
   for(int i = 0; i < total; i++)
     {
      tfs[i]       = rows[i].tf_enum;
      templates[i] = rows[i].template_id;
      times[i]     = rows[i].bar_time;
      sides[i]     = rows[i].signal_direction;
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The rows of a template on a pair, one statement: all or none      |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::UpdateDataToDB(const string symbol,const ENUM_TIMEFRAMES timeframe,const long template_id,const long &times[],const long &sides[])
  {
   int total = ::ArraySize(times);
   if(total == 0)
      return true;
   if(this.m_CDatabaseService == NULL)
      return false;
   string sql = "INSERT OR IGNORE INTO SignalsCollection (name, tf_enum, template_id, bar_time, signal_direction) VALUES ";
   for(int i = 0; i < total; i++)
      sql += (i > 0 ? ", ('" : "('") + this.m_CDatabaseService.QuoteSQLText(symbol) + "', " + (string)(int)timeframe + ", " + (string)template_id + ", " + (string)times[i] + ", " + (string)sides[i] + ")";
   return this.m_CDatabaseService.Create("Account", sql);
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
 CIndicatorSetting *CIndicatorTemplateManager::Read_RAM(const ENUM_INDICATOR type, const string params_text) const
  {
   int index = this.IndexSetting(type, params_text);
   return (index > WRONG_VALUE ? this.m_list_indicator.At(index) : NULL);
  }
 //+------------------------------------------------------------------+
 //| The templates in the order of the table: how to show them is the  |
 //| business of the View                                              |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::Read_RAM(long &ids[], ENUM_INDICATOR &types[], string &params[], string &display[], bool &buy[], bool &sell[], bool &sound[], bool &message[], bool &show[]) const
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
 int CIndicatorTemplateManager::Read_RAM(long &ids[], ENUM_INDICATOR &types[], string &params[], bool &buy[], bool &sell[]) const
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
 bool CIndicatorTemplateManager::Read_RAM(const ENUM_INDICATOR type) const
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
 bool CIndicatorTemplateManager::UpdateDataToDB(const ENUM_INDICATOR_GROUP group,const string first,const string second,const bool on)
  {    
   SIndicatorsRow catalog;
   if(this.m_CDatabaseService == NULL)
     {
      ::Print(__FUNCTION__, " > DatabaseService is not set");
      return false;
     }
   string in_group = "";
   for(int i = 0; i < this.m_list_indicator.Total(); i++)
     {
      CIndicatorSetting *row = this.m_list_indicator.At(i);
      if(row != NULL && this.Read_RAM(row.TypeEnum(), catalog) && catalog.group == group)
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
 bool CIndicatorTemplateManager::Update_IndicatorTemplate_Setting(const ENUM_INDICATOR_GROUP group,const string first,const string second,const bool on,const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event)
  {
   SIndicatorsRow catalog;
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
      if(row == NULL || !this.Read_RAM(row.TypeEnum(), catalog) || catalog.group != group)
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
   SIndicatorsRow catalog;
   insert_id = 0;
   if(this.m_CDatabaseService == NULL)
     {
      ::Print(__FUNCTION__, " > DatabaseService is not set");
      return false;
     }

   this.Read_RAM(type, catalog);
   string name = catalog.name;
   if(type == IND_CUSTOM || name == "")
     {
      ::Print(__FUNCTION__, " > rejected: indicator is not in the standard catalog");
      return false;
     }

   SIndicatorParam schema[];
   int schema_total = this.Read_RAM(type, schema);
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

 bool CIndicatorTemplateManager::UpdateDataToDB(const long template_id)
  {
   if(this.m_CDatabaseService == NULL)
     {
      ::Print(__FUNCTION__, " > DatabaseService is not set");
      return false;
     }

   if(!this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_IndicatorTemplate WHERE id = " + (string)template_id))
     {
      ::Print(__FUNCTION__, " > the template ", template_id, " is not removed");
      return false;
     }
   return true;
  }

 bool CIndicatorTemplateManager::Update_IndicatorTemplate_Setting(const ENUM_INDICATOR type,MqlParam &params[])
  {
   SIndicatorsRow catalog;
   string text = this.ParamsText(type, params);
   if(this.Read_RAM(type, text) != NULL)
     {
      ::Print(__FUNCTION__, " > rejected: template already exists");
      return false;
     }

   this.Read_RAM(type, catalog);
   string name = catalog.name;
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
      if(!this.UpdateDataToDB(id))
         ::Print(__FUNCTION__, " > failed to roll back DB insert for ", name, " (", text, ")");
      return false;
     }

   ::EventChartCustom(::ChartID(),
                      (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED,
                      (long)type, 0.0, text);
   return true;
  }

 bool CIndicatorTemplateManager::Update_IndicatorTemplate_Setting(const ENUM_INDICATOR type,const string params_text)
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
   if(!this.UpdateDataToDB(template_id))
      return false;

   if(!this.m_list_indicator.Delete(index))
     {
      ::Print(__FUNCTION__, " > DB row removed but RAM row could not be deleted: ",
              row.Display());
      return false;
     }

   ::EventChartCustom(::ChartID(),
                      (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE,
                      (long)type, (double)template_id, params_text);
   return true;
  }
 bool CIndicatorTemplateManager::Update_IndicatorTemplate_Setting(const ENUM_INDICATOR_GROUP group, const bool on)
  {
   SIndicatorsRow catalog;
   long ids[];
   ENUM_INDICATOR types[];
   string params[], display[];
   bool buy[], sell[], sound[], message[], show[];
   int total = this.Read_RAM(ids, types, params, display, buy, sell, sound, message, show);
   bool done = true;
   for(int i = 0; i < total; i++)
      if(this.Read_RAM(types[i], catalog) && catalog.group == group)
      done = (this.Update_IndicatorTemplate_Setting(types[i], params[i], "show_on_chart", on,INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED) && done);
   return done;
  }
 bool CIndicatorTemplateManager::Read_RAM(const ENUM_INDICATOR type, const string params_text, const string column) const
  {
   CIndicatorSetting *row = this.Read_RAM(type, params_text);
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
   CIndicatorSetting *row = this.Read_RAM(type, params_text);
   if(row == NULL)
     {
      ::Print(__FUNCTION__, " > rejected: no template for type ", EnumToString(type), " (", params_text, ")");
      return false;
     }
   if(this.Read_RAM(type, params_text, column) == on)
      return true;

   string sql = "UPDATE Setting_IndicatorTemplate SET " + column + " = " +
                (on ? "1" : "0") + " WHERE id = " + (string)row.ID();
   return this.m_CDatabaseService.Update("Common", sql);
  }
 //+------------------------------------------------------------------+
 //| Change one flag of one template: persist, update RAM, then notify |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::Update_IndicatorTemplate_Setting(const ENUM_INDICATOR type,const string params_text,const string column,const bool on,const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event)
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
   CIndicatorSetting *row = this.Read_RAM(type, params_text);
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
 //| The templates whose signal the user shows (the markers and the    |
 //| window of a candle show the same)                                 |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::Read_RAM(long &buy_templates[], long &sell_templates[]) const
  {
   ::ArrayResize(buy_templates, 0);
   ::ArrayResize(sell_templates, 0);
   long ids[];
   ENUM_INDICATOR types[];
   string params[];
   bool buy[], sell[];
   int total = this.Read_RAM(ids, types, params, buy, sell);
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
 int CIndicatorTemplateManager::Read_RAM(long &ids[], string &display[], bool &sound[], bool &message[]) const
  {
   ::ArrayResize(ids, 0);
   ::ArrayResize(display, 0);
   ::ArrayResize(sound, 0);
   ::ArrayResize(message, 0);
   long all_ids[];
   ENUM_INDICATOR types[];
   string params[], all_display[];
   bool buy[], sell[], all_sound[], all_message[], show[];
   int total = this.Read_RAM(all_ids, types, params, all_display, buy, sell, all_sound, all_message, show);
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
 int CIndicatorTemplateManager::Read_RAM(const ENUM_INDICATOR type,SIndicatorParam &out[]) const
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
#endif // CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
#endif // CINDICATORTEMPLATEMANAGER_MQH
