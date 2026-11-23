//+------------------------------------------------------------------+
//|                                                TradeDatabase.mqh |
//| The orders of the account in the database of the library (the   |
//| file LibDatabase.mqh names; the tables orders, TradeEvent,       |
//| sync_state, view position_summary, one account_key for each      |
//| account) with the SQLite functions of MQL5. Read asks a query    |
//| about the account of the terminal; SaveDeal writes a deal        |
//| that has just been done, with its Bid and Ask, under the same    |
//| columns as Python. The result of a query is a flat list of texts |
//+------------------------------------------------------------------+
#ifndef __TRADEDATABASE_MQH__
#define __TRADEDATABASE_MQH__
 #include "Orders\HistoryDeal.mqh"
 #include "..\..\Services\LibDatabase.mqh"   // the file of the database, and with it the key of the account (the same one as the configuration of the account)
 //--- The columns of the view position_summary for the user, in its order (the account_key is left out: the query is about one account)
 #define TRADE_DATABASE_POSITION_COLUMNS "position_id, symbol, side, volume, open_ticket, open_time, open_price, open_bid, open_ask, open_spread, open_source, close_ticket, close_time, close_price, close_bid, close_ask, close_spread, close_source, net"
 //+------------------------------------------------------------------+
 //| One query, the database opened for it and closed again: Python  |
 //| writes all the time, the file is not held                        |
 //+------------------------------------------------------------------+
 class CTradeDatabase
  {
   private:
     string            m_error;                // what went wrong in the last call
   public:
   //--- The file of the database of the library, the same one for every account
     static string     FileName(void);
   //--- In front of a query: the names orders, TradeEvent and position_summary mean the lines of THIS account only (a query written for one account runs as it is)
     static string     Scope(void);
   //--- The columns (names) and every cell as text (cells, row after row); false when the file or the query is not there, Error() says why
     bool              Read(const string sql,string &names[],string &cells[],int &rows);
   //--- A deal that has just been done: its properties and the Bid and the Ask of its time go to the table orders (the line is the same one Python writes)
     bool              SaveDeal(const ulong deal_ticket);
     string            Error(void)             const { return this.m_error; }
  };
 string CTradeDatabase::FileName(void)
  {
   return LIB_DATABASE_FILE;
  }
 string CTradeDatabase::Scope(void)
  {
   string key=JSONConfig_AccountKey();   // letters, digits and _ . - only: it can go into the text as it is
   //--- The lines keep the symbol_id of OUR symbol; the program sees the name the account gives the symbol (symbol_account), as it always did
   return "WITH orders AS (SELECT o.*, a.account_symbol AS symbol FROM main.orders o LEFT JOIN main.symbol_account a ON a.account_key=o.account_key AND a.symbol_id=o.symbol_id WHERE o.account_key='"+key+"'), "+
          "TradeEvent AS (SELECT e.*, a.account_symbol AS symbol FROM main.TradeEvent e LEFT JOIN main.symbol_account a ON a.account_key=e.account_key AND a.symbol_id=e.symbol_id WHERE e.account_key='"+key+"'), "+
          "position_summary AS (SELECT "+TRADE_DATABASE_POSITION_COLUMNS+" FROM main.position_summary WHERE account_key='"+key+"') ";
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
   int request=::DatabasePrepare(db,CTradeDatabase::Scope()+sql);
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
 bool CTradeDatabase::SaveDeal(const ulong deal_ticket)
  {
   if(!::HistoryDealSelect(deal_ticket))
     {
      ::HistorySelect(0,::TimeCurrent()+86400);
      if(!::HistoryDealSelect(deal_ticket))
        {
         this.m_error="the deal "+(string)deal_ticket+" is not in the history";
         return false;
        }
     }
   CHistoryDeal deal(deal_ticket);
   long type=deal.GetProperty(ORDER_PROP_TYPE);
   if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
      return true;   // a balance operation is not kept here
   //--- The terminal does not keep the Bid and the Ask in the deal: the last tick at or before its time, else the tick of now
   if(!deal.BidAskFromTicks())
     {
      MqlTick tick;
      if(::SymbolInfoTick(deal.Symbol(),tick) && tick.bid>0 && tick.ask>0)
         deal.SetBidAsk(tick.bid,tick.ask);
     }
   string symbol=deal.GetProperty(ORDER_PROP_SYMBOL);
   //--- A deal of a symbol that is not joined to one of ours (symbol_account) is not written here: Python writes it when the user has joined the symbol
   string names[],cells[];
   int joined=0;
   string key_symbol=symbol;
   ::StringReplace(key_symbol,"'","''");
   if(!this.Read("SELECT symbol_id FROM symbol_account WHERE account_key='"+JSONConfig_AccountKey()+"' AND account_symbol='"+key_symbol+"' AND symbol_id IS NOT NULL",names,cells,joined) || joined==0)
     {
      this.m_error="the symbol "+symbol+" is not joined to a symbol of ours (symbol_account)";
      return false;
     }
   string comment=deal.GetProperty(ORDER_PROP_COMMENT);
   string ext_id=deal.GetProperty(ORDER_PROP_EXT_ID);
   ::StringReplace(comment,"'","''");
   ::StringReplace(ext_id,"'","''");
   string key=JSONConfig_AccountKey();
   string columns="account_key,status,ticket,magic,time_open,type,reason,position_id,deal_order_ticket,deal_entry,price_open,sl,tp,fee,profit,commission,swap,volume,symbol_id,comment,ext_id";
   string values="'"+key+"',"+(string)(int)ORDER_STATUS_DEAL+","+(string)deal_ticket+","+(string)deal.GetProperty(ORDER_PROP_MAGIC)+","+(string)deal.GetProperty(ORDER_PROP_TIME_OPEN)+","+
                 (string)type+","+(string)deal.GetProperty(ORDER_PROP_REASON)+","+(string)deal.GetProperty(ORDER_PROP_POSITION_ID)+","+
                 (string)deal.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET)+","+(string)deal.GetProperty(ORDER_PROP_DEAL_ENTRY)+","+
                 ::DoubleToString(deal.GetProperty(ORDER_PROP_PRICE_OPEN),8)+","+::DoubleToString(deal.GetProperty(ORDER_PROP_SL),8)+","+
                 ::DoubleToString(deal.GetProperty(ORDER_PROP_TP),8)+","+::DoubleToString(deal.GetProperty(ORDER_PROP_FEE),8)+","+
                 ::DoubleToString(deal.GetProperty(ORDER_PROP_PROFIT),8)+","+::DoubleToString(deal.GetProperty(ORDER_PROP_COMMISSION),8)+","+
                 ::DoubleToString(deal.GetProperty(ORDER_PROP_SWAP),8)+","+::DoubleToString(deal.GetProperty(ORDER_PROP_VOLUME),8)+
                 ","+cells[0]+",'"+comment+"','"+ext_id+"'";
   if(deal.Bid()>0 && deal.Ask()>0)   // no tick: the columns are left as they are and Python looks for the tick later
     {
      columns+=",bid,ask";
      values+=","+::DoubleToString(deal.Bid(),8)+","+::DoubleToString(deal.Ask(),8);
     }
   string parts[],updates="";
   int total=::StringSplit(columns,',',parts);
   for(int i=3;i<total;i++)   // account_key, status and ticket are the key
      updates+=(i>3 ? "," : "")+parts[i]+"=excluded."+parts[i];
   string sql="INSERT INTO orders ("+columns+") VALUES ("+values+") ON CONFLICT(account_key,status,ticket) DO UPDATE SET "+updates;
   string file=CTradeDatabase::FileName();
   int db=::DatabaseOpen(file,DATABASE_OPEN_READWRITE);
   if(db==INVALID_HANDLE)
     {
      this.m_error="the database "+file+" is not opened, error "+(string)::GetLastError();
      return false;
     }
   ::DatabaseExecute(db,"PRAGMA busy_timeout=5000");   // Python writes to the same file
   bool done=::DatabaseExecute(db,sql);
   if(!done)
      this.m_error="the deal "+(string)deal_ticket+" is not written, error "+(string)::GetLastError();
   else
     {
      //--- Saved until now (UTC, as Python writes it): the one that goes on reads it and goes on from there
      ::DatabaseExecute(db,"INSERT INTO sync_state (account_key,key,value,writer,updated) VALUES ('"+key+"','history',"+(string)((long)::TimeGMT()*1000)+",'ea',"+(string)((long)::TimeGMT()*1000)+
                           ") ON CONFLICT(account_key,key) DO UPDATE SET value=MAX(value,excluded.value), writer='ea', updated=excluded.updated");
      this.m_error="";
     }
   ::DatabaseClose(db);
   return done;
  }
#endif // __TRADEDATABASE_MQH__
