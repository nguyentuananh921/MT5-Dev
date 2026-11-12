//+------------------------------------------------------------------+
//|                                              SyncManager.mqh     |
//|                                     Copyright 2026, Anhnt        |
//| CRUD table Setting_Sync in Common Database                       |
//+------------------------------------------------------------------+
#ifndef CSYNCMANAGER_MQH
#define CSYNCMANAGER_MQH
 #include "..\..\Services\DELib\DatabaseService.mqh"
 #include "..\..\Entities\Defines\CommonDefines.mqh"
 #include "..\..\Entities\Defines\EventDefines.mqh"
 #include "..\..\Entities\Bases\BaseObj.mqh"
 //+------------------------------------------------------------------+
 //| A mark of Setting_Sync not written yet (RAM only)                |
 //+------------------------------------------------------------------+
 struct SSyncMark
   {
    long             sync_object;
    long             key;
    string           params;
    string           symbol;
    ENUM_TIMEFRAMES  timeframe;
    datetime         last_update;
    long             sync_by;
   };
 //--- A row of Setting_Sync: as CDatabaseService::Read binds it (the order of the SELECT)
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
      CDatabaseService *m_CDatabaseService; // The EA holds it
       SSyncMark       m_rows[];            // RAM: the rows of this account in Setting_Sync (ReadDataFromDB), what is asked on every bar (no query of the database on a tick)
       SSyncMark       m_marks[];           // the marks of the library (Update_Sync_Setting with defer): RAM only, never written (V5 Calculation Rule: only Python saves)
       bool            m_python_done;       // the Current worker of Python wrote the pairs of Setting_SymbolTF (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE): the library reads and judges from now on
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
      //--- The table of a collection (an object that syncs: its m_type) is not there any more (deleted, or the file of the account is new): what was marked as synced for it is not
      //--- there any more, its marks of this account go and Python makes the first chunk again
       bool                ResetObject(const long sync_object);
      //--- The newest bar synced (last_update) of every key (type_infor) of a pair for an object (its m_type): the keys that have a row only.
      //--- A mark of the library (RAM) counts too. RAM only (m_rows)
       int                 Read_RAM(const long sync_object,const string symbol,const ENUM_TIMEFRAMES timeframe,long &keys[],long &last_updates[]);
      //--- The newest bar synced of an indicator (its type and params) on a pair: false when it has no row
       bool                Read_RAM(const long sync_object,const long key,const string params,const string symbol,const ENUM_TIMEFRAMES timeframe,datetime &last_update);
      //--- The newest bar synced moves forward (the row is there: Python made it with its first chunk), sync_by is the object that did it (its m_type).
      //--- defer: the mark stays in RAM only (V5: the library never writes it)
       bool                Update_Sync_Setting(const long sync_object,const long key,const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime last_update,const long sync_by,const bool defer=false,const string params="");
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
   ::ArrayResize(m_rows, total);
   for(int r = 0; r < total; r++)
     {
      m_rows[r].sync_object = rows[r].sync_object;
      m_rows[r].key         = rows[r].key_id;
      m_rows[r].params      = rows[r].params;
      m_rows[r].symbol      = rows[r].name;
      m_rows[r].timeframe   = (ENUM_TIMEFRAMES)rows[r].tf_enum;
      m_rows[r].last_update = (datetime)rows[r].last_update;
      m_rows[r].sync_by     = rows[r].sync_by;
     }
   ::Print("Complete ", __FUNCTION__, " > ", total, " marks of ", this.m_CDatabaseService.GetAccountKey(), " in Setting_Sync read, ", ::ArraySize(m_marks), " marks of the library kept in RAM");
   return true;
  }
 //+------------------------------------------------------------------+
 //| The marks of an object of this account go: its table is new, so   |
 //| Python and the collection start again from the first chunk        |
 //+------------------------------------------------------------------+
 bool CSyncManager::ResetObject(const long sync_object)
  {
   if(this.m_CDatabaseService == NULL)
      return false;
   if(!this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_Sync WHERE account_key = '" + this.Key() + "' AND sync_object = " + (string)sync_object))
      return false;
   for(int r = ::ArraySize(m_rows) - 1; r >= 0; r--)
      if(m_rows[r].sync_object == sync_object)
         ::ArrayRemove(m_rows, r, 1);
   ::Print("Complete ", __FUNCTION__, " > the table of the object ", sync_object, " was not there: its marks in Setting_Sync are cleared");
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
   for(int r = ::ArraySize(m_rows) - 1; r >= 0; r--)
      if(m_rows[r].sync_object == sync_object && m_rows[r].key == key && m_rows[r].params == params)
         ::ArrayRemove(m_rows, r, 1);
   for(int m = ::ArraySize(m_marks) - 1; m >= 0; m--)
      if(m_marks[m].sync_object == sync_object && m_marks[m].key == key && m_marks[m].params == params)
         ::ArrayRemove(m_marks, m, 1);
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
   for(int r = 0; r < ::ArraySize(m_rows); r++)
    {
     if(m_rows[r].sync_object != sync_object || m_rows[r].symbol != symbol || m_rows[r].timeframe != timeframe)
        continue;
     ::ArrayResize(keys, total + 1);
     ::ArrayResize(last_updates, total + 1);
     keys[total] = m_rows[r].key;
     last_updates[total] = (long)m_rows[r].last_update;
     total++;
    }
   //--- A mark waiting in RAM is newer than the row of the table
   for(int m = 0; m < ::ArraySize(m_marks); m++)
     {
      if(m_marks[m].sync_object != sync_object || m_marks[m].symbol != symbol || m_marks[m].timeframe != timeframe)
         continue;
      for(int k = 0; k < total; k++)
         if(keys[k] == m_marks[m].key && last_updates[k] < (long)m_marks[m].last_update)
            last_updates[k] = (long)m_marks[m].last_update;
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
   for(int r = 0; r < ::ArraySize(m_rows) && !found; r++)
      if(m_rows[r].sync_object == sync_object && m_rows[r].key == key && m_rows[r].params == params && m_rows[r].symbol == symbol && m_rows[r].timeframe == timeframe)
        {
         last_update = m_rows[r].last_update;
         found = true;
        }
   for(int m = 0; m < ::ArraySize(m_marks) && found; m++)   // a mark waiting in RAM is newer than the row of the table
      if(m_marks[m].sync_object == sync_object && m_marks[m].key == key && m_marks[m].params == params && m_marks[m].symbol == symbol && m_marks[m].timeframe == timeframe && last_update < m_marks[m].last_update)
         last_update = m_marks[m].last_update;
   return found;
  }
 //+------------------------------------------------------------------+
 //| The newest bar synced of a key moves forward                      |
 //+------------------------------------------------------------------+
 bool CSyncManager::Update_Sync_Setting(const long sync_object,const long key,const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime last_update,const long sync_by,const bool defer=false,const string params="")
  {
   if(this.m_CDatabaseService == NULL)
      return false;
   if(defer)
     {
      for(int m = 0; m < ::ArraySize(m_marks); m++)
         if(m_marks[m].sync_object == sync_object && m_marks[m].key == key && m_marks[m].params == params && m_marks[m].symbol == symbol && m_marks[m].timeframe == timeframe)
           {
            if(m_marks[m].last_update < last_update)
              {
               m_marks[m].last_update = last_update;
               m_marks[m].sync_by = sync_by;
              }
            return true;
           }
      int n = ::ArraySize(m_marks);
      ::ArrayResize(m_marks, n + 1);
      m_marks[n].sync_object = sync_object;
      m_marks[n].key = key;
      m_marks[n].params = params;
      m_marks[n].symbol = symbol;
      m_marks[n].timeframe = timeframe;
      m_marks[n].last_update = last_update;
      m_marks[n].sync_by = sync_by;
      return true;
     }
   if(!this.m_CDatabaseService.Update("Common", "UPDATE Setting_Sync SET last_update = " + (string)(long)last_update + ", sync_by = " + (string)sync_by +
                                                " WHERE account_key = '" + this.Key() + "' AND name = '" + this.m_CDatabaseService.QuoteSQLText(symbol) + "' AND tf_enum = " + (string)(int)timeframe +
                                                " AND sync_object = " + (string)sync_object + " AND key_id = " + (string)key + " AND params = '" + this.m_CDatabaseService.QuoteSQLText(params) + "' AND last_update < " + (string)(long)last_update))
      return false;   // kept: the caller judges again at the next beat (the rows are written with INSERT OR IGNORE, nothing is written twice)
   for(int r = 0; r < ::ArraySize(m_rows); r++)   // RAM follows (the UPDATE changes a row that is there only)
      if(m_rows[r].sync_object == sync_object && m_rows[r].key == key && m_rows[r].params == params && m_rows[r].symbol == symbol && m_rows[r].timeframe == timeframe &&
         m_rows[r].last_update < last_update)
        {
         m_rows[r].last_update = last_update;
         m_rows[r].sync_by = sync_by;
        }
   return true;
  }
#endif // CSYNCMANAGER_MQH_IMPLEMENTATION
#endif // CSYNCMANAGER_MQH
