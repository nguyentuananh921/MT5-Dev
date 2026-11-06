//+------------------------------------------------------------------+
//|                                            HistoryCollection.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/5669                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
//--- The history of the account (V3 m_list_all_orders): the orders and deals of the terminal live in RAM (the terminal keeps them, they are made again at each
//--- start); the table Orders of the file of the account is this class's (as CBarTimeSeriesCollection owns its tables) and keeps only what the terminal has not or
//--- what must not be done again (Readme "Live on RAM, Save on DB for no more calculation"): the line of each history order and deal, the Bid / Ask of a deal.
//--- Change from DoEasy / V3: base CObject -> CBaseObjExt (Event Rule), Refresh -> RefreshHistory (as RefreshSeries, RefreshAccount), ReadDataFromDB / UpdateDataToDB
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
    CSymbolsCollection *m_SymbolsCollection;  // The EA holds it: the id of OUR symbol of an order (symbols)
    CSymbolTFManager   *m_SymbolTFManager;    // The EA holds it: the id of OUR symbol of an order (symbols)
    CListObj          m_list_all_orders;      // List of all historical orders and deals (V3), owned
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
   public:
    //--- Return the full collection list 'as is'
     CArrayObj        *GetList(void)                                                                       { return &this.m_list_all_orders;      }
    //--- The collection and the manager the EA gives it: the id of a symbol of the account, the marks of Setting_Sync
     void              SetSymbolsCollection(CSymbolsCollection *collection)                                { this.m_SymbolsCollection=collection;  }
     void              SetSymbolTFManager(CSymbolTFManager *manager)                                       { this.m_SymbolTFManager=manager;       }
    //--- Return the number of (1) new orders, (2) new deals, (3) occurred trading event flag
     int               NewOrders(void)                                                               const { return this.m_delta_order;     }
     int               NewDeals(void)                                                                const { return this.m_delta_deal;      }
    //--- Lifecycle: opens the file of the account, makes the table Orders (the lines of what is on the account now, of an older table, go), reads its lines
     bool              OnInitEvent(void);
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
CHistoryCollection::CHistoryCollection(void) : m_SymbolsCollection(NULL),m_SymbolTFManager(NULL),m_index_deal(0),m_delta_deal(0),m_index_order(0),
                                               m_delta_order(0)
  {
   this.m_object_type=COLLECTION_HISTORY_ID;
   this.m_list_all_orders.Sort(SORT_BY_ORDER_TIME_OPEN);
   this.m_list_all_orders.Clear();
   this.m_list_all_orders.Type(COLLECTION_HISTORY_ID);
  }
CHistoryCollection::~CHistoryCollection(void)
  {
  }
bool CHistoryCollection::OnInitEvent(void)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Update the list of orders and deals                              |
//+------------------------------------------------------------------+
//--- Change from V3: Refresh -> RefreshHistory; what has no line is written (the first call is the past: no flag)
void CHistoryCollection::RefreshHistory(void)
  {
   this.m_is_event=false;
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
    if(this.m_first_start)
     {
      this.m_first_start=false;
      return;
     }
   //--- Set the new event flag in history
    this.m_is_event=(this.m_delta_order+this.m_delta_deal>0);
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
   if(deal && !this.m_first_start)
      order.BidAskFromTicks();   // a deal that just happened: the tick of its time (the past is left to Python, the ticks of years are too many for a beat)
   if(!this.m_list_all_orders.InsertSort(order))
     {
      ::Print(DFUN,CMessage::Text(deal ? MSG_LIB_SYS_FAILED_ADD_DEAL_TO_LIST : MSG_LIB_SYS_FAILED_ADD_ORDER_TO_LIST));
      delete order;
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
 #endif // CHISTORYCOLLECTION_MQH_IMPLEMENTATION
#endif // __HISTORYCOLLECTION_MQH__
