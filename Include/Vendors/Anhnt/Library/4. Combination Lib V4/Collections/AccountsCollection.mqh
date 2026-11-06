//+------------------------------------------------------------------+
//|                                           AccountsCollection.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//| Link https://www.mql5.com/en/articles/6952                       |
//| Lib https://www.mql5.com/en/articles/14710                       |
//| V3 SaveObjects -> UpdateDataToDB, LoadObjects -> ReadDataFromDB    |
//| Create table accounts in Common Database                         |
//| Use m_account_key in CDatabaseService to Join 2 Database On RAM  |
//| [] Update in V4: Use CDatabaseService                            |
//+------------------------------------------------------------------+
//| Account collection                                               |
//+------------------------------------------------------------------+
#ifndef __ACCOUNTSCOLLECTION_MQH__
#define __ACCOUNTSCOLLECTION_MQH__
 #include "ListObj.mqh" 
 #include "..\Entities\Bases\BaseObjExt.mqh"
 #include "..\Entities\Trading\Account.mqh"
 #include "..\Services\DELib\DatabaseService.mqh"
#ifndef CACCOUNTSCOLLECTION_MQH_DECLARATION
#define CACCOUNTSCOLLECTION_MQH_DECLARATION  
 struct SAccountRow
  {
   long   login;
   string server;
   string name;
   string company;
   string currency;
   long   currency_digits;
   long   trade_mode;
   long   margin_mode;
   long   margin_so_mode;
   double margin_so_call;
   double margin_so_so;
   long   leverage;
   long   limit_orders;
   long   fifo_close;
   long   hedge_allowed;
   long   server_type;
   long   first_seen;
   long   last_seen;
  };
 class CAccountsCollection : public CBaseObjExt
  {
   private:    
    CListObj          m_list_accounts;                             // Account object list: the account the terminal is logged in to, the others of the table
    int               m_index_current;                             // Index of an account object featuring the current account data
    CDatabaseService  *m_CDatabaseService;                         // The EA holds it
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
   //--- Lifecycle: the table is made, the current account is in the list, the others come from the table (ReadDataFromDB), the list goes to it (UpdateDataToDB)
    bool              OnInitEvent(void);
    void              SetDatabaseService(CDatabaseService *databaseService)    {this.m_CDatabaseService=databaseService;}
   //--- Add the account object to the list
    bool              AddToList(CAccount *account);
   //--- (1) The account objects of the list to the table accounts (what does not change; last_seen of the current one)
   //--- (2) The rows of the table accounts to the list (the accounts that are not there yet)
    bool              UpdateDataToDB(void);    
    bool              ReadDataFromDB(void);    
  };
#endif // CACCOUNTSCOLLECTION_MQH_DECLARATION
#ifndef CACCOUNTSCOLLECTION_MQH_IMPLEMENTATION
#define CACCOUNTSCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CAccountsCollection::CAccountsCollection(void) : m_CDatabaseService(NULL),
                                                  m_index_current(WRONG_VALUE)
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
   // Update in V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService == NULL)
      {
       ::Print(__FUNCTION__, " > DatabaseService is not set");
       return false;
      }
    else
     {
      string sql_create_table_accounts ="CREATE TABLE IF NOT EXISTS accounts (""account_key TEXT NOT NULL PRIMARY KEY, ""login INTEGER NOT NULL DEFAULT 0, ""server TEXT NOT NULL DEFAULT '', ""name TEXT NOT NULL DEFAULT '', ""company TEXT NOT NULL DEFAULT '', ""currency TEXT NOT NULL DEFAULT '', ""currency_digits INTEGER NOT NULL DEFAULT 0, ""trade_mode INTEGER NOT NULL DEFAULT 0, ""margin_mode INTEGER NOT NULL DEFAULT 0, ""margin_so_mode INTEGER NOT NULL DEFAULT 0, ""margin_so_call REAL NOT NULL DEFAULT 0, ""margin_so_so REAL NOT NULL DEFAULT 0, ""leverage INTEGER NOT NULL DEFAULT 0, ""limit_orders INTEGER NOT NULL DEFAULT 0, ""fifo_close INTEGER NOT NULL DEFAULT 0, ""hedge_allowed INTEGER NOT NULL DEFAULT 0, ""server_type INTEGER NOT NULL DEFAULT 0, ""first_seen INTEGER, ""last_seen INTEGER)";
      if(!this.m_CDatabaseService.Create("Common", sql_create_table_accounts))
        {
           ::Print(__FUNCTION__, " > DatabaseService can't create table accounts");
           return false;
        }
        
     }    
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
    this.ReadDataFromDB();
    this.m_index_current=this.Index();
   //--- The row of the current account is there now: Python finds its account_key
   return this.UpdateDataToDB();
  }
 //+------------------------------------------------------------------+
 //| The account objects of the list to the table: what does not       |
 //| change; first_seen the first time, last_seen of the current one   |
 //+------------------------------------------------------------------+
 bool CAccountsCollection::UpdateDataToDB(void)
  {   
   // New In V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService == NULL)
     {
      ::Print(__FUNCTION__," > DatabaseService is not set");
      return false;
     }
   bool res_CDatabaseService=true;  
   string now=(string)((long)::TimeGMT()*1000);

   for(int i=0;i<this.m_list_accounts.Total();i++)
     {
      CAccount *account=this.m_list_accounts.At(i);
      if(account==NULL)
         continue;      
      string account_key = this.m_CDatabaseService.GetAccountKey();
      string sql_UpdateAccountInfor = "INSERT INTO accounts (account_key, login, server, name, company, currency, currency_digits, trade_mode, margin_mode, margin_so_mode, margin_so_call, margin_so_so, " +"leverage, limit_orders, fifo_close, hedge_allowed, server_type, first_seen, last_seen) VALUES ('" +
         this.m_CDatabaseService.QuoteSQLText(account_key)+"', "+
         (string)account.Login()+", '"+
         this.m_CDatabaseService.QuoteSQLText(account.Server())+"', '"+
         this.m_CDatabaseService.QuoteSQLText(account.Name())+"', '"+
         this.m_CDatabaseService.QuoteSQLText(account.Company())+"', '"+
         this.m_CDatabaseService.QuoteSQLText(account.Currency())+"', "+
         (string)account.CurrencyDigits()+", "+(string)(int)account.TradeMode()+", "+(string)(int)account.MarginMode()+", "+
         (string)(int)account.MarginSOMode()+", "+::DoubleToString(account.MarginSOCall(),8)+", "+::DoubleToString(account.MarginSOSO(),8)+", "+
         (string)account.Leverage()+", "+(string)account.LimitOrders()+", "+(string)(int)account.FIFOClose()+", "+(string)(int)account.HedgeAllowed()+", "+
         (string)account.ServerType()+", "+now+", "+now+") ";

      sql_UpdateAccountInfor+=(i==this.m_index_current ?
            "ON CONFLICT(account_key) DO UPDATE SET login=excluded.login, server=excluded.server, name=excluded.name, company=excluded.company, currency=excluded.currency, "+
            "currency_digits=excluded.currency_digits, trade_mode=excluded.trade_mode, margin_mode=excluded.margin_mode, margin_so_mode=excluded.margin_so_mode, "+
            "margin_so_call=excluded.margin_so_call, margin_so_so=excluded.margin_so_so, leverage=excluded.leverage, limit_orders=excluded.limit_orders, "+
            "fifo_close=excluded.fifo_close, hedge_allowed=excluded.hedge_allowed, server_type=excluded.server_type, last_seen=excluded.last_seen" :
            "ON CONFLICT(account_key) DO NOTHING");

      if(!this.m_CDatabaseService.Update("Common", sql_UpdateAccountInfor))
        {
         ::Print(__FUNCTION__," > the account ",account_key," is not written, error ",::GetLastError());
         res_CDatabaseService=false;
        }
     }
    return res_CDatabaseService;
  }
 //+------------------------------------------------------------------+
 //| The rows of the table to the list: an account that is not in the |
 //| list yet. What changes all the time is not known of it (0)       |
 //+------------------------------------------------------------------+
 bool CAccountsCollection::ReadDataFromDB(void)
  {   
   // New In V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService==NULL)
     {
      ::Print(__FUNCTION__," > DatabaseService is not set");
      return false;
     }
   SAccountRow data_rows[];
   string sql_readAccountInfor=
      "SELECT login, server, name, company, currency, currency_digits, trade_mode, "
      "margin_mode, margin_so_mode, margin_so_call, margin_so_so, leverage, "
      "limit_orders, fifo_close, hedge_allowed, server_type, first_seen, last_seen "
      "FROM accounts";

   if(!this.m_CDatabaseService.Read("Common", sql_readAccountInfor, data_rows))
     {
      ::Print(__FUNCTION__," > the table accounts is not read by DatabaseService");
      return false;
     }
   bool res_CDatabaseService=true;
   for(int i=0;i<ArraySize(data_rows);i++)
     {
      CAccount *account=new CAccount();
      if(account==NULL)
        {
         res_CDatabaseService=false;
         continue;
        }

      // reset live fields to safe defaults
      for(int j=0;j<ACCOUNT_PROP_INTEGER_TOTAL;j++)
         account.SetProperty((ENUM_ACCOUNT_PROP_INTEGER)j,0);
      for(int j=ACCOUNT_PROP_INTEGER_TOTAL;j<ACCOUNT_PROP_INTEGER_TOTAL+ACCOUNT_PROP_DOUBLE_TOTAL;j++)
         account.SetProperty((ENUM_ACCOUNT_PROP_DOUBLE)j,0);

      account.SetProperty(ACCOUNT_PROP_LOGIN,data_rows[i].login);
      account.SetProperty(ACCOUNT_PROP_SERVER,data_rows[i].server);
      account.SetProperty(ACCOUNT_PROP_NAME,data_rows[i].name);
      account.SetProperty(ACCOUNT_PROP_COMPANY,data_rows[i].company);
      account.SetProperty(ACCOUNT_PROP_CURRENCY,data_rows[i].currency);
      account.SetProperty(ACCOUNT_PROP_CURRENCY_DIGITS,data_rows[i].currency_digits);
      account.SetProperty(ACCOUNT_PROP_TRADE_MODE,data_rows[i].trade_mode);
      account.SetProperty(ACCOUNT_PROP_MARGIN_MODE,data_rows[i].margin_mode);
      account.SetProperty(ACCOUNT_PROP_MARGIN_SO_MODE,data_rows[i].margin_so_mode);
      account.SetProperty(ACCOUNT_PROP_MARGIN_SO_CALL,data_rows[i].margin_so_call);
      account.SetProperty(ACCOUNT_PROP_MARGIN_SO_SO,data_rows[i].margin_so_so);
      account.SetProperty(ACCOUNT_PROP_LEVERAGE,data_rows[i].leverage);
      account.SetProperty(ACCOUNT_PROP_LIMIT_ORDERS,data_rows[i].limit_orders);
      account.SetProperty(ACCOUNT_PROP_FIFO_CLOSE,data_rows[i].fifo_close);
      account.SetProperty(ACCOUNT_PROP_HEDGE_ALLOWED,data_rows[i].hedge_allowed);
      account.SetProperty(ACCOUNT_PROP_SERVER_TYPE,data_rows[i].server_type);

      if(!this.AddToList(account))
         delete account;
     }

   return res_CDatabaseService;

  }
 //+------------------------------------------------------------------+
 //| The current account follows the terminal: its events go to the   |
 //| chart (id: the property, lparam: ms, reason, type; dparam: the   |
 //| change). A column of the table that changed is written again     |
 //+------------------------------------------------------------------+ 
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
      this.UpdateDataToDB();
  }
#endif // CACCOUNTSCOLLECTION_MQH_IMPLEMENTATION
#endif // __ACCOUNTSCOLLECTION_MQH__
