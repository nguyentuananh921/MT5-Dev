//+------------------------------------------------------------------+
//|                                            HistoryCollection.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/5669                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
//--- The history of the account (V3 m_list_all_orders): the orders and deals of the terminal live in RAM (the terminal keeps them, they are made again at each
//--- start); the table Orders of the file of the account is this class's (as CBarTimeSeriesCollection owns its tables) and keeps only what the terminal has not or
//--- what must not be done again (Readme "Live on RAM, Save on DB for no more calculation"): the line of each history order and deal, the Bid / Ask of a deal.
//--- Change from DoEasy / V3: base CObject -> CBaseObjExt (Event Rule), Refresh -> RefreshHistory (as RefreshSeries, RefreshAccount), SyncDataFromDB / SyncDataToDB
//--- (the table moved here from COrderControl); MQL5 only
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __HISTORYCOLLECTION_MQH__
#define __HISTORYCOLLECTION_MQH__
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include <Arrays\ArrayLong.mqh>
#include "ListObj.mqh"
#include "SymbolsCollection.mqh"
#include "Settings\SyncManager.mqh"
#include "..\Services\DELib\DatabaseDELib.mqh"
#include "..\Entities\Bases\BaseObjExt.mqh"
#include "..\Entities\Defines\CommonDefines.mqh"
#include "..\Entities\Defines\EventDefines.mqh"
#include "..\Entities\Trading\Orders\HistoryOrder.mqh"
#include "..\Entities\Trading\Orders\HistoryPending.mqh"
#include "..\Entities\Trading\Orders\HistoryDeal.mqh"
 #ifndef CHISTORYCOLLECTION_MQH_DECLARATION
 #define CHISTORYCOLLECTION_MQH_DECLARATION
//+------------------------------------------------------------------+
//| A column of the table Orders and the property of COrder it keeps |
//+------------------------------------------------------------------+
struct SOrderColumn
  {
   string            name;                                              // Column
   string            type;                                              // SQL type of the column
   int               prop;                                              // Property of COrder (ENUM_ORDER_PROP_*)
  };
//+------------------------------------------------------------------+
//| Collection of historical orders and deals                        |
//+------------------------------------------------------------------+
class CHistoryCollection : public CBaseObjExt
  {
   private:
    int               m_db;                   // The file of the account: the table Orders
    CSymbolsCollection *m_SymbolsCollection;  // The EA holds it: the id of OUR symbol of an order (symbols)
    CSyncManager     *m_SyncManager;          // The EA holds it: the marks of the history in Setting_Sync
    CListObj          m_list_all_orders;      // List of all historical orders and deals (V3), owned
    CArrayObj         m_list_pending;         // RAM only: the orders and deals of the list that are not lines of the table yet (SyncDataToDB writes them)
    CArrayLong        m_saved_key;            // The lines of the table (status * HISTORY_KEY_STATUS + ticket, sorted) and the Bid / Ask of each, at the same index (SyncDataFromDB):
    double            m_saved_bid[];          // an order made again from the terminal that has its line is not written again, a deal gets its Bid / Ask back
    double            m_saved_ask[];
    bool              m_is_trade_event;       // Trading event flag
    int               m_index_order;          // Index of the last order added to the collection from the terminal history list
    int               m_index_deal;           // Index of the last deal added to the collection from the terminal history list
    int               m_delta_order;          // Difference in the number of orders compared to the previous check
    int               m_delta_deal;           // Difference in the number of deals compared to the previous check
    //--- Return the flag of the order object by its type and ticket in the list of historical orders and deals
     bool              IsPresentOrderInList(const ulong order_ticket,const ENUM_ORDER_TYPE type);
    //--- Return the "lost" order type and ticket
     ulong             OrderSearch(const int start,ENUM_ORDER_TYPE &order_type);
    //--- Create the order object (deal=true: a deal) and place it to the list: a line of the table gives it back its Bid / Ask, one that has no line waits to be written
    //--- (Change from V3: the deals come here too)
     bool              CreateNewOrder(const ulong order_ticket,const ENUM_ORDER_TYPE order_type,const bool deal=false);
    //--- The columns of the table Orders (OnInitEvent makes the table of them, SyncDataToDB writes them)
     int               Columns(SOrderColumn &out[]) const;
   public:
    //--- Return the full collection list 'as is'
     CArrayObj        *GetList(void)                                                                       { return &this.m_list_all_orders;      }
    //--- The collection and the manager the EA gives it: the id of a symbol of the account, the marks of Setting_Sync
     void              SetSymbolsCollection(CSymbolsCollection *collection)                                { this.m_SymbolsCollection=collection;  }
     void              SetSyncManager(CSyncManager *manager)                                               { this.m_SyncManager=manager;           }
    //--- Return the number of (1) new orders, (2) new deals, (3) occurred trading event flag
     int               NewOrders(void)                                                               const { return this.m_delta_order;     }
     int               NewDeals(void)                                                                const { return this.m_delta_deal;      }
     bool              IsTradeEvent(void)                                                            const { return this.m_is_trade_event;  }
    //--- Lifecycle: opens the file of the account, makes the table Orders (the lines of what is on the account now, of an older table, go), reads its lines
     bool              OnInitEvent(void);
    //--- The lines of the table to RAM (which orders have a line, the Bid / Ask of the deals) / the orders of the list that have no line to the table
     bool              SyncDataFromDB(void);
     bool              SyncDataToDB(void);
    //--- A query on the file of the account: the names of its columns and every cell as text, row after row (the tables of the Trade Manage window, on a trading event)
    //--- Change from V4 COrderControl::Read_OrderControl: the table is this class's
     bool              Read(const string sql,string &names[],string &cells[],int &rows);
    //--- Update the list of orders, fill in data on the number of new ones and set the trading event flag (V1 / V3; the first call makes the past again: no flag);
    //--- the EA (as CEngine::TradeEventsControl) gives the lists to CTradeEventsCollection, whose events go to the chart
     void              RefreshHistory(void);
    //--- Constructor, destructor
                     CHistoryCollection(void);
                    ~CHistoryCollection(void);
  };
 #endif // CHISTORYCOLLECTION_MQH_DECLARATION
 #ifndef CHISTORYCOLLECTION_MQH_IMPLEMENTATION
 #define CHISTORYCOLLECTION_MQH_IMPLEMENTATION
 #define HISTORY_KEY_STATUS     ((long)1000000*1000000)   // the key of a line: status * this + ticket (a ticket is far below it)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CHistoryCollection::CHistoryCollection(void) : m_db(INVALID_HANDLE),m_SymbolsCollection(NULL),m_SyncManager(NULL),m_index_deal(0),m_delta_deal(0),m_index_order(0),
                                               m_delta_order(0),m_is_trade_event(false)
  {
   this.m_object_type=COLLECTION_HISTORY_ID;
   this.m_list_all_orders.Sort(SORT_BY_ORDER_TIME_OPEN);
   this.m_list_all_orders.Clear();
   this.m_list_all_orders.Type(COLLECTION_HISTORY_ID);
   this.m_list_pending.FreeMode(false);   // m_list_all_orders owns them
  }
CHistoryCollection::~CHistoryCollection(void)
  {
   if(this.m_db!=INVALID_HANDLE)
      ::DatabaseClose(this.m_db);
  }
//+------------------------------------------------------------------+
//| The columns of the table Orders: the properties of COrder, in the |
//| order of ENUM_ORDER_PROP_*, named as the property in lower case   |
//| without ORDER_PROP_. What the library calculates from the others  |
//| (direction, profit in points, the ids of the magic number...) has |
//| no column; symbol_id is OUR symbol, so no symbol name is kept     |
//+------------------------------------------------------------------+
int CHistoryCollection::Columns(SOrderColumn &out[]) const
  {
   SOrderColumn columns[]=
     {
      {"ticket","INTEGER NOT NULL",ORDER_PROP_TICKET},{"magic","INTEGER",ORDER_PROP_MAGIC},{"time_open","INTEGER",ORDER_PROP_TIME_OPEN},
      {"time_close","INTEGER",ORDER_PROP_TIME_CLOSE},{"time_exp","INTEGER",ORDER_PROP_TIME_EXP},{"type_filling","INTEGER",ORDER_PROP_TYPE_FILLING},
      {"type_time","INTEGER",ORDER_PROP_TYPE_TIME},{"status","INTEGER NOT NULL",ORDER_PROP_STATUS},{"type","INTEGER",ORDER_PROP_TYPE},
      {"reason","INTEGER",ORDER_PROP_REASON},{"state","INTEGER",ORDER_PROP_STATE},{"position_id","INTEGER",ORDER_PROP_POSITION_ID},
      {"position_by_id","INTEGER",ORDER_PROP_POSITION_BY_ID},{"deal_order_ticket","INTEGER",ORDER_PROP_DEAL_ORDER_TICKET},
      {"deal_entry","INTEGER",ORDER_PROP_DEAL_ENTRY},{"time_update","INTEGER",ORDER_PROP_TIME_UPDATE},{"symbol_id","INTEGER",ORDER_PROP_SYMBOL_ID},
      {"price_open","REAL",ORDER_PROP_PRICE_OPEN},{"sl","REAL",ORDER_PROP_SL},{"tp","REAL",ORDER_PROP_TP},{"fee","REAL",ORDER_PROP_FEE},
      {"profit","REAL",ORDER_PROP_PROFIT},{"commission","REAL",ORDER_PROP_COMMISSION},{"swap","REAL",ORDER_PROP_SWAP},{"volume","REAL",ORDER_PROP_VOLUME},
      {"volume_current","REAL",ORDER_PROP_VOLUME_CURRENT},{"price_stop_limit","REAL",ORDER_PROP_PRICE_STOP_LIMIT},{"bid","REAL",ORDER_PROP_BID},
      {"ask","REAL",ORDER_PROP_ASK},{"comment","TEXT",ORDER_PROP_COMMENT},{"ext_id","TEXT",ORDER_PROP_EXT_ID}
     };
   int total=::ArraySize(columns);
   ::ArrayResize(out,total);
   for(int i=0;i<total;i++)
      out[i]=columns[i];
   return total;
  }
//+------------------------------------------------------------------+
//| The table Orders is this class's: made when it is not there (what |
//| was marked as synced for it is not true any more); the lines of   |
//| the orders on the account an older V4 wrote go (they live in RAM: |
//| CMarketCollection); then its lines are read                       |
//+------------------------------------------------------------------+
bool CHistoryCollection::OnInitEvent(void)
  {
   if(this.m_db==INVALID_HANDLE)
     {
      this.m_db=LibDatabase_OpenAccount(DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
      if(this.m_db==INVALID_HANDLE)
        {
         ::Print(__FUNCTION__," > the database ",LibDatabase_AccountFile()," is not opened, error ",::GetLastError());
         return false;
        }
      ::DatabaseExecute(this.m_db,"PRAGMA busy_timeout="+(string)LIB_DATABASE_BUSY_MS);
      ::DatabaseExecute(this.m_db,"PRAGMA journal_mode=WAL");
     }
   const bool table_was_there=LibDatabase_TableExists(this.m_db,"Orders");
   SOrderColumn columns[];
   int total=this.Columns(columns);
   string fields="";
   for(int i=0;i<total;i++)
      fields+=(i>0 ? ", " : "")+columns[i].name+" "+columns[i].type;
   if(!::DatabaseExecute(this.m_db,"CREATE TABLE IF NOT EXISTS Orders (\n-- Library V4: class COrder (Entities/Trading/Order.mqh), properties ENUM_ORDER_PROP_* (Entities/Defines/TradingDefines.mqh); status = ENUM_ORDER_STATUS; the history only (CHistoryCollection)\n"+
                                   fields+", PRIMARY KEY (status, ticket)) WITHOUT ROWID"))
     {
      ::Print(__FUNCTION__," > the table Orders is not made, error ",::GetLastError());
      return false;
     }
   if(!table_was_there && this.m_SyncManager!=NULL)
      this.m_SyncManager.ResetObject_SyncManager(COLLECTION_HISTORY_ID);
   ::DatabaseExecute(this.m_db,"DELETE FROM Orders WHERE status IN ("+(string)(int)ORDER_STATUS_MARKET_PENDING+", "+(string)(int)ORDER_STATUS_MARKET_ORDER+", "+
                               (string)(int)ORDER_STATUS_MARKET_POSITION+")");
   ::Print("Complete ",__FUNCTION__," > ",LibDatabase_AccountFile()," opened");
   return this.SyncDataFromDB();
  }
//+------------------------------------------------------------------+
//| The lines of the table to RAM: the key of each line and the Bid / |
//| Ask of a deal (the orders themselves are made from the terminal)  |
//+------------------------------------------------------------------+
bool CHistoryCollection::SyncDataFromDB(void)
  {
   this.m_saved_key.Clear();
   ::ArrayResize(this.m_saved_bid,0);
   ::ArrayResize(this.m_saved_ask,0);
   if(this.m_db==INVALID_HANDLE)
      return false;
   int request=LibDatabase_Prepare(this.m_db,"SELECT status, ticket, COALESCE(bid, 0), COALESCE(ask, 0) FROM Orders ORDER BY status, ticket");
   if(request==INVALID_HANDLE)
     {
      ::Print(__FUNCTION__," > the table Orders is not read, error ",::GetLastError());
      return false;
     }
   int total=0;
   while(::DatabaseRead(request))
     {
      long status=0,ticket=0;
      double bid=0,ask=0;
      ::DatabaseColumnLong(request,0,status);
      ::DatabaseColumnLong(request,1,ticket);
      ::DatabaseColumnDouble(request,2,bid);
      ::DatabaseColumnDouble(request,3,ask);
      ::ArrayResize(this.m_saved_bid,total+1,4096);
      ::ArrayResize(this.m_saved_ask,total+1,4096);
      this.m_saved_key.Add(status*HISTORY_KEY_STATUS+ticket);   // ascending as the query: the index stays the one of the Bid / Ask
      this.m_saved_bid[total]=bid;
      this.m_saved_ask[total]=ask;
      total++;
     }
   ::DatabaseFinalize(request);
   this.m_saved_key.Sort();   // already ascending: Search can be used
   ::Print("Complete ",__FUNCTION__," > ",total," lines of the history in the table Orders read: the orders of the terminal that have one are not written again");
   return true;
  }
//+------------------------------------------------------------------+
//| The orders of the list that have no line go to the table, in one |
//| transaction: refused, they wait for the next call (Python writes)|
//| A property the kind of the order has not is NULL; a bid or an ask |
//| is never erased by a missing one; an order whose symbol is not    |
//| one of ours yet (symbol_id 0) is not written                      |
//+------------------------------------------------------------------+
bool CHistoryCollection::SyncDataToDB(void)
  {
   if(this.m_list_pending.Total()==0)
      return true;
   if(this.m_db==INVALID_HANDLE)
      return false;
   SOrderColumn columns[];
   int total=this.Columns(columns);
   string names="",updates="";
   for(int c=0;c<total;c++)
     {
      names+=(c>0 ? ", " : "")+columns[c].name;
      if(columns[c].name=="status" || columns[c].name=="ticket")
         continue;
      updates+=(updates=="" ? "" : ", ")+columns[c].name+" = "+((columns[c].name=="bid" || columns[c].name=="ask") ? "COALESCE(excluded."+columns[c].name+", Orders."+columns[c].name+")" : "excluded."+columns[c].name);
     }
   LibDatabase_AskToWrite();
   if(!::DatabaseTransactionBegin(this.m_db))
     {
      LibDatabase_WriteRefused("Begin Orders");
      return false;
     }
   bool done=true;
   for(int i=0;i<this.m_list_pending.Total() && done;i++)
     {
      COrder *order=this.m_list_pending.At(i);
      if(order==NULL || order.SymbolId()==0)
         continue;   // not one of our symbols yet: there is nothing to write
      string values="";
      for(int c=0;c<total;c++)
        {
         const int prop=columns[c].prop;
         string value="NULL";
         if(prop<ORDER_PROP_INTEGER_TOTAL)
           {
            if(order.SupportProperty((ENUM_ORDER_PROP_INTEGER)prop))
               value=(string)order.GetProperty((ENUM_ORDER_PROP_INTEGER)prop);
           }
         else if(prop<ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_DOUBLE_TOTAL)
           {
            double number=(order.SupportProperty((ENUM_ORDER_PROP_DOUBLE)prop) ? order.GetProperty((ENUM_ORDER_PROP_DOUBLE)prop) : 0);
            if(order.SupportProperty((ENUM_ORDER_PROP_DOUBLE)prop) && !((prop==ORDER_PROP_BID || prop==ORDER_PROP_ASK) && number==0))   // no tick was found: the writer of the past (Python) fills it
               value=::DoubleToString(number,8);
           }
         else if(order.SupportProperty((ENUM_ORDER_PROP_STRING)prop))
            value="'"+LibDatabase_Quoted(order.GetProperty((ENUM_ORDER_PROP_STRING)prop))+"'";
         values+=(c>0 ? ", " : "")+value;
        }
      done=::DatabaseExecute(this.m_db,"INSERT INTO Orders ("+names+") VALUES ("+values+") ON CONFLICT(status, ticket) DO UPDATE SET "+updates);
     }
   if(done && ::DatabaseTransactionCommit(this.m_db))
     {
      LibDatabase_WriteDone("Begin Orders");
      this.m_list_pending.Clear();
      return true;
     }
   ::DatabaseTransactionRollback(this.m_db);
   LibDatabase_WriteRefused("Commit Orders");
   return false;
  }
//+------------------------------------------------------------------+
//| A query on the file of the account, as text                      |
//+------------------------------------------------------------------+
bool CHistoryCollection::Read(const string sql,string &names[],string &cells[],int &rows)
  {
   ::ArrayResize(names,0);
   ::ArrayResize(cells,0);
   rows=0;
   if(this.m_db==INVALID_HANDLE)
      return false;
   int request=LibDatabase_Prepare(this.m_db,sql);
   if(request==INVALID_HANDLE)
      return false;
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
   rows=total;
   return true;
  }
//+------------------------------------------------------------------+
//| Update the list of orders and deals                              |
//+------------------------------------------------------------------+
//--- Change from V3: Refresh -> RefreshHistory; what has no line is written (the first call is the past: no flag)
void CHistoryCollection::RefreshHistory(void)
  {
   this.m_is_trade_event=false;
   if(!::HistorySelect(0,END_TIME))
      return;
   //--- Orders
    int total_orders=::HistoryOrdersTotal(),i=this.m_index_order;
    for(; i<total_orders; i++)
     {
      ulong order_ticket=::HistoryOrderGetTicket(i);
      if(order_ticket==0)
         continue;
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::HistoryOrderGetInteger(order_ticket,ORDER_TYPE);
      //--- If there is no order of this type and with this ticket in the list, create an order object and add it to the list
      if(!this.IsPresentOrderInList(order_ticket,type))
         this.CreateNewOrder(order_ticket,type);
      //--- Such an order is already present in the list, which means the necessary order is not the last one in the history list. Let's find it
      else
        {
         ENUM_ORDER_TYPE type_lost=WRONG_VALUE;
         ulong ticket_lost=this.OrderSearch(i,type_lost);
         if(ticket_lost>0)
            this.CreateNewOrder(ticket_lost,type_lost);
        }
     }
   //--- save the index of the last added order and the difference with the last check
    int delta_order=i-this.m_index_order;
    this.m_index_order=i;
    this.m_delta_order=delta_order;
   //--- Deals
    int total_deals=::HistoryDealsTotal(),j=this.m_index_deal;
    for(; j<total_deals; j++)
     {
      ulong deal_ticket=::HistoryDealGetTicket(j);
      if(deal_ticket==0)
         continue;
      this.CreateNewOrder(deal_ticket,WRONG_VALUE,true);
     }
   //--- save the index of the last added deal and the difference with the last check
    int delta_deal=j-this.m_index_deal;
    this.m_index_deal=j;
    this.m_delta_deal=delta_deal;
   //--- What has no line goes to the table (Event Rule: the method that changes the data writes it)
    this.SyncDataToDB();
    if(this.m_first_start)
     {
      this.m_first_start=false;
      this.m_saved_key.Clear();   // the past is made again: every line of the table was matched, the keys are not needed any more
      ::ArrayResize(this.m_saved_bid,0);
      ::ArrayResize(this.m_saved_ask,0);
      return;
     }
   //--- Set the new event flag in history
    this.m_is_trade_event=(this.m_delta_order+this.m_delta_deal>0);
  }
//+-----------------------------------------------------------------------------+
//| Return the flag of the order object presence in the list by type and ticket |
//+-----------------------------------------------------------------------------+
bool CHistoryCollection::IsPresentOrderInList(const ulong order_ticket,const ENUM_ORDER_TYPE type)
  {
   for(int i=0;i<this.m_list_all_orders.Total();i++)
     {
      COrder *order=this.m_list_all_orders.At(i);
      if(order!=NULL && order.Status()!=ORDER_STATUS_DEAL && order.TypeOrder()==type && order.Ticket()==order_ticket)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Return the "lost" order type and ticket                          |
//+------------------------------------------------------------------+
ulong CHistoryCollection::OrderSearch(const int start,ENUM_ORDER_TYPE &order_type)
  {
   ulong order_ticket=0;
   for(int i=start-1;i>=0;i--)
     {
      ulong ticket=::HistoryOrderGetTicket(i);
      if(ticket==0)
         continue;
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::HistoryOrderGetInteger(ticket,ORDER_TYPE);
      if(this.IsPresentOrderInList(ticket,type))
         continue;
      order_ticket=ticket;
      order_type=type;
     }
   return order_ticket;
  }
//+------------------------------------------------------------------+
//| Create the order object and place it to the list: a line of the  |
//| table gives it back its Bid / Ask; with no line it waits to be   |
//| written (a deal that just happened gets the tick of its time)    |
//+------------------------------------------------------------------+
bool CHistoryCollection::CreateNewOrder(const ulong order_ticket,const ENUM_ORDER_TYPE order_type,const bool deal=false)
  {
   COrder* order=NULL;
   if(deal)
      order=new CHistoryDeal(order_ticket);
   else if(order_type==ORDER_TYPE_BUY || order_type==ORDER_TYPE_SELL || order_type==ORDER_TYPE_CLOSE_BY)
      order=new CHistoryOrder(order_ticket);
   else
      order=new CHistoryPending(order_ticket);
   if(order==NULL)
      return false;
   if(this.m_SymbolsCollection!=NULL)
      order.SetSymbolId(this.m_SymbolsCollection.SymbolID(order.Symbol()));
   int index=this.m_saved_key.Search(order.GetProperty(ORDER_PROP_STATUS)*HISTORY_KEY_STATUS+(long)order.Ticket());
   if(index>WRONG_VALUE)
     {
      if(this.m_saved_bid[index]>0 && this.m_saved_ask[index]>0)
         order.SetBidAsk(this.m_saved_bid[index],this.m_saved_ask[index]);
     }
   else if(deal && !this.m_first_start)
      order.BidAskFromTicks();   // a deal that just happened: the tick of its time (the past is left to Python, the ticks of years are too many for a beat)
   if(!this.m_list_all_orders.InsertSort(order))
     {
      ::Print(DFUN,CMessage::Text(deal ? MSG_LIB_SYS_FAILED_ADD_DEAL_TO_LIST : MSG_LIB_SYS_FAILED_ADD_ORDER_TO_LIST));
      delete order;
      return false;
     }
   if(index==WRONG_VALUE)
      this.m_list_pending.Add(order);
   return true;
  }
//+------------------------------------------------------------------+
 #endif // CHISTORYCOLLECTION_MQH_IMPLEMENTATION
#endif // __HISTORYCOLLECTION_MQH__
