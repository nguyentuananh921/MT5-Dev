//+------------------------------------------------------------------+
//|                                     IndicatorTemplateManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Single source of truth for the indicator templates:              |
//| CRUD table Setting_IndicatorTemplate of the database             |
//+------------------------------------------------------------------+
//--- Change from V3: the rows are read from the table (V3: Indicator_Templates JSON), CIndicatorSetting keeps the params as their text
#ifndef CINDICATORTEMPLATEMANAGER_MQH
#define CINDICATORTEMPLATEMANAGER_MQH
 #include "..\..\Services\DELib\DatabaseDELib.mqh"
 #include "..\..\Services\DELib\IndicatorDELib.mqh"
 #include "..\..\Entities\Defines\EventDefines.mqh"
 #include "..\..\Entities\Bases\BaseObj.mqh"
 #include "..\..\Entities\Chart\ChartObj.mqh"
 #include "..\..\Entities\Settings\IndicatorSetting.mqh"
 #include "..\ListObj.mqh"
 #include "..\..\Services\DELib\DatabaseService.mqh"
#ifndef CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
#define CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
 class CIndicatorTemplateManager : public CBaseObj
  {
    private:
    //Plan to replaced by CDatabaseService
     //int                m_db;                 // the open database: a change is written here
     
     CListObj           m_list;               // the templates (CIndicatorSetting), in the order of the table
     
     CDatabaseService   *m_CDatabaseService;                       // The EA holds it
     //Private Method
     //bool               Open(void);
     
     //bool               MakeTimeframes(void);
     //bool               MakeTemplates(void);
     bool               CompleteVolumesParams(MqlParam &params[]) const;
     string             Where(const ENUM_INDICATOR type, const string params_text) const;
     bool               GetFlag(const ENUM_INDICATOR type, const string params_text, const string column) const;
     //Update Database
      bool               ChangeGroup(const ENUM_INDICATOR_GROUP group, const string first, const string second, const bool on, const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event);
      bool               ChangeFlag(const ENUM_INDICATOR type, const string params_text, const string column, const bool on, const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event);
      bool               SyncDataFromDB(void);      
      bool               SyncDataToDB(void);

     void               ParamTexts(const ENUM_INDICATOR type, MqlParam &params[], const int decimals, string &out[]) const;
    public:
                        CIndicatorTemplateManager(void) : m_db(INVALID_HANDLE),m_CDatabaseService(NULL) { this.m_list.Type(OBJECT_DE_TYPE_INDICATOR_SETTING); }
                        ~CIndicatorTemplateManager(void) { if(m_db != INVALID_HANDLE) ::DatabaseClose(m_db); }
     //--- Lifecycle - same convention as the other managers: opens the database, makes the tables when they are not there, then the indicators the chart holds are templates
      bool               OnInitEvent(CChartObj *chart=NULL);
     //--- What this manager announced itself: the chart follows the templates, nobody has to tell it (a template added or shown is attached, hidden or deleted is detached)
      bool               OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam, CChartObj *chart);

     void                SetDatabaseService    (CDatabaseService   *databaseService)    {this.m_CDatabaseService=databaseService;} 
     
     //--Add, Remove a template: written to the database at once, then the event (false if the template exists / does not exist)
      bool               AddToDB(const ENUM_INDICATOR type, MqlParam &params[]);
      bool               RemoveFromDB(const ENUM_INDICATOR type, const string params_text);

   //--- The index of a template in m_list (WRONG_VALUE: none), the template itself (NULL: none)
     int                IndexSetting(const ENUM_INDICATOR type, const string params_text) const;
     CIndicatorSetting *GetSetting(const ENUM_INDICATOR type, const string params_text) const;
   //--- The params of a template as the one text of the table, and back (false when the text does not fit the schema of the type)
     string             ParamsText(const ENUM_INDICATOR type, MqlParam &params[]) const;
     bool               ParamsFromText(const ENUM_INDICATOR type, const string text, MqlParam &out_params[]) const;
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
     bool               ShowGroup(const ENUM_INDICATOR_GROUP group, const bool on);     // show_on_chart of every template of the group (the chart follows each one)
     bool               SignalGroup(const ENUM_INDICATOR_GROUP group, const bool on);   // buy_signal and sell_signal of every template of the group (one event)
     bool               AlertGroup(const ENUM_INDICATOR_GROUP group, const bool on);    // sound_alert and message_alert of every template of the group
   //--- The five flags of a template (Buy / Sell signal, sound alert, message alert, shown on the chart): written at once, the event only when the flag changed
     bool               BuySignal(const ENUM_INDICATOR type, const string params_text, const bool on)    { return this.ChangeFlag(type, params_text, "buy_signal", on, INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED); }
     bool               SellSignal(const ENUM_INDICATOR type, const string params_text, const bool on)   { return this.ChangeFlag(type, params_text, "sell_signal", on, INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED); }
     bool               SoundAlert(const ENUM_INDICATOR type, const string params_text, const bool on)   { return this.ChangeFlag(type, params_text, "sound_alert", on, INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT); }
     bool               MessageAlert(const ENUM_INDICATOR type, const string params_text, const bool on) { return this.ChangeFlag(type, params_text, "message_alert", on, INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT); }
     bool               ShowOnChart(const ENUM_INDICATOR type, const string params_text, const bool on)  { return this.ChangeFlag(type, params_text, "show_on_chart", on, INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED); }
   
  };
#endif // CINDICATORTEMPLATEMANAGER_MQH_DECLARATION

#ifndef CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
#define CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Lifecycle - same convention as the other managers. EA.mq5 calls   |
 //| this from its own OnInit().                                       |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::OnInitEvent(CChartObj *chart)
  {  
    //Create table timeframes
    // New In V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService == NULL)
      {
       ::Print(__FUNCTION__, " > DatabaseService is not set");
       return false;
      }
     string sql_createTimeframe = "CREATE TABLE IF NOT EXISTS timeframes (tf_enum INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL UNIQUE)";     
     if(!this.m_CDatabaseService.ExecuteCommon(sql_createTimeframe))
         return false;    
     string sql_createIndicatorTemplate = "CREATE TABLE IF NOT EXISTS Setting_IndicatorTemplate (id INTEGER PRIMARY KEY AUTOINCREMENT, "
                                          "type_enum INTEGER NOT NULL, params TEXT NOT NULL, display TEXT NOT NULL, "
                                          "buy_signal INTEGER NOT NULL DEFAULT 1, sell_signal INTEGER NOT NULL DEFAULT 1, "
                                          "sound_alert INTEGER NOT NULL DEFAULT 1, message_alert INTEGER NOT NULL DEFAULT 1, "
                                          "show_on_chart INTEGER NOT NULL DEFAULT 1, UNIQUE (type_enum, params))";
     if(!this.m_CDatabaseService.ExecuteCommon(sql_createIndicatorTemplate))
         return false;
     
     struct STimeframeCatalogItem
      {
         ENUM_TIMEFRAMES tf_enum;
         string          name;
      };
     STimeframeCatalogItem timeframe_list[] =
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
     for(int i = 0; i < ::ArraySize(timeframe_list); i++)
      {
       string sql = "INSERT OR IGNORE INTO timeframes (tf_enum, name) VALUES (" +
                     (string)(int)timeframe_list[i].tf_enum + ", '" +
                     timeframe_list[i].name + "')";

       if(!this.m_CDatabaseService.ExecuteCommon(sql))
            return false;
      }

   //  // Old Plan to remove after implemenation  
   //    bool ok = (m_db != INVALID_HANDLE) || this.Open();   // a CHARTCHANGE reinit keeps the database open
   //    if(!ok || chart == NULL)
   //       return ok;

   //--- What the chart holds: an indicator of the catalog that is a row of its own is shown when it is a template, a new template when it is not
   CArrayObj *on_chart = chart.GetList();
   for(int i = on_chart.Total() - 1; i >= 0; i--)
    {
     CWndInd *ind = on_chart.At(i);
     ENUM_INDICATOR type;
     MqlParam params[];
     if(ind == NULL || !ind.GetIdentity(type, params))
        continue;
     if(GetIndicatorNameForType(type) == "" || !chart.ChartIdentity(type, params))
        continue;   // not in the catalog, or a part of another row: never a row
     if(type == IND_VOLUMES && ::ArraySize(params) == 1 && !this.CompleteVolumesParams(params))
        continue;   // the chart holds the Volumes alone and no row has its Applied Volume: the Add form makes it with its MA
     string text = this.ParamsText(type, params);
     if(this.Exists(type, text))
        this.ShowOnChart(type, text, true);   // already a template: Show follows what the chart really holds
     else
        this.AddToDB(type, params);   // new row, Show on by default
    }
   // New In V4 after implemenation CDatabaseService
   if(!this.SyncDataToDB())
      return false;
   //--- A template saved as shown that this chart does not hold: its indicator is attached
   long ids[];
   ENUM_INDICATOR types[];
   string texts[], display[];
   bool buy[], sell[], sound[], message[], show[];
   int total = this.Templates(ids, types, texts, display, buy, sell, sound, message, show);
   for(int row = 0; row < total; row++)
    {
     MqlParam row_params[];
     if(!show[row] || !this.ParamsFromText(types[row], texts[row], row_params))
        continue;
     if(!chart.IsIndicatorShownOnChart(types[row], row_params))
        chart.ShowIndicatorOnChart(types[row], row_params);
    }
   return true;
  }
 //+------------------------------------------------------------------+
 //| (1) What this manager announced itself (lparam = the type,       |
 //| sparam = the params of the template: the identity, never a       |
 //| position): the chart follows the table. (2) What the chart       |
 //| announced (CChartObj: lparam = the index in the window, dparam = |
 //| the window, sparam = the short name): the table follows the chart|
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam, CChartObj *chart)
  {
   if(chart == NULL)
      return false;
   //--- The table changed: a new template, or shown, comes to the chart; a hidden one, or deleted, leaves it
   bool added   = (id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED);
   bool changed = (id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED);
   bool deleted = (id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE);
   if(added || changed || deleted)
    {
     ENUM_INDICATOR type = (ENUM_INDICATOR)(int)lparam;
     MqlParam params[];
     if(!this.ParamsFromText(type, sparam, params))
        return false;
     bool shown  = chart.IsIndicatorShownOnChart(type, params);
     bool wanted = (!deleted && this.GetFlag(type, sparam, "show_on_chart"));
     if(wanted && !shown)
        chart.ShowIndicatorOnChart(type, params);
     else if(!wanted && shown)
        chart.RemoveIndicatorFromChart(type, params);
     ::ChartRedraw();
     return true;
    }
   //--- The chart changed: the parameters of an indicator were changed by hand, its old template goes and the new one comes
   if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_CHANGE)
    {
     CWndInd *old_ind = chart.GetLastChangedIndicator();
     CWndInd *new_ind = chart.GetIndicator((int)dparam, (int)lparam);
     ENUM_INDICATOR old_type, new_type;
     MqlParam old_params[], new_params[];
     if(old_ind == NULL || new_ind == NULL || !old_ind.GetIdentity(old_type, old_params) || !new_ind.GetIdentity(new_type, new_params))
        return false;
     if(this.Exists(new_type, this.ParamsText(new_type, new_params)))
        return false;
     string old_text = this.ParamsText(old_type, old_params);
     if(this.Exists(old_type, old_text))
        this.RemoveFromDB(old_type, old_text);
     if(GetIndicatorNameForType(new_type) != "")
        this.AddToDB(new_type, new_params);
     return true;
    }
   //--- The chart changed: an indicator left it, every template takes Show from what the chart holds now (a template deleted by the user is gone already)
   if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_DEL)
    {
     long ids[];
     ENUM_INDICATOR types[];
     string texts[], display[];
     bool buy[], sell[], sound[], message[], show[];
     int total = this.Templates(ids, types, texts, display, buy, sell, sound, message, show);
     for(int row = 0; row < total; row++)
      {
       MqlParam row_params[];
       if(!this.ParamsFromText(types[row], texts[row], row_params))
          continue;
       bool on_chart = chart.IsIndicatorShownOnChart(types[row], row_params);
       if(on_chart != show[row])
          this.ShowOnChart(types[row], texts[row], on_chart);
      }
     return true;
    }
   if(id != CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_ADD)
      return false;
   //--- The chart changed: an indicator came, it is a new template, or a hidden one the user put back by hand
   CWndInd *ind = chart.GetIndicator((int)dparam, (int)lparam);
   if(ind == NULL || ind.Name() != sparam)
      ind = chart.GetLastAddedIndicator();   // several events queued: the indexes moved
   ENUM_INDICATOR type;
   MqlParam params[];
   if(ind == NULL || !ind.GetIdentity(type, params) || GetIndicatorNameForType(type) == "" || !chart.ChartIdentity(type, params))
      return false;
   if(type == IND_VOLUMES && ::ArraySize(params) == 1 && !this.CompleteVolumesParams(params))
      return false;   // the chart holds the Volumes alone and no template has its Applied Volume: the Add form makes it with its MA
   string text = this.ParamsText(type, params);
   if(!this.Exists(type, text))
      return this.AddToDB(type, params);   // new template, Show on by default
   return this.ShowOnChart(type, text, true);
  }
 bool CIndicatorTemplateManager::SyncDataToDB(void)
  {
   if(this.m_CDatabaseService == NULL)
      return false;

   bool result = true;
   for(int i = 0; i < this.m_list.Total(); i++)
     {
      CIndicatorSetting *row = this.m_list.At(i);
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

      if(!this.m_CDatabaseService.ExecuteCommon(sql))
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
   return "type_enum = " + (string)(int)type + " AND params = '" + LibDatabase_Quoted(params_text) + "'";
  }
 //+------------------------------------------------------------------+
 //| Every param as text: Applied Price / Method / Volume / Stoch     |
 //| price by description, numbers with `decimals`                     |
 //+------------------------------------------------------------------+
 void CIndicatorTemplateManager::ParamTexts(const ENUM_INDICATOR type, MqlParam &params[], const int decimals, string &out[]) const
  {
   SIndicatorParam schema[];
   GetIndicatorParamSchema(type, schema);
   int total = ::ArraySize(params);
   ::ArrayResize(out, total);
   for(int p = 0; p < total; p++)
     out[p] = MqlParameterDescription(params[p], (p < ::ArraySize(schema)) ? schema[p].choices : "", decimals);
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
   int schema_total = GetIndicatorParamSchema(type, schema);
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
          out_params[p].integer_value = (long)AppliedPriceByDescription(raw);
       else if(schema[p].choices == CALCULATION_METHOD_CHOICES)
          out_params[p].integer_value = (long)AveragingMethodByDescription(raw);
       else if(schema[p].choices == VOLUME_CHOICES)
          out_params[p].integer_value = (long)AppliedVolumeByDescription(raw);
       else if(schema[p].choices == STOCH_PRICE_CHOICES)
          out_params[p].integer_value = (long)StochPriceByDescription(raw);
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
   string name = GetIndicatorNameForType(type);
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
 bool CIndicatorTemplateManager::SyncDataFromDB(void)
  {
   this.m_list.Clear();
      // if(m_db == INVALID_HANDLE)
      //    return false;
      // int request = LibDatabase_Prepare(m_db, "SELECT id, type_enum, params, display, buy_signal, sell_signal, sound_alert, message_alert, show_on_chart FROM Setting_IndicatorTemplate ORDER BY rowid");
      // if(request == INVALID_HANDLE)
      //  {
      //   ::Print(__FUNCTION__, " > the query is not accepted, error ", ::GetLastError());
      //   return false;
      //  }
      // while(::DatabaseRead(request))
      //  {
      //   long id, type, b, s, so, m, sh;
      //   string text, shown;
      //   ::DatabaseColumnLong(request, 0, id);
      //   ::DatabaseColumnLong(request, 1, type);
      //   ::DatabaseColumnText(request, 2, text);
      //   ::DatabaseColumnText(request, 3, shown);
      //   ::DatabaseColumnLong(request, 4, b);
      //   ::DatabaseColumnLong(request, 5, s);
      //   ::DatabaseColumnLong(request, 6, so);
      //   ::DatabaseColumnLong(request, 7, m);
      //   ::DatabaseColumnLong(request, 8, sh);
      //   CIndicatorSetting *row = new CIndicatorSetting(id, (ENUM_INDICATOR)(int)type, text, shown);
      //   if(row == NULL)
      //      continue;
      //   row.BuySignal(b != 0, false);
      //   row.SellSignal(s != 0, false);
      //   row.SoundAlert(so != 0);
      //   row.MessageAlert(m != 0);
      //   row.ShowOnChart(sh != 0, false);
      //   if(!this.m_list.Add(row))
      //      delete row;
      //  }
      // ::DatabaseFinalize(request);
   
   ::Print("Complete ", __FUNCTION__, " > ", this.m_list.Total(), " templates of Setting_IndicatorTemplate read to RAM");
   return true;
  }
 int CIndicatorTemplateManager::IndexSetting(const ENUM_INDICATOR type, const string params_text) const
  {
   for(int i = 0; i < this.m_list.Total(); i++)
    {
     CIndicatorSetting *row = this.m_list.At(i);
     if(row != NULL && row.TypeEnum() == type && row.Params() == params_text)
        return i;
    }
   return WRONG_VALUE;
  }
 CIndicatorSetting *CIndicatorTemplateManager::GetSetting(const ENUM_INDICATOR type, const string params_text) const
  {
   int index = this.IndexSetting(type, params_text);
   return (index > WRONG_VALUE ? this.m_list.At(index) : NULL);
  }
 //+------------------------------------------------------------------+
 //| The templates in the order of the table: how to show them is the  |
 //| business of the View                                              |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::Templates(long &ids[], ENUM_INDICATOR &types[], string &params[], string &display[], bool &buy[], bool &sell[], bool &sound[], bool &message[], bool &show[]) const
  {
   int total = this.m_list.Total();
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
     CIndicatorSetting *row = this.m_list.At(i);
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
   int total = this.m_list.Total();
   ::ArrayResize(ids, total);
   ::ArrayResize(types, total);
   ::ArrayResize(params, total);
   ::ArrayResize(buy, total);
   ::ArrayResize(sell, total);
   for(int i = 0; i < total; i++)
    {
     CIndicatorSetting *row = this.m_list.At(i);
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
   for(int i = 0; i < this.m_list.Total(); i++)
    {
     CIndicatorSetting *row = this.m_list.At(i);
     if(row != NULL && row.TypeEnum() == type)
        return true;
    }
   return false;
  }
 //+------------------------------------------------------------------+
 //| Two flags of every template of a group at once; the event says     |
 //| several templates changed (lparam = WRONG_VALUE, dparam = group)   |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::ChangeGroup(const ENUM_INDICATOR_GROUP group, const string first, const string second, const bool on, const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event)
  {
      // if(m_db == INVALID_HANDLE)
      //    return false;
      // string in_group = "";
      // for(int i = 0; i < this.m_list.Total(); i++)
      //  {
      //   CIndicatorSetting *row = this.m_list.At(i);
      //   if(row != NULL && GetIndicatorGroupForType(row.TypeEnum()) == group)
      //      in_group += (in_group == "" ? "" : ",") + (string)row.ID();
      //  }
      // if(in_group == "")
      //    return true;
      // if(!::DatabaseExecute(m_db, "UPDATE Setting_IndicatorTemplate SET " + first + " = " + (on ? "1" : "0") + ", " + second + " = " + (on ? "1" : "0") + " WHERE id IN (" + in_group + ")"))
      //    return false;
   // New In V4 after implemenation CDatabaseService
   if(this.m_CDatabaseService == NULL)
     {
      ::Print(__FUNCTION__, " > DatabaseService is not set");
      return false;
     }
   string in_group = "";
   for(int i = 0; i < this.m_list.Total(); i++)
     {
      CIndicatorSetting *row = this.m_list.At(i);
      if(row != NULL && GetIndicatorGroupForType(row.TypeEnum()) == group)
         in_group += (in_group == "" ? "" : ",") + (string)row.ID();
     }
   if(in_group == "")
      return true;

   string sql = "UPDATE Setting_IndicatorTemplate SET " +
                first + " = " + (on ? "1" : "0") + ", " +
                second + " = " + (on ? "1" : "0") +
                " WHERE id IN (" + in_group + ")";

   if(!this.m_CDatabaseService.ExecuteCommon(sql))
      return false;
   //--- m_list follows, one event for the group (not one for each template)
   for(int i = 0; i < this.m_list.Total(); i++)
    {
     CIndicatorSetting *row = this.m_list.At(i);
     if(row == NULL || GetIndicatorGroupForType(row.TypeEnum()) != group)
        continue;
     if(first == "buy_signal")
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
   if(event != INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT)
      ::EventChartCustom(::ChartID(), (ushort)event, (long)WRONG_VALUE, (double)(int)group, "");
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
      if(GetIndicatorGroupForType(types[i]) == group)
         done = (this.ShowOnChart(types[i], params[i], on) && done);   // a template at a time: the chart follows the event of each
   return done;
  }
 bool CIndicatorTemplateManager::SignalGroup(const ENUM_INDICATOR_GROUP group, const bool on)
  {
   return this.ChangeGroup(group, "buy_signal", "sell_signal", on, INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED);
  }
 bool CIndicatorTemplateManager::AlertGroup(const ENUM_INDICATOR_GROUP group, const bool on)
  {
   return this.ChangeGroup(group, "sound_alert", "message_alert", on, INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT);
  }
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
 //--- A flag that changed: its column at once, then the template in m_list, whose setter tells the listeners (lparam = the type, sparam = the params;
 //--- INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT = nobody needs to know)
 bool CIndicatorTemplateManager::ChangeFlag(const ENUM_INDICATOR type, const string params_text, const string column, const bool on, const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event)
  {
   CIndicatorSetting *row = this.GetSetting(type, params_text);
      // if(m_db == INVALID_HANDLE || row == NULL)
      //    return false;
      // if(this.GetFlag(type, params_text, column) == on)
      //    return true;
      // if(!::DatabaseExecute(m_db, "UPDATE Setting_IndicatorTemplate SET " + column + " = " + (on ? "1" : "0") + " WHERE id = " + (string)row.ID()))
      //    return false;
   // New In V4 after implemenation CDatabaseService
   if(this.m_CDatabaseService == NULL || row == NULL)
      return false;
   if(this.GetFlag(type, params_text, column) == on)
      return true;
   string sql = "UPDATE Setting_IndicatorTemplate SET " + column + " = " +
               (on ? "1" : "0") + " WHERE id = " + (string)row.ID();

   if(!this.m_CDatabaseService.ExecuteCommon(sql))
      return false;
   //--------------------------------------
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
 bool CIndicatorTemplateManager::AddToDB(const ENUM_INDICATOR type, MqlParam &params[])
  {
   string text = this.ParamsText(type, params);
   if(m_db == INVALID_HANDLE || type == IND_CUSTOM || GetIndicatorNameForType(type) == "" || this.Exists(type, text))
      return false;
   SIndicatorParam schema[];
   const int schema_total = GetIndicatorParamSchema(type, schema);
   if(::ArraySize(params) != schema_total)
    {
     ::Print(__FUNCTION__, " > ", GetIndicatorNameForType(type), " (", text, ") not written: ", ::ArraySize(params), " params, the schema has ", schema_total);
     return false;
    }
   string display = this.DisplayLabel(type, text);
   if(!::DatabaseExecute(m_db, "INSERT INTO Setting_IndicatorTemplate (type_enum, params, display) VALUES (" + (string)(int)type + ", '" + LibDatabase_Quoted(text) + "', '" +
                               LibDatabase_Quoted(display) + "')"))
    {
     ::Print(__FUNCTION__, " > ", GetIndicatorNameForType(type), " (", text, ") not written, error ", ::GetLastError());
     return false;
    }
   long id = 0;
   int request = LibDatabase_Prepare(m_db, "SELECT id FROM Setting_IndicatorTemplate WHERE " + this.Where(type, text));
   if(request != INVALID_HANDLE)
     {
      if(::DatabaseRead(request))
         ::DatabaseColumnLong(request, 0, id);
      ::DatabaseFinalize(request);
     }
   CIndicatorSetting *row = new CIndicatorSetting(id, type, text, display);
   if(row == NULL || !this.m_list.Add(row))
     {
      delete row;
      return false;
     }
   // --- Identity (type via lparam, params via sparam), NOT a position - EventChartCustom is queued/async, a position captured now can go stale
   ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED, (long)type, 0.0, text);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Remove a template: the table and m_list at once, then the event   |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::RemoveFromDB(const ENUM_INDICATOR type, const string params_text)
  {
   int index = this.IndexSetting(type, params_text);
   CIndicatorSetting *row = (index > WRONG_VALUE ? this.m_list.At(index) : NULL);
   if(m_db == INVALID_HANDLE || row == NULL)
    {
     ::Print(__FUNCTION__, " > rejected: no row for this identity");
     return false;
    }
   //--- The id of the template (the key of its signals): the event carries it (dparam)
   long template_id = row.ID();
   if(!::DatabaseExecute(m_db, "DELETE FROM Setting_IndicatorTemplate WHERE id = " + (string)template_id))
    {
     ::Print(__FUNCTION__, " > ", GetIndicatorNameForType(type), " (", params_text, ") not removed, error ", ::GetLastError());
     return false;
    }
   this.m_list.Delete(index);
   ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE, (long)type, (double)template_id, params_text);
   return true;
  }
 
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
#endif // CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
#endif // CINDICATORTEMPLATEMANAGER_MQH
