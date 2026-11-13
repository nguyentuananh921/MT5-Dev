//+------------------------------------------------------------------+
//|                                              StrategyManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Single source of truth for the strategies: a strategy (its tf),  |
//| the sources it reads (a standard indicator with its params or a  |
//| bar information, on a tf) and its conditions; levels stay in     |
//| indicators                                                       |
//| Create tables Setting_Strategy, Setting_StrategyIndicator,       |
//| Setting_StrategyCondition                                        |
//| New in V5, as CBarInformationManager                             |
//+------------------------------------------------------------------+
#ifndef CSTRATEGYMANAGER_MQH
#define CSTRATEGYMANAGER_MQH
 #include "..\..\Services\DELib\DatabaseService.mqh"
 #include "..\..\Entities\Defines\CommonDefines.mqh"
 #include "..\..\Entities\Defines\EventDefines.mqh"
 #include "..\..\Entities\Bases\BaseObj.mqh"
 #include "..\..\Entities\Settings\Strategy\Setting_Profitunity.mqh"
 #include "..\ListObj.mqh"
 #include "IndicatorTemplateManager.mqh"
 #include "BarInformationManager.mqh"
#ifndef CSTRATEGYMANAGER_MQH_DECLARATION
#define CSTRATEGYMANAGER_MQH_DECLARATION
 //--- A row of each table, as CDatabaseService::Read binds it (the order of the SELECT)
 struct SStrategyRow                       // Setting_Strategy
  {
   long                  strategy_id;
   string                name;
   string                reference;
   long                  tf_enum;          // 0: NULL in the table, the tf of the chart
   long                  show_on_chart;
  };
 //--- Rows of the table StrategyCollection of the account (what Python found), as CDatabaseService::Read binds them
 struct SStrategyResultRow
  {
   long                  bar_time;
   string                role;             // "entry" / "exit"
   long                  signal_direction;
  };
 //--- How many columns a table has of the ones asked (pragma_table_info)
 struct SStrategyColumns
  {
   long                  count;
  };
 struct SStrategyIndicatorRow              // Setting_StrategyIndicator
  {
   long                  strategy_id;
   string                slot;
   long                  collection;
   long                  source_id;
   long                  tf_enum;          // 0: NULL in the table, the tf of the strategy
   string                params;           // "": NULL in the table, the params of indicators
  };
 struct SStrategyConditionRow              // Setting_StrategyCondition
  {
   long                  strategy_id;
   string                role;
   long                  signal_direction;
   string                slot;
   string                rule;
  };
 class CStrategyManager : public CBaseObj
  {
    private:
     CDatabaseService  *m_CDatabaseService;   // The EA holds it
     CIndicatorTemplateManager *m_IndicatorTemplateManager;   // the EA holds it: the templates of the indicator slots (made when a strategy is ON)
     CBarInformationManager    *m_BarInformationManager;      // the EA holds it: the types of the bar information slots
     CListObj           m_list_strategy;      // the strategies (CStrategySetting, each with its slots and conditions), in the order of strategy_id
   //--- What every strategy IS: one class each (Entities\Settings\Strategy\Setting_<Name>.mqh), written to the tables in OnInit
     void               Catalog(CArrayObj &out) const;
     bool               WriteCatalog(CStrategySetting *strategy);
   //--- DB to RAM: once, in OnInitEvent
     bool               ReadDataFromDB(void);
   //--- An indicator slot as a template: its params as MqlParam and as the one text the templates are told by (false: not an indicator, or they do not fit its schema)
     bool               SlotTemplate(CStrategyIndicatorSetting *slot, MqlParam &params[], string &params_text) const;
   //--- The source of a slot is there: an indicator, a template of these params; a bar information, its type
     bool               SlotAvailable(CStrategyIndicatorSetting *slot) const;
    public:
                        CStrategyManager(void) : m_CDatabaseService(NULL), m_IndicatorTemplateManager(NULL), m_BarInformationManager(NULL) { this.m_list_strategy.Type(OBJECT_DE_TYPE_STRATEGY_SETTING); }
                       ~CStrategyManager(void) {}
     void               SetDatabaseService(CDatabaseService *databaseService) { this.m_CDatabaseService=databaseService; }
     void               SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { this.m_IndicatorTemplateManager=manager; }
     void               SetBarInformationManager(CBarInformationManager *manager)       { this.m_BarInformationManager=manager; }
   //--- Lifecycle - same convention as the other managers: makes the tables, writes the catalog, reads them to RAM
     bool               OnInitEvent(void);
   //--- (1) A strategy (NULL: none), (2) the strategy_id of every strategy, in the order of the table: returns how many
     CStrategySetting  *Read_RAM(const long strategy_id) const;
     int                Read_RAM(long &ids[]) const;
   //--- (3) The params a slot reads: its own (Setting_StrategyIndicator.params), else the standard of the indicator; (4) "available": every slot of the strategy has its source
     string             Read_RAM(CStrategyIndicatorSetting *slot) const;
     bool               Read_RAM(const long strategy_id, const string what) const;
   //--- (5) The params of an indicator slot as the one text the templates (and their CIndicatorDE) are told by (false: not an indicator, or they do not fit its schema)
     bool               Read_RAM(CStrategyIndicatorSetting *slot, string &params_text) const;
   //--- The strategy is ON: the templates of its indicators that are not there yet are made (CIndicatorTemplateManager tells each: ADDED), not shown on the chart
     bool               Create_IndicatorTemplate(const long strategy_id);
   //--- A flag of a strategy (column "show_on_chart"): written, then the strategy tells it (STRATEGY_MANAGER_EVENT_SHOW_CHANGED)
     bool               Update_Strategy_Setting(const long strategy_id, const string column, const bool on);
   //--- The tf of a strategy (column "tf_enum", PERIOD_CURRENT: the tf of the chart): written, then the strategy tells it (STRATEGY_MANAGER_EVENT_TF_CHANGED)
     bool               Update_Strategy_Setting(const long strategy_id, const string column, const ENUM_TIMEFRAMES tf);
   //--- The table StrategyCollection of the account: the rows of a strategy on a pair from_time to to_time (WRONG_VALUE: not read)
     int                ReadDataFromDB(const string symbol, const ENUM_TIMEFRAMES timeframe, const datetime from_time, const datetime to_time, const long strategy_id,
                                       long &times[], string &roles[], long &sides[]);
   //--- The params ("": the standard of indicators) and the tf (PERIOD_CURRENT: the tf of the strategy) of a slot: written, then STRATEGY_MANAGER_EVENT_SLOT_CHANGED
     bool               Update_StrategyIndicator_Setting(const long strategy_id, const string slot, const string params, const ENUM_TIMEFRAMES tf);
  };
#endif // CSTRATEGYMANAGER_MQH_DECLARATION

#ifndef CSTRATEGYMANAGER_MQH_IMPLEMENTATION
#define CSTRATEGYMANAGER_MQH_IMPLEMENTATION
 void CStrategyManager::Catalog(CArrayObj &out) const
  {
   out.Add(new CSetting_Profitunity());
  }
 //+------------------------------------------------------------------+
 //| What a strategy IS (name, reference, its slots and its           |
 //| conditions) is written at every start; what the user sets (the   |
 //| tf of the strategy, the tf and the params of a slot) is only     |
 //| given to a row that is new                                       |
 //+------------------------------------------------------------------+
 bool CStrategyManager::WriteCatalog(CStrategySetting *strategy)
  {
   string id = (string)strategy.StrategyId();
   string tf = "NULL";
   if(strategy.Timeframe() != PERIOD_CURRENT)
      tf = (string)(int)strategy.Timeframe();
   if(!this.m_CDatabaseService.Create("Common", "INSERT INTO Setting_Strategy (strategy_id, name, reference, tf_enum) VALUES (" + id + ", '" +
                                      this.m_CDatabaseService.QuoteSQLText(strategy.Name()) + "', '" + this.m_CDatabaseService.QuoteSQLText(strategy.Reference()) + "', " + tf + ") " +
                                      "ON CONFLICT(strategy_id) DO UPDATE SET name = excluded.name, reference = excluded.reference"))
     {
      ::Print(__FUNCTION__, " > ", strategy.Name(), " not written");
      return false;
     }
   string in_slots = "";
   for(int i = 0; i < strategy.IndicatorsTotal(); i++)
     {
      CStrategyIndicatorSetting *slot = strategy.Indicator(i);
      if(i > 0)
         in_slots += ", ";
      in_slots += "'" + this.m_CDatabaseService.QuoteSQLText(slot.Slot()) + "'";
     }
   this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_StrategyIndicator WHERE strategy_id = " + id + " AND slot NOT IN (" + in_slots + ")");
   for(int i = 0; i < strategy.IndicatorsTotal(); i++)
     {
      CStrategyIndicatorSetting *slot = strategy.Indicator(i);
      string slot_tf = "NULL";
      if(slot.Timeframe() != PERIOD_CURRENT)
         slot_tf = (string)(int)slot.Timeframe();
      string params = "NULL";
      if(slot.Params() != "")
         params = "'" + this.m_CDatabaseService.QuoteSQLText(slot.Params()) + "'";
      if(!this.m_CDatabaseService.Create("Common", "INSERT INTO Setting_StrategyIndicator (strategy_id, slot, collection, source_id, tf_enum, params) VALUES (" + id + ", '" +
                                         this.m_CDatabaseService.QuoteSQLText(slot.Slot()) + "', " + (string)(int)slot.Collection() + ", " + (string)slot.SourceId() + ", " + slot_tf + ", " + params + ") " +
                                         "ON CONFLICT(strategy_id, slot) DO UPDATE SET collection = excluded.collection, source_id = excluded.source_id"))
        {
         ::Print(__FUNCTION__, " > the slot ", slot.Slot(), " of ", strategy.Name(), " not written");
         return false;
        }
     }
   //--- The conditions are the rules of the source EA: written again whole
   this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_StrategyCondition WHERE strategy_id = " + id);
   for(int i = 0; i < strategy.ConditionsTotal(); i++)
     {
      CStrategyConditionSetting *condition = strategy.Condition(i);
      if(!this.m_CDatabaseService.Create("Common", "INSERT INTO Setting_StrategyCondition (strategy_id, role, signal_direction, slot, rule) VALUES (" + id + ", '" +
                                         this.m_CDatabaseService.QuoteSQLText(condition.Role()) + "', " + (string)(int)condition.SignalDirection() + ", '" +
                                         this.m_CDatabaseService.QuoteSQLText(condition.Slot()) + "', '" + this.m_CDatabaseService.QuoteSQLText(condition.Rule()) + "')"))
        {
         ::Print(__FUNCTION__, " > the condition ", condition.Rule(), " of ", strategy.Name(), " not written");
         return false;
        }
     }
   return true;
  }
 bool CStrategyManager::ReadDataFromDB(void)
  {
   this.m_list_strategy.Clear();
   SStrategyRow strategies[];
   if(!this.m_CDatabaseService.Read("Common", "SELECT strategy_id, name, reference, COALESCE(tf_enum, 0), show_on_chart FROM Setting_Strategy ORDER BY strategy_id", strategies))
      return false;
   for(int i = 0; i < ::ArraySize(strategies); i++)
     {
      CStrategySetting *strategy = new CStrategySetting(strategies[i].strategy_id, strategies[i].name, strategies[i].reference, (ENUM_TIMEFRAMES)(int)strategies[i].tf_enum);
      if(strategy == NULL)
         continue;
      strategy.ShowOnChart(strategies[i].show_on_chart != 0, false);
      if(!this.m_list_strategy.Add(strategy))
         delete strategy;
     }
   SStrategyIndicatorRow slots[];
   if(!this.m_CDatabaseService.Read("Common", "SELECT strategy_id, slot, collection, source_id, COALESCE(tf_enum, 0), COALESCE(params, '') FROM Setting_StrategyIndicator ORDER BY rowid", slots))
      return false;
   for(int i = 0; i < ::ArraySize(slots); i++)
     {
      CStrategySetting *strategy = this.Read_RAM(slots[i].strategy_id);
      if(strategy != NULL)
         strategy.AddIndicator(slots[i].slot, (ENUM_OBJECT_DE_TYPE)(int)slots[i].collection, slots[i].source_id, (ENUM_TIMEFRAMES)(int)slots[i].tf_enum, slots[i].params);
     }
   SStrategyConditionRow conditions[];
   if(!this.m_CDatabaseService.Read("Common", "SELECT strategy_id, role, signal_direction, slot, rule FROM Setting_StrategyCondition ORDER BY rowid", conditions))
      return false;
   for(int i = 0; i < ::ArraySize(conditions); i++)
     {
      CStrategySetting *strategy = this.Read_RAM(conditions[i].strategy_id);
      if(strategy != NULL)
         strategy.AddCondition(conditions[i].role, (ENUM_SIGNAL_DIRECTION)(int)conditions[i].signal_direction, conditions[i].slot, conditions[i].rule);
     }
   ::Print("Complete ", __FUNCTION__, " > ", this.m_list_strategy.Total(), " strategies of Setting_Strategy, ", ::ArraySize(slots), " slots of Setting_StrategyIndicator and ",
           ::ArraySize(conditions), " conditions of Setting_StrategyCondition read to RAM");
   return true;
  }
 CStrategySetting *CStrategyManager::Read_RAM(const long strategy_id) const
  {
   for(int i = 0; i < this.m_list_strategy.Total(); i++)
     {
      CStrategySetting *strategy = this.m_list_strategy.At(i);
      if(strategy != NULL && strategy.StrategyId() == strategy_id)
         return strategy;
     }
   return NULL;
  }
 bool CStrategyManager::Update_StrategyIndicator_Setting(const long strategy_id, const string slot, const string params, const ENUM_TIMEFRAMES tf)
  {
   CStrategySetting *strategy = this.Read_RAM(strategy_id);
   CStrategyIndicatorSetting *row = (strategy != NULL ? strategy.Indicator(slot) : NULL);
   if(row == NULL || this.m_CDatabaseService == NULL)
      return false;
   string value_params = "NULL";
   if(params != "")
      value_params = "'" + this.m_CDatabaseService.QuoteSQLText(params) + "'";
   string value_tf = "NULL";
   if(tf != PERIOD_CURRENT)
      value_tf = (string)(int)tf;
   if(!this.m_CDatabaseService.Update("Common", "UPDATE Setting_StrategyIndicator SET params = " + value_params + ", tf_enum = " + value_tf + " WHERE strategy_id = " +
                                      (string)strategy_id + " AND slot = '" + this.m_CDatabaseService.QuoteSQLText(slot) + "'"))
     {
      ::Print(__FUNCTION__, " > the slot ", slot, " of ", strategy.Name(), " not written");
      return false;
     }
   row.Params(params, tf);
   this.EventSend((ushort)STRATEGY_MANAGER_EVENT_SLOT_CHANGED, strategy_id, 0.0, slot);
   return true;
  }
 string CStrategyManager::Read_RAM(CStrategyIndicatorSetting *slot) const
  {
   SIndicatorsRow catalog;
   if(slot == NULL)
      return "";
   if(slot.Params() != "" || this.m_IndicatorTemplateManager == NULL || !this.m_IndicatorTemplateManager.Read_RAM((ENUM_INDICATOR)slot.SourceId(), catalog))
      return slot.Params();
   return catalog.params;
  }
 bool CStrategyManager::SlotTemplate(CStrategyIndicatorSetting *slot, MqlParam &params[], string &params_text) const
  {
   if(this.m_IndicatorTemplateManager == NULL || slot == NULL || slot.Collection() != COLLECTION_SIGNALS_ID)
      return false;
   const ENUM_INDICATOR type = (ENUM_INDICATOR)slot.SourceId();
   if(!this.m_IndicatorTemplateManager.ParamsFromText(type, this.Read_RAM(slot), params))
      return false;
   params_text = this.m_IndicatorTemplateManager.ParamsText(type, params);
   return true;
  }
 bool CStrategyManager::Read_RAM(CStrategyIndicatorSetting *slot, string &params_text) const
  {
   MqlParam params[];
   return this.SlotTemplate(slot, params, params_text);
  }
 bool CStrategyManager::SlotAvailable(CStrategyIndicatorSetting *slot) const
  {
   if(slot == NULL)
      return false;
   if(slot.Collection() == COLLECTION_SERIES_ID)
      return (this.m_BarInformationManager != NULL && this.m_BarInformationManager.Read_RAM((ENUM_BAR_INFOR_TYPE)slot.SourceId()) != NULL);
   MqlParam params[];
   string params_text;
   return (this.SlotTemplate(slot, params, params_text) && this.m_IndicatorTemplateManager.Read_RAM((ENUM_INDICATOR)slot.SourceId(), params_text) != NULL);
  }
 bool CStrategyManager::Read_RAM(const long strategy_id, const string what) const
  {
   CStrategySetting *strategy = this.Read_RAM(strategy_id);
   if(strategy == NULL || what != "available" || strategy.IndicatorsTotal() == 0)
      return false;
   for(int i = 0; i < strategy.IndicatorsTotal(); i++)
      if(!this.SlotAvailable(strategy.Indicator(i)))
         return false;
   return true;
  }
 bool CStrategyManager::Create_IndicatorTemplate(const long strategy_id)
  {
   CStrategySetting *strategy = this.Read_RAM(strategy_id);
   if(strategy == NULL || this.m_IndicatorTemplateManager == NULL)
      return false;
   int made = 0;
   for(int i = 0; i < strategy.IndicatorsTotal(); i++)
     {
      CStrategyIndicatorSetting *slot = strategy.Indicator(i);
      MqlParam params[];
      string params_text;
      if(this.SlotAvailable(slot) || !this.SlotTemplate(slot, params, params_text))
         continue;
      const ENUM_INDICATOR type = (ENUM_INDICATOR)slot.SourceId();
      //--- Made for the strategy, not to be drawn: its show_on_chart is off
      if(!this.m_IndicatorTemplateManager.Update_IndicatorTemplate_Setting(type, params))
         continue;
      this.m_IndicatorTemplateManager.Update_IndicatorTemplate_Setting(type, params_text, "show_on_chart", false, INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED);
      made++;
     }
   ::Print("Complete ", __FUNCTION__, " > ", made, " templates of the ", strategy.IndicatorsTotal(), " slots of ", strategy.Name(), " made in Setting_IndicatorTemplate");
   return true;
  }
 bool CStrategyManager::Update_Strategy_Setting(const long strategy_id, const string column, const bool on)
  {
   CStrategySetting *strategy = this.Read_RAM(strategy_id);
   if(strategy == NULL || this.m_CDatabaseService == NULL || column != "show_on_chart")
      return false;
   if(!this.m_CDatabaseService.Update("Common", "UPDATE Setting_Strategy SET show_on_chart = " + (string)(int)on + " WHERE strategy_id = " + (string)strategy_id))
     {
      ::Print(__FUNCTION__, " > ", column, " of ", strategy.Name(), " not written");
      return false;
     }
   strategy.ShowOnChart(on);
   return true;
  }
 bool CStrategyManager::Update_Strategy_Setting(const long strategy_id, const string column, const ENUM_TIMEFRAMES tf)
  {
   CStrategySetting *strategy = this.Read_RAM(strategy_id);
   if(strategy == NULL || this.m_CDatabaseService == NULL || column != "tf_enum")
      return false;
   string value_tf = "NULL";
   if(tf != PERIOD_CURRENT)
      value_tf = (string)(int)tf;
   if(!this.m_CDatabaseService.Update("Common", "UPDATE Setting_Strategy SET tf_enum = " + value_tf + " WHERE strategy_id = " + (string)strategy_id))
     {
      ::Print(__FUNCTION__, " > ", column, " of ", strategy.Name(), " not written");
      return false;
     }
   strategy.Timeframe(tf);
   return true;
  }
 int CStrategyManager::ReadDataFromDB(const string symbol, const ENUM_TIMEFRAMES timeframe, const datetime from_time, const datetime to_time, const long strategy_id,
                                      long &times[], string &roles[], long &sides[])
  {
   ::ArrayResize(times, 0);
   ::ArrayResize(roles, 0);
   ::ArrayResize(sides, 0);
   SStrategyResultRow rows[];
   if(this.m_CDatabaseService == NULL ||
      !this.m_CDatabaseService.Read("Account", "SELECT bar_time, role, signal_direction FROM StrategyCollection WHERE name = '" + this.m_CDatabaseService.QuoteSQLText(symbol) +
                                               "' AND tf_enum = " + (string)(int)timeframe + " AND bar_time >= " + (string)(long)from_time + " AND bar_time <= " + (string)(long)to_time +
                                               " AND strategy_id = " + (string)strategy_id, rows))
      return WRONG_VALUE;
   int total = ::ArraySize(rows);
   ::ArrayResize(times, total);
   ::ArrayResize(roles, total);
   ::ArrayResize(sides, total);
   for(int i = 0; i < total; i++)
     {
      times[i] = rows[i].bar_time;
      roles[i] = rows[i].role;
      sides[i] = rows[i].signal_direction;
     }
   return total;
  }
 int CStrategyManager::Read_RAM(long &ids[]) const
  {
   int total = this.m_list_strategy.Total();
   ::ArrayResize(ids, total);
   for(int i = 0; i < total; i++)
     {
      CStrategySetting *strategy = this.m_list_strategy.At(i);
      ids[i] = (strategy != NULL ? strategy.StrategyId() : WRONG_VALUE);
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The tables, the catalog (a strategy no longer in it goes, with   |
 //| its rows), then the tables to RAM                                |
 //+------------------------------------------------------------------+
 bool CStrategyManager::OnInitEvent(void)
  {
    if(this.m_CDatabaseService == NULL)
      {
       ::Print(__FUNCTION__, " > DatabaseService is not set");
       return false;
      }
    if(!this.m_first_start)   // a chart change writes nothing
       return true;
    //--- tf_enum NULL: the tf of the chart (timeframes has no PERIOD_CURRENT)
    string sql_create_table_Setting_Strategy = "CREATE TABLE IF NOT EXISTS Setting_Strategy (strategy_id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL UNIQUE, "
                                               "reference TEXT NOT NULL DEFAULT '', tf_enum INTEGER REFERENCES timeframes (tf_enum), show_on_chart INTEGER NOT NULL DEFAULT 0)";
    if(!this.m_CDatabaseService.Create("Common", sql_create_table_Setting_Strategy))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't create table Setting_Strategy");
       return false;
      }
    //--- The table of an EA before show_on_chart gets it
    SStrategyColumns columns;
    if(this.m_CDatabaseService.Read("Common", "SELECT COUNT(*) FROM pragma_table_info('Setting_Strategy') WHERE name = 'show_on_chart'", columns) && columns.count < 1 &&
       !this.m_CDatabaseService.Update("Common", "ALTER TABLE Setting_Strategy ADD COLUMN show_on_chart INTEGER NOT NULL DEFAULT 0"))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't add show_on_chart to Setting_Strategy");
       return false;
      }
    //--- The table of the account: the entries and exits Python found (role "entry" / "exit", the side opened or closed), same schema as SignalsCollection
    string sql_create_table_StrategyCollection = "CREATE TABLE IF NOT EXISTS StrategyCollection (name TEXT NOT NULL, tf_enum INTEGER NOT NULL, strategy_id INTEGER NOT NULL, "
                                                 "role TEXT NOT NULL, bar_time INTEGER NOT NULL, signal_direction INTEGER NOT NULL, "
                                                 "PRIMARY KEY (name, tf_enum, strategy_id, role, bar_time, signal_direction)) WITHOUT ROWID";
    if(!this.m_CDatabaseService.Create("Account", sql_create_table_StrategyCollection))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't create table StrategyCollection");
       return false;
      }
    //--- A slot points to a catalog: collection COLLECTION_SIGNALS_ID -> indicators.type_enum, COLLECTION_SERIES_ID -> Setting_BarInformation.type_infor
    //--- tf_enum NULL: the tf of the strategy; params NULL: the params of indicators
    string sql_create_table_Setting_StrategyIndicator = "CREATE TABLE IF NOT EXISTS Setting_StrategyIndicator (strategy_id INTEGER NOT NULL REFERENCES Setting_Strategy (strategy_id), "
                                                        "slot TEXT NOT NULL, collection INTEGER NOT NULL, source_id INTEGER NOT NULL, tf_enum INTEGER REFERENCES timeframes (tf_enum), "
                                                        "params TEXT, PRIMARY KEY (strategy_id, slot))";
    if(!this.m_CDatabaseService.Create("Common", sql_create_table_Setting_StrategyIndicator))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't create table Setting_StrategyIndicator");
       return false;
      }
    string sql_create_table_Setting_StrategyCondition = "CREATE TABLE IF NOT EXISTS Setting_StrategyCondition (strategy_id INTEGER NOT NULL REFERENCES Setting_Strategy (strategy_id), "
                                                        "role TEXT NOT NULL, signal_direction INTEGER NOT NULL, slot TEXT NOT NULL, rule TEXT NOT NULL, "
                                                        "PRIMARY KEY (strategy_id, role, signal_direction, slot, rule))";
    if(!this.m_CDatabaseService.Create("Common", sql_create_table_Setting_StrategyCondition))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't create table Setting_StrategyCondition");
       return false;
      }
    CArrayObj catalog;
    this.Catalog(catalog);
    string in_catalog = "";
    for(int i = 0; i < catalog.Total(); i++)
      {
       CStrategySetting *strategy = catalog.At(i);
       if(i > 0)
          in_catalog += ", ";
       in_catalog += (string)strategy.StrategyId();
       if(!this.WriteCatalog(strategy))
          return false;
      }
    this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_StrategyCondition WHERE strategy_id NOT IN (" + in_catalog + ")");
    this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_StrategyIndicator WHERE strategy_id NOT IN (" + in_catalog + ")");
    this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_Strategy WHERE strategy_id NOT IN (" + in_catalog + ")");
    if(!this.ReadDataFromDB())
       return false;
    this.m_first_start = false;
    return true;
  }
#endif // CSTRATEGYMANAGER_MQH_IMPLEMENTATION
#endif // CSTRATEGYMANAGER_MQH
