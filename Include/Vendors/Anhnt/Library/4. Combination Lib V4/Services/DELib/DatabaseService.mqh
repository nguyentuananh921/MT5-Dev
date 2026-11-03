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
 class CDatabaseService : public CBaseObjExt
  {
   private:
    string m_database_folder;
    int    m_db_common;
    string m_file_common;
    string m_folder_accounts;
    string m_file_accounts; 
    int    m_db_account;  
    string m_account_key; 

    long   m_write_queue;
    bool   m_write_held;

    string m_list_BusyWrite_Who[];
    int    m_list_BusyWrite_Attempts[];
    ulong  m_list_BusyWrite_FirstMS[];
    //Private Method
     bool MakeFolders(const string path);
     int GetDatabaseHandle(const string target) const;
   public:   

    //--- Constructor, destructor
                      CDatabaseService(const string database_folder,const string folder_accounts,const string file_accounts, const string account_key);
                     ~CDatabaseService(void);
    //--- Lifecycle: 
     bool              OnInitEvent(void);
    //  int               GetDBCommon(void)  const { return m_db_common; }
    //  int               GetDBAccount(void) const { return m_db_account;} 
    // Replace by int GetDatabaseHandle(const string target) const;

     string            GetAccountKey(void) const { return m_account_key; }
    //Helper     
     string QuoteSQLText(const string text) const; //Same as LibDatabase_Quoted      
     //Plan to remove 
      //bool              ExecuteCommon(const string sql);
     //CRUD Operation
      bool Create(const string target, const string sql);
      bool Create(const string target, const string sql, long &insert_id);
      bool Read(const string target, const string sql, CDatabaseReader &reader);
      bool Update(const string target, const string sql);
      bool Delete(const string target, const string sql);
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
   m_account_key(account_key),   
   m_write_queue(0),
   m_write_held(false)
  {
    this.SetSubFolderName(database_folder);      
  }
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CDatabaseService::~CDatabaseService(void)
  {
   if(m_db_common  != INVALID_HANDLE) { ::DatabaseClose(m_db_common);  m_db_common  = INVALID_HANDLE; }
   if(m_db_account != INVALID_HANDLE) { ::DatabaseClose(m_db_account); m_db_account = INVALID_HANDLE; }
  }
 bool CDatabaseService::OnInitEvent (void)
  {
    //--- 1. Open Common DB
     string common_path = this.GetFolderName() + "\\" + m_file_common;
     if(!this.MakeFolders(common_path))
       return false;
     m_db_common = ::DatabaseOpen(common_path, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
    if(m_db_common == INVALID_HANDLE)
     {
      ::Print(__FUNCTION__, " > Common DB not opened: ", common_path, ", error ", ::GetLastError());
      return false;
     }   
     string account_folder = this.GetFolderName() + "\\" + this.m_folder_accounts;
     string account_path   = account_folder + "\\" + this.m_file_accounts;     
     if(!this.MakeFolders(account_path))
        return false;
     m_db_account = ::DatabaseOpen(account_path, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
     if(m_db_account == INVALID_HANDLE)
      {
        ::Print(__FUNCTION__, " > Account DB not opened: ", account_path, ", error ", ::GetLastError());
        return false;
      }
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
    //  bool CDatabaseService::ExecuteCommon(const string sql)
    //   {
    //    if(this.m_db_common == INVALID_HANDLE)
    //      {
    //       ::Print(__FUNCTION__, " > Common DB is not open");
    //       return false;
    //      }

    //    ::ResetLastError();
    //    if(!::DatabaseExecute(this.m_db_common, sql))
    //      {
    //       ::Print(__FUNCTION__, " > SQL execution failed, error ", ::GetLastError());
    //       return false;
    //      }

    //    return true;
    //   }
 int CDatabaseService::GetDatabaseHandle(const string target) const
  {
   if(target == "Common")
      return this.m_db_common;
   if(target == "Account")
      return this.m_db_account;

   ::Print(__FUNCTION__, " > unknown database target: ", target);
   return INVALID_HANDLE;
  }
 bool CDatabaseService::Create(const string target, const string sql)
  {
   int db = this.GetDatabaseHandle(target);
   if(db == INVALID_HANDLE)
     {
      ::Print(__FUNCTION__, " > database is not open");
      return false;
     }

   ::ResetLastError();
   if(!::DatabaseExecute(db, sql))
     {
      ::Print(__FUNCTION__, " > SQL execution failed, error ", ::GetLastError());
      return false;
     }
   return true;
  }
 #endif // CDATABASESERVICE_MQH_IMPLEMENTATION
#endif // CDATABASESERVICE_MQH
