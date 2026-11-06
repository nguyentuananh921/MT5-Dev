//+------------------------------------------------------------------+
//|                                              SymbolsCollection.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//| Link https://www.mql5.com/en/articles/7041                       |
//| Lib https://www.mql5.com/en/articles/14710                       |
//| The symbols of each account (XAUUSDm),(XAUUSDc)....              |
//| Create table       |
//| Create table                                           |
//| CRUD table              |
//| Update in V4: Use CDatabaseService                               |
//+------------------------------------------------------------------+
#ifndef __SYMBOLSCOLLECTION_MQH__
#define __SYMBOLSCOLLECTION_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include <Arrays\ArrayString.mqh>
 #include "..\Entities\Bases\BaseObjExt.mqh"
 #include "..\Entities\Defines\EventDefines.mqh"
 #include "..\Entities\Trading\SymbolCommon.mqh"
 #include "Settings\SymbolTFManager.mqh"
 #define SYMBOLS_COLLECTION_CHECK_MS  1000
#ifndef CSYMBOLSCOLLECTION_MQH_DECLARATION
#define CSYMBOLSCOLLECTION_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Collection of the symbols of this account                        |
 //+------------------------------------------------------------------+
 class CSymbolsCollection : public CBaseObjExt
  {
   private:
    CArrayObj         m_list_all_symbols;                          // The list of all symbol objects, in the order they were written to the database
    CArrayString      m_list_names;                                // Symbol name control list (V3): the names of the Market Watch at the last check
    int               m_delta_symbol;                              // Difference in the number of symbols compared to the previous check
    int               m_total_symbols;                             // Number of symbols in the Market Watch window
    int               m_total_symbol_prev;                         // Number of symbols in the Market Watch window during the previous check
    ulong             m_check_ms;                                  // When the Market Watch was looked at last
    CSymbolTFManager *m_SymbolTFManager;                           // The EA holds it: the center, every work with the database goes through it

   //--- Save names of the Market Watch symbols (V3; Change: the names of the Market Watch, the list is symbols)
    void              CopySymbolsNames(void);
   //--- Return the flag of a symbol presence by its name in the (1) Market Watch window, (2) control list (V3)
    bool              IsPresentSymbolInMW(const string symbol_name);
    bool              IsPresentSymbolInControlList(const string symbol_name);
   //--- Return the number of visible symbols (V3)
    int               SymbolsTotalVisible(void)                    const;
   public:
   //--- Return the full collection list 'as is'
    CArrayObj        *GetList(void)                                   { return &this.m_list_all_symbols; }
   //--- Return the (1) symbol object, (2) the symbol object index from the list by a name (V3)
    CSymbol          *GetSymbolObjByName(const string name);
    int               GetIndexObjByName(const string name);
   //--- Return the number of new symbols in the Market Watch window (V3)
    int               NewSymbols(void)                             const { return this.m_delta_symbol;     }
   //--- Constructor, destructor
                      CSymbolsCollection(void);
                     ~CSymbolsCollection(void);
    void              SetSymbolTFManager(CSymbolTFManager *manager)   { this.m_SymbolTFManager=manager; }
   //--- Lifecycle: the chart symbol and the Market Watch have their lines in symbols, then the symbols of this account are read from the database
    bool              OnInitEvent(void);
   //--- Working with the Market Watch window events (V3): fires MARKET_WATCH_EVENT_SYMBOL_ADD / _DEL / _SORT; a new symbol gets its line and its object
    void              MarketWatchEventsControl(const bool send_events=true);
   //--- Checks the Market Watch window once a second (V3)
    void              OnTimerEvent(void);
  };
#endif // CSYMBOLSCOLLECTION_MQH_DECLARATION
#ifndef CSYMBOLSCOLLECTION_MQH_IMPLEMENTATION
#define CSYMBOLSCOLLECTION_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CSymbolsCollection::CSymbolsCollection(void) :
          m_delta_symbol(0),m_total_symbols(0),m_total_symbol_prev(0),m_check_ms(0),m_SymbolTFManager(NULL)
  {
   this.m_object_type=COLLECTION_SYMBOLS_ID;
   this.m_list_names.Clear();
  }
 CSymbolsCollection::~CSymbolsCollection(void)
  {
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
 //| The symbol of the chart has its line, then the symbols of this    |
 //| account are read from the database                                |
 //+------------------------------------------------------------------+
 bool CSymbolsCollection::OnInitEvent(void)
  {

   // New In V4 after implemenation CDatabaseService
    this.m_list_all_symbols.Clear();
    if(this.m_SymbolTFManager==NULL)
      {
       ::Print(__FUNCTION__," > SymbolTFManager is not set");
       return false;
      }
    string names[];
    int total=this.m_SymbolTFManager.Read_RAM(names);
    if(total==0)
       ::Print(__FUNCTION__," > no symbol of this account from SymbolTFManager");
    for(int i=0;i<total;i++)
       this.m_list_all_symbols.Add(new CSymbolCommon(names[i],this.m_list_all_symbols.Total()));   // V3: every symbol is common until the per-type classes are ported
   //--- V3: the current Market Watch is the starting point, no event for what is already there
   this.MarketWatchEventsControl(false);
   this.m_check_ms=::GetTickCount64();
   return true;
  }
 //+------------------------------------------------------------------+
 //| Save names of the Market Watch symbols                           |
 //+------------------------------------------------------------------+
 void CSymbolsCollection::CopySymbolsNames(void)
  {
   this.m_list_names.Clear();
   int total=::SymbolsTotal(true);
   for(int i=0;i<total;i++)
     {
      string name=::SymbolName(i,true);
      if(::SymbolInfoInteger(name,SYMBOL_VISIBLE))
         this.m_list_names.Add(name);
     }
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
 //| Working with the Market Watch window events                      |
 //+------------------------------------------------------------------+
 //--- Change from V3: the names that came are looked for by name (a symbol added and another removed in one second is both), a new one gets its line
 //--- in symbols and its object; one that left stays in the list (symbols)
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
   //--- No events: remember the snapshot and exit
   if(!send_events)
     {
      this.CopySymbolsNames();
      this.m_hash_sum_prev=this.m_hash_sum;
      this.m_total_symbol_prev=this.m_total_symbols;
      return;
     }
   if(this.m_hash_sum==this.m_hash_sum_prev)
      return;
   //--- The Market Watch window changed: define the events
   this.m_list_events.Clear();   // events are sent to the chart: the list only holds the current ones
   this.m_delta_symbol=this.m_total_symbols-this.m_total_symbol_prev;
   bool told=false;
   //--- A symbol was added: lparam = event time in milliseconds, dparam = symbol index, sparam = symbol name
   for(int i=0;i<total_symbols;i++)
     {
      string name=::SymbolName(i,true);
      if(!::SymbolInfoInteger(name,SYMBOL_VISIBLE) || this.IsPresentSymbolInControlList(name))
         continue;
      // New In V4 after implemenation CDatabaseService
       if(this.m_SymbolTFManager!=NULL)
          this.m_SymbolTFManager.Update_SymbolTF_Setting(name);
      int index=this.GetIndexObjByName(name);
      if(index==WRONG_VALUE && this.m_list_all_symbols.Add(new CSymbolCommon(name,this.m_list_all_symbols.Total())))
         index=this.m_list_all_symbols.Total()-1;
      if(this.EventAdd((ushort)MARKET_WATCH_EVENT_SYMBOL_ADD,this.TickTime(),index,name))
         ::EventChartCustom(::ChartID(),(ushort)MARKET_WATCH_EVENT_SYMBOL_ADD,this.TickTime(),index,name);
      told=true;
     }
   //--- A symbol was removed: lparam = event time in milliseconds, dparam = -1, sparam = removed symbol name
   int total=this.m_list_names.Total();
   for(int i=0;i<total;i++)
     {
      string name=this.m_list_names.At(i);
      if(name==NULL || this.IsPresentSymbolInMW(name))
         continue;
      if(this.EventAdd((ushort)MARKET_WATCH_EVENT_SYMBOL_DEL,this.TickTime(),WRONG_VALUE,name))
         ::EventChartCustom(::ChartID(),(ushort)MARKET_WATCH_EVENT_SYMBOL_DEL,this.TickTime(),WRONG_VALUE,name);
      told=true;
     }
   //--- The symbols were sorted: lparam = event time in milliseconds, dparam = current symbol index, sparam = current symbol name
   if(!told)
     {
      int index=this.GetIndexObjByName(::Symbol());
      if(this.EventAdd((ushort)MARKET_WATCH_EVENT_SYMBOL_SORT,this.TickTime(),index,::Symbol()))
         ::EventChartCustom(::ChartID(),(ushort)MARKET_WATCH_EVENT_SYMBOL_SORT,this.TickTime(),index,::Symbol());
     }
   this.CopySymbolsNames();
   this.m_total_symbol_prev=this.m_total_symbols;
   this.m_hash_sum_prev=this.m_hash_sum;
  }
 //+------------------------------------------------------------------+
 //| Checks the Market Watch window once a second                     |
 //+------------------------------------------------------------------+
 void CSymbolsCollection::OnTimerEvent(void)
  {
   if(::GetTickCount64()-this.m_check_ms<SYMBOLS_COLLECTION_CHECK_MS)
      return;
   this.m_check_ms=::GetTickCount64();
   this.MarketWatchEventsControl();
  }
#endif // CSYMBOLSCOLLECTION_MQH_IMPLEMENTATION
#endif // __SYMBOLSCOLLECTION_MQH__
