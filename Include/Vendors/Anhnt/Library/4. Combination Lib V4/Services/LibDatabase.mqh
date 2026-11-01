//+------------------------------------------------------------------+
//|                                                   LibDatabase.mqh |
//| The database of the library: one SQLite file for what the EA and |
//| Python share. The tables follow the classes of the library        |
//| (accounts = CAccountsCollection, ...). What the terminal already  |
//| has is not saved: the EA asks the terminal by the key of the      |
//| account. Every class writes its own table when it starts          |
//| (OnInitEvent), after the tables it depends on                     |
//+------------------------------------------------------------------+
#ifndef __LIBDATABASE_MQH__
#define __LIBDATABASE_MQH__
 #include "..\Entities\Defines\CommonDefines.mqh"
 //--- The EA names the database (LIB_DATABASE_FILE, in its Configuration\EA Configuration.mqh, included before the library);
 //--- the folders are made before the file is opened (LibDatabase_Open)
 #ifndef LIB_DATABASE_FILE
  #error "LIB_DATABASE_FILE is defined by the EA: include its Configuration\EA Configuration.mqh before the library"
 #endif
 #define LIB_DATABASE_BUSY_MS         250   // how long a statement waits for the database when Python is writing: it is tried again at the next beat, the thread of the EA is not held
 //--- The EA writes first: the workers of Python stand in a line to write (a mutex of Windows), the EA stands in the same line and the workers let it pass (the flag
 //--- EA_Writes.flag). The name is WRITE_QUEUE_NAME of Python\libdb.py. A launch of the EA needs "Allow DLL imports", as the start of Python does
 #define LIB_DATABASE_WRITE_QUEUE     "Local\\EA_V4_SQLLite_DatabaseWrite"
 #define LIB_DATABASE_WRITE_FLAG      "EA_Writes.flag"   // the file next to the database that tells the workers the EA is next (Python reads both names from Setting_PythonBridge)
 #import "kernel32.dll"
  long CreateMutexW(long attributes,int initial_owner,string name);
  uint WaitForSingleObject(long handle,uint milliseconds);
  int  ReleaseMutex(long handle);
 #import
#ifndef LIB_ACCOUNTS_FOLDER
  #error "LIB_ACCOUNTS_FOLDER is defined by the EA: include its Configuration\EA Configuration.mqh before the library"
 #endif
//+------------------------------------------------------------------+
//| Makes the folders of a path (MQL5\Files\<path>), one level after |
//| the other, so that a file can be written there; nothing happens  |
//| to the ones that exist                                           |
//+------------------------------------------------------------------+
void LibDatabase_MakeFolders(const string path)
  {
   for(int i = 0; i < StringLen(path); i++)
     {
      ushort c = StringGetCharacter(path, i);
      if(i > 0 && (c == '/' || c == '\\'))
         FolderCreate(StringSubstr(path, 0, i));
     }
  }
//+------------------------------------------------------------------+
//| Makes the database file when it is not there (the EA calls this  |
//| first in OnInit, before any class opens it). False when it cannot|
//| be made                                                          |
//+------------------------------------------------------------------+
bool LibDatabase_Create(void)
  {
   if(FileIsExist(LIB_DATABASE_FILE))
      return true;
   LibDatabase_MakeFolders(LIB_DATABASE_FILE);
   int db = DatabaseOpen(LIB_DATABASE_FILE, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
   if(db == INVALID_HANDLE)
     {
      Print(__FUNCTION__, " > the database ", LIB_DATABASE_FILE, " is not made, error ", GetLastError());
      return false;
     }
   DatabaseClose(db);
   Print("Complete ", __FUNCTION__, " > ", LIB_DATABASE_FILE, " made");
   return true;
  }
//+------------------------------------------------------------------+
//| Opens the database of the library, its folders are made first.   |
//| INVALID_HANDLE when it cannot be opened                          |
//+------------------------------------------------------------------+
int LibDatabase_Open(const uint flags)
  {
   LibDatabase_MakeFolders(LIB_DATABASE_FILE);
   return ::DatabaseOpen(LIB_DATABASE_FILE, flags);
  }
//+------------------------------------------------------------------+
//| A text as it goes into a SQL string: the quote is doubled        |
//+------------------------------------------------------------------+
string LibDatabase_Quoted(const string text)
  {
   string result = text;
   ::StringReplace(result, "'", "''");
   return result;
  }
//+------------------------------------------------------------------+
//| A text cleaned of what a file name does not take: letters,       |
//| digits and _ . - are kept, the other runs become one _           |
//+------------------------------------------------------------------+
string LibDatabase_Safe(const string text)
  {
   string safe = "";
   bool gap = false;
   for(int i = 0; i < StringLen(text); i++)
     {
      ushort c = StringGetCharacter(text, i);
      bool keep = ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_' || c == '.' || c == '-');
      if(keep)
        {
         safe += ShortToString(c);
         gap = false;
        }
      else if(!gap)
        {
         safe += "_";
         gap = true;
        }
     }
   while(StringLen(safe) > 0 && StringGetCharacter(safe, 0) == '_')
      safe = StringSubstr(safe, 1);
   while(StringLen(safe) > 0 && StringGetCharacter(safe, StringLen(safe) - 1) == '_')
      safe = StringSubstr(safe, 0, StringLen(safe) - 1);
   return (safe == "" ? "account" : safe);
  }
//+------------------------------------------------------------------+
//| The key of the account: <server>_<login>, the server cleaned.    |
//| It is the account_key column of every table that depends on the  |
//| account                                                          |
//+------------------------------------------------------------------+
string LibDatabase_AccountKey(void)
  {
   return LibDatabase_Safe(AccountInfoString(ACCOUNT_SERVER)) + "_" + (string)AccountInfoInteger(ACCOUNT_LOGIN);
  }
//+------------------------------------------------------------------+
//| The name this account gives to the symbol of ours with this id   |
//| (symbol_account); empty when the account has none                |
//+------------------------------------------------------------------+
string LibDatabase_AccountSymbol(const int db, const long symbol_id)
  {
   int request = DatabasePrepare(db, "SELECT account_symbol FROM symbol_account WHERE account_key = '" + LibDatabase_AccountKey() + "' AND symbol_id = " + (string)symbol_id);
   if(request == INVALID_HANDLE)
      return "";
   string name = "";
   if(DatabaseRead(request))
      DatabaseColumnText(request, 0, name);
   DatabaseFinalize(request);
   return name;
  }
//+------------------------------------------------------------------+
//| The id of the symbol of ours (symbols) that a symbol of this     |
//| account is (symbol_account); 0 when it is none of ours            |
//+------------------------------------------------------------------+
long LibDatabase_SymbolID(const int db, const string account_symbol)
  {
   int request = DatabasePrepare(db, "SELECT symbol_id FROM symbol_account WHERE account_key = '" + LibDatabase_AccountKey() + "' AND account_symbol = '" + LibDatabase_Quoted(account_symbol) + "'");
   if(request == INVALID_HANDLE)
      return 0;
   long id = 0;
   if(DatabaseRead(request))
      DatabaseColumnLong(request, 0, id);
   DatabaseFinalize(request);
   return id;
  }
//+------------------------------------------------------------------+
//| The file of the account the terminal is logged in to: what the   |
//| broker gives (the bars, what Python found on them) is kept here, |
//| apart from the file the accounts share                           |
//+------------------------------------------------------------------+
string LibDatabase_AccountFile(void)
  {
   return LIB_ACCOUNTS_FOLDER + "\\" + LibDatabase_AccountKey() + ".sqlite3";
  }
//+------------------------------------------------------------------+
//| Opens the file of the account (made when it is not there with    |
//| DATABASE_OPEN_CREATE in the flags). INVALID_HANDLE when it cannot|
//+------------------------------------------------------------------+
int LibDatabase_OpenAccount(const uint flags)
  {
   LibDatabase_MakeFolders(LibDatabase_AccountFile());
   return ::DatabaseOpen(LibDatabase_AccountFile(), flags);
  }
//+------------------------------------------------------------------+
//| Is the table in the file                                          |
//+------------------------------------------------------------------+
bool LibDatabase_TableExists(const int db, const string name)
  {
   int request = DatabasePrepare(db, "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = '" + name + "'");
   if(request == INVALID_HANDLE)
      return false;
   long found = 0;
   if(DatabaseRead(request))
      DatabaseColumnLong(request, 0, found);
   DatabaseFinalize(request);
   return found > 0;
  }
//+------------------------------------------------------------------+
//| Has the table this column (a table made before the column has not) |
//+------------------------------------------------------------------+
bool LibDatabase_ColumnExists(const int db, const string table, const string column)
  {
   int request = DatabasePrepare(db, "SELECT COUNT(*) FROM pragma_table_info('" + table + "') WHERE name = '" + column + "'");
   if(request == INVALID_HANDLE)
      return false;
   long found = 0;
   if(DatabaseRead(request))
      DatabaseColumnLong(request, 0, found);
   DatabaseFinalize(request);
   return found > 0;
  }
//+------------------------------------------------------------------+
//| The EA has the first place: a write of it that is refused makes the |
//| file EA_Writes.flag next to the database, the workers of Python     |
//| that see it let it write first (they do not start another write);   |
//| the file goes when the write is done. The workers do not look at a  |
//| file older than EA_WRITE_FLAG_STALE_S seconds (the EA that made it   |
//| is gone)                                                            |
//+------------------------------------------------------------------+
string LibDatabase_FileNextToDatabase(const string name)
  {
   string file = LIB_DATABASE_FILE;
   int last = -1;
   for(int i = 0; i < StringLen(file); i++)
     {
      ushort c = StringGetCharacter(file, i);
      if(c == '/' || c == '\\')
         last = i;
     }
   return (last < 0 ? "" : StringSubstr(file, 0, last + 1)) + name;
  }
string LibDatabase_WriteFlag(void)
  {
   return LibDatabase_FileNextToDatabase(LIB_DATABASE_WRITE_FLAG);
  }
bool LibDatabase_FileExists(const string name)
  {
   return FileIsExist(LibDatabase_FileNextToDatabase(name));
  }
void LibDatabase_DoneFile(const string name)
  {
   if(FileIsExist(LibDatabase_FileNextToDatabase(name)))
      FileDelete(LibDatabase_FileNextToDatabase(name));
  }
//--- The first place before a write. The flag tells the workers of Python that the EA is next (the ones that wait in the line step aside when they get their turn);
//--- then, with take_turn, the EA stands in the same line (the mutex): waited for LIB_DATABASE_BUSY_MS at most, after it the EA tries the database anyway.
//--- The turn is given back by LibDatabase_GiveTurn (a write that is done or refused, the end of a beat). A refusal only keeps the flag raised: take_turn false
long g_lib_write_queue = 0;
bool g_lib_write_held = false;
void LibDatabase_AskToWrite(const bool take_turn = true)
  {
   int handle = FileOpen(LibDatabase_WriteFlag(), FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle != INVALID_HANDLE)
     {
      FileWriteString(handle, "1");
      FileClose(handle);
     }
   if(!take_turn || g_lib_write_held)
      return;
   if(g_lib_write_queue == 0)
      g_lib_write_queue = CreateMutexW(0, 0, LIB_DATABASE_WRITE_QUEUE);
   if(g_lib_write_queue == 0)
      return;
   uint answer = WaitForSingleObject(g_lib_write_queue, LIB_DATABASE_BUSY_MS);
   g_lib_write_held = (answer == 0 || answer == 0x80);   // WAIT_OBJECT_0, WAIT_ABANDONED (the worker that held it ended)
  }
void LibDatabase_GiveTurn(void)
  {
   if(!g_lib_write_held)
      return;
   ReleaseMutex(g_lib_write_queue);
   g_lib_write_held = false;
  }
void LibDatabase_DoneWriting(void)
  {
   if(FileIsExist(LibDatabase_WriteFlag()))
      FileDelete(LibDatabase_WriteFlag());
  }
//+------------------------------------------------------------------+
//| A write that is refused (the database is locked: Python writes) is |
//| tried again at the next beat: what was refused, how many times and |
//| since when is kept here, so that the journal can tell at which     |
//| retry it was written. who = the text that names the write          |
//+------------------------------------------------------------------+
string g_lib_busy_who[];
int    g_lib_busy_attempts[];
ulong  g_lib_busy_first_ms[];
void LibDatabase_WriteRefused(const string who)
  {
   LibDatabase_AskToWrite(false);   // the EA is still next: the flag stays
   LibDatabase_GiveTurn();    // the turn goes back, the workers write meanwhile; the EA takes it again at the next try
   int total = ArraySize(g_lib_busy_who);
   for(int i = 0; i < total; i++)
      if(g_lib_busy_who[i] == who)
        {
         g_lib_busy_attempts[i]++;
         return;
        }
   ArrayResize(g_lib_busy_who, total + 1);
   ArrayResize(g_lib_busy_attempts, total + 1);
   ArrayResize(g_lib_busy_first_ms, total + 1);
   g_lib_busy_who[total] = who;
   g_lib_busy_attempts[total] = 1;
   g_lib_busy_first_ms[total] = GetTickCount64();
   Print("MY DEBUG    LibDatabase_WriteRefused ", who, ": the first refusal, ", total + 1, " waiting");   // which write is refused (the terminal prints "database is locked" without the statement)
  }
void LibDatabase_WriteDone(const string who)
  {
   LibDatabase_GiveTurn();   // the write is done: the turn goes back to the line
   int total = ArraySize(g_lib_busy_who);
   for(int i = 0; i < total; i++)
      if(g_lib_busy_who[i] == who)
        {
         Print("MY DEBUG    LibDatabase_WriteDone ", who, " written at retry ", g_lib_busy_attempts[i], ", ", GetTickCount64() - g_lib_busy_first_ms[i], " ms after the first refusal");
         for(int j = i; j < total - 1; j++)
           {
            g_lib_busy_who[j] = g_lib_busy_who[j + 1];
            g_lib_busy_attempts[j] = g_lib_busy_attempts[j + 1];
            g_lib_busy_first_ms[j] = g_lib_busy_first_ms[j + 1];
           }
         ArrayResize(g_lib_busy_who, total - 1);
         ArrayResize(g_lib_busy_attempts, total - 1);
         ArrayResize(g_lib_busy_first_ms, total - 1);
         if(total - 1 == 0)
            LibDatabase_DoneWriting();   // nothing is waiting for its turn any more
         return;
        }
   if(total == 0)
      LibDatabase_DoneWriting();   // this write asked for the first place before its first try and was done at once: the place goes back
  }
//+------------------------------------------------------------------+
//| The rows found go to the result table of the account (a type or a |
//| template is the key), one transaction. The progress is not here:  |
//| it is CSyncManager's, written after the rows (a row that is there |
//| is never changed: INSERT OR IGNORE)                               |
//+------------------------------------------------------------------+
bool LibDatabase_AddRows(const int db, const string result_table, const string key_column, const long key, const long symbol_id, const ENUM_TIMEFRAMES timeframe,
                         const long &times[], const long &sides[])
  {
   int rows = ArraySize(times);
   if(rows == 0)
      return true;
   string who = "AddRows " + result_table + " (" + key_column + " " + (string)key + ", symbol_id " + (string)symbol_id + ", tf_enum " + (string)(int)timeframe + ")";
   LibDatabase_AskToWrite();   // the first place before the first try: the workers of Python let this write go first
   if(!DatabaseTransactionBegin(db))
     {
      LibDatabase_WriteRefused(who);
      return false;
     }
   bool done = true;
   for(int row = 0; row < rows && done; row++)
      done = DatabaseExecute(db, "INSERT OR IGNORE INTO " + result_table + " (symbol_id, tf_enum, " + key_column + ", bar_time, signal_direction) VALUES (" + (string)symbol_id + ", " + (string)(int)timeframe + ", " +
                                 (string)key + ", " + (string)times[row] + ", " + (string)sides[row] + ")");
   if(!done)
     {
      DatabaseTransactionRollback(db);
      LibDatabase_WriteRefused(who);
      Print("MY DEBUG    LibDatabase_AddRows the rows of ", result_table, " (", key_column, " ", key, ") are not written, error ", GetLastError());
      return false;
     }
   if(!DatabaseTransactionCommit(db))
     {
      LibDatabase_WriteRefused(who);
      return false;
     }
   LibDatabase_WriteDone(who);
   return true;
  }
//+------------------------------------------------------------------+
//| The ids as the text of an IN list ("NULL" when there is none: it  |
//| matches nothing)                                                  |
//+------------------------------------------------------------------+
string LibDatabase_InList(const long &ids[])
  {
   string list = "";
   for(int i = 0; i < ArraySize(ids); i++)
      list += (list == "" ? "" : ",") + (string)ids[i];
   return (list == "" ? "NULL" : list);
  }
//+------------------------------------------------------------------+
//| The tf_enum of every TF of the library as short as the timeframe  |
//| or shorter, as the text of an IN list                             |
//+------------------------------------------------------------------+
string LibDatabase_TimeframesUpTo(const ENUM_TIMEFRAMES timeframe)
  {
   string list = "";
   for(int i = 0; i < LIB_TIMEFRAMES_TOTAL; i++)
      if(LIB_TIMEFRAMES[i] <= timeframe)
         list += (list == "" ? "" : ",") + (string)(int)LIB_TIMEFRAMES[i];
   return (list == "" ? "NULL" : list);
  }
//+------------------------------------------------------------------+
//| The name of a symbol of an account without its suffix: up to the |
//| first character that is not an upper-case letter or a digit      |
//| (XAUUSDc, XAUUSDm and XAUUSD.a are XAUUSD). Only used to look    |
//| for one of OUR symbols                                           |
//+------------------------------------------------------------------+
string LibDatabase_CanonicalSymbol(const string name)
  {
   int end = 0;
   while(end < StringLen(name))
     {
      ushort c = StringGetCharacter(name, end);
      if(!((c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')))
         break;
      end++;
     }
   return (end > 0 ? StringSubstr(name, 0, end) : name);
  }
#endif // __LIBDATABASE_MQH__
