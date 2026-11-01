//+------------------------------------------------------------------+
//|                                     IndicatorTemplateManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Single source of truth for the indicator templates: they live in |
//| the table Setting_IndicatorTemplate of the database (one list    |
//| for every account), the manager keeps no copy and asks the       |
//| database each time. A template is told by its type and its      |
//| params (the key of the table); the params are kept as one text:  |
//| the numbers bare, the other values quoted, joined with ", ".     |
//| Methods come from V3 one by one when a class asks for them       |
//+------------------------------------------------------------------+
#ifndef CINDICATORTEMPLATEMANAGER_MQH
#define CINDICATORTEMPLATEMANAGER_MQH
 #include "..\..\Services\LibDatabase.mqh"
 #include "..\..\Services\DELib\IndicatorDELib.mqh"
 #include "..\..\Entities\Defines\EventDefines.mqh"
 #include "..\..\Entities\Bases\BaseObj.mqh"
 #include "..\..\Entities\Chart\ChartObj.mqh"
#ifndef CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
#define CINDICATORTEMPLATEMANAGER_MQH_DECLARATION
 class CIndicatorTemplateManager : public CBaseObj
  {
    private:
     int                m_db;                 // the open database: Setting_IndicatorTemplate is asked here, nothing is copied
     //Private Method
     bool               Open(void);
     bool               MakeTimeframes(void);
     bool               MakeTemplates(void);
     bool               CompleteVolumesParams(MqlParam &params[]) const;
     string             Where(const ENUM_INDICATOR type, const string params_text) const;
     bool               ChangeGroup(const ENUM_INDICATOR_GROUP group, const string first, const string second, const bool on, const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event);
     bool               GetFlag(const ENUM_INDICATOR type, const string params_text, const string column) const;
     bool               ChangeFlag(const ENUM_INDICATOR type, const string params_text, const string column, const bool on, const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event);
     void               ParamTexts(const ENUM_INDICATOR type, MqlParam &params[], const int decimals, string &out[]) const;
    public:
                        CIndicatorTemplateManager(void) : m_db(INVALID_HANDLE) {}
                       ~CIndicatorTemplateManager(void) { if(m_db != INVALID_HANDLE) ::DatabaseClose(m_db); }
   //--- Lifecycle - same convention as the other managers: opens the database, makes the tables when they are not there, then the indicators the chart holds are templates
     bool               OnInitEvent(CChartObj *chart=NULL);
   //--- What this manager announced itself: the chart follows the templates, nobody has to tell it (a template added or shown is attached, hidden or deleted is detached)
     bool               OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam, CChartObj *chart);
   //--- The params of a template as the one text of the table, and back (false when the text does not fit the schema of the type)
     string             ParamsText(const ENUM_INDICATOR type, MqlParam &params[]) const;
     bool               ParamsFromText(const ENUM_INDICATOR type, const string text, MqlParam &out_params[]) const;
   //--- The short text of the column display of a template: the catalog name and the params, "MA  (14, 0, SMA, Close)"
     string             DisplayLabel(const ENUM_INDICATOR type, const string params_text) const;
   //--- The templates, asked to the database each time, in the order of the table (the View sorts them as it likes). params = the saved text, display = the short text the user reads
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
   //--Add, Remove a template: written to the database at once, then the event (false if the template exists / does not exist)
     bool               Add_IndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[]);
     bool               Delete_IndicatorTemplateSetting(const ENUM_INDICATOR type, const string params_text);
  };
#endif // CINDICATORTEMPLATEMANAGER_MQH_DECLARATION

#ifndef CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
#define CINDICATORTEMPLATEMANAGER_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Open the database once: it stays open while the EA runs, the     |
 //| table is made when it is not there                                |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::Open(void)
  {
   m_db = LibDatabase_Open(DATABASE_OPEN_READWRITE);
   if(m_db == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > the database ", LIB_DATABASE_FILE, " is not opened, error ", ::GetLastError());
     return false;
    }
   ::DatabaseExecute(m_db, "PRAGMA busy_timeout=5000");
   if(!this.MakeTimeframes())
      return false;
   if(!this.MakeTemplates())
      return false;
   ::Print("Complete ", __FUNCTION__, " > ", LIB_DATABASE_FILE, " opened");
   return true;
  }
 //+------------------------------------------------------------------+
 //| One row = one indicator template. The key is the type and the     |
 //| params, the text saved (a type with no params has an empty text);  |
 //| display is the short text the user reads. id is a short name of   |
 //| the template for the tables that point to it (the signals of the   |
 //| indicator): AUTOINCREMENT, so it is never given to another template|
 //| after this one is deleted. A table made before the id has it now   |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::MakeTemplates(void)
  {
   const string columns = "type_enum INTEGER NOT NULL, params TEXT NOT NULL, display TEXT NOT NULL, buy_signal INTEGER NOT NULL DEFAULT 1, "
                          "sell_signal INTEGER NOT NULL DEFAULT 1, sound_alert INTEGER NOT NULL DEFAULT 1, message_alert INTEGER NOT NULL DEFAULT 1, "
                          "show_on_chart INTEGER NOT NULL DEFAULT 1";
   const string create = "CREATE TABLE Setting_IndicatorTemplate (id INTEGER PRIMARY KEY AUTOINCREMENT, " + columns + ", UNIQUE (type_enum, params))";
   long exists = 0, has_id = 0;
   int request = ::DatabasePrepare(m_db, "SELECT COUNT(*), COALESCE(SUM(name = 'id'), 0) FROM pragma_table_info('Setting_IndicatorTemplate')");
   if(request != INVALID_HANDLE)
    {
     if(::DatabaseRead(request))
      {
       ::DatabaseColumnLong(request, 0, exists);
       ::DatabaseColumnLong(request, 1, has_id);
      }
     ::DatabaseFinalize(request);
    }
   if(exists == 0)
    {
     if(::DatabaseExecute(m_db, create))
        return true;
     ::Print(__FUNCTION__, " > the table Setting_IndicatorTemplate is not made, error ", ::GetLastError());
     return false;
    }
   if(has_id != 0)
      return true;
   //--- The table of a program before the id: the rows go to the new table in the order they were, the old one is dropped
   const string names = "type_enum, params, display, buy_signal, sell_signal, sound_alert, message_alert, show_on_chart";
   if(!::DatabaseTransactionBegin(m_db))
      return false;
   if(!::DatabaseExecute(m_db, "ALTER TABLE Setting_IndicatorTemplate RENAME TO Setting_IndicatorTemplate_old") || !::DatabaseExecute(m_db, create) ||
      !::DatabaseExecute(m_db, "INSERT INTO Setting_IndicatorTemplate (" + names + ") SELECT " + names + " FROM Setting_IndicatorTemplate_old ORDER BY rowid") ||
      !::DatabaseExecute(m_db, "DROP TABLE Setting_IndicatorTemplate_old"))
    {
     ::Print(__FUNCTION__, " > the table Setting_IndicatorTemplate is not changed to have an id, error ", ::GetLastError());
     ::DatabaseTransactionRollback(m_db);
     return false;
    }
   ::DatabaseTransactionCommit(m_db);
   return true;
  }
 //+------------------------------------------------------------------+
 //| The table timeframes: the 21 timeframes of MT5, fixed, small. The |
 //| key tf_enum keeps them in increasing order of duration; a row     |
 //| already there is left as it is                                    |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::MakeTimeframes(void)
  {
   if(!::DatabaseExecute(m_db, "CREATE TABLE IF NOT EXISTS timeframes (tf_enum INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL UNIQUE)"))
    {
     ::Print(__FUNCTION__, " > the table timeframes is not made, error ", ::GetLastError());
     return false;
    }
   for(int i = 0; i < LIB_TIMEFRAMES_TOTAL; i++)
      if(!::DatabaseExecute(m_db, "INSERT OR IGNORE INTO timeframes (tf_enum, name) VALUES (" + (string)(int)LIB_TIMEFRAMES[i] + ", '" + ::StringSubstr(::EnumToString(LIB_TIMEFRAMES[i]), 7) + "')"))
       {
        ::Print(__FUNCTION__, " > ", ::EnumToString(LIB_TIMEFRAMES[i]), " not written, error ", ::GetLastError());
        return false;
       }
   return true;
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
 //| The templates in the order of the table: how to show them is the  |
 //| business of the View                                              |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::Templates(long &ids[], ENUM_INDICATOR &types[], string &params[], string &display[], bool &buy[], bool &sell[], bool &sound[], bool &message[], bool &show[]) const
  {
   ::ArrayResize(ids, 0);
   ::ArrayResize(types, 0);
   ::ArrayResize(params, 0);
   ::ArrayResize(display, 0);
   ::ArrayResize(buy, 0);
   ::ArrayResize(sell, 0);
   ::ArrayResize(sound, 0);
   ::ArrayResize(message, 0);
   ::ArrayResize(show, 0);
   if(m_db == INVALID_HANDLE)
      return 0;
   int request = ::DatabasePrepare(m_db, "SELECT type_enum, params, display, buy_signal, sell_signal, sound_alert, message_alert, show_on_chart, id FROM Setting_IndicatorTemplate ORDER BY rowid");
   if(request == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > the query is not accepted, error ", ::GetLastError());
     return 0;
    }
   int total = 0;
   while(::DatabaseRead(request))
    {
     long type, b, s, so, m, sh, id;
     string text, shown;
     ::DatabaseColumnLong(request, 0, type);
     ::DatabaseColumnText(request, 1, text);
     ::DatabaseColumnText(request, 2, shown);
     ::DatabaseColumnLong(request, 3, b);
     ::DatabaseColumnLong(request, 4, s);
     ::DatabaseColumnLong(request, 5, so);
     ::DatabaseColumnLong(request, 6, m);
     ::DatabaseColumnLong(request, 7, sh);
     ::DatabaseColumnLong(request, 8, id);
     ::ArrayResize(ids, total + 1);
     ::ArrayResize(types, total + 1);
     ::ArrayResize(params, total + 1);
     ::ArrayResize(display, total + 1);
     ::ArrayResize(buy, total + 1);
     ::ArrayResize(sell, total + 1);
     ::ArrayResize(sound, total + 1);
     ::ArrayResize(message, total + 1);
     ::ArrayResize(show, total + 1);
     ids[total]     = id;
     types[total]   = (ENUM_INDICATOR)(int)type;
     params[total]  = text;
     display[total] = shown;
     buy[total]     = (b != 0);
     sell[total]    = (s != 0);
     sound[total]   = (so != 0);
     message[total] = (m != 0);
     show[total]    = (sh != 0);
     total++;
    }
   ::DatabaseFinalize(request);
   return total;
  }
 //+------------------------------------------------------------------+
 //| The id of every template (the key of its signals in               |
 //| IndicatorSignalSeries) with its Buy and Sell flag                 |
 //+------------------------------------------------------------------+
 int CIndicatorTemplateManager::TemplateIds(long &ids[], ENUM_INDICATOR &types[], string &params[], bool &buy[], bool &sell[]) const
  {
   ::ArrayResize(ids, 0);
   ::ArrayResize(types, 0);
   ::ArrayResize(params, 0);
   ::ArrayResize(buy, 0);
   ::ArrayResize(sell, 0);
   if(m_db == INVALID_HANDLE)
      return 0;
   int request = ::DatabasePrepare(m_db, "SELECT id, type_enum, params, buy_signal, sell_signal FROM Setting_IndicatorTemplate ORDER BY id");
   if(request == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > the query is not accepted, error ", ::GetLastError());
     return 0;
    }
   int total = 0;
   while(::DatabaseRead(request))
    {
     long id, type, b, s;
     string text;
     ::DatabaseColumnLong(request, 0, id);
     ::DatabaseColumnLong(request, 1, type);
     ::DatabaseColumnText(request, 2, text);
     ::DatabaseColumnLong(request, 3, b);
     ::DatabaseColumnLong(request, 4, s);
     ::ArrayResize(ids, total + 1);
     ::ArrayResize(types, total + 1);
     ::ArrayResize(params, total + 1);
     ::ArrayResize(buy, total + 1);
     ::ArrayResize(sell, total + 1);
     ids[total] = id;
     types[total] = (ENUM_INDICATOR)type;
     params[total] = text;
     buy[total] = (b != 0);
     sell[total] = (s != 0);
     total++;
    }
   ::DatabaseFinalize(request);
   return total;
  }
 bool CIndicatorTemplateManager::Exists(const ENUM_INDICATOR type, const string params_text) const
  {
   if(m_db == INVALID_HANDLE)
      return false;
   int request = ::DatabasePrepare(m_db, "SELECT 1 FROM Setting_IndicatorTemplate WHERE " + this.Where(type, params_text) + " LIMIT 1");
   if(request == INVALID_HANDLE)
      return false;
   bool found = ::DatabaseRead(request);
   ::DatabaseFinalize(request);
   return found;
  }
 bool CIndicatorTemplateManager::Exists(const ENUM_INDICATOR type) const
  {
   if(m_db == INVALID_HANDLE)
      return false;
   int request = ::DatabasePrepare(m_db, "SELECT 1 FROM Setting_IndicatorTemplate WHERE type_enum = " + (string)(int)type + " LIMIT 1");
   if(request == INVALID_HANDLE)
      return false;
   bool found = ::DatabaseRead(request);
   ::DatabaseFinalize(request);
   return found;
  }
 //+------------------------------------------------------------------+
 //| Two flags of every template of a group at once; the event says     |
 //| several templates changed (lparam = WRONG_VALUE, dparam = group)   |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::ChangeGroup(const ENUM_INDICATOR_GROUP group, const string first, const string second, const bool on, const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event)
  {
   if(m_db == INVALID_HANDLE)
      return false;
   long ids[];
   ENUM_INDICATOR types[];
   string params[], display[];
   bool buy[], sell[], sound[], message[], show[];
   int total = this.Templates(ids, types, params, display, buy, sell, sound, message, show);
   string in_group = "";
   for(int i = 0; i < total; i++)
      if(GetIndicatorGroupForType(types[i]) == group)
         in_group += (in_group == "" ? "" : ",") + (string)ids[i];
   if(in_group == "")
      return true;
   if(!::DatabaseExecute(m_db, "UPDATE Setting_IndicatorTemplate SET " + first + " = " + (on ? "1" : "0") + ", " + second + " = " + (on ? "1" : "0") + " WHERE id IN (" + in_group + ")"))
      return false;
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
   if(m_db == INVALID_HANDLE)
      return false;
   int request = ::DatabasePrepare(m_db, "SELECT " + column + " FROM Setting_IndicatorTemplate WHERE " + this.Where(type, params_text));
   if(request == INVALID_HANDLE)
      return false;
   long value = 0;
   if(::DatabaseRead(request))
      ::DatabaseColumnLong(request, 0, value);
   ::DatabaseFinalize(request);
   return (value != 0);
  }
 //--- A flag that changed tells the listeners: lparam = the type, sparam = the params of the template (INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT = nobody needs to know)
 bool CIndicatorTemplateManager::ChangeFlag(const ENUM_INDICATOR type, const string params_text, const string column, const bool on, const ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT event)
  {
   if(m_db == INVALID_HANDLE)
      return false;
   if(this.GetFlag(type, params_text, column) == on)
      return true;
   if(!::DatabaseExecute(m_db, "UPDATE Setting_IndicatorTemplate SET " + column + " = " + (on ? "1" : "0") + " WHERE " + this.Where(type, params_text)))
      return false;
   if(event != INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT)
      ::EventChartCustom(::ChartID(), (ushort)event, (long)type, 0.0, params_text);
   return true;
  } //+------------------------------------------------------------------+
 //| Add a template: written at once, then the event. False when it   |
 //| exists or the type is not in the catalog                          |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::Add_IndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &params[])
  {
   string text = this.ParamsText(type, params);
   if(m_db == INVALID_HANDLE || type == IND_CUSTOM || GetIndicatorNameForType(type) == "" || this.Exists(type, text))
      return false;
   if(!::DatabaseExecute(m_db, "INSERT INTO Setting_IndicatorTemplate (type_enum, params, display) VALUES (" + (string)(int)type + ", '" + LibDatabase_Quoted(text) + "', '" +
                               LibDatabase_Quoted(this.DisplayLabel(type, text)) + "')"))
    {
     ::Print(__FUNCTION__, " > ", GetIndicatorNameForType(type), " (", text, ") not written, error ", ::GetLastError());
     return false;
    }
   // --- Identity (type via lparam, params via sparam), NOT a position - EventChartCustom is queued/async, a position captured now can go stale
   ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED, (long)type, 0.0, text);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Remove a template: written at once, then the event                |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::Delete_IndicatorTemplateSetting(const ENUM_INDICATOR type, const string params_text)
  {
   if(m_db == INVALID_HANDLE || !this.Exists(type, params_text))
    {
     ::Print(__FUNCTION__, " > rejected: no row for this identity");
     return false;
    }
   //--- The id of the template (the key of its signals) is asked before the row goes: the event carries it (dparam)
   long template_id = 0;
   int request = ::DatabasePrepare(m_db, "SELECT id FROM Setting_IndicatorTemplate WHERE " + this.Where(type, params_text));
   if(request != INVALID_HANDLE)
     {
      if(::DatabaseRead(request))
         ::DatabaseColumnLong(request, 0, template_id);
      ::DatabaseFinalize(request);
     }
   if(!::DatabaseExecute(m_db, "DELETE FROM Setting_IndicatorTemplate WHERE " + this.Where(type, params_text)))
    {
     ::Print(__FUNCTION__, " > ", GetIndicatorNameForType(type), " (", params_text, ") not removed, error ", ::GetLastError());
     return false;
    }
   ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE, (long)type, (double)template_id, params_text);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Lifecycle - same convention as the other managers. EA.mq5 calls   |
 //| this from its own OnInit().                                       |
 //+------------------------------------------------------------------+
 bool CIndicatorTemplateManager::OnInitEvent(CChartObj *chart)
  {
   bool ok = (m_db != INVALID_HANDLE) || this.Open();   // a CHARTCHANGE reinit keeps the database open
   if(!ok || chart == NULL)
      return ok;
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
        this.Add_IndicatorTemplateSetting(type, params);   // new row, Show on by default
    }
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
        this.Delete_IndicatorTemplateSetting(old_type, old_text);
     if(GetIndicatorNameForType(new_type) != "")
        this.Add_IndicatorTemplateSetting(new_type, new_params);
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
      return this.Add_IndicatorTemplateSetting(type, params);   // new template, Show on by default
   return this.ShowOnChart(type, text, true);
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
