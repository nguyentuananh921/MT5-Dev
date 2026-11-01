//+------------------------------------------------------------------+
//|                                             AccountsCollection.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//| Link https://www.mql5.com/en/articles/6952                       |
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
//--- Change from V3 Collections\AccountsCollection.mqh (Lib V1 the same): SaveObjects -> SyncDataToDB, LoadObjects -> SyncDataFromDB, the files Accounts\*.bin -> the
//--- table accounts. Only the EA + Library make and write this table: Python reads account_key once (by login + server) to know which account it works for, it
//--- never writes it. Readme "Live on RAM, Save on DB for no more calculation": a row keeps what does not change (who the account is and its terms); what
//--- changes all the time (balance, equity, profit, margin, the permissions) lives in the CAccount of m_list_accounts in RAM only (RefreshAccount, OnTick).
//--- Parent Child: the CAccount makes its events, this class sends them to the chart, the siblings (the status bar, the Automatic Trade) hear them
//--- Methods come from V3 one by one when a class asks for them
#ifndef __ACCOUNTSCOLLECTION_MQH__
#define __ACCOUNTSCOLLECTION_MQH__
 #include "ListObj.mqh"
 #include "..\Services\LibDatabase.mqh"
 #include "..\Entities\Bases\BaseObjExt.mqh"
 #include "..\Entities\Trading\Account.mqh"
#ifndef CACCOUNTSCOLLECTION_MQH_DECLARATION
#define CACCOUNTSCOLLECTION_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Account collection                                               |
 //+------------------------------------------------------------------+
 class CAccountsCollection : public CBaseObjExt
  {
   private:
    int               m_db;                                        // the file the accounts share (LibDatabase_Open): the table accounts is asked here
    CListObj          m_list_accounts;                             // Account object list: the account the terminal is logged in to, the others of the table
    int               m_index_current;                             // Index of an account object featuring the current account data
   //--- Check the account object presence in the collection list
    bool              IsPresent(CAccount *account);
   //--- Find and return the account object index with the current account data
    int               Index(void);
   public:
   //--- Return the full account collection list "as is"
    CArrayObj        *GetList(void)                                { return &this.m_list_accounts;}
   //--- Return the current account object index and the account object
    int               IndexCurrentAccount(void)              const { return this.m_index_current;}
    CAccount         *GetCurrentAccount(void)                      { int idx=this.IndexCurrentAccount(); return(idx==WRONG_VALUE ? NULL : (CAccount*)this.GetList().At(idx)); }
   //--- The current account follows the terminal (OnTick, as RefreshSeries): its events go to the chart, a change of a column of the table is written
    void              RefreshAccount(void);
   //--- Constructor, destructor
                      CAccountsCollection(void);
                     ~CAccountsCollection(void);
   //--- Lifecycle: the table is made, the current account is in the list, the others come from the table (SyncDataFromDB), the list goes to it (SyncDataToDB)
    bool              OnInitEvent(void);
   //--- Add the account object to the list
    bool              AddToList(CAccount *account);
   //--- (1) The account objects of the list to the table accounts (what does not change; last_seen of the current one)
   //--- (2) The rows of the table accounts to the list (the accounts that are not there yet)
    bool              SyncDataToDB(void);
    bool              SyncDataFromDB(void);
  };
#endif // CACCOUNTSCOLLECTION_MQH_DECLARATION
#ifndef CACCOUNTSCOLLECTION_MQH_IMPLEMENTATION
#define CACCOUNTSCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CAccountsCollection::CAccountsCollection(void) : m_db(INVALID_HANDLE),m_index_current(WRONG_VALUE)
  {
   this.m_object_type=COLLECTION_ACCOUNT_ID;
   this.m_list_accounts.Clear();
   this.m_list_accounts.Type(COLLECTION_ACCOUNT_ID);
   ::ZeroMemory(this.m_tick);
  }
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CAccountsCollection::~CAccountsCollection(void)
  {
   //--- Save account objects from the list to the table
   this.SyncDataToDB();
   if(this.m_db!=INVALID_HANDLE)
      ::DatabaseClose(this.m_db);
  }
 //+------------------------------------------------------------------+
 //| Add the account object to the list                               |
 //+------------------------------------------------------------------+
 bool CAccountsCollection::AddToList(CAccount *account)
  {
   if(account==NULL)
      return false;
   if(!this.IsPresent(account))
      return this.m_list_accounts.Add(account);
   return false;
  }
 //+------------------------------------------------------------------+
 //| Check the account object presence in the collection list         |
 //+------------------------------------------------------------------+
 bool CAccountsCollection::IsPresent(CAccount *account)
  {
   int total=this.m_list_accounts.Total();
   for(int i=0;i<total;i++)
     {
      CAccount *check=this.m_list_accounts.At(i);
      if(check!=NULL && check.IsEqual(account))
         return true;
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| Return the account object index with the current account data    |
 //+------------------------------------------------------------------+
 int CAccountsCollection::Index(void)
  {
   int total=this.m_list_accounts.Total();
   for(int i=0;i<total;i++)
     {
      CAccount *account=this.m_list_accounts.At(i);
      if(account==NULL)
         continue;
      if(account.Login()==::AccountInfoInteger(ACCOUNT_LOGIN)    &&
         account.Company()==::AccountInfoString(ACCOUNT_COMPANY) &&
         account.Name()==::AccountInfoString(ACCOUNT_NAME)
        ) return i;
     }
   return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| The table is made, the current account is in the list, the       |
 //| others come from the table, then the list goes to the table      |
 //+------------------------------------------------------------------+
 bool CAccountsCollection::OnInitEvent(void)
  {
   if(this.m_db==INVALID_HANDLE)
     {
      this.m_db=LibDatabase_Open(DATABASE_OPEN_READWRITE);
      if(this.m_db==INVALID_HANDLE)
        {
         ::Print(__FUNCTION__," > the database ",LIB_DATABASE_FILE," is not opened, error ",::GetLastError());
         return false;
        }
      ::DatabaseExecute(this.m_db,"PRAGMA busy_timeout=5000");
     }
   //--- accounts: what does not change of an account (who it is and its terms)
   if(!::DatabaseExecute(this.m_db,"CREATE TABLE IF NOT EXISTS accounts (\n-- Library V4: class CAccount (Entities/Trading/Account.mqh), only what does not change; the EA + Library write it, Python reads account_key\n"+
                                   "account_key TEXT NOT NULL PRIMARY KEY, login INTEGER NOT NULL DEFAULT 0, server TEXT NOT NULL DEFAULT '', name TEXT NOT NULL DEFAULT '', "+
                                   "company TEXT NOT NULL DEFAULT '', currency TEXT NOT NULL DEFAULT '', currency_digits INTEGER NOT NULL DEFAULT 0, trade_mode INTEGER NOT NULL DEFAULT 0, "+
                                   "margin_mode INTEGER NOT NULL DEFAULT 0, margin_so_mode INTEGER NOT NULL DEFAULT 0, margin_so_call REAL NOT NULL DEFAULT 0, margin_so_so REAL NOT NULL DEFAULT 0, "+
                                   "leverage INTEGER NOT NULL DEFAULT 0, limit_orders INTEGER NOT NULL DEFAULT 0, fifo_close INTEGER NOT NULL DEFAULT 0, hedge_allowed INTEGER NOT NULL DEFAULT 0, "+
                                   "server_type INTEGER NOT NULL DEFAULT 0, first_seen INTEGER, last_seen INTEGER)"))
     {
      ::Print(__FUNCTION__," > the table accounts is not made, error ",::GetLastError());
      return false;
     }
   //--- The columns of an older table that kept a property changing all the time (a picture of OnInit, wrong at the next tick): they go
   string live[]={"balance","credit","profit","equity","margin","margin_free","margin_level","margin_initial","margin_maintenance","assets","liabilities",
                  "commission_blocked","trade_allowed","trade_expert"};
   for(int i=0;i<ArraySize(live);i++)
      if(LibDatabase_ColumnExists(this.m_db,"accounts",live[i]) && !::DatabaseExecute(this.m_db,"ALTER TABLE accounts DROP COLUMN "+live[i]))
         ::Print(__FUNCTION__," > the column ",live[i]," is not dropped, error ",::GetLastError(),": it stays with its default, nothing writes it");
   //--- Create the current account object and add it to the list (OnInit again: a chart change keeps it, another account logged in gets its own)
   this.m_index_current=this.Index();
   if(this.m_index_current==WRONG_VALUE)
     {
      CAccount *account=new CAccount();
      if(account==NULL || !this.AddToList(account))
        {
         ::Print(__FUNCTION__," > the current account is not added to the list");
         delete account;
         return false;
        }
      //--- Its events (Event Rule): every change of the money (balance, credit, profit, equity as V1 CTradingEngine::OnInitEvent), of the permissions and of the terms.
      //--- Not margin (its level comes from the Configuration of the EA with the Automatic Trade)
      account.SetControlBalanceInc(0);       account.SetControlBalanceDec(0);
      account.SetControlProfitInc(0);        account.SetControlProfitDec(0);
      account.SetControlEquityInc(0);        account.SetControlEquityDec(0);
      account.SetControlCreditInc(0);        account.SetControlCreditDec(0);
      account.SetControlTradeAllowedInc(0);  account.SetControlTradeAllowedDec(0);
      account.SetControlTradeExpertInc(0);   account.SetControlTradeExpertDec(0);
      account.SetControlLeverageInc(0);      account.SetControlLeverageDec(0);
      account.SetControlLimitOrdersInc(0);   account.SetControlLimitOrdersDec(0);
      account.SetControlMarginCallInc(0);    account.SetControlMarginCallDec(0);
      account.SetControlMarginStopOutInc(0); account.SetControlMarginStopOutDec(0);
     }
   else
      this.GetCurrentAccount().RefreshAccount();   // asks the terminal again
   //--- Download account objects from the table to the collection, save the current account index
   this.SyncDataFromDB();
   this.m_index_current=this.Index();
   //--- The row of the current account is there now: Python finds its account_key
   return this.SyncDataToDB();
  }
 //+------------------------------------------------------------------+
 //| The account objects of the list to the table: what does not       |
 //| change; first_seen the first time, last_seen of the current one   |
 //+------------------------------------------------------------------+
 bool CAccountsCollection::SyncDataToDB(void)
  {
   if(this.m_db==INVALID_HANDLE)
      return false;
   bool res=true;
   string now=(string)((long)::TimeGMT()*1000);
   for(int i=0;i<this.m_list_accounts.Total();i++)
     {
      CAccount *account=this.m_list_accounts.At(i);
      if(account==NULL)
         continue;
      string key=LibDatabase_Safe(account.Server())+"_"+(string)account.Login();   // LibDatabase_AccountKey of that account
      string sql=
         "INSERT INTO accounts (account_key, login, server, name, company, currency, currency_digits, trade_mode, margin_mode, margin_so_mode, margin_so_call, margin_so_so, "+
         "leverage, limit_orders, fifo_close, hedge_allowed, server_type, first_seen, last_seen) VALUES ('"+LibDatabase_Quoted(key)+"', "+
         (string)account.Login()+", '"+LibDatabase_Quoted(account.Server())+"', '"+LibDatabase_Quoted(account.Name())+"', '"+LibDatabase_Quoted(account.Company())+"', '"+
         LibDatabase_Quoted(account.Currency())+"', "+(string)account.CurrencyDigits()+", "+(string)(int)account.TradeMode()+", "+(string)(int)account.MarginMode()+", "+
         (string)(int)account.MarginSOMode()+", "+::DoubleToString(account.MarginSOCall(),8)+", "+::DoubleToString(account.MarginSOSO(),8)+", "+(string)account.Leverage()+", "+
         (string)account.LimitOrders()+", "+(string)(int)account.FIFOClose()+", "+(string)(int)account.HedgeAllowed()+", "+(string)account.ServerType()+", "+now+", "+now+") ";
      //--- Only the current account is asked of the terminal: the row of another one stays as it is
      sql+=(i==this.m_index_current ?
            "ON CONFLICT(account_key) DO UPDATE SET login=excluded.login, server=excluded.server, name=excluded.name, company=excluded.company, currency=excluded.currency, "+
            "currency_digits=excluded.currency_digits, trade_mode=excluded.trade_mode, margin_mode=excluded.margin_mode, margin_so_mode=excluded.margin_so_mode, "+
            "margin_so_call=excluded.margin_so_call, margin_so_so=excluded.margin_so_so, leverage=excluded.leverage, limit_orders=excluded.limit_orders, "+
            "fifo_close=excluded.fifo_close, hedge_allowed=excluded.hedge_allowed, server_type=excluded.server_type, last_seen=excluded.last_seen" :
            "ON CONFLICT(account_key) DO NOTHING");
      if(!::DatabaseExecute(this.m_db,sql))
        {
         ::Print(__FUNCTION__," > the account ",key," is not written, error ",::GetLastError());
         res=false;
        }
     }
   return res;
  }
 //+------------------------------------------------------------------+
 //| The rows of the table to the list: an account that is not in the |
 //| list yet. What changes all the time is not known of it (0)       |
 //+------------------------------------------------------------------+
 bool CAccountsCollection::SyncDataFromDB(void)
  {
   if(this.m_db==INVALID_HANDLE)
      return false;
   int request=::DatabasePrepare(this.m_db,"SELECT login, server, name, company, currency, currency_digits, trade_mode, margin_mode, margin_so_mode, margin_so_call, "+
                                           "margin_so_so, leverage, limit_orders, fifo_close, hedge_allowed, server_type FROM accounts");
   if(request==INVALID_HANDLE)
     {
      ::Print(__FUNCTION__," > the table accounts is not read, error ",::GetLastError());
      return false;
     }
   bool res=true;
   while(::DatabaseRead(request))
     {
      CAccount *account=new CAccount();
      if(account==NULL)
        {
         res=false;
         continue;
        }
      for(int i=0;i<ACCOUNT_PROP_INTEGER_TOTAL;i++)
         account.SetProperty((ENUM_ACCOUNT_PROP_INTEGER)i,0);
      for(int i=ACCOUNT_PROP_INTEGER_TOTAL;i<ACCOUNT_PROP_INTEGER_TOTAL+ACCOUNT_PROP_DOUBLE_TOTAL;i++)
         account.SetProperty((ENUM_ACCOUNT_PROP_DOUBLE)i,0);
      long   value=0;
      double real=0;
      string text="";
      ::DatabaseColumnLong(request,0,value);    account.SetProperty(ACCOUNT_PROP_LOGIN,value);
      ::DatabaseColumnText(request,1,text);     account.SetProperty(ACCOUNT_PROP_SERVER,text);
      ::DatabaseColumnText(request,2,text);     account.SetProperty(ACCOUNT_PROP_NAME,text);
      ::DatabaseColumnText(request,3,text);     account.SetProperty(ACCOUNT_PROP_COMPANY,text);
      ::DatabaseColumnText(request,4,text);     account.SetProperty(ACCOUNT_PROP_CURRENCY,text);
      ::DatabaseColumnLong(request,5,value);    account.SetProperty(ACCOUNT_PROP_CURRENCY_DIGITS,value);
      ::DatabaseColumnLong(request,6,value);    account.SetProperty(ACCOUNT_PROP_TRADE_MODE,value);
      ::DatabaseColumnLong(request,7,value);    account.SetProperty(ACCOUNT_PROP_MARGIN_MODE,value);
      ::DatabaseColumnLong(request,8,value);    account.SetProperty(ACCOUNT_PROP_MARGIN_SO_MODE,value);
      ::DatabaseColumnDouble(request,9,real);   account.SetProperty(ACCOUNT_PROP_MARGIN_SO_CALL,real);
      ::DatabaseColumnDouble(request,10,real);  account.SetProperty(ACCOUNT_PROP_MARGIN_SO_SO,real);
      ::DatabaseColumnLong(request,11,value);   account.SetProperty(ACCOUNT_PROP_LEVERAGE,value);
      ::DatabaseColumnLong(request,12,value);   account.SetProperty(ACCOUNT_PROP_LIMIT_ORDERS,value);
      ::DatabaseColumnLong(request,13,value);   account.SetProperty(ACCOUNT_PROP_FIFO_CLOSE,value);
      ::DatabaseColumnLong(request,14,value);   account.SetProperty(ACCOUNT_PROP_HEDGE_ALLOWED,value);
      ::DatabaseColumnLong(request,15,value);   account.SetProperty(ACCOUNT_PROP_SERVER_TYPE,value);
      if(!this.AddToList(account))
         delete account;   // it is there already (the current one)
     }
   ::DatabaseFinalize(request);
   return res;
  }
 //+------------------------------------------------------------------+
 //| The current account follows the terminal: its events go to the   |
 //| chart (id: the property, lparam: ms, reason, type; dparam: the   |
 //| change). A column of the table that changed is written again     |
 //+------------------------------------------------------------------+
 //--- Change from V3: Refresh + RefreshAndEventsControl (the same lines twice) -> RefreshAccount (as RefreshSeries)
 void CAccountsCollection::RefreshAccount(void)
  {
   this.m_is_event=false;
   this.m_list_events.Clear();
   this.m_list_events.Sort();
   ::ResetLastError();
   if(!::SymbolInfoTick(::Symbol(),this.m_tick))   // the time of the events (CheckEvents)
     {
      this.m_global_error=::GetLastError();
      return;
     }
   CAccount *account=this.GetCurrentAccount();
   if(account==NULL)
      return;
   account.RefreshAccount();
   if(!account.IsEvent())
      return;
   CArrayObj *list=account.GetListEvents();
   if(list==NULL)
      return;
   this.m_is_event=true;
   this.m_event_code=account.GetEventCode();
   bool stored=false;   // a column of the table accounts changed
   for(int j=0;j<list.Total();j++)
     {
      CEventBaseObj *event=list.At(j);
      if(event==NULL)
         continue;
      const int property=(int)event.ID();
      stored=stored || property==ACCOUNT_PROP_LEVERAGE || property==ACCOUNT_PROP_LIMIT_ORDERS || property==ACCOUNT_PROP_MARGIN_SO_CALL || property==ACCOUNT_PROP_MARGIN_SO_SO;
      if(this.EventAdd((ushort)event.ID(),event.LParam(),event.DParam(),event.SParam()))
         ::EventChartCustom(::ChartID(),(ushort)event.ID(),event.LParam(),event.DParam(),event.SParam());   // the parent and the siblings hear it
     }
   if(stored)
      this.SyncDataToDB();
  }
#endif // CACCOUNTSCOLLECTION_MQH_IMPLEMENTATION
#endif // __ACCOUNTSCOLLECTION_MQH__
