//+------------------------------------------------------------------+
//|                                            SymbolsCollection.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//| Lean version of the DoEasy symbol collection: the Market Watch   |
//| symbols as CSymbol objects and the Market Watch window events    |
//+------------------------------------------------------------------+
#ifndef __SYMBOLSCOLLECTION_MQH__
#define __SYMBOLSCOLLECTION_MQH__
#include <Arrays\ArrayString.mqh>
#include "ListObj.mqh"
#include "..\Entities\Bases\BaseObjExt.mqh"
#include "..\Entities\Defines\EventDefines.mqh"
#include "..\Entities\Trading\Symbol.mqh"
#include "..\Entities\Trading\SymbolCommon.mqh"
#ifndef SYMBOLS_COMMON_TOTAL
 #define SYMBOLS_COMMON_TOTAL        (TerminalInfoInteger(TERMINAL_BUILD)<2430 ? 1000 : 5000)   // Total number of MQL5 working symbols
#endif
#define SYMBOLS_COLLECTION_CHECK_MS  1000

#ifndef CSYMBOLSCOLLECTION_MQH_DECLARATION
#define CSYMBOLSCOLLECTION_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Symbol collection                                                |
 //+------------------------------------------------------------------+
 class CSymbolsCollection : public CBaseObjExt
  {
    private:
     CListObj           m_list_all_symbols;                          // The list of all symbol objects
     CArrayString       m_list_names;                                // Symbol name control list
     int                m_delta_symbol;                              // Difference in the number of symbols compared to the previous check
     int                m_total_symbols;                             // Number of symbols in the Market Watch window
     int                m_total_symbol_prev;                         // Number of symbols in the Market Watch window during the previous check
     ulong              m_check_ms;
   //--- Save names of the Market Watch symbols
     void               CopySymbolsNames(void);
   //--- Return the flag of a symbol object presence by its name in the (1) list of all symbols, (2) Market Watch window, (3) control list
     bool               IsPresentSymbolInList(const string symbol_name);
     bool               IsPresentSymbolInMW(const string symbol_name);
     bool               IsPresentSymbolInControlList(const string symbol_name);
   //--- Create the symbol object and place it to the list
     bool               CreateNewSymbol(const ENUM_SYMBOL_STATUS symbol_status,const string symbol_name,const int index);
   //--- Return (1) the number of visible symbols, (2) symbol index in the Market Watch window
     int                SymbolsTotalVisible(void)                    const;
     int                SymbolIndexInMW(const string symbol_name)    const;
   //--- A symbol affiliation with a group by name (every symbol is common until the per-type classes are ported)
     ENUM_SYMBOL_STATUS SymbolStatus(const string symbol_name)       const { return SYMBOL_STATUS_COMMON; }
    public:
   //--- Return the full collection list 'as is'
     CArrayObj         *GetList(void)                                      { return &this.m_list_all_symbols; }
   //--- Return the (1) symbol object, (2) the symbol object index from the list by a name
     CSymbol           *GetSymbolObjByName(const string name);
     int                GetIndexObjByName(const string name);
   //--- Return (1) the number of new symbols in the Market Watch window, (2) the number of symbols in the collection
     int                NewSymbols(void)                             const { return this.m_delta_symbol;                    }
     int                GetSymbolsCollectionTotal(void)              const { return this.m_list_all_symbols.Total();        }
   //--- Constructor
                        CSymbolsCollection(void);
   //--- Creating the symbol list (Market Watch or the complete list)
     bool               CreateSymbolsList(const bool flag);
   //--- Update (1) all, (2) quote data of the collection symbols
     virtual void       Refresh(void);
     void               RefreshRates(void);
   //--- Working with the Market Watch window events: fires MARKET_WATCH_EVENT_SYMBOL_ADD / _DEL / _SORT
     void               MarketWatchEventsControl(const bool send_events=true);
   //--- Takes the current Market Watch as the starting point: no event for what is already there
     void               OnInitEvent(void);
   //--- Checks the Market Watch window once a second
     void               OnTimerEvent(void);
   //--- Return the description of the Market Watch window event
     string             EventMWDescription(const ENUM_MW_EVENT event);
  };
#endif // CSYMBOLSCOLLECTION_MQH_DECLARATION

#ifndef CSYMBOLSCOLLECTION_MQH_IMPLEMENTATION
#define CSYMBOLSCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CSymbolsCollection::CSymbolsCollection(void) : m_delta_symbol(0),
                                                m_total_symbols(0),
                                                m_total_symbol_prev(0),
                                                m_check_ms(0)
  {
   this.m_type=COLLECTION_SYMBOLS_ID;
   this.m_list_all_symbols.Sort(SYMBOL_PROP_INDEX_MW);
   this.m_list_all_symbols.Clear();
   this.m_list_all_symbols.Type(COLLECTION_SYMBOLS_ID);
   this.m_list_names.Clear();
  }
 //+------------------------------------------------------------------+
 //| Update all collection symbol data                                |
 //+------------------------------------------------------------------+
 void CSymbolsCollection::Refresh(void)
  {
   int total=this.m_list_all_symbols.Total();
   for(int i=0;i<total;i++)
     {
      CSymbol *symbol=this.m_list_all_symbols.At(i);
      if(symbol==NULL)
         continue;
      symbol.Refresh();
     }
  }
 //+------------------------------------------------------------------+
 //| Update quote data of the collection symbols                      |
 //+------------------------------------------------------------------+
 void CSymbolsCollection::RefreshRates(void)
  {
   int total=this.m_list_all_symbols.Total();
   for(int i=0;i<total;i++)
     {
      CSymbol *symbol=this.m_list_all_symbols.At(i);
      if(symbol==NULL)
         continue;
      symbol.RefreshRates();
     }
  }
 //+------------------------------------------------------------------+
 //| Save names of the Market Watch symbols                           |
 //+------------------------------------------------------------------+
 void CSymbolsCollection::CopySymbolsNames(void)
  {
   this.m_list_names.Clear();
   int total=this.m_list_all_symbols.Total();
   for(int i=0;i<total;i++)
     {
      CSymbol *symbol=this.m_list_all_symbols.At(i);
      if(symbol==NULL)
         continue;
      this.m_list_names.Add(symbol.Name());
     }
  }
 //+------------------------------------------------------------------+
 //| A symbol object is in the list of all symbols                    |
 //+------------------------------------------------------------------+
 bool CSymbolsCollection::IsPresentSymbolInList(const string symbol_name)
  {
   return this.GetIndexObjByName(symbol_name)>WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| A symbol is in the Market Watch window                           |
 //+------------------------------------------------------------------+
 bool CSymbolsCollection::IsPresentSymbolInMW(const string symbol_name)
  {
   int total=::SymbolsTotal(true);
   for(int i=0;i<total;i++)
     {
      string name=::SymbolName(i,true);
      if(!::SymbolInfoInteger(name,SYMBOL_VISIBLE))
         continue;
      if(name==symbol_name)
         return true;
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| A symbol is in the control list                                  |
 //+------------------------------------------------------------------+
 bool CSymbolsCollection::IsPresentSymbolInControlList(const string symbol_name)
  {
   int total=this.m_list_names.Total();
   for(int i=0;i<total;i++)
      if(this.m_list_names.At(i)==symbol_name)
         return true;
   return false;
  }
 //+------------------------------------------------------------------+
 //| Create the symbol object and place it to the list                |
 //+------------------------------------------------------------------+
 bool CSymbolsCollection::CreateNewSymbol(const ENUM_SYMBOL_STATUS symbol_status,const string symbol_name,const int index)
  {
   string name=(symbol_name==NULL || symbol_name=="" ? ::Symbol() : symbol_name);
   if(this.IsPresentSymbolInList(name))
      return true;
   if(!::SymbolInfoInteger(name,SYMBOL_EXIST))
     {
      string t1=CMessage::Text(MSG_LIB_SYS_INPUT_ERROR_NO_SYMBOL);
      string t2=CMessage::Text(MSG_LIB_TEXT_SYMBOL_ON_SERVER);
      ::Print(DFUN,t1,name,t2);
      this.m_global_error=ERR_MARKET_UNKNOWN_SYMBOL;
      return false;
     }
   CSymbol *symbol=NULL;
   switch(symbol_status)
     {
      default : symbol=new CSymbolCommon(name,index); break;   // The rest: the per-type classes are added here as case labels
     }
   if(symbol==NULL)
     {
      ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_SYM_OBJ)," ",name);
      return false;
     }
   if(!this.m_list_all_symbols.Add(symbol))
     {
      ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_ADD_SYM_OBJ)," ",name);
      delete symbol;
      return false;
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Creating the symbol list (Market Watch or the complete list)     |
 //+------------------------------------------------------------------+
 bool CSymbolsCollection::CreateSymbolsList(const bool flag)
  {
   bool res=true;
   int total=::SymbolsTotal(flag);
   for(int i=0;i<total && i<SYMBOLS_COMMON_TOTAL;i++)
     {
      string name=::SymbolName(i,flag);
      if(flag && !::SymbolInfoInteger(name,SYMBOL_VISIBLE))
         continue;
      res&=this.CreateNewSymbol(this.SymbolStatus(name),name,i);
     }
   return res;
  }
 //+------------------------------------------------------------------+
 //| Number of visible symbols in the Market Watch window             |
 //+------------------------------------------------------------------+
 int CSymbolsCollection::SymbolsTotalVisible(void) const
  {
   int total=::SymbolsTotal(true),n=0;
   for(int i=0;i<total;i++)
      if(::SymbolInfoInteger(::SymbolName(i,true),SYMBOL_VISIBLE))
         n++;
   return n;
  }
 //+------------------------------------------------------------------+
 //| Symbol index in the Market Watch window                          |
 //+------------------------------------------------------------------+
 int CSymbolsCollection::SymbolIndexInMW(const string symbol_name) const
  {
   string name=(symbol_name==NULL || symbol_name=="" ? ::Symbol() : symbol_name);
   int total=::SymbolsTotal(true);
   for(int i=0;i<total;i++)
     {
      if(!::SymbolInfoInteger(::SymbolName(i,true),SYMBOL_VISIBLE))
         continue;
      if(::SymbolName(i,true)==name)
         return i;
     }
   return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Return the symbol object from the list by a name                 |
 //+------------------------------------------------------------------+
 CSymbol *CSymbolsCollection::GetSymbolObjByName(const string name)
  {
   int index=this.GetIndexObjByName(name);
   return(index>WRONG_VALUE ? this.m_list_all_symbols.At(index) : NULL);
  }
 //+------------------------------------------------------------------+
 //| Return the symbol object index from the list by a name           |
 //+------------------------------------------------------------------+
 int CSymbolsCollection::GetIndexObjByName(const string name)
  {
   int total=this.m_list_all_symbols.Total();
   for(int i=0;i<total;i++)
     {
      CSymbol *symbol=this.m_list_all_symbols.At(i);
      if(symbol!=NULL && symbol.Name()==name)
         return i;
     }
   return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Working with the Market Watch window events                      |
 //+------------------------------------------------------------------+
 void CSymbolsCollection::MarketWatchEventsControl(const bool send_events=true)
  {
   ::ResetLastError();
   //--- If no current prices are received, exit
   if(!::SymbolInfoTick(::Symbol(),this.m_tick))
     {
      this.m_global_error=::GetLastError();
      return;
     }
   uchar array[];
   int sum=0;
   this.m_hash_sum=0;
   //--- Hash sum of all visible symbols in the Market Watch window
   this.m_total_symbols=this.SymbolsTotalVisible();
   int total_symbols=::SymbolsTotal(true);
   for(int i=0;i<total_symbols;i++)
     {
      string name=::SymbolName(i,true);
      if(!::SymbolInfoInteger(name,SYMBOL_VISIBLE))
         continue;
      ::StringToCharArray(name,array);
      for(int j=::ArraySize(array)-1;j>WRONG_VALUE;j--)
         sum+=array[j];
      this.m_hash_sum+=i+sum;
     }
   //--- No events: create the collection list, remember the snapshot and exit
   if(!send_events)
     {
      this.m_list_all_symbols.Clear();
      this.CreateSymbolsList(true);
      this.CopySymbolsNames();
      this.m_hash_sum_prev=this.m_hash_sum;
      this.m_total_symbol_prev=this.m_total_symbols;
      return;
     }
   if(this.m_hash_sum==this.m_hash_sum_prev)
      return;
   //--- The Market Watch window changed: define the event
   this.m_list_events.Clear();   // events are sent to the chart: the list only holds the current ones
   this.m_delta_symbol=this.m_total_symbols-this.m_total_symbol_prev;
   ushort event_id=
    (ushort(
     this.m_total_symbols>this.m_total_symbol_prev ? MARKET_WATCH_EVENT_SYMBOL_ADD :
     this.m_total_symbols<this.m_total_symbol_prev ? MARKET_WATCH_EVENT_SYMBOL_DEL :
     MARKET_WATCH_EVENT_SYMBOL_SORT)
    );
   //--- A symbol was added: lparam = event time in milliseconds, dparam = symbol index, sparam = symbol name
   if(event_id==MARKET_WATCH_EVENT_SYMBOL_ADD)
     {
      int total=::SymbolsTotal(true);
      for(int i=0;i<total;i++)
        {
         string name=::SymbolName(i,true);
         if(!::SymbolInfoInteger(name,SYMBOL_VISIBLE))
            continue;
         if(this.IsPresentSymbolInList(name))
            continue;
         this.m_list_all_symbols.Clear();
         this.CreateSymbolsList(true);
         this.CopySymbolsNames();
         int index=this.GetIndexObjByName(name);
         if(this.EventAdd(event_id,this.TickTime(),index,name))
            ::EventChartCustom(::ChartID(),(ushort)event_id,this.TickTime(),index,name);
        }
      this.m_total_symbols=this.SymbolsTotalVisible();
     }
   //--- A symbol was removed: lparam = event time in milliseconds, dparam = -1, sparam = removed symbol name
   else if(event_id==MARKET_WATCH_EVENT_SYMBOL_DEL)
     {
      this.m_list_all_symbols.Clear();
      this.CreateSymbolsList(true);
      int total=this.m_list_names.Total();
      for(int i=0;i<total;i++)
        {
         string name=this.m_list_names.At(i);
         if(name==NULL || this.IsPresentSymbolInList(name))
            continue;
         if(this.EventAdd(event_id,this.TickTime(),WRONG_VALUE,name))
            ::EventChartCustom(::ChartID(),(ushort)event_id,this.TickTime(),WRONG_VALUE,name);
        }
      this.CopySymbolsNames();
      this.m_total_symbols=this.SymbolsTotalVisible();
     }
   //--- The symbols were sorted: lparam = event time in milliseconds, dparam = current symbol index, sparam = current symbol name
   else if(event_id==MARKET_WATCH_EVENT_SYMBOL_SORT)
     {
      this.m_list_all_symbols.Clear();
      this.m_list_all_symbols.Sort(SYMBOL_PROP_INDEX_MW);
      this.CreateSymbolsList(true);
      this.CopySymbolsNames();
      int index=this.GetIndexObjByName(::Symbol());
      ::EventChartCustom(::ChartID(),(ushort)event_id,this.TickTime(),index,::Symbol());
     }
   this.m_total_symbol_prev=this.m_total_symbols;
   this.m_hash_sum_prev=this.m_hash_sum;
  }
 void CSymbolsCollection::OnInitEvent(void)
  {
   this.MarketWatchEventsControl(false);
   this.m_check_ms=::GetTickCount64();
  }
 void CSymbolsCollection::OnTimerEvent(void)
  {
   if(::GetTickCount64()-this.m_check_ms<SYMBOLS_COLLECTION_CHECK_MS)
      return;
   this.m_check_ms=::GetTickCount64();
   this.MarketWatchEventsControl();
  }
 //+------------------------------------------------------------------+
 //| Return the Market Watch window event description                 |
 //+------------------------------------------------------------------+
 string CSymbolsCollection::EventMWDescription(const ENUM_MW_EVENT event)
  {
   return
     (
      event==MARKET_WATCH_EVENT_SYMBOL_ADD   ?  CMessage::Text(MSG_SYM_EVENT_SYMBOL_ADD)  :
      event==MARKET_WATCH_EVENT_SYMBOL_DEL   ?  CMessage::Text(MSG_SYM_EVENT_SYMBOL_DEL)  :
      event==MARKET_WATCH_EVENT_SYMBOL_SORT  ?  CMessage::Text(MSG_SYM_EVENT_SYMBOL_SORT) :
      EnumToString(event)
     );
  }
#endif // CSYMBOLSCOLLECTION_MQH_IMPLEMENTATION
#endif // __SYMBOLSCOLLECTION_MQH__
