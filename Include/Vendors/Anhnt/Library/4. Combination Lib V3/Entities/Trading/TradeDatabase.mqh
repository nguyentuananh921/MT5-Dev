//+------------------------------------------------------------------+
//|                                                TradeDatabase.mqh |
//| Reads the SQLite file of the account that Python writes (the     |
//| orders of the library, with the spread of the moment) with the   |
//| SQLite functions of MQL5, read only: the EA only asks, it does   |
//| not write. The result of a query is a flat list of texts         |
//+------------------------------------------------------------------+
#ifndef __TRADEDATABASE_MQH__
#define __TRADEDATABASE_MQH__
 #define TRADE_DATABASE_FOLDER   "EA LibV3\\Trade History\\"
 //+------------------------------------------------------------------+
 //| One query, the database opened for it and closed again: Python  |
 //| writes all the time, the file is not held                        |
 //+------------------------------------------------------------------+
 class CTradeDatabase
  {
   private:
     string            m_error;                // what went wrong in the last call
   public:
   //--- The file of this account: the folder of Python, <server>_<login>.sqlite3 (Python keeps letters, digits, _ . - and makes the rest _)
     static string     FileName(void);
   //--- The columns (names) and every cell as text (cells, row after row); false when the file or the query is not there, Error() says why
     bool              Read(const string sql,string &names[],string &cells[],int &rows);
     string            Error(void)             const { return this.m_error; }
  };
 string CTradeDatabase::FileName(void)
  {
   string server=::AccountInfoString(ACCOUNT_SERVER);
   string safe="";
   bool gap=false;
   for(int i=0;i<::StringLen(server);i++)
     {
      ushort c=::StringGetCharacter(server,i);
      bool keep=((c>='A' && c<='Z') || (c>='a' && c<='z') || (c>='0' && c<='9') || c=='_' || c=='.' || c=='-');
      if(keep)
        {
         safe+=::ShortToString(c);
         gap=false;
        }
      else if(!gap)
        {
         safe+="_";
         gap=true;
        }
     }
   while(::StringLen(safe)>0 && ::StringGetCharacter(safe,0)=='_')
      safe=::StringSubstr(safe,1);
   while(::StringLen(safe)>0 && ::StringGetCharacter(safe,::StringLen(safe)-1)=='_')
      safe=::StringSubstr(safe,0,::StringLen(safe)-1);
   if(safe=="")
      safe="account";
   return TRADE_DATABASE_FOLDER+safe+"_"+(string)::AccountInfoInteger(ACCOUNT_LOGIN)+".sqlite3";
  }
 bool CTradeDatabase::Read(const string sql,string &names[],string &cells[],int &rows)
  {
   ::ArrayResize(names,0);
   ::ArrayResize(cells,0);
   rows=0;
   string file=CTradeDatabase::FileName();
   int db=::DatabaseOpen(file,DATABASE_OPEN_READONLY);
   if(db==INVALID_HANDLE)
     {
      this.m_error="the database "+file+" is not opened, error "+(string)::GetLastError();
      return false;
     }
   int request=::DatabasePrepare(db,sql);
   if(request==INVALID_HANDLE)
     {
      this.m_error="the query is not accepted, error "+(string)::GetLastError();
      ::DatabaseClose(db);
      return false;
     }
   int columns=::DatabaseColumnsCount(request);
   ::ArrayResize(names,columns);
   for(int c=0;c<columns;c++)
     {
      string name;
      ::DatabaseColumnName(request,c,name);
      names[c]=name;
     }
   int total=0;
   while(::DatabaseRead(request))
     {
      ::ArrayResize(cells,(total+1)*columns,256*columns);
      for(int c=0;c<columns;c++)
        {
         string text="";
         ::DatabaseColumnText(request,c,text);
         cells[total*columns+c]=text;
        }
      total++;
     }
   ::DatabaseFinalize(request);
   ::DatabaseClose(db);
   rows=total;
   this.m_error="";
   return true;
  }
#endif // __TRADEDATABASE_MQH__
