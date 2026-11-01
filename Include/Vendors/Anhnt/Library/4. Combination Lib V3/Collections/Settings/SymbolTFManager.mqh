//+------------------------------------------------------------------+
//|                                        SymbolTFManager.mqh       |
//|                                     Copyright 2026, Anhnt        |
//| Center Point of Data (Single Source of Truth) for the pairs      |
//| Symbol+TF the EA cares about: they live in the table             |
//| Setting_SymbolTF of the database (one list for each account), the|
//| manager keeps no copy and asks the database each time. Its own   |
//| event chain (ADDED/DELETE) lets both CGUIPannel (Table/TreeView  |
//| refresh) and EA (future Layer 1 series management) react         |
//| independently, same split already established for indicators.    |
//+------------------------------------------------------------------+
#ifndef CSYMBOLTFMANAGER_MQH
#define CSYMBOLTFMANAGER_MQH
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\JSONConfig.mqh>     // JSONConfig_AccountKey(): the key of the account
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\LibDatabase.mqh>   // the file of the database (LIB_DATABASE_FILE)
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\EventDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Chart\ChartObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\DELib\TimeseriesDELib.mqh>
#ifndef CSYMBOLTFMANAGER_MQH_DECLARATION
#define CSYMBOLTFMANAGER_MQH_DECLARATION
 class CSymbolTFManager : public CBaseObj
   {
     private:
       int             m_db;                // the open database: Setting_SymbolTF is asked here, nothing is copied
       ENUM_TIMEFRAMES m_available_tf[];    // every timeframe Python serves, ascending (not the tracked pairs)
       //Private Method
       bool            Open(void);
       string          Quoted(const string text) const;
       string          Key(void) const { return JSONConfig_AccountKey(); }
       string          Where(const string symbol, const ENUM_TIMEFRAMES tf) const;
       bool            SetFlag(const string symbol, const ENUM_TIMEFRAMES tf, const string column, const bool on);
       bool            GetFlag(const string symbol, const ENUM_TIMEFRAMES tf, const string column) const;
       int             Fetch(string &symbols[], ENUM_TIMEFRAMES &tfs[], bool &buy[], bool &sell[], bool &sound[], bool &message[]) const;

     public:
                     CSymbolTFManager(void) : m_db(INVALID_HANDLE) {}
                    ~CSymbolTFManager(void) { if(m_db != INVALID_HANDLE) ::DatabaseClose(m_db); }
      //--- Lifecycle - same convention as CIndicatorTemplateManager::OnInitEvent: opens the database, the pair of the chart joins the list
       bool                OnInitEvent(void);
      //--- What it announced itself: a pair picked (NotifySettingChanged), the chart goes there. The EA only passes the event on
       bool                OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam, CChartObj *chart);

      //--- The pairs of this account, asked to the database each time: Symbol-grouped (in the order a Symbol first appeared), TF-ascending within a Symbol.
      //--- A pair whose symbol does not exist on this server is left out
       int                 Total(void) const;
       int                 Pairs(string &symbols[], ENUM_TIMEFRAMES &tfs[]) const;
       int                 Pairs(string &symbols[], ENUM_TIMEFRAMES &tfs[], bool &buy[], bool &sell[], bool &sound[], bool &message[]) const;
       int                 TimeframesOf(const string symbol, ENUM_TIMEFRAMES &tfs[]) const;   // the TFs of one Symbol, ascending
       bool                Exists(const string symbol, const ENUM_TIMEFRAMES tf) const;

      //--- The four flags of a pair (Buy / Sell signal into the Signal Bridge, sound alert, message alert): read, and set (written at once)
       bool                BuySignal(const string symbol, const ENUM_TIMEFRAMES tf) const            { return this.GetFlag(symbol, tf, "buy_signal");     }
       bool                BuySignal(const string symbol, const ENUM_TIMEFRAMES tf, const bool on)   { return this.SetFlag(symbol, tf, "buy_signal", on);  }
       bool                SellSignal(const string symbol, const ENUM_TIMEFRAMES tf) const           { return this.GetFlag(symbol, tf, "sell_signal");    }
       bool                SellSignal(const string symbol, const ENUM_TIMEFRAMES tf, const bool on)  { return this.SetFlag(symbol, tf, "sell_signal", on); }
       bool                SoundAlert(const string symbol, const ENUM_TIMEFRAMES tf) const           { return this.GetFlag(symbol, tf, "sound_alert");    }
       bool                SoundAlert(const string symbol, const ENUM_TIMEFRAMES tf, const bool on)  { return this.SetFlag(symbol, tf, "sound_alert", on); }
       bool                MessageAlert(const string symbol, const ENUM_TIMEFRAMES tf) const         { return this.GetFlag(symbol, tf, "message_alert");  }
       bool                MessageAlert(const string symbol, const ENUM_TIMEFRAMES tf, const bool on){ return this.SetFlag(symbol, tf, "message_alert", on); }

      //--Add, Remove a pair: written to the database at once, then the event
       bool                Add_SymbolTFSetting(const string symbol, const ENUM_TIMEFRAMES tf);      // false if the pair exists or the symbol is not joined (symbol_account)
       bool                Delete_SymbolTFSetting(const string symbol, const ENUM_TIMEFRAMES tf);
       void                NotifySettingChanged(const string symbol, const ENUM_TIMEFRAMES tf);
      //--- The timeframes Python can serve for any Symbol, "M1;M2;..." as Python sends them
       void                SetAvailableTimeframes(const string texts);
       int                 AvailableTimeframes(ENUM_TIMEFRAMES &out[]) const;
       virtual void        Print(const bool full_prop=false, const bool dash=false);
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
   m_db = ::DatabaseOpen(LIB_DATABASE_FILE, DATABASE_OPEN_READWRITE);
   if(m_db == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > the database ", LIB_DATABASE_FILE, " is not opened, error ", ::GetLastError());
     return false;
    }
   ::DatabaseExecute(m_db, "PRAGMA busy_timeout=5000");
   ::Print("Complete ", __FUNCTION__, " > ", LIB_DATABASE_FILE, " opened");
   return true;
  }
 //--- A text as it goes into a SQL string: the quote is doubled
 string CSymbolTFManager::Quoted(const string text) const
  {
   string result = text;
   ::StringReplace(result, "'", "''");
   return result;
  }
 //--- The WHERE of one pair of this account: the symbol is the name this account gives it (symbol_account joins it to ours)
 string CSymbolTFManager::Where(const string symbol, const ENUM_TIMEFRAMES tf) const
  {
   return "t.account_key = '" + this.Key() + "' AND a.account_symbol = '" + this.Quoted(symbol) + "' AND t.tf_enum = " + (string)(int)tf;
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
   if(m_db == INVALID_HANDLE)
      return 0;
   int request = ::DatabasePrepare(m_db, "SELECT a.account_symbol, t.tf_enum, t.buy_signal, t.sell_signal, t.sound_alert, t.message_alert FROM Setting_SymbolTF t "
                                         "JOIN symbol_account a ON a.account_key = t.account_key AND a.symbol_id = t.symbol_id WHERE t.account_key = '" + this.Key() + "' ORDER BY t.rowid");
   if(request == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > the query is not accepted, error ", ::GetLastError());
     return 0;
    }
   string          row_symbol[];
   ENUM_TIMEFRAMES row_tf[];
   bool            row_buy[], row_sell[], row_sound[], row_message[];
   int rows = 0;
   while(::DatabaseRead(request))
    {
     string symbol;
     long tf, b, s, so, m;
     ::DatabaseColumnText(request, 0, symbol);
     ::DatabaseColumnLong(request, 1, tf);
     ::DatabaseColumnLong(request, 2, b);
     ::DatabaseColumnLong(request, 3, s);
     ::DatabaseColumnLong(request, 4, so);
     ::DatabaseColumnLong(request, 5, m);
     if(!::SymbolInfoInteger(symbol, SYMBOL_EXIST))
      {
       ::Print(__FUNCTION__, " > skipped ", symbol, " ", TimeframeDescription((ENUM_TIMEFRAMES)(int)tf), ": symbol does not exist on this server");
       continue;
      }
     ::ArrayResize(row_symbol, rows + 1);
     ::ArrayResize(row_tf, rows + 1);
     ::ArrayResize(row_buy, rows + 1);
     ::ArrayResize(row_sell, rows + 1);
     ::ArrayResize(row_sound, rows + 1);
     ::ArrayResize(row_message, rows + 1);
     row_symbol[rows]  = symbol;
     row_tf[rows]      = (ENUM_TIMEFRAMES)(int)tf;
     row_buy[rows]     = (b != 0);
     row_sell[rows]    = (s != 0);
     row_sound[rows]   = (so != 0);
     row_message[rows] = (m != 0);
     rows++;
    }
   ::DatabaseFinalize(request);
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
       //--- inserted at its place in the group (TF-ascending)
       int at = total;
       while(at > first && IndexEnumTimeframe(row_tf[i]) < IndexEnumTimeframe(tfs[at - 1]))
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
 int CSymbolTFManager::Total(void) const
  {
   string symbols[];
   ENUM_TIMEFRAMES tfs[];
   return this.Pairs(symbols, tfs);
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
   if(m_db == INVALID_HANDLE)
      return false;
   int request = ::DatabasePrepare(m_db, "SELECT 1 FROM Setting_SymbolTF t JOIN symbol_account a ON a.account_key = t.account_key AND a.symbol_id = t.symbol_id WHERE " + this.Where(symbol, tf) + " LIMIT 1");
   if(request == INVALID_HANDLE)
      return false;
   bool found = ::DatabaseRead(request);
   ::DatabaseFinalize(request);
   return found;
  }
 bool CSymbolTFManager::GetFlag(const string symbol, const ENUM_TIMEFRAMES tf, const string column) const
  {
   if(m_db == INVALID_HANDLE)
      return false;
   int request = ::DatabasePrepare(m_db, "SELECT t." + column + " FROM Setting_SymbolTF t JOIN symbol_account a ON a.account_key = t.account_key AND a.symbol_id = t.symbol_id WHERE " + this.Where(symbol, tf));
   if(request == INVALID_HANDLE)
      return false;
   long value = 0;
   if(::DatabaseRead(request))
      ::DatabaseColumnLong(request, 0, value);
   ::DatabaseFinalize(request);
   return (value != 0);
  }
 bool CSymbolTFManager::SetFlag(const string symbol, const ENUM_TIMEFRAMES tf, const string column, const bool on)
  {
   if(m_db == INVALID_HANDLE)
      return false;
   return ::DatabaseExecute(m_db, "UPDATE Setting_SymbolTF SET " + column + " = " + (on ? "1" : "0") + " WHERE account_key = '" + this.Key() + "' AND tf_enum = " + (string)(int)tf +
                                  " AND symbol_id = (SELECT symbol_id FROM symbol_account WHERE account_key = '" + this.Key() + "' AND account_symbol = '" + this.Quoted(symbol) + "')");
  }
 void CSymbolTFManager::SetAvailableTimeframes(const string texts)
  {
   string part[];
   int total = ::StringSplit(texts, ';', part);
   ::ArrayResize(m_available_tf, 0);
   for(int i = 0; i < total; i++)
    {
     ENUM_TIMEFRAMES tf = TimestampByDescription(part[i]);
     if(tf == PERIOD_CURRENT) continue;
     int n = ::ArraySize(m_available_tf);
     ::ArrayResize(m_available_tf, n + 1);
     m_available_tf[n] = tf;
    }
   ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_TIMEFRAMES_CHANGED, 0, 0.0, "");   // the lists built from them follow
  }
 int CSymbolTFManager::AvailableTimeframes(ENUM_TIMEFRAMES &out[]) const
  {
   int total = ::ArraySize(m_available_tf);
   ::ArrayResize(out, total);
   for(int i = 0; i < total; i++)
      out[i] = m_available_tf[i];
   return total;
  }
 //+------------------------------------------------------------------+
 //| Add a pair: written at once, then the event. False when the pair  |
 //| exists, the symbol does not exist on this server, or it is not    |
 //| joined to one of ours (symbol_account)                            |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::Add_SymbolTFSetting(const string symbol, const ENUM_TIMEFRAMES tf)
  {
   if(m_db == INVALID_HANDLE || this.Exists(symbol, tf))
      return false;
   if(!::SymbolInfoInteger(symbol, SYMBOL_EXIST))
    {
     ::Print(__FUNCTION__, " > rejected ", symbol, ": symbol does not exist on this server");
     return false;
    }
   if(!::DatabaseExecute(m_db, "INSERT INTO Setting_SymbolTF (account_key, symbol_id, tf_enum) SELECT '" + this.Key() + "', symbol_id, " + (string)(int)tf +
                               " FROM symbol_account WHERE account_key = '" + this.Key() + "' AND account_symbol = '" + this.Quoted(symbol) + "' AND symbol_id IS NOT NULL"))
    {
     ::Print(__FUNCTION__, " > ", symbol, " ", TimeframeDescription(tf), " not written, error ", ::GetLastError());
     return false;
    }
   if(!this.Exists(symbol, tf))
    {
     ::Print(__FUNCTION__, " > rejected ", symbol, ": it is not joined to a symbol of ours (symbol_account)");
     return false;
    }
   // --- Identity (symbol via sparam, TF via lparam), NOT a position - EventChartCustom is queued/async, a position captured now can go stale
   // by the time a listener reads it. Passing identity directly is immune to that.
   ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_ADDED, (long)tf, 0.0, symbol);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Remove a pair: written at once, then the event                    |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::Delete_SymbolTFSetting(const string symbol, const ENUM_TIMEFRAMES tf)
  {
   if(symbol == ::Symbol() && tf == (ENUM_TIMEFRAMES)::Period())
    {
     ::Print(__FUNCTION__, " > rejected: ", symbol, " ", EnumToString(tf), " is this chart's own pair");
     return false;
    }
   if(m_db == INVALID_HANDLE || !this.Exists(symbol, tf))
    {
     ::Print(__FUNCTION__, " > rejected: no row for this identity");
     return false;
    }
   if(!::DatabaseExecute(m_db, "DELETE FROM Setting_SymbolTF WHERE account_key = '" + this.Key() + "' AND tf_enum = " + (string)(int)tf +
                               " AND symbol_id = (SELECT symbol_id FROM symbol_account WHERE account_key = '" + this.Key() + "' AND account_symbol = '" + this.Quoted(symbol) + "')"))
    {
     ::Print(__FUNCTION__, " > ", symbol, " ", TimeframeDescription(tf), " not removed, error ", ::GetLastError());
     return false;
    }
   ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_DELETE, (long)tf, 0.0, symbol);
   return true;
  }
 //+------------------------------------------------------------------+
 //| No row Add/Delete - see declaration comment.                      |
 //+------------------------------------------------------------------+
 void CSymbolTFManager::NotifySettingChanged(const string symbol, const ENUM_TIMEFRAMES tf)
   {
     // The same payload as ADDED / DELETE: the identity of the pair, symbol via sparam and TF via lparam
     ::EventChartCustom(::ChartID(), (ushort)SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED, (long)tf, 0.0, symbol);
   }
 //+------------------------------------------------------------------+
 //| Lifecycle - same convention as CIndicatorTemplateManager::        |
 //| OnInitEvent. EA.mq5 calls this from its own OnInit().             |
 //+------------------------------------------------------------------+
 bool CSymbolTFManager::OnInitEvent(void)
   {
     bool ok = (m_db != INVALID_HANDLE) || this.Open();   // a CHARTCHANGE reinit keeps the database open
     if(!ok)
        return false;
     string cur_sym = ::Symbol();
     ENUM_TIMEFRAMES cur_tf = (ENUM_TIMEFRAMES)::Period();
     if(!Exists(cur_sym, cur_tf))
       Add_SymbolTFSetting(cur_sym, cur_tf);
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
 //+------------------------------------------------------------------+
 //| Debug dump - README Working Rule Print Debug format                |
 //+------------------------------------------------------------------+
 void CSymbolTFManager::Print(const bool full_prop=false, const bool dash=false)
   {
     string symbols[];
     ENUM_TIMEFRAMES tfs[];
     bool buy[], sell[], sound[], message[];
     int total = this.Pairs(symbols, tfs, buy, sell, sound, message);
     ::Print("CSymbolTFManager::Print total=", total);
     for(int i = 0; i < total; i++)
        ::Print((dash ? " - " : ""), "CSymbolTFManager::Print symbol=", symbols[i], " tf=", TimeframeDescription(tfs[i]), " buy=", buy[i], " sell=", sell[i], " sound=", sound[i], " message=", message[i]);
   }
#endif // CSYMBOLTFMANAGER_MQH_IMPLEMENTATION
#endif // CSYMBOLTFMANAGER_MQH
