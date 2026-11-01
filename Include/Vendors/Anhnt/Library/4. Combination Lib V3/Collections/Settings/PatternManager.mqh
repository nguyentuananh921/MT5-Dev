//+------------------------------------------------------------------+
//|                                               PatternManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Single source of truth for the candle pattern settings: the list |
//| and the tables Setting_Pattern / Setting_PatternManager of the   |
//| database (V2 CBarPatternsControl without the calculation)        |
//+------------------------------------------------------------------+
#ifndef CPATTERNMANAGER_MQH
#define CPATTERNMANAGER_MQH
 #include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\EventDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Settings\PatternSetting.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\LibDatabase.mqh>   // the file of the database (LIB_DATABASE_FILE)
 //Inputs of the EA: in EA Configuration.mqh (section: Candle patterns)

#ifndef CPATTERNMANAGER_MQH_DECLARATION
#define CPATTERNMANAGER_MQH_DECLARATION
 class CPatternManager : public CBaseObj
  {
    private:
     CArrayObj          m_list;                // CPatternSetting*, in the order of the Python catalog once it arrived
     bool               m_loaded;              // the list was read from the database once: a chart-change re-init keeps what the user changed
     bool               m_show_markers;        // the badges are shown: the EA sets it from its input in OnInit (SetMarkers), the check box of the Quick Setting tab changes it
     color              m_buy_color;           // the colour of the Buy badge
     color              m_sell_color;          // the colour of the Sell badge
     int                IndexOf(const string name) const;
     CPatternSetting   *Add(const string name);
    public:
                        CPatternManager(void) : m_loaded(false),m_show_markers(false),m_buy_color(clrDodgerBlue),m_sell_color(clrRed) {}
                       ~CPatternManager(void) {}
   //--- Loads the list from the database once: the names and flags it holds
     bool               OnInitEvent(void);
     int                Total(void)                    const { return m_list.Total();   }
     CPatternSetting   *At(const int index)            const { return m_list.At(index); }
     CPatternSetting   *Find(const string name)        const;
   //--- The badges of the candle patterns: shown at all, and the colour of each side
   //--- The badges as the EA wants them at the start (its inputs): no event, nothing is listening yet
     void               SetMarkers(const bool show,const color buy_color,const color sell_color) { m_show_markers=show; m_buy_color=buy_color; m_sell_color=sell_color; }
     bool               ShowMarkers(void) const { return m_show_markers; }
     void               ShowMarkers(const bool on);   // fires PATTERN_MANAGER_EVENT_BUYSELL_CHANGED (empty sparam): the listeners draw the badges again
   //--- The colour of the badge that gathers the patterns of one side (all the Buy patterns of a candle are one badge, all the Sell ones another)
     color              BuyColor(void)  const { return m_buy_color;  }
     color              SellColor(void) const { return m_sell_color; }
   //--- Buy / Sell flag of a pattern by name, false when it is unknown
     bool               PatternSignalBuy(const string name)  const;
     bool               PatternSignalSell(const string name) const;
   //--- Python catalog "name:candles:sides;name:candles:sides;...": sets the candle counts and the sides, adds the patterns the file did not have
   //--- and puts the list in the catalog order. Returns true when anything changed
     bool               SetCatalog(const string catalog);
   //--- The master switch: every pattern shows (or hides) its Buy and Sell markers
     void               SetAllBuySell(const bool on);
     bool               AllBuySell(void) const;
   //--- The database (tables Setting_Pattern and Setting_PatternManager, the same set for every account): Load reads it, Save replaces it
     bool               LoadFromDatabase(void);
     bool               SaveToDatabase(void);
     virtual void       Print(const bool full_prop=false,const bool dash=false);
  };
#endif // CPATTERNMANAGER_MQH_DECLARATION

#ifndef CPATTERNMANAGER_MQH_IMPLEMENTATION
#define CPATTERNMANAGER_MQH_IMPLEMENTATION
 int CPatternManager::IndexOf(const string name) const
  {
   for(int i = 0; i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      if(row != NULL && row.Name() == name)
         return i;
     }
   return WRONG_VALUE;
  }
 CPatternSetting *CPatternManager::Find(const string name) const
  {
   int i = IndexOf(name);
   return (i >= 0) ? m_list.At(i) : NULL;
  }
 CPatternSetting *CPatternManager::Add(const string name)
  {
   CPatternSetting *row = new CPatternSetting(name);
   if(!m_list.Add(row))
     {
      delete row;
      return NULL;
     }
   return row;
  }
 bool CPatternManager::PatternSignalBuy(const string name) const
  {
   CPatternSetting *row = Find(name);
   return (row != NULL && row.BuySignal());
  }
 bool CPatternManager::PatternSignalSell(const string name) const
  {
   CPatternSetting *row = Find(name);
   return (row != NULL && row.SellSignal());
  }
 bool CPatternManager::SetCatalog(const string catalog)
  {
   string items[];
   int n = ::StringSplit(catalog, ';', items);
   bool changed = false;
   CArrayObj ordered;
   ordered.FreeMode(false);
   for(int i = 0; i < n; i++)
     {
      string parts[];
      int fields = ::StringSplit(items[i], ':', parts);
      if(fields < 2)
         continue;
      CPatternSetting *row = Find(parts[0]);
      if(row == NULL)
        {
         row = Add(parts[0]);
         changed = true;
        }
      if(row == NULL)
         continue;
      uint candles = (uint)::StringToInteger(parts[1]);
      if(row.Candles() != candles)
        {
         row.Candles(candles);
         changed = true;
        }
      if(fields == 3)
        {
         bool had_buy = row.HasBuy(), had_sell = row.HasSell();
         row.Sides(parts[2]);
         changed |= (had_buy != row.HasBuy() || had_sell != row.HasSell());
        }
      ordered.Add(row);
     }
   //--- A pattern of the file that Python does not know stays at the end
   for(int i = 0; i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      bool listed = false;
      for(int k = 0; k < ordered.Total() && !listed; k++)
         listed = (ordered.At(k) == row);
      if(row != NULL && !listed)
         ordered.Add(row);
     }
   bool same_order = (ordered.Total() == m_list.Total());
   for(int i = 0; i < ordered.Total() && same_order; i++)
      same_order = (ordered.At(i) == m_list.At(i));
   if(!same_order)
     {
      m_list.FreeMode(false);
      m_list.Clear();
      for(int i = 0; i < ordered.Total(); i++)
         m_list.Add(ordered.At(i));
      m_list.FreeMode(true);
      changed = true;
     }
   return changed;
  }
 void CPatternManager::SetAllBuySell(const bool on)
  {
   bool changed = false;
   for(int i = 0; i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      if(row == NULL)
         continue;
      //--- A side the pattern never has stays as it is
      bool buy_changed = (row.HasBuy() && row.BuySignal() != on);
      bool sell_changed = (row.HasSell() && row.SellSignal() != on);
      changed |= (buy_changed || sell_changed);
      if(row.HasBuy())
         row.BuySignal(on, false);
      if(row.HasSell())
         row.SellSignal(on, false);
     }
   if(changed)
      ::EventChartCustom(::ChartID(), (ushort)PATTERN_MANAGER_EVENT_BUYSELL_CHANGED, 0, 0.0, "");
  }
 bool CPatternManager::AllBuySell(void) const
  {
   for(int i = 0; i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      if(row != NULL && ((row.HasBuy() && !row.BuySignal()) || (row.HasSell() && !row.SellSignal())))
         return false;
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Read the patterns (Setting_Pattern, in the order of the rows) and |
 //| the check box (Setting_PatternManager) into the list - clears     |
 //| whatever was there first                                          |
 //+------------------------------------------------------------------+
 bool CPatternManager::LoadFromDatabase(void)
  {
   ulong started = ::GetMicrosecondCount();
   int db = ::DatabaseOpen(LIB_DATABASE_FILE, DATABASE_OPEN_READONLY);
   if(db == INVALID_HANDLE)
     {
      ::Print(__FUNCTION__, " > the database ", LIB_DATABASE_FILE, " is not opened, error ", ::GetLastError());
      return false;
     }
   int request = ::DatabasePrepare(db, "SELECT name, buy_signal, sell_signal, sound_alert, message_alert FROM Setting_Pattern ORDER BY rowid");
   if(request == INVALID_HANDLE)
     {
      ::Print(__FUNCTION__, " > the query is not accepted, error ", ::GetLastError());
      ::DatabaseClose(db);
      return false;
     }
   m_list.Clear();
   while(::DatabaseRead(request))
     {
      string name;
      long buy, sell, sound, message;
      ::DatabaseColumnText(request, 0, name);
      ::DatabaseColumnLong(request, 1, buy);
      ::DatabaseColumnLong(request, 2, sell);
      ::DatabaseColumnLong(request, 3, sound);
      ::DatabaseColumnLong(request, 4, message);
      if(name == "" || Find(name) != NULL)
         continue;
      CPatternSetting *row = Add(name);
      if(row == NULL)
         continue;
      row.BuySignal(buy != 0, false);
      row.SellSignal(sell != 0, false);
      row.SoundAlert(sound != 0);
      row.MessageAlert(message != 0);
     }
   ::DatabaseFinalize(request);
   request = ::DatabasePrepare(db, "SELECT show_markers FROM Setting_PatternManager WHERE id = 1");
   if(request != INVALID_HANDLE)
     {
      long show;
      if(::DatabaseRead(request) && ::DatabaseColumnLong(request, 0, show))
         m_show_markers = (show != 0);
      ::DatabaseFinalize(request);
     }
   ::DatabaseClose(db);
   ::Print("Complete ", __FUNCTION__, " > loaded ", m_list.Total(), " candle pattern(s) from ", LIB_DATABASE_FILE, " in ", ::GetMicrosecondCount() - started, " us");
   return true;
  }
 //+------------------------------------------------------------------+
 //| Write the list and the check box: the rows of Setting_Pattern are |
 //| replaced                                                          |
 //+------------------------------------------------------------------+
 bool CPatternManager::SaveToDatabase(void)
  {
   ulong started = ::GetMicrosecondCount();
   int db = ::DatabaseOpen(LIB_DATABASE_FILE, DATABASE_OPEN_READWRITE);
   if(db == INVALID_HANDLE)
     {
      ::Print(__FUNCTION__, " > the database ", LIB_DATABASE_FILE, " is not opened, error ", ::GetLastError());
      return false;
     }
   ::DatabaseExecute(db, "PRAGMA busy_timeout=5000");   // Python writes to the same file
   ::DatabaseTransactionBegin(db);
   bool ok = ::DatabaseExecute(db, "DELETE FROM Setting_Pattern");
   int saved = 0;
   for(int i = 0; ok && i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      if(row == NULL)
         continue;
      string name = row.Name();
      ::StringReplace(name, "'", "''");
      ok = ::DatabaseExecute(db, "INSERT OR REPLACE INTO Setting_Pattern (name, buy_signal, sell_signal, sound_alert, message_alert) VALUES ('" + name + "'," +
                                 (row.BuySignal() ? "1" : "0") + "," + (row.SellSignal() ? "1" : "0") + "," + (row.SoundAlert() ? "1" : "0") + "," + (row.MessageAlert() ? "1" : "0") + ")");
      if(ok)
         saved++;
     }
   if(ok)
      ok = ::DatabaseExecute(db, "INSERT OR REPLACE INTO Setting_PatternManager (id, show_markers) VALUES (1," + (m_show_markers ? "1" : "0") + ")");
   if(ok)
      ::DatabaseTransactionCommit(db);
   else
     {
      ::Print(__FUNCTION__, " > not written, error ", ::GetLastError());
      ::DatabaseTransactionRollback(db);
     }
   ::DatabaseClose(db);
   if(ok)
      ::Print("Complete ", __FUNCTION__, " > ", saved, " candle pattern(s) written to ", LIB_DATABASE_FILE, " in ", ::GetMicrosecondCount() - started, " us");
   return ok;
  }
 void CPatternManager::ShowMarkers(const bool on)
  {
   if(m_show_markers == on)
      return;
   m_show_markers = on;
   ::EventChartCustom(::ChartID(), (ushort)PATTERN_MANAGER_EVENT_BUYSELL_CHANGED, 0, 0.0, "");
  }
 bool CPatternManager::OnInitEvent(void)
  {
   if(m_loaded)
      return true;   // a chart-change re-init keeps what the user already changed
   m_loaded = true;
   return LoadFromDatabase();   // the check box of the tab was saved too: it is set over the input of the EA
  }
 void CPatternManager::Print(const bool full_prop=false,const bool dash=false)
  {
   ::Print("CPatternManager::Print total=", m_list.Total());
   for(int i = 0; i < m_list.Total(); i++)
     {
      CPatternSetting *row = m_list.At(i);
      if(row != NULL)
         row.Print(full_prop, true);
     }
  }
#endif // CPATTERNMANAGER_MQH_IMPLEMENTATION
#endif // CPATTERNMANAGER_MQH
