//+------------------------------------------------------------------+
//|                                              SymbolsCollection.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//| Link https://www.mql5.com/en/articles/7041                       |
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
//--- The symbols of this account, read from the database (symbol_account): the chart symbol and the Market Watch are registered there by the library
//--- (a small job, not Python's): in OnInit, then the Market Watch is watched (V3 MarketWatchEventsControl) and its events go to the chart.
//--- Change from V3: the list is the lines of symbol_account (a symbol that leaves the Market Watch stays: a pair may use it), not the Market Watch itself
#ifndef __SYMBOLSCOLLECTION_MQH__
#define __SYMBOLSCOLLECTION_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include <Arrays\ArrayString.mqh>
 #include "..\Services\LibDatabase.mqh"
 #include "..\Entities\Bases\BaseObjExt.mqh"
 #include "..\Entities\Defines\EventDefines.mqh"
 #include "..\Entities\Trading\SymbolCommon.mqh"
 #define SYMBOLS_COLLECTION_CHECK_MS  1000
#ifndef CSYMBOLSCOLLECTION_MQH_DECLARATION
#define CSYMBOLSCOLLECTION_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Collection of the symbols of this account                        |
 //+------------------------------------------------------------------+
 class CSymbolsCollection : public CBaseObjExt
  {
   private:
    int               m_db;                                        // The open database: symbol_account is asked here (SymbolID), nothing is copied
    CArrayObj         m_list_all_symbols;                          // The list of all symbol objects, in the order they were written to the database
    CArrayString      m_list_names;                                // Symbol name control list (V3): the names of the Market Watch at the last check
    int               m_delta_symbol;                              // Difference in the number of symbols compared to the previous check
    int               m_total_symbols;                             // Number of symbols in the Market Watch window
    int               m_total_symbol_prev;                         // Number of symbols in the Market Watch window during the previous check
    ulong             m_check_ms;                                  // When the Market Watch was looked at last
   //--- The symbol of OUR list (symbols) that the name of an account is: the same name, or the name without its suffix. 0 when it is none of ours
    long              FindSymbolID(const int db,const string account_symbol);
   //--- The line of a symbol of the account in symbol_account: written when it is not there, joined to the symbol of ours it is
    void              RegisterSymbol(const int db,const string account_symbol);
   //--- Save names of the Market Watch symbols (V3; Change: the names of the Market Watch, the list is symbol_account)
    void              CopySymbolsNames(void);
   //--- Return the flag of a symbol presence by its name in the (1) Market Watch window, (2) control list (V3)
    bool              IsPresentSymbolInMW(const string symbol_name);
    bool              IsPresentSymbolInControlList(const string symbol_name);
   //--- Return the number of visible symbols (V3)
    int               SymbolsTotalVisible(void)                    const;
   public:
   //--- Return the full collection list 'as is'
    CArrayObj        *GetList(void)                                   { return &this.m_list_all_symbols; }
   //--- Return the (1) symbol object, (2) the symbol object index from the list by a name (V3)
    CSymbol          *GetSymbolObjByName(const string name);
    int               GetIndexObjByName(const string name);
   //--- Return the number of new symbols in the Market Watch window (V3)
    int               NewSymbols(void)                             const { return this.m_delta_symbol;     }
   //--- Constructor, destructor
                      CSymbolsCollection(void);
                     ~CSymbolsCollection(void);
   //--- Lifecycle: the chart symbol and the Market Watch have their lines in symbol_account, then the symbols of this account are read from the database
    bool              OnInitEvent(void);
   //--- Working with the Market Watch window events (V3): fires MARKET_WATCH_EVENT_SYMBOL_ADD / _DEL / _SORT; a new symbol gets its line and its object
    void              MarketWatchEventsControl(const bool send_events=true);
   //--- Checks the Market Watch window once a second (V3)
    void              OnTimerEvent(void);
   //--- The id of the symbol of ours (symbols) that a symbol of this account is: 0 when it is none of ours
    long              SymbolID(const string account_symbol) const;
   //--- The name this account gives to the symbol of ours with this id: empty when it has none
    string            AccountSymbol(const long symbol_id) const;
  };
#endif // CSYMBOLSCOLLECTION_MQH_DECLARATION
#ifndef CSYMBOLSCOLLECTION_MQH_IMPLEMENTATION
#define CSYMBOLSCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CSymbolsCollection::CSymbolsCollection(void) : m_db(INVALID_HANDLE),m_delta_symbol(0),m_total_symbols(0),m_total_symbol_prev(0),m_check_ms(0)
  {
   this.m_object_type=COLLECTION_SYMBOLS_ID;
   this.m_list_names.Clear();
  }
 CSymbolsCollection::~CSymbolsCollection(void)
  {
   if(m_db!=INVALID_HANDLE)
      ::DatabaseClose(m_db);
  }
 //+------------------------------------------------------------------+
 //| The id of the symbol of ours a symbol of this account is         |
 //+------------------------------------------------------------------+
 long CSymbolsCollection::SymbolID(const string account_symbol) const
  {
   return LibDatabase_SymbolID(this.m_db,account_symbol);
  }
 //+------------------------------------------------------------------+
 //| The name this account gives to the symbol of ours with this id   |
 //+------------------------------------------------------------------+
 string CSymbolsCollection::AccountSymbol(const long symbol_id) const
  {
   return LibDatabase_AccountSymbol(this.m_db,symbol_id);
  }
 //+------------------------------------------------------------------+
 //| Return the symbol object from the list by a name                 |
 //+------------------------------------------------------------------+
 CSymbol *CSymbolsCollection::GetSymbolObjByName(const string name)
  {
   int index=this.GetIndexObjByName(name);
   return(index>WRONG_VALUE ? this.m_list_all_symbols.At(index) : NULL);
  }
 //+------------------------------------------------------------------+
 //| Return the symbol object index from the list by a name           |
 //+------------------------------------------------------------------+
 int CSymbolsCollection::GetIndexObjByName(const string name)
  {
   int total=this.m_list_all_symbols.Total();
   for(int i=0;i<total;i++)
     {
      CSymbol *symbol=this.m_list_all_symbols.At(i);
      if(symbol!=NULL && symbol.Name()==name)
         return i;
     }
   return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| The id of the symbol of ours (symbols) the name of an account is |
 //+------------------------------------------------------------------+
 long CSymbolsCollection::FindSymbolID(const int db,const string account_symbol)
  {
   string candidates[2];
   candidates[0]=account_symbol;
   candidates[1]=LibDatabase_CanonicalSymbol(account_symbol);
   for(int i=0;i<2;i++)
     {
      int request=::DatabasePrepare(db,"SELECT id FROM symbols WHERE name = '"+LibDatabase_Quoted(candidates[i])+"'");
      if(request==INVALID_HANDLE)
         return 0;
      long id=0;
      bool found=::DatabaseRead(request);
      if(found)
         ::DatabaseColumnLong(request,0,id);
      ::DatabaseFinalize(request);
      if(found)
         return id;
     }
   return 0;
  }
 //+------------------------------------------------------------------+
 //| One line in symbol_account for a symbol of the account, joined to |
 //| the symbol of ours when it is one of them; symbol_id stays empty  |
 //| for the user to fill in otherwise (nothing is made in symbols)    |
 //+------------------------------------------------------------------+
 void CSymbolsCollection::RegisterSymbol(const int db,const string account_symbol)
  {
   string key=LibDatabase_AccountKey();
   int request=::DatabasePrepare(db,"SELECT 1 FROM symbol_account WHERE account_key = '"+key+"' AND account_symbol = '"+LibDatabase_Quoted(account_symbol)+"'");
   if(request==INVALID_HANDLE)
     {
      ::Print(__FUNCTION__," > the query is not accepted, error ",::GetLastError());
      return;
     }
   bool known=::DatabaseRead(request);
   ::DatabaseFinalize(request);
   if(known)
      return;
   long symbol_id=this.FindSymbolID(db,account_symbol);
   //--- one symbol of ours for one symbol of the account: when another one of the account is already joined to it, this one stays empty
   if(symbol_id>0)
     {
      request=::DatabasePrepare(db,"SELECT 1 FROM symbol_account WHERE account_key = '"+key+"' AND symbol_id = "+(string)symbol_id);
      if(request!=INVALID_HANDLE)
        {
         if(::DatabaseRead(request))
            symbol_id=0;
         ::DatabaseFinalize(request);
        }
     }
   if(!::DatabaseExecute(db,"INSERT INTO symbol_account (account_key, account_symbol, symbol_id) VALUES ('"+key+"', '"+LibDatabase_Quoted(account_symbol)+"', "+(symbol_id>0 ? (string)symbol_id : "NULL")+")"))
      ::Print(__FUNCTION__," > ",account_symbol," is not written, error ",::GetLastError());
  }
 //+------------------------------------------------------------------+
 //| The symbol of the chart has its line, then the symbols of this    |
 //| account are read from the database                                |
 //+------------------------------------------------------------------+
 bool CSymbolsCollection::OnInitEvent(void)
  {
   this.m_list_all_symbols.Clear();
   int db=LibDatabase_Open(DATABASE_OPEN_READWRITE);
   if(db==INVALID_HANDLE)
     {
      ::Print(__FUNCTION__," > the database ",LIB_DATABASE_FILE," is not opened, error ",::GetLastError());
      return false;
     }
   ::DatabaseExecute(db,"PRAGMA busy_timeout=5000");
   //--- The tables are this class's: made here when they are not there. symbol_id stays empty (NULL) when the name is none of ours, the user fills it in by hand
   if(!::DatabaseExecute(db,"CREATE TABLE IF NOT EXISTS symbols (id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE)") ||
      !::DatabaseExecute(db,"CREATE TABLE IF NOT EXISTS symbol_account (account_key TEXT NOT NULL REFERENCES accounts (account_key), account_symbol TEXT NOT NULL, "
                            "symbol_id INTEGER REFERENCES symbols (id), PRIMARY KEY (account_key, account_symbol), UNIQUE (account_key, symbol_id))"))
     {
      ::Print(__FUNCTION__," > the tables symbols and symbol_account are not made, error ",::GetLastError());
      ::DatabaseClose(db);
      return false;
     }
   //--- The chart symbol, then the symbols of the Market Watch (moved here from Python register_market_watch): the names without a suffix first,
   //--- they take the symbol of ours before a name with a suffix does (as the sort of Python)
   this.RegisterSymbol(db,::Symbol());
   int total_mw=::SymbolsTotal(true);
   for(int pass=0;pass<2;pass++)
      for(int i=0;i<total_mw;i++)
        {
         string name=::SymbolName(i,true);
         if((name==LibDatabase_CanonicalSymbol(name))==(pass==0))
            this.RegisterSymbol(db,name);
        }
   int request=::DatabasePrepare(db,"SELECT account_symbol FROM symbol_account WHERE account_key = '"+LibDatabase_AccountKey()+"' ORDER BY rowid");
   if(request==INVALID_HANDLE)
     {
      ::Print(__FUNCTION__," > the query is not accepted, error ",::GetLastError());
      ::DatabaseClose(db);
      return false;
     }
   while(::DatabaseRead(request))
     {
      string name;
      ::DatabaseColumnText(request,0,name);
      this.m_list_all_symbols.Add(new CSymbolCommon(name,this.m_list_all_symbols.Total()));   // V3: every symbol is common until the per-type classes are ported
     }
   ::DatabaseFinalize(request);
   if(m_db!=INVALID_HANDLE)
      ::DatabaseClose(m_db);
   m_db=db;   // kept open: SymbolID asks it, a new symbol of the Market Watch is written to it
   //--- V3: the current Market Watch is the starting point, no event for what is already there
   this.MarketWatchEventsControl(false);
   this.m_check_ms=::GetTickCount64();
   return true;
  }
 //+------------------------------------------------------------------+
 //| Save names of the Market Watch symbols                           |
 //+------------------------------------------------------------------+
 void CSymbolsCollection::CopySymbolsNames(void)
  {
   this.m_list_names.Clear();
   int total=::SymbolsTotal(true);
   for(int i=0;i<total;i++)
     {
      string name=::SymbolName(i,true);
      if(::SymbolInfoInteger(name,SYMBOL_VISIBLE))
         this.m_list_names.Add(name);
     }
  }
 //+------------------------------------------------------------------+
 //| A symbol is in the Market Watch window                           |
 //+------------------------------------------------------------------+
 bool CSymbolsCollection::IsPresentSymbolInMW(const string symbol_name)
  {
   int total=::SymbolsTotal(true);
   for(int i=0;i<total;i++)
     {
      string name=::SymbolName(i,true);
      if(!::SymbolInfoInteger(name,SYMBOL_VISIBLE))
         continue;
      if(name==symbol_name)
         return true;
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| A symbol is in the control list                                  |
 //+------------------------------------------------------------------+
 bool CSymbolsCollection::IsPresentSymbolInControlList(const string symbol_name)
  {
   int total=this.m_list_names.Total();
   for(int i=0;i<total;i++)
      if(this.m_list_names.At(i)==symbol_name)
         return true;
   return false;
  }
 //+------------------------------------------------------------------+
 //| Number of visible symbols in the Market Watch window             |
 //+------------------------------------------------------------------+
 int CSymbolsCollection::SymbolsTotalVisible(void) const
  {
   int total=::SymbolsTotal(true),n=0;
   for(int i=0;i<total;i++)
      if(::SymbolInfoInteger(::SymbolName(i,true),SYMBOL_VISIBLE))
         n++;
   return n;
  }
 //+------------------------------------------------------------------+
 //| Working with the Market Watch window events                      |
 //+------------------------------------------------------------------+
 //--- Change from V3: the names that came are looked for by name (a symbol added and another removed in one second is both), a new one gets its line
 //--- in symbol_account and its object; one that left stays in the list (symbol_account)
 void CSymbolsCollection::MarketWatchEventsControl(const bool send_events=true)
  {
   ::ResetLastError();
   //--- If no current prices are received, exit
   if(!::SymbolInfoTick(::Symbol(),this.m_tick))
     {
      this.m_global_error=::GetLastError();
      return;
     }
   uchar array[];
   int sum=0;
   this.m_hash_sum=0;
   //--- Hash sum of all visible symbols in the Market Watch window
   this.m_total_symbols=this.SymbolsTotalVisible();
   int total_symbols=::SymbolsTotal(true);
   for(int i=0;i<total_symbols;i++)
     {
      string name=::SymbolName(i,true);
      if(!::SymbolInfoInteger(name,SYMBOL_VISIBLE))
         continue;
      ::StringToCharArray(name,array);
      for(int j=::ArraySize(array)-1;j>WRONG_VALUE;j--)
         sum+=array[j];
      this.m_hash_sum+=i+sum;
     }
   //--- No events: remember the snapshot and exit
   if(!send_events)
     {
      this.CopySymbolsNames();
      this.m_hash_sum_prev=this.m_hash_sum;
      this.m_total_symbol_prev=this.m_total_symbols;
      return;
     }
   if(this.m_hash_sum==this.m_hash_sum_prev)
      return;
   //--- The Market Watch window changed: define the events
   this.m_list_events.Clear();   // events are sent to the chart: the list only holds the current ones
   this.m_delta_symbol=this.m_total_symbols-this.m_total_symbol_prev;
   bool told=false;
   //--- A symbol was added: lparam = event time in milliseconds, dparam = symbol index, sparam = symbol name
   for(int i=0;i<total_symbols;i++)
     {
      string name=::SymbolName(i,true);
      if(!::SymbolInfoInteger(name,SYMBOL_VISIBLE) || this.IsPresentSymbolInControlList(name))
         continue;
      this.RegisterSymbol(this.m_db,name);
      int index=this.GetIndexObjByName(name);
      if(index==WRONG_VALUE && this.m_list_all_symbols.Add(new CSymbolCommon(name,this.m_list_all_symbols.Total())))
         index=this.m_list_all_symbols.Total()-1;
      if(this.EventAdd((ushort)MARKET_WATCH_EVENT_SYMBOL_ADD,this.TickTime(),index,name))
         ::EventChartCustom(::ChartID(),(ushort)MARKET_WATCH_EVENT_SYMBOL_ADD,this.TickTime(),index,name);
      told=true;
     }
   //--- A symbol was removed: lparam = event time in milliseconds, dparam = -1, sparam = removed symbol name
   int total=this.m_list_names.Total();
   for(int i=0;i<total;i++)
     {
      string name=this.m_list_names.At(i);
      if(name==NULL || this.IsPresentSymbolInMW(name))
         continue;
      if(this.EventAdd((ushort)MARKET_WATCH_EVENT_SYMBOL_DEL,this.TickTime(),WRONG_VALUE,name))
         ::EventChartCustom(::ChartID(),(ushort)MARKET_WATCH_EVENT_SYMBOL_DEL,this.TickTime(),WRONG_VALUE,name);
      told=true;
     }
   //--- The symbols were sorted: lparam = event time in milliseconds, dparam = current symbol index, sparam = current symbol name
   if(!told)
     {
      int index=this.GetIndexObjByName(::Symbol());
      if(this.EventAdd((ushort)MARKET_WATCH_EVENT_SYMBOL_SORT,this.TickTime(),index,::Symbol()))
         ::EventChartCustom(::ChartID(),(ushort)MARKET_WATCH_EVENT_SYMBOL_SORT,this.TickTime(),index,::Symbol());
     }
   this.CopySymbolsNames();
   this.m_total_symbol_prev=this.m_total_symbols;
   this.m_hash_sum_prev=this.m_hash_sum;
  }
 //+------------------------------------------------------------------+
 //| Checks the Market Watch window once a second                     |
 //+------------------------------------------------------------------+
 void CSymbolsCollection::OnTimerEvent(void)
  {
   if(::GetTickCount64()-this.m_check_ms<SYMBOLS_COLLECTION_CHECK_MS)
      return;
   this.m_check_ms=::GetTickCount64();
   this.MarketWatchEventsControl();
  }
#endif // CSYMBOLSCOLLECTION_MQH_IMPLEMENTATION
#endif // __SYMBOLSCOLLECTION_MQH__
