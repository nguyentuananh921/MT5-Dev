//+------------------------------------------------------------------+
//|                                        SymbolTFManager.mqh       |
//|                                     Copyright 2026, Anhnt        |
//| Center Point of Data (Single Source of Truth) for the pairs      |
//| Symbol+TF the EA cares about: they live in the table             |
//| Setting_SymbolTF of the database (one list for each account),    |
//| read once to m_list (Live on RAM); a change is written to the    |
//| table at once (Save on DB: Python reads it). Its own event chain |
//| (ADDED/DELETE) lets both CGUIPannel (Table/TreeView refresh) and |
//| EA react independently                                           |
//+------------------------------------------------------------------+
#ifndef CSYMBOLTFMANAGER_MQH
#define CSYMBOLTFMANAGER_MQH
 #include "..\..\Services\DELib\DatabaseDELib.mqh"
 #include "..\..\Entities\Defines\EventDefines.mqh"
 #include "..\..\Entities\Bases\BaseObj.mqh"
 #include "..\..\Entities\Chart\ChartObj.mqh"
 #include "..\..\Entities\Settings\SymbolTFSetting.mqh"
 #include "..\ListObj.mqh"
#ifndef CSYMBOLTFMANAGER_MQH_DECLARATION
#define CSYMBOLTFMANAGER_MQH_DECLARATION
 class CSymbolTFManager : public CBaseObj
   {
     private:
       int             m_db;                // the open database: a change is written here
       CListObj        m_list;              // the pairs of this account (CSymbolTFSetting), in the order of the table
       int             m_tf_enums[];        // the table timeframes, read once (TimeframeName)
       string          m_tf_names[];
       //Private Method
       bool            Open(void);
       string          Key(void) const { return LibDatabase_AccountKey(); }
       string          Where(const long symbol_id, const ENUM_TIMEFRAMES tf) const;
       bool            SetFlag(const string symbol, const ENUM_TIMEFRAMES tf, const string column, const bool on);
       int             Fetch(string &symbols[], ENUM_TIMEFRAMES &tfs[], bool &buy[], bool &sell[], bool &sound[], bool &message[]) const;

     public:
                     CSymbolTFManager(void) : m_db(INVALID_HANDLE) { this.m_list.Type(OBJECT_DE_TYPE_SYMBOLTF_SETTING); }
                    ~CSymbolTFManager(void) { if(m_db != INVALID_HANDLE) ::DatabaseClose(m_db); }
      //--- Lifecycle - same convention as the other managers: opens the database, reads the table to m_list once, the pair of the chart joins the list
       bool                OnInitEvent(void);
      //--- The rows of this account to m_list, and the table timeframes (once, in OnInitEvent)
       bool                SyncDataFromDB(void);
      //--- The index of a pair in m_list (WRONG_VALUE: none), the pair itself (NULL: none)
       int                 IndexSetting(const string symbol, const ENUM_TIMEFRAMES tf) const;
       CSymbolTFSetting   *GetSetting(const string symbol, const ENUM_TIMEFRAMES tf) const;
      //--- What it announced itself: a pair picked (NotifySettingChanged), the chart goes there. The EA only passes the event on
       bool                OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam, CChartObj *chart);

      //--- The pairs of this account (m_list): Symbol-grouped (in the order a Symbol first appeared), TF-ascending within a Symbol.
      //--- A pair whose symbol does not exist on this server is left out
       int                 Pairs(string &symbols[], ENUM_TIMEFRAMES &tfs[]) const;
       int                 Pairs(string &symbols[], ENUM_TIMEFRAMES &tfs[], bool &buy[], bool &sell[], bool &sound[], bool &message[]) const;
       int                 TimeframesOf(const string symbol, ENUM_TIMEFRAMES &tfs[]) const;   // the TFs of one Symbol, ascending
       bool                Exists(const string symbol, const ENUM_TIMEFRAMES tf) const;
       string              TimeframeName(const ENUM_TIMEFRAMES tf) const;   // the text of a tf_enum, of the table timeframes (CIndicatorTemplateManager makes it in OnInitEvent), read once

      //--- The four flags of a pair (Buy / Sell signal, sound alert, message alert): read from m_list, and set (m_list, then the table at once)
       bool                BuySignal(const string symbol, const ENUM_TIMEFRAMES tf) const            { CSymbolTFSetting *row = this.GetSetting(symbol, tf); return (row != NULL && row.BuySignal());    }
       bool                BuySignal(const string symbol, const ENUM_TIMEFRAMES tf, const bool on)   { return this.SetFlag(symbol, tf, "buy_signal", on);  }
       bool                SellSignal(const string symbol, const ENUM_TIMEFRAMES tf) const           { CSymbolTFSetting *row = this.GetSetting(symbol, tf); return (row != NULL && row.SellSignal());   }
       bool                SellSignal(const string symbol, const ENUM_TIMEFRAMES tf, const bool on)  { return this.SetFlag(symbol, tf, "sell_signal", on); }
       bool                SoundAlert(const string symbol, const ENUM_TIMEFRAMES tf) const           { CSymbolTFSetting *row = this.GetSetting(symbol, tf); return (row != NULL && row.SoundAlert());   }
       bool                SoundAlert(const string symbol, const ENUM_TIMEFRAMES tf, const bool on)  { return this.SetFlag(symbol, tf, "sound_alert", on); }
       bool                MessageAlert(const string symbol, const ENUM_TIMEFRAMES tf) const         { CSymbolTFSetting *row = this.GetSetting(symbol, tf); return (row != NULL && row.MessageAlert()); }
       bool                MessageAlert(const string symbol, const ENUM_TIMEFRAMES tf, const bool on){ return this.SetFlag(symbol, tf, "message_alert", on); }

      //--Add, Remove a pair: m_list and the table at once, then the event
       bool                AddToDB(const string symbol, const ENUM_TIMEFRAMES tf);      // false if the pair exists or the symbol is not joined (symbols)
       bool                RemoveFromDB(const string symbol, const ENUM_TIMEFRAMES tf);
       void                NotifySettingChanged(const string symbol, const ENUM_TIMEFRAMES tf);
   };
#endif // CSYMBOLTFMANAGER_MQH_DECLARATION
#ifndef CSYMBOLTFMANAGER_MQH_IMPLEMENTATION
#define CSYMBOLTFMANAGER_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Open the database once: it stays open while the EA runs. Python   |
 //| writes to the same file, so a write waits for it                  |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::Open(void)
  {
   m_db = LibDatabase_Open(DATABASE_OPEN_READWRITE);
   if(m_db == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > the database ", LIB_DATABASE_FILE, " is not opened, error ", ::GetLastError());
     return false;
    }
   ::DatabaseExecute(m_db, "PRAGMA busy_timeout=5000");
   //--- The table is this class's: one list for each account (account_key), the symbol is OUR symbol, tf_enum the value of ENUM_TIMEFRAMES
   if(!::DatabaseExecute(m_db, "CREATE TABLE IF NOT EXISTS Setting_SymbolTF (account_key TEXT NOT NULL REFERENCES accounts (account_key), symbol_id INTEGER NOT NULL REFERENCES symbol_base (id), "
                               "tf_enum INTEGER NOT NULL REFERENCES timeframes (tf_enum), buy_signal INTEGER NOT NULL DEFAULT 1, sell_signal INTEGER NOT NULL DEFAULT 1, "
                               "sound_alert INTEGER NOT NULL DEFAULT 1, message_alert INTEGER NOT NULL DEFAULT 1, PRIMARY KEY (account_key, symbol_id, tf_enum))"))
    {
     ::Print(__FUNCTION__, " > the table Setting_SymbolTF is not made, error ", ::GetLastError());
     return false;
    }
   ::Print("Complete ", __FUNCTION__, " > ", LIB_DATABASE_FILE, " opened");
   return true;
  }
 //--- The WHERE of one row of this account in Setting_SymbolTF: the symbol of ours (its id) and the TF
 string CSymbolTFManager::Where(const long symbol_id, const ENUM_TIMEFRAMES tf) const
  {
   return "account_key = '" + this.Key() + "' AND symbol_id = " + (string)symbol_id + " AND tf_enum = " + (string)(int)tf;
  }
 //+------------------------------------------------------------------+
 //| The rows of this account to m_list, in the order of the table (a  |
 //| symbol that does not exist on this server is left out), and the   |
 //| table timeframes: once, the table is not asked again              |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::SyncDataFromDB(void)
  {
   this.m_list.Clear();
   ::ArrayResize(this.m_tf_enums, 0);
   ::ArrayResize(this.m_tf_names, 0);
   if(m_db == INVALID_HANDLE)
      return false;
   int request = LibDatabase_Prepare(m_db, "SELECT tf_enum, name FROM timeframes ORDER BY tf_enum");
   if(request != INVALID_HANDLE)
    {
     while(::DatabaseRead(request))
      {
       long tf;
       string name;
       ::DatabaseColumnLong(request, 0, tf);
       ::DatabaseColumnText(request, 1, name);
       int total = ::ArraySize(this.m_tf_enums);
       ::ArrayResize(this.m_tf_enums, total + 1);
       ::ArrayResize(this.m_tf_names, total + 1);
       this.m_tf_enums[total] = (int)tf;
       this.m_tf_names[total] = name;
      }
     ::DatabaseFinalize(request);
    }
   request = LibDatabase_Prepare(m_db, "SELECT t.symbol_id, a.name, t.tf_enum, t.buy_signal, t.sell_signal, t.sound_alert, t.message_alert FROM Setting_SymbolTF t "
                                     "JOIN symbols a ON a.account_key = t.account_key AND a.symbol_id = t.symbol_id WHERE t.account_key = '" + this.Key() + "' ORDER BY t.rowid");
   if(request == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > the query is not accepted, error ", ::GetLastError());
     return false;
    }
   while(::DatabaseRead(request))
    {
     string symbol;
     long symbol_id, tf, b, s, so, m;
     ::DatabaseColumnLong(request, 0, symbol_id);
     ::DatabaseColumnText(request, 1, symbol);
     ::DatabaseColumnLong(request, 2, tf);
     ::DatabaseColumnLong(request, 3, b);
     ::DatabaseColumnLong(request, 4, s);
     ::DatabaseColumnLong(request, 5, so);
     ::DatabaseColumnLong(request, 6, m);
     if(!::SymbolInfoInteger(symbol, SYMBOL_EXIST))
      {
       ::Print(__FUNCTION__, " > skipped ", symbol, " ", this.TimeframeName((ENUM_TIMEFRAMES)(int)tf), ": symbol does not exist on this server");
       continue;
      }
     CSymbolTFSetting *row = new CSymbolTFSetting(symbol_id, symbol, (ENUM_TIMEFRAMES)(int)tf);
     if(row == NULL)
        continue;
     row.BuySignal(b != 0);
     row.SellSignal(s != 0);
     row.SoundAlert(so != 0);
     row.MessageAlert(m != 0);
     if(!this.m_list.Add(row))
        delete row;
    }
   ::DatabaseFinalize(request);
   ::Print("Complete ", __FUNCTION__, " > ", this.m_list.Total(), " pairs of Setting_SymbolTF and ", ::ArraySize(this.m_tf_enums), " timeframes read to RAM");
   return true;
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
 CSymbolTFSetting *CSymbolTFManager::GetSetting(const string symbol, const ENUM_TIMEFRAMES tf) const
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
 int CSymbolTFManager::Pairs(string &symbols[], ENUM_TIMEFRAMES &tfs[], bool &buy[], bool &sell[], bool &sound[], bool &message[]) const
  {
   return this.Fetch(symbols, tfs, buy, sell, sound, message);
  }
 int CSymbolTFManager::Pairs(string &symbols[], ENUM_TIMEFRAMES &tfs[]) const
  {
   bool buy[], sell[], sound[], message[];
   return this.Fetch(symbols, tfs, buy, sell, sound, message);
  }
 int CSymbolTFManager::TimeframesOf(const string symbol, ENUM_TIMEFRAMES &out[]) const
  {
   string symbols[];
   ENUM_TIMEFRAMES tfs[];
   int total = this.Pairs(symbols, tfs);
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
 bool CSymbolTFManager::Exists(const string symbol, const ENUM_TIMEFRAMES tf) const
  {
   return (this.IndexSetting(symbol, tf) > WRONG_VALUE);
  }
 string CSymbolTFManager::TimeframeName(const ENUM_TIMEFRAMES tf) const
  {
   for(int i = 0; i < ::ArraySize(this.m_tf_enums); i++)
      if(this.m_tf_enums[i] == (int)tf)
         return this.m_tf_names[i];
   return (string)(int)tf;   // the table has no row for it: the number shows
  }
 //--- A flag of a pair: m_list, then its column at once
 bool CSymbolTFManager::SetFlag(const string symbol, const ENUM_TIMEFRAMES tf, const string column, const bool on)
  {
   CSymbolTFSetting *row = this.GetSetting(symbol, tf);
   if(row == NULL || m_db == INVALID_HANDLE)
      return false;
   if(column == "buy_signal")
      row.BuySignal(on);
   else if(column == "sell_signal")
      row.SellSignal(on);
   else if(column == "sound_alert")
      row.SoundAlert(on);
   else if(column == "message_alert")
      row.MessageAlert(on);
   return ::DatabaseExecute(m_db, "UPDATE Setting_SymbolTF SET " + column + " = " + (on ? "1" : "0") + " WHERE " + this.Where(row.SymbolID(), tf));
  }
 //+------------------------------------------------------------------+
 //| Add a pair: m_list and the table at once, then the event. False   |
 //| when the pair exists, the symbol does not exist on this server,   |
 //| or it is not joined to one of ours (symbols)                      |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::AddToDB(const string symbol, const ENUM_TIMEFRAMES tf)
  {
   if(m_db == INVALID_HANDLE || this.Exists(symbol, tf))
      return false;
   if(!::SymbolInfoInteger(symbol, SYMBOL_EXIST))
    {
     ::Print(__FUNCTION__, " > rejected ", symbol, ": symbol does not exist on this server");
     return false;
    }
   long symbol_id = LibDatabase_SymbolID(m_db, symbol);
   if(symbol_id <= 0)
    {
     ::Print(__FUNCTION__, " > rejected ", symbol, ": it is not joined to a symbol of ours (symbols)");
     return false;
    }
   if(!::DatabaseExecute(m_db, "INSERT INTO Setting_SymbolTF (account_key, symbol_id, tf_enum) VALUES ('" + this.Key() + "', " + (string)symbol_id + ", " + (string)(int)tf + ")"))
    {
     ::Print(__FUNCTION__, " > ", symbol, " ", this.TimeframeName(tf), " not written, error ", ::GetLastError());
     return false;
    }
   CSymbolTFSetting *row = new CSymbolTFSetting(symbol_id, symbol, tf);
   if(row == NULL || !this.m_list.Add(row))
    {
     delete row;
     return false;
    }
   // --- Identity (symbol via sparam, TF via lparam), NOT a position - EventChartCustom is queued/async, a position captured now can go stale
   // by the time a listener reads it. Passing identity directly is immune to that.
   ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_ADDED, (long)tf, 0.0, symbol);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Remove a pair: m_list and the table at once, then the event       |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::RemoveFromDB(const string symbol, const ENUM_TIMEFRAMES tf)
  {
   if(symbol == ::Symbol() && tf == (ENUM_TIMEFRAMES)::Period())
    {
     ::Print(__FUNCTION__, " > rejected: ", symbol, " ", EnumToString(tf), " is this chart's own pair");
     return false;
    }
   int index = this.IndexSetting(symbol, tf);
   CSymbolTFSetting *row = (index > WRONG_VALUE ? this.m_list.At(index) : NULL);
   if(m_db == INVALID_HANDLE || row == NULL)
    {
     ::Print(__FUNCTION__, " > rejected: no row for this identity");
     return false;
    }
   if(!::DatabaseExecute(m_db, "DELETE FROM Setting_SymbolTF WHERE " + this.Where(row.SymbolID(), tf)))
    {
     ::Print(__FUNCTION__, " > ", symbol, " ", this.TimeframeName(tf), " not removed, error ", ::GetLastError());
     return false;
    }
   this.m_list.Delete(index);
   ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_DELETE, (long)tf, 0.0, symbol);
   return true;
  }
 //+------------------------------------------------------------------+
 //| No row Add/Delete: the chart goes to the pair                     |
 //+------------------------------------------------------------------+
 void CSymbolTFManager::NotifySettingChanged(const string symbol, const ENUM_TIMEFRAMES tf)
   {
     // The same payload as ADDED / DELETE: the identity of the pair, symbol via sparam and TF via lparam
     ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED, (long)tf, 0.0, symbol);
   }
 //+------------------------------------------------------------------+
 //| Lifecycle - same convention as the other managers. EA.mq5 calls   |
 //| this from its own OnInit(). The table is read once: a CHARTCHANGE |
 //| reinit keeps the database open and m_list as it is               |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::OnInitEvent(void)
   {
     if(m_db == INVALID_HANDLE && (!this.Open() || !this.SyncDataFromDB()))
        return false;
     string cur_sym = ::Symbol();
     ENUM_TIMEFRAMES cur_tf = (ENUM_TIMEFRAMES)::Period();
     if(!Exists(cur_sym, cur_tf))
       AddToDB(cur_sym, cur_tf);
     return true;
   }

 //+------------------------------------------------------------------+
 //| A pair was picked (NotifySettingChanged): sparam = its Symbol,   |
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
