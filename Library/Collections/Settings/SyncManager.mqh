//+------------------------------------------------------------------+
//|                                              SyncManager.mqh     |
//|                                     Copyright 2026, Anhnt        |
//| CRUD table Setting_Sync in Common Database                       |
//+------------------------------------------------------------------+
//--- Change in V5: the rows and the marks on RAM are CSyncMark objects (WorkingOnRamSaveToDB rule 2, were struct SSyncMark arrays); the library never writes
//--- a mark (only Python saves): Update_Sync_Setting keeps it in RAM, ResetObject (no caller) is gone
#ifndef CSYNCMANAGER_MQH
#define CSYNCMANAGER_MQH
 #include <Arrays\ArrayObj.mqh>
 #include "..\..\Services\DELib\DatabaseService.mqh"
 #include "..\..\Entities\Defines\CommonDefines.mqh"
 #include "..\..\Entities\Defines\EventDefines.mqh"
 #include "..\..\Entities\Bases\BaseObj.mqh"
 #include "..\..\Entities\Settings\SyncMark.mqh"
 #include "..\..\Entities\Strategies\StrategyBase.mqh"   // STRATEGY_ROLE_ENTRY / _EXIT: the params of the marks of a strategy
 //--- A row of Setting_Sync: as CDatabaseService::Read binds it (the order of the SELECT), a local of ReadDataFromDB only
 struct SSyncRow
   {
    long sync_object;
    long key_id;
    string params;
    string name;
    long tf_enum;
    long last_update;
    long sync_by;
   };
#ifndef CSYNCMANAGER_MQH_DECLARATION
#define CSYNCMANAGER_MQH_DECLARATION
 class CSyncManager : public CBaseObj
   {
     private:
      CDatabaseService *m_CDatabaseService;       // The EA holds it
       CArrayObj       m_list_Table_Setting_Sync; // RAM: the rows of this account in Setting_Sync (CSyncMark, ReadDataFromDB), what is asked on every bar (no query of the database on a tick)
       CArrayObj       m_list_marks;              // the marks of the library (CSyncMark, Update_Sync_Setting): RAM only, never written (V5 Calculation Rule: only Python saves)
       bool            m_python_done;             // the Current worker of Python wrote the pairs of Setting_SymbolTF (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE): the library reads and judges from now on
       bool            DropMark(const long sync_object,const long key,const string params="");   // every pair, the marks waiting in RAM too
       string          Key(void) const { return this.m_CDatabaseService.QuoteSQLText(this.m_CDatabaseService.GetAccountKey()); }
     public:
                     CSyncManager(void) : m_CDatabaseService(NULL),m_python_done(false) {}
      void            SetDatabaseService(CDatabaseService *databaseService) { this.m_CDatabaseService=databaseService; }
                    ~CSyncManager(void) {}
      //--- Lifecycle - same convention as the other managers: opens the database and makes the table (its rows go to RAM after Python: OnChartEvent)
       bool                OnInitEvent(void);
      //--- Heard before the collections. PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE: the marks go to RAM and the library may judge; PYTHON_BRIDGE_EVENT_CURRENT_START: it waits again
       bool                OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
      //--- Python has done its part of the pairs of Setting_SymbolTF: the library reads and judges them (Readme: every hand of the library starts after Python)
       bool                IsPythonDone(void)                         const { return m_python_done; }
      //--- The rows of this account in Setting_Sync go to RAM (once at OnInit, then when Python tells it wrote more); the marks of the library stay
       bool                ReadDataFromDB(void);
      //--- The newest bar synced (last_update) of every key (type_infor) of a pair for an object (its m_type): the keys that have a row only.
      //--- A mark of the library (RAM) counts too. RAM only
       int                 Read_RAM(const long sync_object,const string symbol,const ENUM_TIMEFRAMES timeframe,long &keys[],long &last_updates[]);
      //--- The newest bar synced of an indicator (its type and params) on a pair: false when it has no row
       bool                Read_RAM(const long sync_object,const long key,const string params,const string symbol,const ENUM_TIMEFRAMES timeframe,datetime &last_update);
      //--- The newest bar the library judged moves forward, sync_by is the object that did it (its m_type). Change in V5: RAM only (was written unless defer)
       bool                Update_Sync_Setting(const long sync_object,const long key,const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime last_update,const long sync_by,const string params="");
   };
#endif // CSYNCMANAGER_MQH_DECLARATION
#ifndef CSYNCMANAGER_MQH_IMPLEMENTATION
#define CSYNCMANAGER_MQH_IMPLEMENTATION
 // New In V4 after implemenation CDatabaseService
 //+------------------------------------------------------------------+
 //| The table is this class's: sync_object is the m_type of the       |
 //| collection that finds, key_id + params: the type_infor (no        |
 //| params) or the type and the params of an indicator                |
 //+------------------------------------------------------------------+
 bool CSyncManager::OnInitEvent(void)
  {
   if(this.m_CDatabaseService == NULL)
     {
      ::Print(__FUNCTION__, " > DatabaseService is not set");
      return false;
     }
   if(!this.m_first_start)   // a chart change writes nothing
      return true;
   if(!this.m_CDatabaseService.Create("Common", "CREATE TABLE IF NOT EXISTS Setting_Sync (account_key TEXT NOT NULL, name TEXT NOT NULL, "
                                                "tf_enum INTEGER NOT NULL REFERENCES timeframes (tf_enum), sync_object INTEGER NOT NULL, key_id INTEGER NOT NULL, params TEXT NOT NULL DEFAULT '', "
                                                "lost_from_time INTEGER NOT NULL DEFAULT 0, lost_to_time INTEGER NOT NULL DEFAULT 0, sync_by INTEGER NOT NULL DEFAULT " + (string)(int)OBJECT_DE_TYPE_PYTHON + ", "
                                                "last_update INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (account_key, name, tf_enum, sync_object, key_id, params), FOREIGN KEY (account_key, name) REFERENCES symbols (account_key, name))"))
     {
      ::Print(__FUNCTION__, " > DatabaseService can't create table Setting_Sync");
      return false;
     }
   this.m_first_start = false;
   return true;
  }
 //+------------------------------------------------------------------+
 //| Python wrote its part: the marks go to RAM, the library starts.   |
 //| A run of Current starts again: the library waits for it           |
 //+------------------------------------------------------------------+
 bool CSyncManager::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id == CHARTEVENT_CUSTOM + PYTHON_BRIDGE_EVENT_CURRENT_START)
     {
      m_python_done = false;
      ::Print("Complete ", __FUNCTION__, " > a run of the Current worker of Python started: the library waits for its pairs of Setting_SymbolTF");
      return true;
     }
   //--- A pair or a template was added: CPythonBridge asks Python for its rows. The library waits from now (heard before the collections): nothing is read or judged
   //--- until Python wrote them (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE), one writer for a pair at a time
   if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED || id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
     {
      m_python_done = false;
      string added = "a template";
      if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED)
         added = "the pair " + sparam + " " + ::EnumToString((ENUM_TIMEFRAMES)lparam);
      string text = "Complete " + __FUNCTION__ + " > " + added + " was added: the library waits for Python to write its rows";
      ::Print(text);
      return true;
     }
   //--- A parameter of a type changed: what was synced is not true any more. The marks go first, then CPythonBridge tells the Current worker
   if(id == CHARTEVENT_CUSTOM + BAR_INFORMATION_MANAGER_EVENT_SETUP_CHANGED)
     {
      if(!this.DropMark(COLLECTION_SERIES_ID, lparam))
        {
         ::Print(__FUNCTION__, " > the marks of the type ", lparam, " are not deleted: Python does not judge it again");
         return false;
        }
      ::Print("Complete ", __FUNCTION__, " > the marks of the type ", lparam, " in Setting_Sync are gone");
      this.EventSend((ushort)BAR_INFORMATION_MANAGER_EVENT_RESET_DONE, lparam, 0.0, "");
      return true;
     }
   //--- New in V5: a slot (its params, its tf) changed (lparam = strategy_id): its entries and exits were found with the old ones. Its marks go,
   //--- then CPythonBridge (heard next, the same event) tells the Current worker, which deletes the old rows of a key without a mark and finds them again
   if(id == CHARTEVENT_CUSTOM + STRATEGY_MANAGER_EVENT_SLOT_CHANGED)
     {
      if(!this.DropMark(COLLECTION_STRATEGY_ID, lparam, STRATEGY_ROLE_ENTRY) || !this.DropMark(COLLECTION_STRATEGY_ID, lparam, STRATEGY_ROLE_EXIT))
        {
         ::Print(__FUNCTION__, " > the marks of the strategy ", lparam, " are not deleted: Python does not find its entries again");
         return false;
        }
      ::Print("Complete ", __FUNCTION__, " > the marks of the strategy ", lparam, " in Setting_Sync are gone: Python finds its entries and exits again");
      return true;
     }
   if(id != CHARTEVENT_CUSTOM + PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE)
      return false;
   m_python_done = this.ReadDataFromDB();
   return m_python_done;
  }
 //+------------------------------------------------------------------+
 //| The rows of this account go to RAM                                |
 //+------------------------------------------------------------------+
 bool CSyncManager::ReadDataFromDB(void)
  {
   if(this.m_CDatabaseService == NULL)
      return false;
   SSyncRow rows[];
   if(!this.m_CDatabaseService.Read("Common", "SELECT sync_object, key_id, params, name, tf_enum, last_update, sync_by FROM Setting_Sync WHERE account_key = '" + this.Key() + "'", rows))
      return false;
   int total = ::ArraySize(rows);
   this.m_list_Table_Setting_Sync.Clear();
   for(int r = 0; r < total; r++)
     {
      CSyncMark *row = new CSyncMark(rows[r].sync_object, rows[r].key_id, rows[r].params, rows[r].name, (ENUM_TIMEFRAMES)rows[r].tf_enum, (datetime)rows[r].last_update, rows[r].sync_by);
      if(row != NULL && !this.m_list_Table_Setting_Sync.Add(row))
         delete row;
     }
   ::Print("Complete ", __FUNCTION__, " > ", total, " marks of ", this.m_CDatabaseService.GetAccountKey(), " in Setting_Sync read, ", this.m_list_marks.Total(), " marks of the library kept in RAM");
   return true;
  }
 //+------------------------------------------------------------------+
 //| The marks of a key go, on every pair                              |
 //+------------------------------------------------------------------+
 bool CSyncManager::DropMark(const long sync_object,const long key,const string params="")
  {
   if(this.m_CDatabaseService == NULL)
      return false;
   if(!this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_Sync WHERE account_key = '" + this.Key() + "' AND sync_object = " + (string)sync_object + " AND key_id = " + (string)key + " AND params = '" + this.m_CDatabaseService.QuoteSQLText(params) + "'"))
      return false;
   for(int r = this.m_list_Table_Setting_Sync.Total() - 1; r >= 0; r--)
     {
      CSyncMark *row = this.m_list_Table_Setting_Sync.At(r);
      if(row != NULL && row.SyncObject() == sync_object && row.Key() == key && row.Params() == params)
         this.m_list_Table_Setting_Sync.Delete(r);
     }
   for(int m = this.m_list_marks.Total() - 1; m >= 0; m--)
     {
      CSyncMark *mark = this.m_list_marks.At(m);
      if(mark != NULL && mark.SyncObject() == sync_object && mark.Key() == key && mark.Params() == params)
         this.m_list_marks.Delete(m);
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| The newest bar synced of every key of a pair                      |
 //+------------------------------------------------------------------+
 int CSyncManager::Read_RAM(const long sync_object,const string symbol,const ENUM_TIMEFRAMES timeframe,long &keys[],long &last_updates[])
  {
   ::ArrayResize(keys, 0);
   ::ArrayResize(last_updates, 0);
   int total = 0;
   for(int r = 0; r < this.m_list_Table_Setting_Sync.Total(); r++)
    {
     CSyncMark *row = this.m_list_Table_Setting_Sync.At(r);
     if(row == NULL || !row.IsOf(sync_object, symbol, timeframe))
        continue;
     ::ArrayResize(keys, total + 1);
     ::ArrayResize(last_updates, total + 1);
     keys[total] = row.Key();
     last_updates[total] = (long)row.LastUpdate();
     total++;
    }
   //--- A mark waiting in RAM is newer than the row of the table
   for(int m = 0; m < this.m_list_marks.Total(); m++)
     {
      CSyncMark *mark = this.m_list_marks.At(m);
      if(mark == NULL || !mark.IsOf(sync_object, symbol, timeframe))
         continue;
      for(int k = 0; k < total; k++)
         if(keys[k] == mark.Key() && last_updates[k] < (long)mark.LastUpdate())
            last_updates[k] = (long)mark.LastUpdate();
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The newest bar synced of an indicator on a pair                   |
 //+------------------------------------------------------------------+
 bool CSyncManager::Read_RAM(const long sync_object,const long key,const string params,const string symbol,const ENUM_TIMEFRAMES timeframe,datetime &last_update)
  {
   last_update = 0;
   bool found = false;
   for(int r = 0; r < this.m_list_Table_Setting_Sync.Total() && !found; r++)
     {
      CSyncMark *row = this.m_list_Table_Setting_Sync.At(r);
      if(row != NULL && row.IsKey(sync_object, key, params, symbol, timeframe))
        {
         last_update = row.LastUpdate();
         found = true;
        }
     }
   for(int m = 0; m < this.m_list_marks.Total() && found; m++)   // a mark waiting in RAM is newer than the row of the table
     {
      CSyncMark *mark = this.m_list_marks.At(m);
      if(mark != NULL && mark.IsKey(sync_object, key, params, symbol, timeframe) && last_update < mark.LastUpdate())
         last_update = mark.LastUpdate();
     }
   return found;
  }
 //+------------------------------------------------------------------+
 //| The newest bar the library judged moves forward: RAM only         |
 //+------------------------------------------------------------------+
 bool CSyncManager::Update_Sync_Setting(const long sync_object,const long key,const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime last_update,const long sync_by,const string params="")
  {
   for(int m = 0; m < this.m_list_marks.Total(); m++)
     {
      CSyncMark *mark = this.m_list_marks.At(m);
      if(mark != NULL && mark.IsKey(sync_object, key, params, symbol, timeframe))
        {
         mark.MoveTo(last_update, sync_by);
         return true;
        }
     }
   CSyncMark *mark = new CSyncMark(sync_object, key, params, symbol, timeframe, last_update, sync_by);
   if(mark == NULL || !this.m_list_marks.Add(mark))
     {
      delete mark;
      return false;
     }
   return true;
  }
#endif // CSYNCMANAGER_MQH_IMPLEMENTATION
#endif // CSYNCMANAGER_MQH
