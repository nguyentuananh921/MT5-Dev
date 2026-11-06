//+-------------------------------------------------------------------+
//|                                              DatabaseService.mqh  |
//| Shared SQLite database service for the library.                   |
//| The EA owns this service and injects its pointer into consumers.  |
//| It coordinates access to the Common and current Account database. |
//| Collections keep table-specific schema and data mapping; this     | 
//| New in  V4. Migrate from DatabaseDELib.mqh                        |
//| Response to working with Database as singleton service            |
//+-------------------------------------------------------------------+
#ifndef CDATABASESERVICE_MQH
#define CDATABASESERVICE_MQH
 #ifndef CDATABASESERVICE_MQH_DECLARATION
 #define CDATABASESERVICE_MQH_DECLARATION
 #include "..\..\Entities\Bases\BaseObjExt.mqh"
 #define DATABASE_SERVICE_BUSY_TIMEOUT_MS  1000              // the most a write waits for the one writing now
 #define DATABASE_SERVICE_WRITE_FLAG       "EA_Writes.flag"  // the file next to the database that makes the workers of Python step aside
 #define DATABASE_SERVICE_WRITE_QUEUE      "Local\\EA_V4_SQLLite_DatabaseWrite"   // the Windows mutex the workers of Python stand in to write
 class CDatabaseService : public CBaseObjExt
  {
   private:
    string m_database_folder;
    int    m_db_common;
    string m_file_common;
    string m_folder_accounts;
    string m_file_accounts; 
    int    m_db_account;
    string m_file_write_flag;   // next to the Common DB: the workers of Python step aside while it is there
    //m_account_key Set from EA use to Join Common Database and Accounts Database
     // ::AccountInfoString(ACCOUNT_COMPANY) + 
     // ::AccountInfoString(ACCOUNT_SERVER) + 
     // "_" + (string)::AccountInfoInteger(ACCOUNT_LOGIN);  
     string m_account_key;       
   
     bool MakeFolders(const string path);
     int GetDatabaseHandle(const string target) const;
     //--- "Move aside, I write first" / "Done, your turn" to the workers of Python
     void Create_WriteFlag(void);
     void Delete_WriteFlag(void);
   public:   

    //--- Constructor, destructor
                      CDatabaseService(const string database_folder,const string folder_accounts,const string file_accounts, const string account_key);
                     ~CDatabaseService(void);
    //--- Lifecycle: 
     bool              OnInitEvent(void);    
     string            GetAccountKey(void) const { return m_account_key; }
     string            GetDatabaseFile(const string target) const;   // the path under MQL5\Files: Python gets it from the EA
    //Helper     
     string            QuoteSQLText(const string text) const; 
     string            InList(const long &values[]) const;   
     //CRUD Operation
      bool Create(const string target, const string sql);
      bool Create(const string target, const string sql, long &insert_id);
      bool Update(const string target, const string sql);
      bool Delete(const string target, const string sql);
      template<typename T> bool Read(const string target, const string sql, T &resultOut);
      template<typename T> bool Read(const string target, const string sql, T &resultsOut[]);
      
  };
 #endif // CDATABASESERVICE_MQH_DECLARATION
 #ifndef CDATABASESERVICE_MQH_IMPLEMENTATION
 #define CDATABASESERVICE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CDatabaseService::CDatabaseService(const string database_folder,const string folder_accounts,const string file_accounts,const string account_key) :
   m_database_folder(database_folder),
   m_db_common(INVALID_HANDLE),
   m_file_common(::MQLInfoString(MQL_PROGRAM_NAME) + "_Common.sqlite3"),
   m_folder_accounts(folder_accounts),
   m_file_accounts(file_accounts),
   m_db_account(INVALID_HANDLE),
   m_account_key(account_key)
  {
    this.SetSubFolderName(database_folder);
    this.m_file_write_flag = this.GetFolderName() + "\\" + DATABASE_SERVICE_WRITE_FLAG;
  }
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CDatabaseService::~CDatabaseService(void)
  {
   this.Delete_WriteFlag();
   if(m_db_common  != INVALID_HANDLE) { ::DatabaseClose(m_db_common);  m_db_common  = INVALID_HANDLE; }
   if(m_db_account != INVALID_HANDLE) { ::DatabaseClose(m_db_account); m_db_account = INVALID_HANDLE; }
  }
 bool CDatabaseService::OnInitEvent (void)
  {
    if(!this.m_first_start)   // the databases stay open across a chart change
     return true;
    //--- 1. Open Common DB
     string common_path = this.GetDatabaseFile("Common");
     if(!this.MakeFolders(common_path))
       return false;
     m_db_common = ::DatabaseOpen(common_path, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
    if(m_db_common == INVALID_HANDLE)
     {
      ::Print(__FUNCTION__, " > Common DB not opened: ", common_path, ", error ", ::GetLastError());
      return false;
     }
     ::DatabaseExecute(m_db_common, "PRAGMA busy_timeout=" + (string)DATABASE_SERVICE_BUSY_TIMEOUT_MS);
     string account_path = this.GetDatabaseFile("Account");
     if(!this.MakeFolders(account_path))
        return false;
     m_db_account = ::DatabaseOpen(account_path, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
     if(m_db_account == INVALID_HANDLE)
      {
        ::Print(__FUNCTION__, " > Account DB not opened: ", account_path, ", error ", ::GetLastError());
        return false;
      }
     ::DatabaseExecute(m_db_account, "PRAGMA busy_timeout=" + (string)DATABASE_SERVICE_BUSY_TIMEOUT_MS);
     this.m_first_start = false;
     return true;
  }
 //+------------------------------------------------------------------+
 //| Makes the folders of a path (MQL5\Files\<path>), one level after |
 //| the other, so that a file can be written there; nothing happens  |
 //| to the ones that exist                                           |
 //+------------------------------------------------------------------+
 bool CDatabaseService::MakeFolders(const string path)
 {
  for(int i = 0; i < StringLen(path); i++)
    {
     ushort c = StringGetCharacter(path, i);
     if(i == 0 || (c != '/' && c != '\\'))
        continue;
     string folder = StringSubstr(path, 0, i);
     ResetLastError();
     if(!FolderCreate(folder))
       {
        int err = GetLastError();
        // 5019 = ERR_FILE_REWRITE_ERROR (folder đã tồn tại)
        if(err != 0 && err != 5019)
          {
           ::Print(__FUNCTION__, " > folder is not created: ", folder, ", error ", err);
           return false;
          }
       }
    }
  return true;
 }
 string CDatabaseService::QuoteSQLText(const string text) const
  {
   string result = text;
   ::StringReplace(result, "'", "''");
   return result;
  }    
 string CDatabaseService::InList(const long &values[]) const
  {
   string list = "";
   for(int i = 0; i < ::ArraySize(values); i++)
      list += (i > 0 ? ", " : "") + (string)values[i];
   return list;
  }
 int CDatabaseService::GetDatabaseHandle(const string target) const
  {
   if(target == "Common")
      return this.m_db_common;
   if(target == "Account")
      return this.m_db_account;

   ::Print(__FUNCTION__, " > unknown database target: ", target);
   return INVALID_HANDLE;
  }
 string CDatabaseService::GetDatabaseFile(const string target) const
  {
   if(target == "Common")
      return this.GetFolderName() + "\\" + this.m_file_common;
   if(target == "Account")
      return this.GetFolderName() + "\\" + this.m_folder_accounts + "\\" + this.m_file_accounts;

   ::Print(__FUNCTION__, " > unknown database target: ", target);
   return "";
  }
 bool CDatabaseService::Create(const string target, const string sql)
  {
   int db = this.GetDatabaseHandle(target);
   if(db == INVALID_HANDLE)
     {
      ::Print(__FUNCTION__, " > database is not open");
      return false;
     }
   this.Create_WriteFlag();
   ::ResetLastError();
   bool done = ::DatabaseExecute(db, sql);
   if(!done)
      ::Print(__FUNCTION__, " > SQL execution failed, error ", ::GetLastError());
   this.Delete_WriteFlag();
   return done;
  }
 //+------------------------------------------------------------------+
 //| "Move aside, I write first": the workers of Python read this file |
 //+------------------------------------------------------------------+
 void CDatabaseService::Create_WriteFlag(void)
  {
   int handle = ::FileOpen(this.m_file_write_flag, FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
      return;
   ::FileWriteString(handle, "1");
   ::FileClose(handle);
   this.SetAvailable(false);   // writing
  }
 //+------------------------------------------------------------------+
 //| "Done, your turn"                                                 |
 //+------------------------------------------------------------------+
 void CDatabaseService::Delete_WriteFlag(void)
  {
   if(::FileIsExist(this.m_file_write_flag))
      ::FileDelete(this.m_file_write_flag);
   this.SetAvailable(true);    // done
  }
//+------------------------------------------------------------------+
 //| Insert a row and return its last_insert_rowid                    |
 //+------------------------------------------------------------------+
 bool CDatabaseService::Create(const string target, const string sql, long &insert_id)
  {
    insert_id = 0;
    if(!this.Create(target, sql))
      return false;
    int db = this.GetDatabaseHandle(target);
    int request = ::DatabasePrepare(db, "SELECT last_insert_rowid();");
    if(request != INVALID_HANDLE)
    {
      if(::DatabaseRead(request))
        ::DatabaseColumnLong(request, 0, insert_id);
      ::DatabaseFinalize(request);
    }
    return true;
  }
 //+------------------------------------------------------------------+
 //| Execute UPDATE query                                             |
 //+------------------------------------------------------------------+
 bool CDatabaseService::Update(const string target, const string sql)
  {
    return this.Create(target, sql);
  }
 //+------------------------------------------------------------------+
 //| Execute DELETE query                                             |
 //+------------------------------------------------------------------+
 bool CDatabaseService::Delete(const string target, const string sql)
  {
    return this.Create(target, sql);
  }
 //+------------------------------------------------------------------+
 //| Read a single row into bound struct/class T                      |
 //+------------------------------------------------------------------+
template<typename T> bool CDatabaseService::Read(const string target, const string sql, T &resultOut)
 {
  int db = this.GetDatabaseHandle(target);
  if(db == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > database is not open");
     return false;
    }
  int request = ::DatabasePrepare(db, sql);
  if(request == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > prepare failed: ", sql, ", error ", ::GetLastError());
     return false;
    }
  bool success = false;
  ::ResetLastError();
  if(::DatabaseReadBind(request, resultOut))
     success = true;
  ::DatabaseFinalize(request);
  return success;
 }
 //+------------------------------------------------------------------+
 //| Read multiple rows into array of bound struct/class T            |
 //+------------------------------------------------------------------+
 template<typename T> bool CDatabaseService::Read(const string target, const string sql, T &resultsOut[])
  {
    int db = this.GetDatabaseHandle(target);
    if(db == INVALID_HANDLE)
      {
      ::Print(__FUNCTION__, " > database is not open");
      return false;
      }
    int request = ::DatabasePrepare(db, sql);
    if(request == INVALID_HANDLE)
      {
      ::Print(__FUNCTION__, " > prepare failed: ", sql, ", error ", ::GetLastError());
      return false;
      }
    ::ArrayResize(resultsOut, 0, 100);
    T row;
    while(::DatabaseReadBind(request, row))
    {
      int total = ::ArraySize(resultsOut);
      ::ArrayResize(resultsOut, total + 1, 100);
      resultsOut[total] = row;
    }
    ::DatabaseFinalize(request);
    return true;
  }

 #endif // CDATABASESERVICE_MQH_IMPLEMENTATION
#endif // CDATABASESERVICE_MQH
