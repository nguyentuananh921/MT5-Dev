//+------------------------------------------------------------------+
//|                                               CSymbolManager.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"

#ifndef _CSYMBOL_MANAGER_
#define _CSYMBOL_MANAGER_

#include "DashboardDefines.mqh"

//+------------------------------------------------------------------+
//| Class CSymbolManager                                             |
//| Manages the list of tradable symbols and provides filtering      |
//+------------------------------------------------------------------+
class CSymbolManager
  {
private:
   string            m_symbols[];     // Full list of symbols
   string            m_filtered[];    // Filtered list based on search
   string            m_searchText;    // Current search string

   //+------------------------------------------------------------------+
   //| Sorts the symbol list alphabetically                             |
   //+------------------------------------------------------------------+
   void              SortSymbols();

public:
   //+------------------------------------------------------------------+
   //| Loads all tradable symbols from the broker                       |
   //+------------------------------------------------------------------+
   bool              Initialize();

   //+------------------------------------------------------------------+
   //| Returns the total number of symbols                              |
   //+------------------------------------------------------------------+
   int               GetCount() const;

   //+------------------------------------------------------------------+
   //| Returns the symbol at the given index                            |
   //+------------------------------------------------------------------+
   string            GetSymbol(int index) const;

   //+------------------------------------------------------------------+
   //| Filters the symbol list by a case‑insensitive substring search    |
   //+------------------------------------------------------------------+
   void              Filter(const string search);

   //+------------------------------------------------------------------+
   //| Returns the number of symbols after filtering                    |
   //+------------------------------------------------------------------+
   int               GetFilteredCount() const;

   //+------------------------------------------------------------------+
   //| Returns a filtered symbol by index                               |
   //+------------------------------------------------------------------+
   string            GetFilteredSymbol(int index) const;

   //+------------------------------------------------------------------+
   //| Returns the current search string                                |
   //+------------------------------------------------------------------+
   string            GetSearchText() const;

   //+------------------------------------------------------------------+
   //| Refreshes the symbol list (reloads and reapplies filter)         |
   //+------------------------------------------------------------------+
   void              Refresh();
  };

//+------------------------------------------------------------------+
//| Sorts the symbol list alphabetically                             |
//+------------------------------------------------------------------+
void CSymbolManager::SortSymbols()
  {
   ArraySort(m_symbols);
  }

//+------------------------------------------------------------------+
//| Loads all tradable symbols from the broker                       |
//+------------------------------------------------------------------+
bool CSymbolManager::Initialize()
  {
//--- Clear existing list
   ArrayResize(m_symbols, 0);
   int total = SymbolsTotal(false);   // Get only tradable symbols
   for(int i = 0; i < total; i++)
     {
      string sym = SymbolName(i, false);
      if(sym != "")
        {
         int sz = ArraySize(m_symbols);
         ArrayResize(m_symbols, sz + 1);
         m_symbols[sz] = sym;
        }
     }
//--- Sort and reset filter
   SortSymbols();
   m_searchText = "";
   return (ArraySize(m_symbols) > 0);
  }

//+------------------------------------------------------------------+
//| Returns the total number of symbols                              |
//+------------------------------------------------------------------+
int CSymbolManager::GetCount() const
  {
   return ArraySize(m_symbols);
  }

//+------------------------------------------------------------------+
//| Returns the symbol at the given index                            |
//+------------------------------------------------------------------+
string CSymbolManager::GetSymbol(int index) const
  {
   if(index < 0 || index >= ArraySize(m_symbols))
      return("");
   return m_symbols[index];
  }

//+------------------------------------------------------------------+
//| Filters the symbol list by a case‑insensitive substring search    |
//+------------------------------------------------------------------+
void CSymbolManager::Filter(const string search)
  {
   m_searchText = search;
   ArrayResize(m_filtered, 0);
//--- If search is empty, return all symbols
   if(search == "")
     {
      ArrayCopy(m_filtered, m_symbols);
      return;
     }
   string searchUpper = search;
   StringToUpper(searchUpper);
//--- Iterate and collect matching symbols
   for(int i = 0; i < ArraySize(m_symbols); i++)
     {
      string symUpper = m_symbols[i];
      StringToUpper(symUpper);
      if(StringFind(symUpper, searchUpper) != -1)
        {
         int sz = ArraySize(m_filtered);
         ArrayResize(m_filtered, sz + 1);
         m_filtered[sz] = m_symbols[i];
        }
     }
  }

//+------------------------------------------------------------------+
//| Returns the number of symbols after filtering                    |
//+------------------------------------------------------------------+
int CSymbolManager::GetFilteredCount() const
  {
   return ArraySize(m_filtered);
  }

//+------------------------------------------------------------------+
//| Returns a filtered symbol by index                               |
//+------------------------------------------------------------------+
string CSymbolManager::GetFilteredSymbol(int index) const
  {
   if(index < 0 || index >= ArraySize(m_filtered))
      return("");
   return m_filtered[index];
  }

//+------------------------------------------------------------------+
//| Returns the current search string                                |
//+------------------------------------------------------------------+
string CSymbolManager::GetSearchText() const
  {
   return m_searchText;
  }

//+------------------------------------------------------------------+
//| Refreshes the symbol list (reloads and reapplies filter)         |
//+------------------------------------------------------------------+
void CSymbolManager::Refresh()
  {
   Initialize();
   Filter(m_searchText);
  }

#endif
//+------------------------------------------------------------------+