//+------------------------------------------------------------------+
//|                                            HistoryCollection.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/5669                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __HISTORYCOLLECTION_MQH__
#define __HISTORYCOLLECTION_MQH__
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "ListObj.mqh"
#include "..\Entities\Defines\CommonDefines.mqh"
#include "..\Entities\Trading\Orders\HistoryOrder.mqh"
#include "..\Entities\Trading\Orders\HistoryPending.mqh"
#include "..\Entities\Trading\Orders\HistoryDeal.mqh"
#ifdef __MQL4__
#include "..\Objects\Orders\HistoryBalance.mqh"
#endif 
 #ifndef CHISTORYCOLLECTION_MQH_DECLARATION
 #define CHISTORYCOLLECTION_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Collection of historical orders and deals                        |
//+------------------------------------------------------------------+
class CHistoryCollection : public CObject
  {
   private:
    CListObj          m_list_all_orders;      // List of all historical orders and deals
    bool              m_is_trade_event;       // Trading event flag
    int               m_index_order;          // Index of the last order added to the collection from the terminal history list (MQL4, MQL5)
    int               m_index_deal;           // Index of the last deal added to the collection from the terminal history list (MQL5)
    int               m_delta_order;          // Difference in the number of orders compared to the previous check
    int               m_delta_deal;           // Difference in the number of deals compared to the previous check
    int               m_type;                 // Object type
    //--- Return the flag of the order object by its type and ticket in the list of historical orders and deals
     bool              IsPresentOrderInList(const ulong order_ticket,const ENUM_ORDER_TYPE type);
    //--- Return the "lost" order type and ticket
     ulong             OrderSearch(const int start,ENUM_ORDER_TYPE &order_type);
    //--- Create the order object and place it to the list
     bool              CreateNewOrder(const ulong order_ticket,const ENUM_ORDER_TYPE order_type);
   public:
    //--- Return itself
     CHistoryCollection *GetObject(void)                                                                   { return &this;   }
    //--- Return the full collection list 'as is'
     CArrayObj        *GetList(void)                                                                       { return &this.m_list_all_orders;                                       }
    //--- Return the number of (1) new orders, (2) new deals, (3) occurred trading event flag and (4) the object type
     int               NewOrders(void)                                                               const { return this.m_delta_order;     }
     int               NewDeals(void)                                                                const { return this.m_delta_deal;      }
     bool              IsTradeEvent(void)                                                            const { return this.m_is_trade_event;  }
     virtual int       Type(void)                                                                    const { return this.m_type;            }
    //--- Constructor
                     CHistoryCollection();
   //--- Update the list of orders, fill in data on the number of new ones and set the trading event flag
   void              Refresh(void);
  };
 #endif // CHISTORYCOLLECTION_MQH_DECLARATION
 #ifndef CHISTORYCOLLECTION_MQH_IMPLEMENTATION
 #define CHISTORYCOLLECTION_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CHistoryCollection::CHistoryCollection(void) : m_index_deal(0),m_delta_deal(0),m_index_order(0),m_delta_order(0),m_is_trade_event(false)
  {
   this.m_type=COLLECTION_HISTORY_ID;
   this.m_list_all_orders.Sort(#ifdef __MQL5__ SORT_BY_ORDER_TIME_OPEN #else SORT_BY_ORDER_TIME_CLOSE #endif );
   this.m_list_all_orders.Clear();
   this.m_list_all_orders.Type(COLLECTION_HISTORY_ID);
  }
//+------------------------------------------------------------------+
//| Update the list of orders and deals                              |
//+------------------------------------------------------------------+
void CHistoryCollection::Refresh(void)
  {
   #ifdef __MQL4__
     int total=::OrdersHistoryTotal(),i=m_index_order;
     for(; i<total; i++)
      {
         if(!::OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
         ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)::OrderType();
         //--- Closed positions
         if(order_type<ORDER_TYPE_BUY_LIMIT)
         {
            CHistoryOrder *order=new CHistoryOrder(::OrderTicket());
            if(order==NULL) continue;
            if(!this.m_list_all_orders.InsertSort(order))
            {
               CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ADD_ORDER_TO_LIST);
               delete order;               
            }
         }
         //--- Balance/credit operations
         else if(order_type>ORDER_TYPE_SELL_STOP)
         {
            CHistoryBalance *order=new CHistoryBalance(::OrderTicket());
            if(order==NULL) continue;
            if(!this.m_list_all_orders.InsertSort(order))
            {
               CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ADD_ORDER_TO_LIST);
               delete order;
            }
         }
         else
         {
            //--- Removed pending orders
            CHistoryPending *order=new CHistoryPending(::OrderTicket());
            if(order==NULL) continue;
            if(!this.m_list_all_orders.InsertSort(order))
            {
               CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ADD_ORDER_TO_LIST);
               delete order;
            }
         }
      }
    //---
      int delta_order=i-this.m_index_order;
      this.m_index_order=i;
      this.m_delta_order=delta_order;
      this.m_is_trade_event=(this.m_delta_order!=0 ? true : false);
    //--- __MQL5__
   #else 
      if(!::HistorySelect(0,END_TIME)) return;
    //--- Orders
     int total_orders=::HistoryOrdersTotal(),i=this.m_index_order;
     for(; i<total_orders; i++)
      {
         ulong order_ticket=::HistoryOrderGetTicket(i);
         if(order_ticket==0) continue;
         ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::HistoryOrderGetInteger(order_ticket,ORDER_TYPE);
         if(type==ORDER_TYPE_BUY || type==ORDER_TYPE_SELL || type==ORDER_TYPE_CLOSE_BY)
         {
            //--- If there is no order of this type and with this ticket in the list, create an order object and add it to the list
            if(!this.IsPresentOrderInList(order_ticket,type))
            {
               if(!this.CreateNewOrder(order_ticket,type))
                  CMessage::ToLog(DFUN_ERR_LINE,MSG_LIB_SYS_FAILED_ADD_ORDER_TO_LIST);
            }
            //--- Such an order is already present in the list, which means the necessary order is not the last one in the history list. Let's find it
            else
            {
               ENUM_ORDER_TYPE type_lost=WRONG_VALUE;
               ulong ticket_lost=this.OrderSearch(i,type_lost);
               if(ticket_lost>0 && !this.CreateNewOrder(ticket_lost,type_lost))
                  CMessage::ToLog(DFUN_ERR_LINE,MSG_LIB_SYS_FAILED_ADD_ORDER_TO_LIST);
            }
         }
         else
         {
            //--- If there is no pending order of this type and with this ticket in the list, create an order object and add it to the list
            if(!this.IsPresentOrderInList(order_ticket,type))
            {
               if(!this.CreateNewOrder(order_ticket,type))
                  CMessage::ToLog(DFUN_ERR_LINE,MSG_LIB_SYS_FAILED_ADD_ORDER_TO_LIST);
            }
            //--- Such an order is already present in the list, which means the necessary order is not the last one in the history list. Let's find it
            else
            {
               ENUM_ORDER_TYPE type_lost=WRONG_VALUE;
               ulong ticket_lost=this.OrderSearch(i,type_lost);
               if(ticket_lost>0 && !this.CreateNewOrder(ticket_lost,type_lost))
                  CMessage::ToLog(DFUN_ERR_LINE,MSG_LIB_SYS_FAILED_ADD_ORDER_TO_LIST);
            }
         }
      }
    //--- save the index of the last added order and the difference with the last check
      int delta_order=i-this.m_index_order;
      this.m_index_order=i;
      this.m_delta_order=delta_order;

    //--- Deals
     int total_deals=::HistoryDealsTotal(),j=m_index_deal;
     for(; j<total_deals; j++)
      {
         ulong deal_ticket=::HistoryDealGetTicket(j);
         if(deal_ticket==0) continue;
         CHistoryDeal *deal=new CHistoryDeal(deal_ticket);
         if(deal==NULL) continue;
         if(!this.m_list_all_orders.InsertSort(deal))
         {
            CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ADD_DEAL_TO_LIST);
            delete deal;
         }
      }
    //--- save the index of the last added deal and the difference with the last check
      int delta_deal=j-this.m_index_deal;
      this.m_index_deal=j;
      this.m_delta_deal=delta_deal;
    //--- Set the new event flag in history
      this.m_is_trade_event=(this.m_delta_order+this.m_delta_deal);
   #endif 
  }
//+-----------------------------------------------------------------------------+
//| Return the flag of the order object presence in the list by type and ticket |
//+-----------------------------------------------------------------------------+
bool CHistoryCollection::IsPresentOrderInList(const ulong order_ticket,const ENUM_ORDER_TYPE type)
  {
   for(int i=0;i<this.m_list_all_orders.Total();i++)
     {
      COrder *order=this.m_list_all_orders.At(i);
      if(order!=NULL && order.TypeOrder()==type && order.Ticket()==order_ticket) return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Return the "lost" order type and ticket                          |
//+------------------------------------------------------------------+
ulong CHistoryCollection::OrderSearch(const int start,ENUM_ORDER_TYPE &order_type)
  {
   ulong order_ticket=0;
   #ifdef __MQL5__
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
   #else 
      for(int i=start-1;i>=0;i--)
      {
         if(!::OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
            continue;
         ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::OrderType();
         ulong ticket=::OrderTicket();
         if(ticket==0 || type<ORDER_TYPE_BUY_LIMIT || type>ORDER_TYPE_SELL_STOP)
            continue;
         if(this.IsPresentOrderInList(ticket,type))
            continue;
         order_ticket=ticket;
         order_type=type;
      }
   #endif    
   return order_ticket;
  }
//+------------------------------------------------------------------+
//| Create the order object and place it to the list                 |
//+------------------------------------------------------------------+
bool CHistoryCollection::CreateNewOrder(const ulong order_ticket,const ENUM_ORDER_TYPE order_type)
  {
   COrder* order=NULL;
   if(order_type==ORDER_TYPE_BUY)
     {
      order=new CHistoryOrder(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_BUY_LIMIT)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_BUY_STOP)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_SELL)
     {
      order=new CHistoryOrder(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_SELL_LIMIT)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_SELL_STOP)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   #ifdef __MQL5__
      else if(order_type==ORDER_TYPE_BUY_STOP_LIMIT)
      {
         order=new CHistoryPending(order_ticket);
         if(order==NULL)
            return false;
      }
      else if(order_type==ORDER_TYPE_SELL_STOP_LIMIT)
      {
         order=new CHistoryPending(order_ticket);
         if(order==NULL)
            return false;
      }
      else if(order_type==ORDER_TYPE_CLOSE_BY)
      {
         order=new CHistoryOrder(order_ticket);
         if(order==NULL)
            return false;
      }
   #endif 
      if(this.m_list_all_orders.InsertSort(order))
         return true;
      else
      {
         delete order;
         return false;
      }
      return false;
  }
//+------------------------------------------------------------------+

 #endif // CHISTORYCOLLECTION_MQH_IMPLEMENTATION
#endif // __HISTORYCOLLECTION_MQH__