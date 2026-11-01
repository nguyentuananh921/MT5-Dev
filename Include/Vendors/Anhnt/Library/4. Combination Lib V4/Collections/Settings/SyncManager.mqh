//+------------------------------------------------------------------+
//|                                              SyncManager.mqh     |
//|                                     Copyright 2026, Anhnt        |
//+------------------------------------------------------------------+
#ifndef CSYNCMANAGER_MQH
#define CSYNCMANAGER_MQH
 #include "..\..\Services\LibDatabase.mqh"
 #include "..\..\Entities\Defines\CommonDefines.mqh"
 #include "..\..\Entities\Defines\EventDefines.mqh"
 #include "..\..\Entities\Bases\BaseObj.mqh"
 #define SYNC_RESET_ROWS              5000  // the rows of a source deleted in one step of a pair (a delete of all of them stops the EA)
 //+------------------------------------------------------------------+
 //| A mark of Setting_Sync not written yet (RAM only)                |
 //+------------------------------------------------------------------+
 struct SSyncMark
   {
    long             sync_object;
    long             key;
    long             symbol_id;
    ENUM_TIMEFRAMES  timeframe;
    datetime         last_update;
    long             sync_by;
   };
#ifndef CSYNCMANAGER_MQH_DECLARATION
#define CSYNCMANAGER_MQH_DECLARATION
 class CSyncManager : public CBaseObj
   {
     private:
       int             m_db;                // the open database: Setting_Sync is written here
       SSyncMark       m_rows[];            // RAM: the rows of this account in Setting_Sync (SyncDataFromDB), what is asked on every bar (no query of the database on a tick)
       SSyncMark       m_marks[];           // the marks waiting to be written (Advance_SyncManager with defer): written by SyncDataToDB after the rows of their object
       bool            m_python_done;       // the Current worker of Python wrote the pairs of Setting_SymbolTF (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE): the library reads and judges from now on
       bool            NextPair_SyncManager(const long sync_object,const long key,long &symbol_id,ENUM_TIMEFRAMES &timeframe);
       bool            DropMark_SyncManager(const long sync_object,const long key,const long symbol_id,const ENUM_TIMEFRAMES timeframe);
       string          Key(void) const { return LibDatabase_AccountKey(); }
     public:
                     CSyncManager(void) : m_db(INVALID_HANDLE),m_python_done(false) {}
                    ~CSyncManager(void) { if(m_db != INVALID_HANDLE) ::DatabaseClose(m_db); }
      //--- Lifecycle - same convention as the other managers: opens the database and makes the table (its rows go to RAM after Python: OnChartEvent)
       bool                OnInitEvent(void);
      //--- Heard before the collections. PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE: the marks go to RAM and the library may judge; PYTHON_BRIDGE_EVENT_CURRENT_START: it waits again
       bool                OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
      //--- Python has done its part of the pairs of Setting_SymbolTF: the library reads and judges them (Readme: every hand of the library starts after Python)
       bool                IsPythonDone(void)                         const { return m_python_done; }
      //--- The rows of this account in Setting_Sync go to RAM (once at OnInit, then when Python tells it wrote more); the marks waiting to be written stay
       bool                SyncDataFromDB(void);
      //--- The table of a collection (an object that syncs: its m_type) is not there any more (deleted, or the file of the account is new): what was marked as synced for it is not
      //--- there any more, its marks of this account go and Python makes the first chunk again
       bool                ResetObject_SyncManager(const long sync_object);
      //--- A source (a type of information, an indicator template) is judged again, or is gone: a step of it goes pair by pair, for the pairs that still have its mark: the rows
      //--- of the pair in the table of the account (account_db, table, key_column: its own) are deleted SYNC_RESET_ROWS at a time, then its mark goes. True when no pair has the
      //--- mark any more; the step stops at budget_ms (started = the tick count of the beat)
       bool                ResetStep_SyncManager(const int account_db,const string table,const string key_column,const long sync_object,const long key,const ulong started,const uint budget_ms);
      //--- The newest bar synced (last_update) of every key (type_infor or template_id) of a pair for an object (its m_type): the keys that have a row only.
      //--- A mark waiting to be written counts as written. RAM only (m_rows)
       int                 Ranges_SyncManager(const long sync_object,const long symbol_id,const ENUM_TIMEFRAMES timeframe,long &keys[],long &last_updates[]);
      //--- The newest bar synced moves forward (the row is there: Python made it with its first chunk), sync_by is the object that did it (its m_type).
      //--- defer: the mark waits in RAM, SyncDataToDB writes it
       bool                Advance_SyncManager(const long sync_object,const long key,const long symbol_id,const ENUM_TIMEFRAMES timeframe,const datetime last_update,const long sync_by,const bool defer=false);
      //--- The marks of an object waiting in RAM go to Setting_Sync (the object wrote its rows first): every pair, or one pair (symbol_id > 0). True when none of them is left
       bool                SyncDataToDB(const long sync_object,const long symbol_id=0,const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT);
      //--- The rows of a table of progress an EA before Setting_Sync made in the file of the account (symbol_id, tf_enum, key, first_bar_time, last_bar_time,
      //--- updated_at) go to Setting_Sync as Python's, then the old table goes. Nothing happens when it is not there
       bool                Import_SyncManager(const int account_db,const string old_table,const string key_column,const long sync_object);
   };
#endif // CSYNCMANAGER_MQH_DECLARATION
#ifndef CSYNCMANAGER_MQH_IMPLEMENTATION
#define CSYNCMANAGER_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Open the database once: it stays open while the EA runs. Python   |
 //| writes to the same file, so a write waits for it a short time     |
 //+------------------------------------------------------------------+
 bool CSyncManager::OnInitEvent(void)
  {
   if(m_db != INVALID_HANDLE)
      return true;   // a CHARTCHANGE reinit keeps the database open
   m_db = LibDatabase_Open(DATABASE_OPEN_READWRITE);
   if(m_db == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > the database ", LIB_DATABASE_FILE, " is not opened, error ", ::GetLastError());
     return false;
    }
   ::DatabaseExecute(m_db, "PRAGMA busy_timeout="+(string)LIB_DATABASE_BUSY_MS);
   //--- The table is this class's: sync_object is the m_type of the collection that finds (COLLECTION_*_ID), key_id the type_infor or the template id. The times are the open
   //--- time of a bar. last_update: the newest bar synced; sync_by: the m_type of whoever moved it last (OBJECT_DE_TYPE_PYTHON or the collection itself).
   //--- lost_from_time .. lost_to_time: what is still missing before the bars of the first chunk, for the History workers of Python (lost_from_time 0: back to the first bar;
   //--- both 0: nothing is missing)
   string who = "Make Setting_Sync";
   LibDatabase_AskToWrite();   // the workers of Python let this write go first
   const string columns = "(account_key TEXT NOT NULL REFERENCES accounts (account_key), symbol_id INTEGER NOT NULL REFERENCES symbols (id), "
                          "tf_enum INTEGER NOT NULL REFERENCES timeframes (tf_enum), sync_object INTEGER NOT NULL, key_id INTEGER NOT NULL, "
                          "lost_from_time INTEGER NOT NULL DEFAULT 0, lost_to_time INTEGER NOT NULL DEFAULT 0, sync_by INTEGER NOT NULL DEFAULT "+(string)(int)OBJECT_DE_TYPE_PYTHON+", "
                          "last_update INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (account_key, symbol_id, tf_enum, sync_object, key_id))";
   //--- The older shape (from_time, to_time, updated_at) moves: the oldest bar judged is what is still missing before it, the newest bar synced stays; a row that had no
   //--- oldest bar yet has no first chunk, it goes (Python makes the chunk again)
   const bool old_shape = LibDatabase_TableExists(m_db, "Setting_Sync") && LibDatabase_ColumnExists(m_db, "Setting_Sync", "to_time");
   bool done = true;
   if(old_shape)
      done = ::DatabaseExecute(m_db, "DROP TABLE IF EXISTS Setting_Sync_new") &&
             ::DatabaseExecute(m_db, "CREATE TABLE Setting_Sync_new " + columns) &&
             ::DatabaseExecute(m_db, "INSERT INTO Setting_Sync_new (account_key, symbol_id, tf_enum, sync_object, key_id, lost_from_time, lost_to_time, sync_by, last_update) "
                                     "SELECT account_key, symbol_id, tf_enum, sync_object, key_id, 0, from_time, sync_by, to_time FROM Setting_Sync WHERE from_time <> 0") &&
             ::DatabaseExecute(m_db, "DROP TABLE Setting_Sync") &&
             ::DatabaseExecute(m_db, "ALTER TABLE Setting_Sync_new RENAME TO Setting_Sync");
   if(!done || !::DatabaseExecute(m_db, "CREATE TABLE IF NOT EXISTS Setting_Sync " + columns))
    {
     LibDatabase_WriteRefused(who);
     ::Print(__FUNCTION__, " > the table Setting_Sync is not made, error ", ::GetLastError());
     return false;
    }
   LibDatabase_WriteDone(who);
   ::Print("Complete ", __FUNCTION__, " > ", LIB_DATABASE_FILE, " opened");
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
   if(id != CHARTEVENT_CUSTOM + PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE)
      return false;
   m_python_done = this.SyncDataFromDB();
   return m_python_done;
  }
 //+------------------------------------------------------------------+
 //| The rows of this account go to RAM                                |
 //+------------------------------------------------------------------+
 bool CSyncManager::SyncDataFromDB(void)
  {
   if(m_db == INVALID_HANDLE)
      return false;
   int request = ::DatabasePrepare(m_db, "SELECT sync_object, key_id, symbol_id, tf_enum, last_update, sync_by FROM Setting_Sync WHERE account_key = '" + this.Key() + "'");
   if(request == INVALID_HANDLE)
    {
     ::Print("MY DEBUG    CSyncManager::SyncDataFromDB the query is not accepted, error ", ::GetLastError());
     return false;
    }
   ::ArrayResize(m_rows, 0);
   int total = 0;
   while(::DatabaseRead(request))
    {
     long tf = 0, last_update = 0;
     ::ArrayResize(m_rows, total + 1, 1024);
     ::DatabaseColumnLong(request, 0, m_rows[total].sync_object);
     ::DatabaseColumnLong(request, 1, m_rows[total].key);
     ::DatabaseColumnLong(request, 2, m_rows[total].symbol_id);
     ::DatabaseColumnLong(request, 3, tf);
     ::DatabaseColumnLong(request, 4, last_update);
     ::DatabaseColumnLong(request, 5, m_rows[total].sync_by);
     m_rows[total].timeframe = (ENUM_TIMEFRAMES)tf;
     m_rows[total].last_update = (datetime)last_update;
     total++;
    }
   ::DatabaseFinalize(request);
   ::Print("Complete ", __FUNCTION__, " > ", total, " marks of ", this.Key(), " in Setting_Sync read, ", ::ArraySize(m_marks), " marks waiting to be written kept");
   return true;
  }
 //+------------------------------------------------------------------+
 //| The marks of an object of this account go: its table is new, so   |
 //| Python and the collection start again from the first chunk        |
 //+------------------------------------------------------------------+
 bool CSyncManager::ResetObject_SyncManager(const long sync_object)
  {
   if(m_db == INVALID_HANDLE)
      return false;
   if(!::DatabaseExecute(m_db, "DELETE FROM Setting_Sync WHERE account_key = '" + this.Key() + "' AND sync_object = " + (string)sync_object))
    {
     ::Print("MY DEBUG    CSyncManager::ResetObject_SyncManager the marks of ", this.Key(), " (object ", sync_object, ") are not deleted, error ", ::GetLastError());
     return false;
    }
   for(int r = ::ArraySize(m_rows) - 1; r >= 0; r--)
      if(m_rows[r].sync_object == sync_object)
         ::ArrayRemove(m_rows, r, 1);
   ::Print("Complete ", __FUNCTION__, " > the table of the object ", sync_object, " was not there: its marks of ", this.Key(), " in Setting_Sync are cleared");
   return true;
  }
 //+------------------------------------------------------------------+
 //| The first pair that has the mark of a key                         |
 //+------------------------------------------------------------------+
 bool CSyncManager::NextPair_SyncManager(const long sync_object,const long key,long &symbol_id,ENUM_TIMEFRAMES &timeframe)
  {
   if(m_db == INVALID_HANDLE)
      return false;
   int request = ::DatabasePrepare(m_db, "SELECT symbol_id, tf_enum FROM Setting_Sync WHERE account_key = '" + this.Key() + "' AND sync_object = " + (string)sync_object +
                                         " AND key_id = " + (string)key + " LIMIT 1");
   if(request == INVALID_HANDLE)
      return false;
   bool found = ::DatabaseRead(request);
   if(found)
     {
      long tf = 0;
      ::DatabaseColumnLong(request, 0, symbol_id);
      ::DatabaseColumnLong(request, 1, tf);
      timeframe = (ENUM_TIMEFRAMES)tf;
     }
   ::DatabaseFinalize(request);
   return found;
  }
 //+------------------------------------------------------------------+
 //| The mark of a key on a pair goes: Python makes its first chunk    |
 //| again (and goes back in its history)                              |
 //+------------------------------------------------------------------+
 bool CSyncManager::DropMark_SyncManager(const long sync_object,const long key,const long symbol_id,const ENUM_TIMEFRAMES timeframe)
  {
   if(m_db == INVALID_HANDLE)
      return false;
   string who = "DropMark Setting_Sync (object " + (string)sync_object + ", key " + (string)key + ", symbol_id " + (string)symbol_id + ", tf_enum " + (string)(int)timeframe + ")";
   LibDatabase_AskToWrite();   // the first place before the try: the workers of Python let this write go first
   if(!::DatabaseExecute(m_db, "DELETE FROM Setting_Sync WHERE account_key = '" + this.Key() + "' AND symbol_id = " + (string)symbol_id + " AND tf_enum = " + (string)(int)timeframe +
                               " AND sync_object = " + (string)sync_object + " AND key_id = " + (string)key))
    {
     LibDatabase_WriteRefused(who);   // kept: the next beat tries again
     return false;
    }
   LibDatabase_WriteDone(who);
   for(int r = ::ArraySize(m_rows) - 1; r >= 0; r--)
      if(m_rows[r].sync_object == sync_object && m_rows[r].key == key && m_rows[r].symbol_id == symbol_id && m_rows[r].timeframe == timeframe)
         ::ArrayRemove(m_rows, r, 1);
   return true;
  }
 //+------------------------------------------------------------------+
 //| A step of judging a source again, or of dropping it               |
 //+------------------------------------------------------------------+
 bool CSyncManager::ResetStep_SyncManager(const int account_db,const string table,const string key_column,const long sync_object,const long key,const ulong started,const uint budget_ms)
  {
   while(::GetTickCount64()-started<=budget_ms)
     {
      long symbol_id=0;
      ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT;
      if(!this.NextPair_SyncManager(sync_object,key,symbol_id,timeframe))
         return true;   // no pair has the mark: the rows and the marks are gone
      string wanted="symbol_id = "+(string)symbol_id+" AND tf_enum = "+(string)(int)timeframe+" AND "+key_column+" = "+(string)key;
      string who="Reset "+table+" ("+wanted+")";
      LibDatabase_AskToWrite();   // the first place: the EA is the one that writes
      if(!::DatabaseExecute(account_db,"DELETE FROM "+table+" WHERE "+wanted+" AND bar_time IN (SELECT bar_time FROM "+table+" WHERE "+wanted+" LIMIT "+(string)SYNC_RESET_ROWS+")"))
        {
         LibDatabase_WriteRefused(who);
         return false;   // the database is busy: the next beat tries again
        }
      int request=::DatabasePrepare(account_db,"SELECT 1 FROM "+table+" WHERE "+wanted+" LIMIT 1");
      bool left=(request!=INVALID_HANDLE && ::DatabaseRead(request));
      if(request!=INVALID_HANDLE)
         ::DatabaseFinalize(request);
      LibDatabase_WriteDone(who);
      if(left)
         return false;   // rows are left in this pair: the next beat goes on
      if(!this.DropMark_SyncManager(sync_object,key,symbol_id,timeframe))   // the rows of the pair are gone: its mark goes
         return false;   // the database is busy: the next beat tries again (the rows are gone already, nothing is deleted twice)
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| The newest bar synced of every key of a pair                      |
 //+------------------------------------------------------------------+
 int CSyncManager::Ranges_SyncManager(const long sync_object,const long symbol_id,const ENUM_TIMEFRAMES timeframe,long &keys[],long &last_updates[])
  {
   ::ArrayResize(keys, 0);
   ::ArrayResize(last_updates, 0);
   int total = 0;
   for(int r = 0; r < ::ArraySize(m_rows); r++)
    {
     if(m_rows[r].sync_object != sync_object || m_rows[r].symbol_id != symbol_id || m_rows[r].timeframe != timeframe)
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
      if(m_marks[m].sync_object != sync_object || m_marks[m].symbol_id != symbol_id || m_marks[m].timeframe != timeframe)
         continue;
      for(int k = 0; k < total; k++)
         if(keys[k] == m_marks[m].key && last_updates[k] < (long)m_marks[m].last_update)
            last_updates[k] = (long)m_marks[m].last_update;
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The newest bar synced of a key moves forward                      |
 //+------------------------------------------------------------------+
 bool CSyncManager::Advance_SyncManager(const long sync_object,const long key,const long symbol_id,const ENUM_TIMEFRAMES timeframe,const datetime last_update,const long sync_by,const bool defer=false)
  {
   if(m_db == INVALID_HANDLE)
      return false;
   if(defer)
     {
      for(int m = 0; m < ::ArraySize(m_marks); m++)
         if(m_marks[m].sync_object == sync_object && m_marks[m].key == key && m_marks[m].symbol_id == symbol_id && m_marks[m].timeframe == timeframe)
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
      m_marks[n].symbol_id = symbol_id;
      m_marks[n].timeframe = timeframe;
      m_marks[n].last_update = last_update;
      m_marks[n].sync_by = sync_by;
      return true;
     }
   string who = "Advance Setting_Sync (object " + (string)sync_object + ", key " + (string)key + ", symbol_id " + (string)symbol_id + ", tf_enum " + (string)(int)timeframe + ")";
   LibDatabase_AskToWrite();   // the first place before the try: the workers of Python let this write go first
   if(!::DatabaseExecute(m_db, "UPDATE Setting_Sync SET last_update = " + (string)(long)last_update + ", sync_by = " + (string)sync_by +
                               " WHERE account_key = '" + this.Key() + "' AND symbol_id = " + (string)symbol_id + " AND tf_enum = " + (string)(int)timeframe +
                               " AND sync_object = " + (string)sync_object + " AND key_id = " + (string)key + " AND last_update < " + (string)(long)last_update))
    {
     LibDatabase_WriteRefused(who);   // kept: the caller judges again at the next beat (the rows are written with INSERT OR IGNORE, nothing is written twice)
     return false;
    }
   LibDatabase_WriteDone(who);
   for(int r = 0; r < ::ArraySize(m_rows); r++)   // RAM follows (the UPDATE changes a row that is there only)
      if(m_rows[r].sync_object == sync_object && m_rows[r].key == key && m_rows[r].symbol_id == symbol_id && m_rows[r].timeframe == timeframe &&
         m_rows[r].last_update < last_update)
        {
         m_rows[r].last_update = last_update;
         m_rows[r].sync_by = sync_by;
        }
   return true;
  }
 //+------------------------------------------------------------------+
 //| The marks of an object waiting in RAM go to Setting_Sync          |
 //+------------------------------------------------------------------+
 bool CSyncManager::SyncDataToDB(const long sync_object,const long symbol_id=0,const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   for(int m = ::ArraySize(m_marks) - 1; m >= 0; m--)
     {
      if(m_marks[m].sync_object != sync_object || (symbol_id > 0 && (m_marks[m].symbol_id != symbol_id || m_marks[m].timeframe != timeframe)))
         continue;
      if(!this.Advance_SyncManager(m_marks[m].sync_object, m_marks[m].key, m_marks[m].symbol_id, m_marks[m].timeframe, m_marks[m].last_update, m_marks[m].sync_by))
         return false;   // the database is busy: the rest waits for the next call
      ::ArrayRemove(m_marks, m, 1);
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| The old table of progress of the file of the account moves here   |
 //+------------------------------------------------------------------+
 bool CSyncManager::Import_SyncManager(const int account_db,const string old_table,const string key_column,const long sync_object)
  {
   if(m_db == INVALID_HANDLE || account_db == INVALID_HANDLE)
      return false;
   int exists = ::DatabasePrepare(account_db, "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = '" + old_table + "'");
   if(exists == INVALID_HANDLE)
      return false;
   long found = 0;
   if(::DatabaseRead(exists))
      ::DatabaseColumnLong(exists, 0, found);
   ::DatabaseFinalize(exists);
   if(found == 0)
      return false;   // the table is not there (moved already): nothing to move
   int request = ::DatabasePrepare(account_db, "SELECT symbol_id, tf_enum, " + key_column + ", first_bar_time, last_bar_time FROM " + old_table);
   if(request == INVALID_HANDLE)
      return false;
   long rows[][5];
   int total = 0;
   while(::DatabaseRead(request))
    {
     ::ArrayResize(rows, total + 1);
     for(int column = 0; column < 5; column++)
        ::DatabaseColumnLong(request, column, rows[total][column]);
     total++;
    }
   ::DatabaseFinalize(request);
   if(!::DatabaseTransactionBegin(m_db))
      return false;
   bool done = true;
   for(int row = 0; row < total && done; row++)
      done = ::DatabaseExecute(m_db, "INSERT OR IGNORE INTO Setting_Sync (account_key, symbol_id, tf_enum, sync_object, key_id, lost_from_time, lost_to_time, sync_by, last_update) VALUES ('" + this.Key() + "', " +
                                     (string)rows[row][0] + ", " + (string)rows[row][1] + ", " + (string)sync_object + ", " + (string)rows[row][2] + ", 0, " + (string)rows[row][3] + ", " +
                                     (string)(int)OBJECT_DE_TYPE_PYTHON + ", " + (string)rows[row][4] + ")");
   if(!done)
    {
     ::DatabaseTransactionRollback(m_db);
     ::Print("MY DEBUG    CSyncManager::Import_SyncManager the rows of ", old_table, " are not moved, error ", ::GetLastError());
     return false;
    }
   if(!::DatabaseTransactionCommit(m_db))
      return false;
   ::Print("Complete ", __FUNCTION__, " > ", total, " rows of ", old_table, " moved to Setting_Sync");
   this.SyncDataFromDB();   // the moved marks go to RAM
   return ::DatabaseExecute(account_db, "DROP TABLE " + old_table);
  }
#endif // CSYNCMANAGER_MQH_IMPLEMENTATION
#endif // CSYNCMANAGER_MQH
