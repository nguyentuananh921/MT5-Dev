//+------------------------------------------------------------------+
//|                                   TradingSetupSettingManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Center Point of Data (Single Source of Truth) for per-Symbol      |
//| StopLost+Trailing rows - same pattern as CSymbolTFManager/         |
//| CIndicatorTemplateManager. Kept in Services (EA-local) rather than |
//| the Library, since CTradingSetupSetting itself is EA-local too -   |
//| the Library's CTrading/CTradingControl never needs to know about   |
//| it directly.                                                        |
//+------------------------------------------------------------------+
#ifndef CTRADINGSETUPSETTINGMANAGER_MQH
#define CTRADINGSETUPSETTINGMANAGER_MQH
 #include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Base\BaseObj.mqh>
 #include "TradingSetupSetting.mqh"
 #include "SymbolTFManager.mqh"

 //+------------------------------------------------------------------------------------+
 //| Events CTradingSetupSettingManager fires whenever Data genuinely changes - same     |
 //| principle as ENUM_SYMBOLTF_MANAGER_EVENT. Chains off SymbolTFManager's own LAST     |
 //| value (SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED), not off any earlier one.            |
 //+------------------------------------------------------------------------------------+
 enum ENUM_TRADING_SETUP_MANAGER_EVENT
  {
   TRADING_SETUP_MANAGER_EVENT_NO_EVENT = SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED + 1,
   TRADING_SETUP_MANAGER_EVENT_ADDED,     // a Symbol's Trading Setup row was genuinely added
   TRADING_SETUP_MANAGER_EVENT_DELETE,    // a Symbol's Trading Setup row was genuinely removed
   TRADING_SETUP_MANAGER_EVENT_CHANGED,   // an existing row's StopLost/Trailing fields were edited+Saved
  };

#ifndef CTRADINGSETUPSETTINGMANAGER_MQH_DECLARATION
#define CTRADINGSETUPSETTINGMANAGER_MQH_DECLARATION
 class CTradingSetupSettingManager : public CBaseObj
   {
     private:
       CArrayObj   m_list;                 // list of CTradingSetupSetting*
       string      m_last_removed_symbol;

     public:
                     CTradingSetupSettingManager(void) : m_last_removed_symbol("") {}
                    ~CTradingSetupSettingManager(void) {}

       int                     Total(void)                          const { return m_list.Total();   }
       CTradingSetupSetting   *At(const int index)                  const { return m_list.At(index); }

      //--- identity-based lookup - works in POINTERS, not array index
       CTradingSetupSetting   *FindByIdentity(const string symbol)   const;
       bool                    Exists(const string symbol)           const { return FindByIdentity(symbol) != NULL; }

      //--- Add/Remove based on Symbol identity
       CTradingSetupSetting   *Add_TradingSetupSetting(const string symbol);   // NULL if identity already exists
       bool                    Delete_TradingSetupSetting(const string symbol);
       void                    GetLastRemoved(string &out_symbol)     const;
       void                    NotifySettingChanged(const string symbol);

       virtual void            Print(const bool full_prop=false, const bool dash=false);
   };
 //+------------------------------------------------------------------+
 //| Identity-based lookup - returns the row itself, not an index      |
 //+------------------------------------------------------------------+
 CTradingSetupSetting *CTradingSetupSettingManager::FindByIdentity(const string symbol) const
   {
     for(int i = 0; i < m_list.Total(); i++)
      {
       CTradingSetupSetting *row = m_list.At(i);
       if(row != NULL && row.Symbol() == symbol) return row;
      }
     return NULL;
   }
 //+------------------------------------------------------------------+
 //| Append a new row - Data only, NULL if the identity already exists |
 //+------------------------------------------------------------------+
 CTradingSetupSetting *CTradingSetupSettingManager::Add_TradingSetupSetting(const string symbol)
  {
   if(Exists(symbol))
    {
     ::Print("MY DEBUG CTradingSetupSettingManager::Add_TradingSetupSetting: rejected, already exists ", symbol);
     return NULL;
    }
   CTradingSetupSetting *row = new CTradingSetupSetting();   // constructor already defaults SL/Trailing fields
   row.Symbol(symbol);
   if(!m_list.Add(row))
    {
     delete row;
     return NULL;
    }
   ::Print("MY DEBUG CTradingSetupSettingManager::Add_TradingSetupSetting: added ", symbol,
           " at index=", m_list.Total() - 1, " - firing TRADING_SETUP_MANAGER_EVENT_ADDED");
   ::EventChartCustom(::ChartID(), (ushort)TRADING_SETUP_MANAGER_EVENT_ADDED, (long)(m_list.Total() - 1), 0.0, symbol);
   return row;
  }
 //+------------------------------------------------------------------+
 //| Remove a row by identity - Data only                              |
 //+------------------------------------------------------------------+
 bool CTradingSetupSettingManager::Delete_TradingSetupSetting(const string symbol)
  {
   for(int i = 0; i < m_list.Total(); i++)
    {
     CTradingSetupSetting *row = m_list.At(i);
     if(row == NULL || row.Symbol() != symbol) continue;
     m_last_removed_symbol = symbol;
     if(!m_list.Delete(i)) return false;   // FreeMode default true - deletes the CTradingSetupSetting too
     ::EventChartCustom(::ChartID(), (ushort)TRADING_SETUP_MANAGER_EVENT_DELETE, 0, 0.0, symbol);
     return true;
    }
   ::Print(__FUNCTION__, " > rejected: no row for this identity");
   return false;
  }
 //+------------------------------------------------------------------+
 //| Identity of the row most recently removed - see declaration.      |
 //+------------------------------------------------------------------+
 void CTradingSetupSettingManager::GetLastRemoved(string &out_symbol) const
   {
     out_symbol = m_last_removed_symbol;
   }
 //+------------------------------------------------------------------+
 //| An existing row's fields were edited+Saved - no Add/Remove.       |
 //+------------------------------------------------------------------+
 void CTradingSetupSettingManager::NotifySettingChanged(const string symbol)
   {
     ::EventChartCustom(::ChartID(), (ushort)TRADING_SETUP_MANAGER_EVENT_CHANGED, 0, 0.0, symbol);
   }
 //+------------------------------------------------------------------+
 //| Debug dump - README Working Rule Print Debug format                |
 //+------------------------------------------------------------------+
 void CTradingSetupSettingManager::Print(const bool full_prop=false, const bool dash=false)
   {
     ::Print("CTradingSetupSettingManager::Print total=", m_list.Total());
     for(int i = 0; i < m_list.Total(); i++)
      {
       CTradingSetupSetting *row = m_list.At(i);
       if(row != NULL) row.Print(full_prop, true);
      }
   }
#endif // CTRADINGSETUPSETTINGMANAGER_MQH_DECLARATION
#endif // CTRADINGSETUPSETTINGMANAGER_MQH
