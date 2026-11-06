//+------------------------------------------------------------------+
//|                                        SymbolTFManager.mqh       |
//|                                     Copyright 2026, Anhnt        |
//| Center Point of Data (Single Source of Truth) for the pairs      |
//| Create table symbol_base                                         |
//| CRUD table symbols base on name and account_key                  |
//| account_key base on m_account_key in CDatabaseService            |
//| [] Update in V4: Use CDatabaseService                            |
//+------------------------------------------------------------------+
#ifndef CSYMBOLTFMANAGER_MQH
#define CSYMBOLTFMANAGER_MQH
 #include "..\..\Entities\Defines\EventDefines.mqh"
 #include "..\..\Entities\Bases\BaseObj.mqh"
 #include "..\..\Entities\Chart\ChartObj.mqh"
 #include "..\..\Entities\Settings\SymbolTFSetting.mqh"
 #include "..\ListObj.mqh"
 #include "..\..\Services\DELib\DatabaseService.mqh"
#ifndef CSYMBOLTFMANAGER_MQH_DECLARATION
#define CSYMBOLTFMANAGER_MQH_DECLARATION
 struct SSymbolBaseItem
  {
   long   id;
   string name;
  };
 SSymbolBaseItem symbol_base_list[] =
  {
   {1, "BTCUSD"},
   {2, "ETHUSD"},
   {3, "XAUUSD"},
   {4, "XAGUSD"},
   {5, "USOIL"},
   {6, "UKOIL"},
   {7, "USDVND"}
  };
 struct SSymbolsRow
  {
   string name;
   long   symbol_base_id;   // 0: not joined to symbol_base
  };
 //--- Rows of the tables, as CDatabaseService::Read binds them (the order of the SELECT)
 struct SSymbolTFRow
  {
   string name;
   long   tf_enum;
   long   buy_signal;
   long   sell_signal;
   long   sound_alert;
   long   message_alert;
  };
 class CSymbolTFManager : public CBaseObj
   {
     private:
       CListObj        m_list;              // the pairs of this account (CSymbolTFSetting), in the order of the table
       
       CDatabaseService  *m_CDatabaseService;  // The EA holds it
       SSymbolsRow     m_list_Table_symbols[]; // the rows of symbols of this account on RAM (new database)
       //Private Method
       int             IndexSetting(const string symbol, const ENUM_TIMEFRAMES tf) const;
       string          CanonicalSymbol(const string name) const;   // the name without its suffix
       int             Fetch(string &symbols[], ENUM_TIMEFRAMES &tfs[], bool &buy[], bool &sell[], bool &sound[], bool &message[]) const;
      //--- DB to RAM: once, in OnInitEvent
       bool            ReadDataFromDB(void);
       bool            ReadDataFromDB(const string symbol);   // symbols of the new database to RAM: one row, "" = every row of this account
      //--- Save on DB: everything of this account, one row of symbols, one pair as it is on RAM (the event tells what happened to it)
       bool            UpdateDataToDB(void);
       bool            UpdateDataToDB(const string symbol);
       bool            UpdateDataToDB(const string symbol, const ENUM_TIMEFRAMES tf, const ENUM_SYMBOLTF_MANAGER_EVENT event);

     public:
                          CSymbolTFManager(void) : m_CDatabaseService(NULL) { this.m_list.Type(OBJECT_DE_TYPE_SYMBOLTF_SETTING); }
                          ~CSymbolTFManager(void) {}
      void                SetDatabaseService    (CDatabaseService   *databaseService)    {this.m_CDatabaseService=databaseService;}
      //--- Lifecycle - same convention as the other managers: opens the database, reads the table to m_list once, the pair of the chart joins the list
       bool                OnInitEvent(void);
      //--- The symbols of this account on RAM, what CSymbolsCollection asks the database today: (1) the id in symbol_base (0: none), (2) the name of an id (empty: none), (3) the names
       long                SymbolID(const string account_symbol) const;
       string              AccountSymbol(const long symbol_id) const;
       int                 Read_RAM(string &names[]) const;
      //--- The index of a pair in m_list (WRONG_VALUE: none), the pair itself (NULL: none)
       CSymbolTFSetting   *Read_RAM(const string symbol, const ENUM_TIMEFRAMES tf) const;
      //--- What it announced itself: a pair picked (SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED), the chart goes there. The EA only passes the event on
       bool                OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam, CChartObj *chart);

      //--- The pairs of this account (m_list): Symbol-grouped (in the order a Symbol first appeared), TF-ascending within a Symbol.
      //--- A pair whose symbol does not exist on this server is left out
       int                 Read_RAM(string &symbols[], ENUM_TIMEFRAMES &tfs[]) const;
       int                 Read_RAM(string &symbols[], ENUM_TIMEFRAMES &tfs[], bool &buy[], bool &sell[], bool &sound[], bool &message[]) const;
       int                 Read_RAM(const string symbol, ENUM_TIMEFRAMES &tfs[]) const;   // the TFs of one Symbol, ascending
       string              Read_RAM(const ENUM_TIMEFRAMES tf) const;   // the text of a tf_enum, of timeframe_list

      //--- The four flags of a pair (Buy / Sell signal, sound alert, message alert): read from m_list, and set (m_list, then the table at once)
       bool                Read_RAM(const string symbol, const ENUM_TIMEFRAMES tf, const string column) const;   // a flag of a pair: buy_signal, sell_signal, sound_alert, message_alert
       bool                Update_SymbolTF_Setting(const string symbol, const ENUM_TIMEFRAMES tf, const string column, const bool on);   // a flag of a pair
       bool                Update_SymbolTF_Setting(const string symbol);   // a symbol of this account: its row of symbols, on DB and RAM
       bool                Update_SymbolTF_Setting(const string symbol, const ENUM_TIMEFRAMES tf, const ENUM_SYMBOLTF_MANAGER_EVENT event);
   };
#endif // CSYMBOLTFMANAGER_MQH_DECLARATION
#ifndef CSYMBOLTFMANAGER_MQH_IMPLEMENTATION
#define CSYMBOLTFMANAGER_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Lifecycle - same convention as the other managers. EA.mq5 calls   |
 //| this from its own OnInit(). The table is read once: a CHARTCHANGE |
 //| reinit keeps the database open and m_list as it is               |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::OnInitEvent(void)
   {
    // New In V4 after implemenation CDatabaseService
     if(this.m_CDatabaseService == NULL)
      {
       ::Print(__FUNCTION__, " > DatabaseService is not set");
       return false;
      }
     string sql_create_table_symbol_base = "CREATE TABLE IF NOT EXISTS symbol_base (id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE)";
     if(!this.m_CDatabaseService.Create("Common", sql_create_table_symbol_base))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't create table symbol_base");
       return false;
      }
     //--- Seed Default symbol_base data
     for(int i = 0; i < ::ArraySize(symbol_base_list); i++)
      {
       SSymbolBaseItem row = symbol_base_list[i];
       string sql_symbol_base = "INSERT OR IGNORE INTO symbol_base (id, name) VALUES (" + (string)row.id + ", '" +
                                this.m_CDatabaseService.QuoteSQLText(row.name) + "')";
       if(!this.m_CDatabaseService.Create("Common", sql_symbol_base))
        {
         ::Print(__FUNCTION__, " > symbol_base row not written: ", row.name);
         return false;
        }
      }
     string sql_create_table_symbols = "CREATE TABLE IF NOT EXISTS symbols (account_key TEXT NOT NULL REFERENCES accounts (account_key), name TEXT NOT NULL, "
                                       "symbol_base_id INTEGER REFERENCES symbol_base (id), PRIMARY KEY (account_key, name), UNIQUE (account_key, symbol_base_id))";
     if(!this.m_CDatabaseService.Create("Common", sql_create_table_symbols))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't create table symbols");
       return false;
      }
     string sql_create_table_Setting_SymbolTF = "CREATE TABLE IF NOT EXISTS Setting_SymbolTF (account_key TEXT NOT NULL, name TEXT NOT NULL, "
                                                "tf_enum INTEGER NOT NULL REFERENCES timeframes (tf_enum), buy_signal INTEGER NOT NULL DEFAULT 1, sell_signal INTEGER NOT NULL DEFAULT 1, "
                                                "sound_alert INTEGER NOT NULL DEFAULT 1, message_alert INTEGER NOT NULL DEFAULT 1, PRIMARY KEY (account_key, name, tf_enum), "
                                                "FOREIGN KEY (account_key, name) REFERENCES symbols (account_key, name))";
     if(!this.m_CDatabaseService.Create("Common", sql_create_table_Setting_SymbolTF))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't create table Setting_SymbolTF");
       return false;
      }
     //--- Once: a chart change writes nothing, RAM stays
     if(this.m_first_start)
      {
       if(!this.UpdateDataToDB())
          ::Print(__FUNCTION__, " > symbols / Setting_SymbolTF are not fully written to the new database");
       if(!this.ReadDataFromDB("") || !this.ReadDataFromDB())
          return false;
       this.m_first_start = false;
      }
     //--- The pair of the chart joins the list
     string cur_sym = ::Symbol();
     ENUM_TIMEFRAMES cur_tf = (ENUM_TIMEFRAMES)::Period();
     if(this.Read_RAM(cur_sym, cur_tf) == NULL)
        this.Update_SymbolTF_Setting(cur_sym, cur_tf, SYMBOLTF_MANAGER_EVENT_ADDED);
     return true;
   }
 //+------------------------------------------------------------------+
 //| The rows of this account to m_list, in the order of the table (a  |
 //| symbol that does not exist on this server is left out), and the   |
 //| table timeframes: once, the table is not asked again              |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::ReadDataFromDB(void)
  {
   // New In V4 after implemenation CDatabaseService
   this.m_list.Clear();
   if(this.m_CDatabaseService == NULL)
      return false;
   SSymbolTFRow rows[];
   if(!this.m_CDatabaseService.Read("Common", "SELECT name, tf_enum, buy_signal, sell_signal, sound_alert, message_alert FROM Setting_SymbolTF WHERE account_key = '" +
                                              this.m_CDatabaseService.QuoteSQLText(this.m_CDatabaseService.GetAccountKey()) + "' ORDER BY rowid", rows))
      return false;
   for(int i = 0; i < ::ArraySize(rows); i++)
    {
     if(!::SymbolInfoInteger(rows[i].name, SYMBOL_EXIST))
      {
       ::Print(__FUNCTION__, " > skipped ", rows[i].name, " ", this.Read_RAM((ENUM_TIMEFRAMES)(int)rows[i].tf_enum), ": symbol does not exist on this server");
       continue;
      }
     CSymbolTFSetting *row = new CSymbolTFSetting(rows[i].name, (ENUM_TIMEFRAMES)(int)rows[i].tf_enum);
     if(row == NULL)
        continue;
     row.BuySignal(rows[i].buy_signal != 0);
     row.SellSignal(rows[i].sell_signal != 0);
     row.SoundAlert(rows[i].sound_alert != 0);
     row.MessageAlert(rows[i].message_alert != 0);
     if(!this.m_list.Add(row))
        delete row;
    }
   ::Print("Complete ", __FUNCTION__, " > ", this.m_list.Total(), " pairs of Setting_SymbolTF read to RAM");
   return true;
  }
 //+------------------------------------------------------------------+
 //| symbols of the new database to RAM: one row (a symbol just        |
 //| written), "" = every row of this account, in the order of the     |
 //| table                                                             |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::ReadDataFromDB(const string symbol)
  {
   // New In V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService == NULL)
       return false;
    string sql = "SELECT name, COALESCE(symbol_base_id, 0) FROM symbols WHERE account_key = '" + this.m_CDatabaseService.QuoteSQLText(this.m_CDatabaseService.GetAccountKey()) + "'" +
                 (symbol == "" ? " ORDER BY rowid" : " AND name = '" + this.m_CDatabaseService.QuoteSQLText(symbol) + "'");
    SSymbolsRow rows[];
    if(!this.m_CDatabaseService.Read("Common", sql, rows))
       return false;
    if(symbol == "")
       ::ArrayResize(this.m_list_Table_symbols, 0);
    for(int i = 0; i < ::ArraySize(rows); i++)
      {
       int total = ::ArraySize(this.m_list_Table_symbols);
       int index = total;
       for(int k = 0; k < total; k++)
          if(this.m_list_Table_symbols[k].name == rows[i].name)
             index = k;
       if(index == total)
          ::ArrayResize(this.m_list_Table_symbols, total + 1);
       this.m_list_Table_symbols[index] = rows[i];
      }
    if(symbol == "")
       ::Print("Complete ", __FUNCTION__, " > ", ::ArraySize(this.m_list_Table_symbols), " rows of symbols of this account read to RAM");
    return true;
  }
 //--- The id in symbol_base of a symbol of this account: 0 when it has none
 long CSymbolTFManager::SymbolID(const string account_symbol) const
  {
   for(int i = 0; i < ::ArraySize(this.m_list_Table_symbols); i++)
      if(this.m_list_Table_symbols[i].name == account_symbol)
         return this.m_list_Table_symbols[i].symbol_base_id;
   return 0;
  }
 //--- The name this account gives to an id of symbol_base: empty when it has none
 string CSymbolTFManager::AccountSymbol(const long symbol_id) const
  {
   for(int i = 0; i < ::ArraySize(this.m_list_Table_symbols); i++)
      if(this.m_list_Table_symbols[i].symbol_base_id == symbol_id)
         return this.m_list_Table_symbols[i].name;
   return "";
  }
 //--- The names of the symbols of this account, in the order of the table
 int CSymbolTFManager::Read_RAM(string &names[]) const
  {
   int total = ::ArraySize(this.m_list_Table_symbols);
   ::ArrayResize(names, total);
   for(int i = 0; i < total; i++)
      names[i] = this.m_list_Table_symbols[i].name;
   return total;
  }
 //+------------------------------------------------------------------+
 //| The name of a symbol without its suffix: up to the first          |
 //| character that is not an upper-case letter or a digit             |
 //+------------------------------------------------------------------+
 string CSymbolTFManager::CanonicalSymbol(const string name) const
  {
   int end = 0;
   while(end < ::StringLen(name))
     {
      ushort c = ::StringGetCharacter(name, end);
      if(!((c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')))
         break;
      end++;
     }
   return (end > 0 ? ::StringSubstr(name, 0, end) : name);
  }
 int CSymbolTFManager::IndexSetting(const string symbol, const ENUM_TIMEFRAMES tf) const
  {
   for(int i = 0; i < this.m_list.Total(); i++)
    {
     CSymbolTFSetting *row = this.m_list.At(i);
     if(row != NULL && row.Symbol() == symbol && row.Timeframe() == tf)
        return i;
    }
   return WRONG_VALUE;
  }
 CSymbolTFSetting *CSymbolTFManager::Read_RAM(const string symbol, const ENUM_TIMEFRAMES tf) const
  {
   int index = this.IndexSetting(symbol, tf);
   return (index > WRONG_VALUE ? this.m_list.At(index) : NULL);
  }
 //+------------------------------------------------------------------+
 //| The pairs of this account, in the order the rows were written:    |
 //| grouped by Symbol (the order a Symbol first appears), then        |
 //| TF-ascending in a group                                           |
 //+------------------------------------------------------------------+
 int CSymbolTFManager::Fetch(string &symbols[], ENUM_TIMEFRAMES &tfs[], bool &buy[], bool &sell[], bool &sound[], bool &message[]) const
  {
   ::ArrayResize(symbols, 0);
   ::ArrayResize(tfs, 0);
   ::ArrayResize(buy, 0);
   ::ArrayResize(sell, 0);
   ::ArrayResize(sound, 0);
   ::ArrayResize(message, 0);
   string          row_symbol[];
   ENUM_TIMEFRAMES row_tf[];
   bool            row_buy[], row_sell[], row_sound[], row_message[];
   int rows = 0;
   for(int r = 0; r < this.m_list.Total(); r++)
    {
     CSymbolTFSetting *row = this.m_list.At(r);
     if(row == NULL)
        continue;
     ::ArrayResize(row_symbol, rows + 1);
     ::ArrayResize(row_tf, rows + 1);
     ::ArrayResize(row_buy, rows + 1);
     ::ArrayResize(row_sell, rows + 1);
     ::ArrayResize(row_sound, rows + 1);
     ::ArrayResize(row_message, rows + 1);
     row_symbol[rows]  = row.Symbol();
     row_tf[rows]      = row.Timeframe();
     row_buy[rows]     = row.BuySignal();
     row_sell[rows]    = row.SellSignal();
     row_sound[rows]   = row.SoundAlert();
     row_message[rows] = row.MessageAlert();
     rows++;
    }
   //--- the order of the Symbols: the order they first appear
   string order[];
   for(int i = 0; i < rows; i++)
    {
     bool known = false;
     for(int k = 0; k < ::ArraySize(order) && !known; k++)
        known = (order[k] == row_symbol[i]);
     if(!known)
      {
       ::ArrayResize(order, ::ArraySize(order) + 1);
       order[::ArraySize(order) - 1] = row_symbol[i];
      }
    }
   int total = 0;
   for(int g = 0; g < ::ArraySize(order); g++)
    {
     int first = total;
     for(int i = 0; i < rows; i++)
      {
       if(row_symbol[i] != order[g])
          continue;
       ::ArrayResize(symbols, total + 1);
       ::ArrayResize(tfs, total + 1);
       ::ArrayResize(buy, total + 1);
       ::ArrayResize(sell, total + 1);
       ::ArrayResize(sound, total + 1);
       ::ArrayResize(message, total + 1);
       //--- inserted at its place in the group (TF-ascending: tf_enum grows with the duration)
       int at = total;
       while(at > first && row_tf[i] < tfs[at - 1])
        {
         symbols[at] = symbols[at - 1];
         tfs[at]     = tfs[at - 1];
         buy[at]     = buy[at - 1];
         sell[at]    = sell[at - 1];
         sound[at]   = sound[at - 1];
         message[at] = message[at - 1];
         at--;
        }
       symbols[at] = row_symbol[i];
       tfs[at]     = row_tf[i];
       buy[at]     = row_buy[i];
       sell[at]    = row_sell[i];
       sound[at]   = row_sound[i];
       message[at] = row_message[i];
       total++;
      }
    }
   return total;
  }
 int CSymbolTFManager::Read_RAM(string &symbols[], ENUM_TIMEFRAMES &tfs[], bool &buy[], bool &sell[], bool &sound[], bool &message[]) const
  {
   return this.Fetch(symbols, tfs, buy, sell, sound, message);
  }
 int CSymbolTFManager::Read_RAM(string &symbols[], ENUM_TIMEFRAMES &tfs[]) const
  {
   bool buy[], sell[], sound[], message[];
   return this.Fetch(symbols, tfs, buy, sell, sound, message);
  }
 int CSymbolTFManager::Read_RAM(const string symbol, ENUM_TIMEFRAMES &out[]) const
  {
   string symbols[];
   ENUM_TIMEFRAMES tfs[];
   int total = this.Read_RAM(symbols, tfs);
   ::ArrayResize(out, 0);
   int count = 0;
   for(int i = 0; i < total; i++)
    {
     if(symbols[i] != symbol)
        continue;
     ::ArrayResize(out, count + 1);
     out[count++] = tfs[i];
    }
   return count;
  }
 string CSymbolTFManager::Read_RAM(const ENUM_TIMEFRAMES tf) const
  {
   for(int i = 0; i < ::ArraySize(timeframe_list); i++)
      if(timeframe_list[i].tf_enum == tf)
         return timeframe_list[i].name;
   return (string)(int)tf;   // not a timeframe of the list: the number shows
  }
 //+------------------------------------------------------------------+
 //| A flag of a pair (buy_signal, sell_signal, sound_alert,           |
 //| message_alert): m_list, then the row, then the event              |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::Read_RAM(const string symbol, const ENUM_TIMEFRAMES tf, const string column) const
  {
   CSymbolTFSetting *row = this.Read_RAM(symbol, tf);
   if(row == NULL)
      return false;
   if(column == "buy_signal")
      return row.BuySignal();
   if(column == "sell_signal")
      return row.SellSignal();
   if(column == "sound_alert")
      return row.SoundAlert();
   if(column == "message_alert")
      return row.MessageAlert();
   ::Print(__FUNCTION__, " > rejected: invalid column ", column);
   return false;
  }
 bool CSymbolTFManager::Update_SymbolTF_Setting(const string symbol, const ENUM_TIMEFRAMES tf, const string column, const bool on)
  {
   CSymbolTFSetting *row = this.Read_RAM(symbol, tf);
   if(row == NULL)
      return false;
   if(column == "buy_signal")
      row.BuySignal(on);
   else if(column == "sell_signal")
      row.SellSignal(on);
   else if(column == "sound_alert")
      row.SoundAlert(on);
   else if(column == "message_alert")
      row.MessageAlert(on);
   else
     {
      ::Print(__FUNCTION__, " > rejected: invalid column ", column);
      return false;
     }
   return this.Update_SymbolTF_Setting(symbol, tf, (column == "buy_signal" || column == "sell_signal") ? SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED : SYMBOLTF_MANAGER_EVENT_NO_EVENT);
  }
 //+------------------------------------------------------------------+
 //| One row of symbols: always added. symbol_base_id is the base of   |
 //| the name without its suffix; none or already taken: NULL          |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::UpdateDataToDB(const string symbol)
  {
   // New In V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService == NULL)
       return false;
    string account_key = this.m_CDatabaseService.QuoteSQLText(this.m_CDatabaseService.GetAccountKey());
    string name        = this.m_CDatabaseService.QuoteSQLText(symbol);
    string base        = this.m_CDatabaseService.QuoteSQLText(this.CanonicalSymbol(symbol));
    return this.m_CDatabaseService.Create("Common", "INSERT OR IGNORE INTO symbols (account_key, name, symbol_base_id) VALUES ('" + account_key + "', '" + name + "', "
           "(SELECT id FROM symbol_base WHERE name = '" + base + "' AND id NOT IN (SELECT symbol_base_id FROM symbols WHERE account_key = '" + account_key + "' AND symbol_base_id IS NOT NULL)))");
  }
 //+------------------------------------------------------------------+
 //| The chart symbol and the Market Watch (the names without a suffix |
 //| first, they take the symbol of ours), then the pairs of m_list    |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::UpdateDataToDB(void)
  {
   // New In V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService == NULL)
       return false;
    bool result = this.UpdateDataToDB(::Symbol());
    int total = ::SymbolsTotal(true);
    for(int pass = 0; pass < 2; pass++)
       for(int i = 0; i < total; i++)
         {
          string name = ::SymbolName(i, true);
          if((name == this.CanonicalSymbol(name)) == (pass == 0))
             result &= this.UpdateDataToDB(name);
         }
    string account_key = this.m_CDatabaseService.QuoteSQLText(this.m_CDatabaseService.GetAccountKey());
    for(int i = 0; i < this.m_list.Total(); i++)
      {
       CSymbolTFSetting *row = this.m_list.At(i);
       if(row == NULL)
          continue;
       result &= this.m_CDatabaseService.Create("Common", "INSERT OR IGNORE INTO Setting_SymbolTF (account_key, name, tf_enum, buy_signal, sell_signal, sound_alert, message_alert) VALUES ('" +
                 account_key + "', '" + this.m_CDatabaseService.QuoteSQLText(row.Symbol()) + "', " + (string)(int)row.Timeframe() + ", " + (string)(int)row.BuySignal() + ", " +
                 (string)(int)row.SellSignal() + ", " + (string)(int)row.SoundAlert() + ", " + (string)(int)row.MessageAlert() + ")");
      }
    return result;
  }
 //+------------------------------------------------------------------+
 //| A symbol of this account: its row of symbols. The id comes from   |
 //| the database, so RAM follows the write                            |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::Update_SymbolTF_Setting(const string symbol)
  {
   return (this.UpdateDataToDB(symbol) && this.ReadDataFromDB(symbol));
  }
 //+------------------------------------------------------------------+
 //| A pair: added (false when it exists or the symbol does not exist |
 //| on this server), deleted (not the pair of the                     |
 //| chart), picked (the chart goes there, nothing is written), or its |
 //| flags changed on RAM (BUYSELL_CHANGED; NO_EVENT: no event sent).  |
 //| The event carries the identity: symbol via sparam, TF via lparam, |
 //| NOT a position: EventChartCustom is queued, a position goes stale |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::Update_SymbolTF_Setting(const string symbol, const ENUM_TIMEFRAMES tf, const ENUM_SYMBOLTF_MANAGER_EVENT event)
  {
   if(event == SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED)
    {
     ::EventChartCustom(::ChartID(), (ushort)event, (long)tf, 0.0, symbol);
     return true;
    }
   if(event == SYMBOLTF_MANAGER_EVENT_ADDED)
    {
     if(this.Read_RAM(symbol, tf) != NULL)
        return false;
     if(!::SymbolInfoInteger(symbol, SYMBOL_EXIST))
      {
       ::Print(__FUNCTION__, " > rejected ", symbol, ": symbol does not exist on this server");
       return false;
      }
     CSymbolTFSetting *added = new CSymbolTFSetting(symbol, tf);
     if(added == NULL || !this.m_list.Add(added))
      {
       delete added;
       return false;
      }
     if(!this.UpdateDataToDB(symbol, tf, event))
      {
       this.m_list.Delete(this.m_list.Total() - 1);
       return false;
      }
     ::EventChartCustom(::ChartID(), (ushort)event, (long)tf, 0.0, symbol);
     return true;
    }
   if(event == SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED || event == SYMBOLTF_MANAGER_EVENT_NO_EVENT)
    {
     if(!this.UpdateDataToDB(symbol, tf, event))
        return false;
     if(event == SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED)
        ::EventChartCustom(::ChartID(), (ushort)event, (long)tf, 0.0, symbol);
     return true;
    }
   if(event == SYMBOLTF_MANAGER_EVENT_DELETE)
    {
     if(symbol == ::Symbol() && tf == (ENUM_TIMEFRAMES)::Period())
      {
       ::Print(__FUNCTION__, " > rejected: ", symbol, " ", EnumToString(tf), " is this chart's own pair");
       return false;
      }
     int index = this.IndexSetting(symbol, tf);
     if(index <= WRONG_VALUE)
      {
       ::Print(__FUNCTION__, " > rejected: no row for this identity");
       return false;
      }
     if(!this.UpdateDataToDB(symbol, tf, event))
        return false;
     this.m_list.Delete(index);
     ::EventChartCustom(::ChartID(), (ushort)event, (long)tf, 0.0, symbol);
     return true;
    }
   ::Print(__FUNCTION__, " > rejected: event ", (int)event, " is not for a pair");
   return false;
  }
 //+------------------------------------------------------------------+
 //| A pair on DB as it is on RAM: DELETE removes it, every other event|
 //| writes the whole row (ADDED: its symbol first)                    |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::UpdateDataToDB(const string symbol, const ENUM_TIMEFRAMES tf, const ENUM_SYMBOLTF_MANAGER_EVENT event)
  {
   CSymbolTFSetting *row = this.Read_RAM(symbol, tf);
   if(row == NULL)
      return false;
   // New In V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService == NULL)
       return false;
    string account_key = this.m_CDatabaseService.QuoteSQLText(this.m_CDatabaseService.GetAccountKey());
    string name        = this.m_CDatabaseService.QuoteSQLText(symbol);
    bool written = false;
    if(event == SYMBOLTF_MANAGER_EVENT_DELETE)
       written = this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_SymbolTF WHERE account_key = '" + account_key + "' AND name = '" + name + "' AND tf_enum = " + (string)(int)tf);
    else
     {
      if(event == SYMBOLTF_MANAGER_EVENT_ADDED && this.UpdateDataToDB(symbol))
         this.ReadDataFromDB(symbol);
      written = this.m_CDatabaseService.Update("Common", "INSERT INTO Setting_SymbolTF (account_key, name, tf_enum, buy_signal, sell_signal, sound_alert, message_alert) VALUES ('" +
                account_key + "', '" + name + "', " + (string)(int)tf + ", " + (string)(int)row.BuySignal() + ", " + (string)(int)row.SellSignal() + ", " +
                (string)(int)row.SoundAlert() + ", " + (string)(int)row.MessageAlert() + ") "
                "ON CONFLICT (account_key, name, tf_enum) DO UPDATE SET buy_signal = excluded.buy_signal, sell_signal = excluded.sell_signal, "
                "sound_alert = excluded.sound_alert, message_alert = excluded.message_alert");
     }
    if(!written)
       ::Print(__FUNCTION__, " > ", symbol, " ", this.Read_RAM(tf), " not written");
    return written;
  }
 //+------------------------------------------------------------------+
 //| A pair was picked (SETTING_CHANGED): sparam = its Symbol,        |
 //| lparam = its TF. The chart goes there                            |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam, CChartObj *chart)
   {
     if(chart == NULL || id != CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED)
        return false;
     return chart.SetSymbol(sparam, (ENUM_TIMEFRAMES)(int)lparam);
   }
#endif // CSYMBOLTFMANAGER_MQH_IMPLEMENTATION
#endif // CSYMBOLTFMANAGER_MQH
