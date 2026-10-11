//+------------------------------------------------------------------+
//|                                        TradeEventsCollection.mqh |
//|                            Modify name from EventsCollection.mqh |
//|Link https://www.mql5.com/en/articles/7326                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef CTRADEEVENTSCOLLECTION_MQH
#define CTRADEEVENTSCOLLECTION_MQH
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "ListObj.mqh"
 #include "..\Entities\Trading\Order.mqh"
 #include "..\Entities\Trading\OrderControl.mqh"
 #include "..\Entities\Trading\TradeEvent\TradeEventBalanceOperation.mqh"
 #include "..\Entities\Trading\TradeEvent\TradeEventOrderPlaced.mqh"
 #include "..\Entities\Trading\TradeEvent\TradeEventOrderRemoved.mqh"
 #include "..\Entities\Trading\TradeEvent\TradeEventPositionOpen.mqh"
 #include "..\Entities\Trading\TradeEvent\TradeEventPositionClose.mqh"
 #include "..\Entities\Trading\TradeEvent\TradeEventModify.mqh"

 #ifndef CTRADEEVENTSCOLLECTION_MQH_DECLARATION
 #define CTRADEEVENTSCOLLECTION_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Collection of account trading events                             |
  //+------------------------------------------------------------------+
  class CTradeEventsCollection : public CBaseObjExt
   {
     private:
      CListObj          m_list_trade_events;             // List of events
      bool              m_is_hedge;                      // Hedge account flag
      int               m_trade_event_code;              // Trading event code
      ENUM_TRADE_EVENT  m_trade_event;                   // Account trading event
      ulong             m_position_id;                   // Position ID (MQL4)
      ENUM_ORDER_TYPE   m_type_first;                    // Opening order type (MQL4)

      //--- Create a trading event depending on the (1) order status and (2) change type
       void              CreateNewEvent(COrder* order,CArrayObj* list_history,CArrayObj* list_market,CArrayObj* list_control);
       void              CreateNewEvent(COrderControl* order);
      //--- Create an event for a (1) hedging account, (2) netting account
       void              NewDealEventHedge(COrder* deal,CArrayObj* list_history,CArrayObj* list_market);
       void              NewDealEventNetto(COrder* deal,CArrayObj* list_history,CArrayObj* list_market);
      //--- Fill the caller's list (elements stay owned by the collections) with the (1) market pending orders, (2) removed pending orders, (3) deals
       bool              GetListMarketPendings(CArrayObj* list,CArrayObj &list_out);
       bool              GetListHistoryPendings(CArrayObj* list,CArrayObj &list_out);
       bool              GetListDeals(CArrayObj* list,CArrayObj &list_out);
      //--- Fill the caller's list with (1) all deals, (2) all position reversal deals (IN_OUT) by position ID
       bool              GetListAllDealsByPosID(CArrayObj* list,const ulong position_id,CArrayObj &list_out);
       bool              GetListAllDealsInOutByPosID(CArrayObj* list,const ulong position_id,CArrayObj &list_out);
      //--- Return the total volume of all deals (1) IN, (2) OUT of the position by its ID
       double            SummaryVolumeDealsInByPosID(CArrayObj* list,const ulong position_id);
       double            SummaryVolumeDealsOutByPosID(CArrayObj* list,const ulong position_id);
      //--- Return the (1) first, (2) last and (3) closing order from the list of all position orders,
      //--- (4) an order by ticket, (5) market position by ID,
      //--- (6) the last and (7) penultimate InOut deal by position ID
       COrder*           GetFirstOrderFromList(CArrayObj* list,const ulong position_id);
       COrder*           GetLastOrderFromList(CArrayObj* list,const ulong position_id);
       COrder*           GetCloseByOrderFromList(CArrayObj* list,const ulong position_id);
       COrder*           GetHistoryOrderByTicket(CArrayObj* list,const ulong order_ticket);
       COrder*           GetPositionByID(CArrayObj* list,const ulong position_id);
      //--- Return (1) the control order by a ticket, (2) the type of the opening order by the position ticket (MQL4)
       COrderControl*    GetOrderControlByTicket(CArrayObj* list,const ulong ticket);
       ENUM_ORDER_TYPE   GetTypeFirst(CArrayObj* list,const ulong ticket);
      //--- Return the flag of the event object presence in the event list
       bool              IsPresentEventInList(CTradeEvent* compared_event);
      //--- The handler of an existing order/position change event
       void              OnChangeEvent(CArrayObj* list_changes,const int index);

     public:
      //--- Return itself
       CTradeEventsCollection*GetObject(void)                                                                     { return &this;                                                         }
      //--- Return the full event collection list "as is"
       CArrayObj        *GetList(void)                                                                       { return &this.m_list_trade_events;                                     }
      //--- Update the list of events
       void              Refresh(CArrayObj* list_history,
                             CArrayObj* list_market,
                             CArrayObj* list_changes,
                             CArrayObj* list_control,
                             const bool is_history_event,
                             const bool is_market_event,
                             const int  new_history_orders,
                             const int  new_market_pendings,
                             const int  new_market_positions,
                             const int  new_deals,
                             const double changed_volume);
      //--- Return (1) the last trading event on an account, (2) base event object by index and (3) number of new events
       ENUM_TRADE_EVENT  GetLastTradeEvent(void)                const { return this.m_trade_event;                 }
       CEventBaseObj    *GetTradeEventByIndex(const int index)        { return this.GetEvent(index,false);         }
       int               GetTradeEventsTotal(void)              const { return this.m_list_events.Total();         }
      //--- Reset the last trading event
       void              ResetLastTradeEvent(void)                    { this.m_trade_event=TRADE_EVENT_NO_EVENT;   }
      //--- Constructor
                     CTradeEventsCollection(void);
   };
 #endif // CTRADEEVENTSCOLLECTION_MQH_DECLARATION
 #ifndef CTRADEEVENTSCOLLECTION_MQH_IMPLEMENTATION
 #define CTRADEEVENTSCOLLECTION_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CTradeEventsCollection::CTradeEventsCollection(void) : m_trade_event(TRADE_EVENT_NO_EVENT),m_trade_event_code(TRADE_EVENT_FLAG_NO_EVENT)
   {
     this.m_type=COLLECTION_TRADE_EVENTS_ID;
     this.m_list_trade_events.Clear();
     this.m_list_trade_events.Sort(SORT_BY_EVENT_TIME_EVENT);
     //https://www.mql5.com/en/articles/6211
     //--- Collection list IDs COLLECTION_TRADE_EVENTS_ID in CommonDefines.mqh
      this.m_list_trade_events.Type(COLLECTION_TRADE_EVENTS_ID);
     this.m_is_hedge=#ifdef __MQL4__ true #else bool(::AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) #endif;
     this.m_is_event=false;
     ::ZeroMemory(this.m_tick);
   }
  //+------------------------------------------------------------------+
  //| Update the event list                                            |
  //+------------------------------------------------------------------+
  void CTradeEventsCollection::Refresh(CArrayObj* list_history,
                                CArrayObj* list_market,
                                CArrayObj* list_changes,
                                CArrayObj* list_control,
                                const bool is_history_event,
                                const bool is_market_event,
                                const int  new_history_orders,
                                const int  new_market_pendings,
                                const int  new_market_positions,
                                const int  new_deals,
                                const double changed_volume)
   {
    //--- Exit if the lists are empty
     if(list_history==NULL || list_market==NULL)
      return;
    //---
     this.m_is_event=false;
     this.m_list_events.Clear();
     this.m_list_events.Sort();
    //--- If the event is in the market environment
     if(is_market_event)
      {
       //--- if there was a change in the order properties
        int total_changes=list_changes.Total();
        if(total_changes>0)
         {
          for(int i=total_changes-1;i>WRONG_VALUE;i--)
           {
            this.OnChangeEvent(list_changes,i);
           }
         }
       //--- if the number of placed pending orders increased (MQL5, MQL4)
        if(new_market_pendings>0)
         {
          //--- Receive the list of the newly placed pending orders
          CArrayObj list;
          if(this.GetListMarketPendings(list_market,list))
           {
            //--- Sort the new list by order placement time
             list.Sort(SORT_BY_ORDER_TIME_OPEN);
            //--- Take the number of orders equal to the number of newly placed ones from the end of the list in a loop (the last N events)
             int total=list.Total(), n=new_market_pendings;
             for(int i=total-1; i>WRONG_VALUE && n>0; i--,n--)
              {
               //--- Receive an order from the list, if this is a pending order, set a trading event
               COrder* order=list.At(i);
               if(order!=NULL && order.Status()==ORDER_STATUS_MARKET_PENDING)
                  this.CreateNewEvent(order,list_history,list_market,list_control);
              }
           }
         }
       #ifdef __MQL4__
         //--- If the number of positions increased (MQL4)
         if(new_market_positions>0)
           {
            //--- Get the list of open positions
            CArrayObj* list=this.GetListPositions(list_market);
            if(list!=NULL)
              {
               //--- Sort the new list by a position open time
               list.Sort(SORT_BY_ORDER_TIME_OPEN);
               //--- Take the number of positions equal to the number of newly placed open positions from the end of the list in a loop (the last N events)
               int total=list.Total(), n=new_market_positions;
               for(int i=total-1; i>WRONG_VALUE && n>0; i--,n--)
                 {
                  //--- Receive a position from the list. If this is a position, search for opening order data and set a trading event
                  COrder* position=list.At(i);
                  if(position!=NULL && position.Status()==ORDER_STATUS_MARKET_POSITION)
                    {
                     //--- Find an order and set (1) a type of an order that led to opening a position and a (2) position ID
                     this.m_type_first=this.GetTypeFirst(list_control,position.Ticket());
                     this.m_position_id=position.Ticket();
                     this.CreateNewEvent(position,list_history,list_market,list_control);
                    }
                 }
              }
           }
         //--- If the number of positions decreased or a position is closed partially (MQL4)
         else if(new_market_positions<0 || (new_market_positions==0 && changed_volume<0 && new_history_orders>0 && new_market_pendings>WRONG_VALUE))
           {
            //--- Get the list of closed positions
            CArrayObj* list=this.GetListHistoryPositions(list_history);
            if(list!=NULL)
              {
               //--- Sort the new list by a position close time
               list.Sort(SORT_BY_ORDER_TIME_CLOSE);
               //--- Take the number of positions equal to the number of newly closed positions from the end of the list in a loop (the last N events)
               int total=list.Total(), n=new_history_orders;
               for(int i=total-1; i>WRONG_VALUE && n>0; i--,n--)
                 {
                  //--- Receive a position from the list. If this is a position, search for opening order data and set a trading event
                  COrder* position=list.At(i);
                  if(position!=NULL && position.Status()==ORDER_STATUS_HISTORY_ORDER)
                    {
                     //--- If there is a control order of a closed position
                     COrderControl* ctrl=this.GetOrderControlByTicket(list_control,position.Ticket());
                     if(ctrl!=NULL)
                       {
                        //--- Set (1) a type of an order that led to opening a position and a (2) position ID, and create a position closure event
                        this.m_type_first=(ENUM_ORDER_TYPE)ctrl.TypeOrder();
                        this.m_position_id=position.Ticket();
                        this.CreateNewEvent(position,list_history,list_market,list_control);
                       }
                    }
                 }
              }
           }
        #endif
     }
    //--- If the event is in the account history
     if(is_history_event)
      {
       //--- If the number of historical orders increased (MQL5, MQL4)
       if(new_history_orders>0 && new_market_pendings<0)
        {
         //--- Receive the list of removed pending orders only
         CArrayObj list;
         if(this.GetListHistoryPendings(list_history,list))
           {
            //--- Sort the new list by order removal time
            list.Sort(SORT_BY_ORDER_TIME_CLOSE);
            //--- Take the number of orders equal to the number of newly removed ones from the end of the list in a loop (the last N events)
            int total=list.Total(), n=new_history_orders;
            for(int i=total-1; i>WRONG_VALUE && n>0; i--,n--)
              {
               //--- Receive an order from the list. If this is a removed pending order without a position ID,
               //--- this is an order removal - set a trading event
               COrder* order=list.At(i);
               if(order!=NULL && order.Status()==ORDER_STATUS_HISTORY_PENDING && order.PositionID()==0)
                  this.CreateNewEvent(order,list_history,list_market,list_control);
              }
           }
        }
       //--- If the number of deals increased (MQL5)
       #ifdef __MQL5__
         if(new_deals>0)
           {
            //--- Receive the list of deals only
            CArrayObj list;
            if(this.GetListDeals(list_history,list))
              {
               //--- Sort the new list by deal time
               list.Sort(SORT_BY_ORDER_TIME_OPEN);
               //--- Take the number of deals equal to the number of new ones from the end of the list in a loop (the last N events)
               int total=list.Total(), n=new_deals;
               for(int i=total-1; i>WRONG_VALUE && n>0; i--,n--)
                 {
                  //--- Receive a deal from the list and set a trading event
                  COrder* order=list.At(i);
                  if(order!=NULL)
                     this.CreateNewEvent(order,list_history,list_market,list_control);
                 }
              }
           }
       #endif
      }
   }
  //+------------------------------------------------------------------+
  //| The handler of an existing order/position change event           |
  //+------------------------------------------------------------------+
  void CTradeEventsCollection::OnChangeEvent(CArrayObj* list_changes,const int index)
    {
     COrderControl* order_changed=list_changes.Detach(index);
     if(order_changed!=NULL)
       {
        this.CreateNewEvent(order_changed);
        delete order_changed;
       }
    }
  //+------------------------------------------------------------------+
  //| Create a trading event depending on the order change type        |
  //+------------------------------------------------------------------+
  void CTradeEventsCollection::CreateNewEvent(COrderControl* order)
   {
     ENUM_EVENT_REASON reason=WRONG_VALUE;
     if(!::SymbolInfoTick(order.Symbol(),this.m_tick))
      {
        ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_NOT_GET_CURR_PRICES),order.Symbol());
        return;
      }
     CTradeEvent* event=NULL;
    //--- Pending StopLimit order is activated
     if(order.GetChangeType()==CHANGE_TYPE_ORDER_TYPE)
      {
       reason=EVENT_REASON_STOPLIMIT_TRIGGERED;
       this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_PLASED;
       event=new CTradeEventOrderPlaced(this.m_trade_event_code,order.Ticket());
      }
    //--- Modification
     else
      {
       //--- Pending order price is modified
        if(order.GetChangeType()==CHANGE_TYPE_ORDER_PRICE)
          this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_PRICE;
       //--- Pending order price and StopLoss are modified
        else if(order.GetChangeType()==CHANGE_TYPE_ORDER_PRICE_STOP_LOSS)
         this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_PRICE+TRADE_EVENT_FLAG_SL;
       //--- Pending order price and TakeProfit are modified
        else if(order.GetChangeType()==CHANGE_TYPE_ORDER_PRICE_TAKE_PROFIT)
         this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_PRICE+TRADE_EVENT_FLAG_TP;
       //--- Pending order price, as well as its StopLoss and TakeProfit are modified
        else if(order.GetChangeType()==CHANGE_TYPE_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT)
         this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_PRICE+TRADE_EVENT_FLAG_SL+TRADE_EVENT_FLAG_TP;
       //--- Pending order StopLoss is modified
        else if(order.GetChangeType()==CHANGE_TYPE_ORDER_STOP_LOSS)
          this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_SL;
       //--- Pending order TakeProfit is modified
        else if(order.GetChangeType()==CHANGE_TYPE_ORDER_TAKE_PROFIT)
          this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_TP;
       //--- Pending order StopLoss and TakeProfit are modified
        else if(order.GetChangeType()==CHANGE_TYPE_ORDER_STOP_LOSS_TAKE_PROFIT)
          this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_SL+TRADE_EVENT_FLAG_TP;

       //--- Position StopLoss is modified
        else if(order.GetChangeType()==CHANGE_TYPE_POSITION_STOP_LOSS)
          this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_MODIFY+TRADE_EVENT_FLAG_SL;
       //--- Position TakeProfit is modified
        else if(order.GetChangeType()==CHANGE_TYPE_POSITION_TAKE_PROFIT)
          this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_MODIFY+TRADE_EVENT_FLAG_TP;
       //--- Position StopLoss and TakeProfit are modified
        else if(order.GetChangeType()==CHANGE_TYPE_POSITION_STOP_LOSS_TAKE_PROFIT)
          this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_MODIFY+TRADE_EVENT_FLAG_SL+TRADE_EVENT_FLAG_TP;

       //--- Create a modification event
       reason=EVENT_REASON_MODIFY;
       event=new CTradeEventModify(this.m_trade_event_code,order.Ticket());
     }
    //--- Create an event
     if(event!=NULL)
      {
        event.SetProperty(EVENT_PROP_TIME_EVENT,order.Time());                        // Event time
        event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                            // Event reason (from the ENUM_EVENT_REASON enumeration)
        event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,PositionTypeByOrderType((ENUM_ORDER_TYPE)order.TypeOrderPrev())); // Type of the order that triggered an event
        event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());               // Ticket of the order that triggered an event
        event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());             // Event order type
        event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());              // Event order ticket
        event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());          // Position first order type
        event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());           // Position first order ticket
        event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                 // Position ID
        event.SetProperty(EVENT_PROP_POSITION_BY_ID,0);                               // Opposite position ID
        event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                  // Opposite position magic number

        event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrderPrev());      // Position order type before changing direction
        event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());           // Position order ticket before changing direction
        event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());         // Current position order type
        event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());          // Current position order ticket

        event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order.PricePrev());            // Order price before modification
        event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order.StopLossPrev());           // StopLoss price before modification
        event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order.TakeProfitPrev());         // TakeProfit price before modification
        event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,this.m_tick.ask);                // Ask price during an event
        event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,this.m_tick.bid);                // Bid price during an event

        event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                      // Order magic number
        event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimePrev());           // Position first order time
        event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PricePrev());                  // Event price
        event.SetProperty(EVENT_PROP_PRICE_OPEN,order.Price());                       // Order placement price
        event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.Price());                      // Order closure price
        event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                      // StopLoss order price
        event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                    // TakeProfit order price
        event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());            // Requested order volume
        event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,0);                        // Executed order volume
        event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.Volume());            // Remaining (unexecuted) order volume
        event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,0);                     // Executed position volume
        event.SetProperty(EVENT_PROP_PROFIT,0);                                       // Profit
        event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                          // Order symbol
        event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                    // Opposite position symbol
       //--- Decode the event code and set the event type
        event.SetTypeEvent();
       //--- Add the event object if it is not in the list
        if(!this.IsPresentEventInList(event))
         {
           this.m_list_trade_events.InsertSort(event);
           //--- Send a message about the event and set the value of the last trading event
            this.m_trade_event=event.TradeEvent();
            this.m_is_event=true;
            event.SendEvent();
            CBaseObjExt::EventAdd(this.m_trade_event,order.Ticket(),order.Price(),order.Symbol());
         }
       //--- If the event is already present in the list, remove a new event object and display a debugging message
       else
        {
         ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
         delete event;
        }
      }
   }
  //+------------------------------------------------------------------+
  //| Create a trading event depending on the order status             |
  //+------------------------------------------------------------------+
  void CTradeEventsCollection::CreateNewEvent(COrder* order,CArrayObj* list_history,CArrayObj* list_market,CArrayObj* list_control)
   {
     if(!::SymbolInfoTick(order.Symbol(),this.m_tick))
      {
       ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_NOT_GET_CURR_PRICES),order.Symbol());
       return;
      }
     this.m_trade_event_code=TRADE_EVENT_FLAG_NO_EVENT;
     ENUM_ORDER_STATUS status=order.Status();
     //--- Pending order placed
      if(status==ORDER_STATUS_MARKET_PENDING)
       {
        this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_PLASED;
        CTradeEvent* event=new CTradeEventOrderPlaced(this.m_trade_event_code,order.Ticket());
        if(event!=NULL)
         {
           event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeOpen());                                // Event time
           event.SetProperty(EVENT_PROP_REASON_EVENT,EVENT_REASON_DONE);                             // Event reason (from the ENUM_EVENT_REASON enumeration)
           event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeByDirection());                    // Event deal type
           event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());                           // Event order ticket
           event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());                         // Event order type
           event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());                      // Event order type
           event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());                          // Event order ticket
           event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());                       // Order ticket
           event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                             // Position ID
           event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());                        // Opposite position ID
           event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                              // Opposite position magic number

           event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());                      // Position order type before changing direction
           event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());                       // Position order ticket before changing direction
           event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());                     // Current position order type
           event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());                      // Current position order ticket
           event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order.PriceOpen());                        // Order price before modification
           event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order.StopLoss());                           // StopLoss price before modification
           event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order.TakeProfit());                         // TakeProfit price before modification
           event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,this.m_tick.ask);                            // Ask price during an event
           event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,this.m_tick.bid);                            // Bid price during an event

           event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                                  // Order magic number
           event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpen());                       // Order time
           event.SetProperty(EVENT_PROP_PRICE_EVENT,this.m_tick.bid);                                // Bid price an event occurred on
           event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                               // Order placement price
           event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceClose());                             // Order closure price
           event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                                  // StopLoss order price
           event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                                // TakeProfit order price
           event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());                        // Requested order volume
           event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume()-order.VolumeCurrent()); // Executed order volume
           event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.VolumeCurrent());                 // Remaining (unexecuted) order volume
           event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,0);                                 // Executed position volume
           event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                                      // Profit
           event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                                      // Order symbol
           event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                                // Opposite position symbol
          //--- Decode the event code and set the event type
           event.SetTypeEvent();
          //--- Add the event object if it is not in the list
           if(!this.IsPresentEventInList(event))
            {
             this.m_list_trade_events.InsertSort(event);
             //--- Send a message about the event and set the value of the last trading event
              this.m_trade_event=event.TradeEvent();
              this.m_is_event=true;
              event.SendEvent();
              CBaseObjExt::EventAdd(this.m_trade_event,order.Ticket(),order.PriceOpen(),order.Symbol());
            }
          //--- If the event is already present in the list, remove a new event object and display a debugging message
          else
            {
              ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
              delete event;
            }
         }
       }
     //--- Pending order removed
      if(status==ORDER_STATUS_HISTORY_PENDING)
       {
        this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_REMOVED;
         CTradeEvent* event=new CTradeEventOrderRemoved(this.m_trade_event_code,order.Ticket());
         if(event!=NULL)
          {
           ENUM_EVENT_REASON reason=
             (
              order.State()==ORDER_STATE_CANCELED ? EVENT_REASON_CANCEL :
              order.State()==ORDER_STATE_EXPIRED  ? EVENT_REASON_EXPIRED : EVENT_REASON_DONE
             );
           event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeClose());                               // Event time
           event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                        // Event reason (from the ENUM_EVENT_REASON enumeration)
           event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeByDirection());                    // Event order type
           event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());                           // Event order ticket
           event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());                         // Type of the order that triggered an event deal (the last position order)
           event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());                      // Type of the order that triggered a position deal (the first position order)
           event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());                          // Ticket of the order, based on which an event deal is opened (the last position order)
           event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());                       // Ticket of the order, based on which a position deal is opened (the first position order)
           event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                             // Position ID
           event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());                        // Opposite position ID
           event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                              // Opposite position magic number

           event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());                      // Position order type before changing direction
           event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());                       // Position order ticket before changing direction
           event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());                     // Current position order type
           event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());                      // Current position order ticket

           event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order.PriceOpen());                        // Order price before modification
           event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order.StopLoss());                           // StopLoss price before modification
           event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order.TakeProfit());                         // TakeProfit price before modification
           event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,this.m_tick.ask);                            // Ask price during an event
           event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,this.m_tick.bid);                            // Bid price during an event

           event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                                  // Order magic number
           event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpen());                       // Time of an order, based on which a position deal is opened (the first position order)
           event.SetProperty(EVENT_PROP_PRICE_EVENT,this.m_tick.bid);                                // Bid price an event occurred on
           event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                               // Order placement price
           event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceClose());                             // Order closure price
           event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                                  // StopLoss order price
           event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                                // TakeProfit order price
           event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());                        // Requested order volume
           event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume()-order.VolumeCurrent()); // Executed order volume
           event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.VolumeCurrent());                 // Remaining (unexecuted) order volume
           event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,0);                                 // Executed position volume
           event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                                      // Profit
           event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                                      // Order symbol
           event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                                // Opposite position symbol
          //--- Decode the event code and set the event type
           event.SetTypeEvent();
          //--- Add the event object if it is not in the list
           if(!this.IsPresentEventInList(event))
            {
             this.m_list_trade_events.InsertSort(event);
             //--- Send a message about the event and set the value of the last trading event
              this.m_trade_event=event.TradeEvent();
              this.m_is_event=true;
              event.SendEvent();
              CBaseObjExt::EventAdd(this.m_trade_event,order.Ticket(),order.PriceOpen(),order.Symbol());
             }
          //--- If the event is already present in the list, remove a new event object and display a debugging message
           else
           {
            ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
            delete event;
           }
         }
       }
    //--- Position opened (__MQL4__)
    #ifdef __MQL4__
      if(status==ORDER_STATUS_MARKET_POSITION)
        {
          //--- Set the "position opened" trading event code
          this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED;
          //--- Set the "request executed partially" reason
          ENUM_EVENT_REASON reason=EVENT_REASON_DONE;
          //--- If an opening order is a pending one
          if(this.m_type_first>ORDER_TYPE_SELL && this.m_type_first<ORDER_TYPE_BALANCE)
            {
            //--- set the "pending order activated" reason
            reason=EVENT_REASON_ACTIVATED_PENDING;
            //--- add a pending order activation flag to the event code
            this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_ACTIVATED;
            }
          CEvent* event=new CEventPositionOpen(this.m_trade_event_code,order.Ticket());
          if(event!=NULL)
            {
            event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeOpen());                                // Event time
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                        // Event reason (from the ENUM_EVENT_REASON enumeration)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,this.m_type_first);                          // Event deal type
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());                           // Event deal ticket
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,this.m_type_first);                         // Type of the order that triggered an event deal (the last position order)
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,this.m_type_first);                      // Type of the order that triggered a position deal (the first position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());                          // Ticket of the order, based on which an event deal is opened (the last position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());                       // Ticket of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_POSITION_ID,this.m_position_id);                             // Position ID
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());                        // Opposite position ID
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                              // Opposite position magic number

            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());                      // Position order type before changing direction
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());                       // Position order ticket before changing direction
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());                     // Current position order type
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());                      // Current position order ticket

            event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order.PriceOpen());                        // Order price before modification
            event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order.StopLoss());                           // StopLoss price before modification
            event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order.TakeProfit());                         // TakeProfit price before modification
            event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,this.m_tick.ask);                            // Ask price during an event
            event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,this.m_tick.bid);                            // Bid price during an event

            event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                                  // Order/deal/position magic number
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpen());                       // Time of an order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PriceOpen());                              // Event price
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                               // Order/deal/position open price
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceClose());                             // Order/deal/position close price
            event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                                  // StopLoss position price
            event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                                // TakeProfit position price
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());                        // Requested order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume()-order.VolumeCurrent()); // Executed order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.VolumeCurrent());                 // Remaining (unexecuted) order volume
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,order.Volume());                    // Executed position volume
            event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                                      // Profit
            event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                                      // Order symbol
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                                // Opposite position symbol
            //--- Decode the event code and set the event type
            event.SetTypeEvent();
            //--- Add the event object if it is not in the list
            if(!this.IsPresentEventInList(event))
              {
                this.m_list_trade_events.InsertSort(event);
                //--- Send a message about the event and set the value of the last trading event
                this.m_trade_event=event.TradeEvent();
                this.m_is_event=true;
                event.SendEvent();
                CBaseObjExt::EventAdd(this.m_trade_event,order.Ticket(),order.PriceOpen(),order.Symbol());
              }
            //--- If the event is already present in the list, remove a new event object and display a debugging message
            else
              {
                ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
                delete event;
              }
            }
        }
    //--- Position closed (__MQL4__)
      if(status==ORDER_STATUS_HISTORY_ORDER)
        {
          //--- Set the "position closed" trading event code
          this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_CLOSED;
          //--- Set the "request executed partially" reason
          ENUM_EVENT_REASON reason=EVENT_REASON_DONE;
          //--- If the closure by StopLoss flag is set for an order, a position is closed by StopLoss
          if(order.IsCloseByStopLoss())
            {
            //--- set the "closure by StopLoss" reason
            reason=EVENT_REASON_DONE_SL;
            //--- add the StopLoss closure flag to the event code
            this.m_trade_event_code+=TRADE_EVENT_FLAG_SL;
            }
          //--- If the closure by TakeProfit flag is set for an order, a position is closed by TakeProfit
          if(order.IsCloseByTakeProfit())
            {
            //--- set the "closure by TakeProfit" reason
            reason=EVENT_REASON_DONE_TP;
            //--- add the TakeProfit closure flag to the event code
            this.m_trade_event_code+=TRADE_EVENT_FLAG_TP;
            }
          //--- If an order has the property with an inherited order filled, a position is closed partially
          if(order.TicketTo()>0)
            {
            //--- set the "partial closure" reason
            reason=EVENT_REASON_DONE_PARTIALLY;
            //--- add the partial closure flag to the event code
            this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
            }
          //--- Check closure by an opposite position
          COrder* order_close_by=this.GetCloseByOrderFromList(list_history,order.Ticket());
          //--- Declare the variables of the opposite order properties and initialize them with the values of the current closed position
          ENUM_ORDER_TYPE close_by_type=this.m_type_first;
          double close_by_volume=order.Volume();
          ulong  close_by_ticket=order.Ticket();
          long   close_by_magic=order.Magic();
          string close_by_symbol=order.Symbol();
          //--- If the list of historical orders features an order with a closed position ID, the position is closed by an opposite one
          if(order_close_by!=NULL)
            {
            //--- Fill in the properties of an opposite closing order using data on the opposite position properties
            close_by_type=(ENUM_ORDER_TYPE)order_close_by.TypeOrder();
            close_by_ticket=order_close_by.Ticket();
            close_by_magic=order_close_by.Magic();
            close_by_symbol=order_close_by.Symbol();
            close_by_volume=order_close_by.Volume();
            //--- set the "close by" reason
            reason=EVENT_REASON_DONE_BY_POS;
            //--- add the close by flag to the event code
            this.m_trade_event_code+=TRADE_EVENT_FLAG_BY_POS;
            //--- Take data on (1) closed and (2) opposite positions from the list of control orders
            //--- (in this list, the properties of two opposite positions remain the same as before the closure)
            COrderControl* ctrl_closed=this.GetOrderControlByTicket(list_control,order.Ticket());
            COrderControl* ctrl_close_by=this.GetOrderControlByTicket(list_control,close_by_ticket);
            double vol_closed=0;
            double vol_close_by=0;
            //--- If no errors detected when receiving these two opposite orders
            if(ctrl_closed!=NULL && ctrl_close_by!=NULL)
              {
                //--- Calculate closed volumes of a (1) closed and (2) an opposite positions
                vol_closed=ctrl_closed.Volume()-order.Volume();
                vol_close_by=vol_closed-close_by_volume;
                //--- If a position is closed partially (the previous volume exceeds the currently closed one)
                if(ctrl_closed.Volume()>order.Volume())
                  {
                  //--- add the partial closure flag to the event code
                  this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
                  //--- set the "partial closure" reason
                  reason=EVENT_REASON_DONE_PARTIALLY_BY_POS;
                  }
              }
            }
          //--- Create the position closure event
          CEvent* event=new CEventPositionClose(this.m_trade_event_code,order.Ticket());
          if(event!=NULL && order.PositionByID()==0)
            {
            event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeClose());                               // Event time
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                        // Event reason (from the ENUM_EVENT_REASON enumeration)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,close_by_type);                              // Event deal type
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());                           // Event deal ticket
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,close_by_type);                             // Type of the order that triggered an event deal (the last position order)
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,this.m_type_first);                      // Type of the order that triggered a position deal (the first position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,close_by_ticket);                         // Ticket of the order, based on which an event deal is opened (the last position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());                       // Ticket of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_POSITION_ID,this.m_position_id);                             // Position ID
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,close_by_ticket);                             // Opposite position ID
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,close_by_magic);                                 // Opposite position magic number

            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());                      // Position order type before changing direction
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());                       // Position order ticket before changing direction
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());                     // Current position order type
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());                      // Current position order ticket

            event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order.PriceOpen());                        // Order price before modification
            event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order.StopLoss());                           // StopLoss price before modification
            event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order.TakeProfit());                         // TakeProfit price before modification
            event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,this.m_tick.ask);                            // Ask price during an event
            event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,this.m_tick.bid);                            // Bid price during an event

            event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                                  // Order/deal/position magic number
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpen());                       // Time of an order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PriceOpen());                              // Event price
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                               // Order/deal/position open price
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceClose());                             // Order/deal/position close price
            event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                                  // StopLoss position price
            event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                                // TakeProfit position price
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());                        // Requested order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume()-order.VolumeCurrent()); // Executed order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.VolumeCurrent());                 // Remaining (unexecuted) order volume
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,order.Volume());                    // Executed position volume
            event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                                      // Profit
            event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                                      // Order symbol
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,close_by_symbol);                               // Opposite position symbol
            //--- Decode the event code and set the event type
            event.SetTypeEvent();
            //--- Add the event object if it is not in the list
            if(!this.IsPresentEventInList(event))
              {
                this.m_list_trade_events.InsertSort(event);
                //--- Send a message about the event and set the value of the last trading event
                this.m_trade_event=event.TradeEvent();
                this.m_is_event=true;
                event.SendEvent();
                CBaseObjExt::EventAdd(this.m_trade_event,order.Ticket(),order.PriceClose(),order.Symbol());
              }
            //--- If the event is already present in the list, remove a new event object and display a debugging message
            else
              {
                ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
                delete event;
              }
            }
        }
    #endif
    //--- New deal (__MQL5__)
     if(status==ORDER_STATUS_DEAL)
      {
        //--- New balance operation
         if((ENUM_DEAL_TYPE)order.TypeOrder()>DEAL_TYPE_SELL)
          {
            this.m_trade_event_code=TRADE_EVENT_FLAG_ACCOUNT_BALANCE;
            CTradeEvent* event=new CTradeEventBalanceOperation(this.m_trade_event_code,order.Ticket());
            if(event!=NULL)
             {
              ENUM_EVENT_REASON reason=
              (
               (ENUM_DEAL_TYPE)order.TypeOrder()==DEAL_TYPE_BALANCE ? (order.Profit()>0 ? EVENT_REASON_BALANCE_REFILL : EVENT_REASON_BALANCE_WITHDRAWAL) :
               (ENUM_EVENT_REASON)(order.TypeOrder()+REASON_EVENT_SHIFT)
              );
              event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeOpen());                    // Event time
              event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                            // Event reason (from the ENUM_EVENT_REASON enumeration)
              event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeOrder());              // Event deal type
              event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());               // Event deal ticket
              event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());             // Type of the order that triggered an event deal (the last position order)
              event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());          // Type of an order that triggered a position deal (the first position order)
              event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());              // Ticket of an order, based on which an event deal is opened (the last position order)
              event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());           // Ticket of the order, based on which a position deal is opened (the first position order)
              event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                 // Position ID
              event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());            // Opposite position ID
              event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                  // Opposite position magic number

              event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());          // Position order type before changing direction
              event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());           // Position order ticket before changing direction
              event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());         // Current position order type
              event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());          // Current position order ticket

              event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order.PriceOpen());            // Order price before modification
              event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order.StopLoss());               // StopLoss price before modification
              event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order.TakeProfit());             // TakeProfit price before modification
              event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,this.m_tick.ask);                // Ask price during an event
              event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,this.m_tick.bid);                // Bid price during an event

              event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                      // Order/deal/position magic number
              event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpen());           // Time of an order, based on which a position deal is opened (the first position order)
              event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PriceOpen());                  // Event price
              event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                   // Order/deal/position open price
              event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceOpen());                  // Order/deal/position close price
              event.SetProperty(EVENT_PROP_PRICE_SL,0);                                     // StopLoss deal price
              event.SetProperty(EVENT_PROP_PRICE_TP,0);                                     // TakeProfit deal price
              event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());            // Requested deal volume
              event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume());           // Executed deal volume
              event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,0);                         // Remaining (unexecuted) deal volume
              event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,order.Volume());        // Executed position volume
              event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                          // Profit
              event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                          // Order symbol
              event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                    // Opposite position symbol
              //--- Decode the event code and set the event type
               event.SetTypeEvent();
              //--- Add the event object if it is not in the list
               if(!this.IsPresentEventInList(event))
                 {
                  //--- Send a message about the event and set the value of the last trading event
                   this.m_list_trade_events.InsertSort(event);
                   this.m_trade_event=event.TradeEvent();
                   this.m_is_event=true;
                   event.SendEvent();
                   CBaseObjExt::EventAdd(this.m_trade_event,order.Ticket(),order.Profit(),order.Symbol());
                 }
               //--- If the event is already present in the list, remove a new event object and display a debugging message
                else
                 {
                   ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
                   delete event;
                 }
             }
          }
        //--- If this is not a balance operation
         else
          {
           if(this.m_is_hedge)
            this.NewDealEventHedge(order,list_history,list_market);
           else
            this.NewDealEventNetto(order,list_history,list_market);
          }
      }
   }
  //+------------------------------------------------------------------+
  //| Create a hedging account event                                   |
  //+------------------------------------------------------------------+
  void CTradeEventsCollection::NewDealEventHedge(COrder* deal,CArrayObj* list_history,CArrayObj* list_market)
    {
     #ifdef __MQL5__
      double ask=::SymbolInfoDouble(deal.Symbol(),SYMBOL_ASK);
      double bid=::SymbolInfoDouble(deal.Symbol(),SYMBOL_BID);
      //--- Market entry
       if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_IN)
        {
         this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED;
         int reason=EVENT_REASON_DONE;
         //--- Look for all position deals in the direction of its opening and count its total volume
          double volume_in=this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID());
         //--- Take the deal order and the last position order from the list of all position orders
          ulong order_ticket=deal.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET);
          COrder* order_first=this.GetHistoryOrderByTicket(list_history,order_ticket);
          COrder* order_last=this.GetLastOrderFromList(list_history,deal.PositionID());
         //--- Get an open position by ticket
          COrder* position=this.GetPositionByID(list_market,deal.PositionID());
          double vol_position=(position!=NULL ? position.Volume() : 0);
         //--- If there is no last order, the first and last position orders coincide
          if(order_last==NULL)
            order_last=order_first;
          if(order_first!=NULL)
           {
            //--- If the order volume is opened partially, this is a partial execution
             if(this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID())<order_first.Volume())
              {
               this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
               reason=EVENT_REASON_DONE_PARTIALLY;
              }
            //--- If an opening order is a pending one, the pending order is activated
            if(order_first.TypeOrder()>ORDER_TYPE_SELL && order_first.TypeOrder()<ORDER_TYPE_CLOSE_BY)
            {
             this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_ACTIVATED;
             //--- If an order is executed partially, set the partial order execution as an event reason
              reason=
              (this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID())<order_first.Volume() ?
               EVENT_REASON_ACTIVATED_PENDING_PARTIALLY :
               EVENT_REASON_ACTIVATED_PENDING
              );
            }
            CTradeEvent* event=new CTradeEventPositionOpen(this.m_trade_event_code,deal.PositionID());
            if(event!=NULL)
             {
              event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpen());                           // Event time (position open time)
              event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                  // Event reason (from the ENUM_EVENT_REASON enumeration)
              event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                     // Event deal type
              event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                      // Event deal ticket
              event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order_first.TypeOrder());          // Type of the order that triggered a position deal (the first position order)
              event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order_first.Ticket());           // Ticket of the order, based on which a position deal is opened (the first position order)
              event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order_last.TypeOrder());              // Type of the order that triggered an event deal (the last position order)
              event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order_last.Ticket());               // Ticket of the order, based on which an event deal is opened (the last position order)
              event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                        // Position ID
              event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last.PositionByID());             // Opposite position ID
              //---
               event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                        // Opposite position magic number
               event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order_first.TypeOrder());          // Position order type before changing direction
               event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order_first.Ticket());           // Position order ticket before changing direction
               event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order_first.TypeOrder());         // Current position order type
               event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order_first.Ticket());          // Current position order ticket
               event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                           // Opposite position symbol
              //---
               event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first.PriceOpen());            // Order price before modification
               event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first.StopLoss());               // StopLoss price before modification
               event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first.TakeProfit());             // TakeProfit price before modification
               event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                                  // Ask price during an event
               event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                                  // Bid price during an event
              //---
               event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                             // Order/deal/position magic number
               event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first.TimeOpen());           // Time of an order, based on which a position deal is opened (the first position order)
               event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                         // Event price (position open price)
               event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first.PriceOpen());                   // Order open price (position opening order price)
               event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last.PriceClose());                  // Order close price (the last position order close price)
               event.SetProperty(EVENT_PROP_PRICE_SL,order_first.StopLoss());                      // StopLoss price (Position order StopLoss price)
               event.SetProperty(EVENT_PROP_PRICE_TP,order_first.TakeProfit());                    // TakeProfit price (Position order TakeProfit price)
               event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_first.Volume());            // Requested order volume
               event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,(order_first.Volume()-order_first.VolumeCurrent()));  // Executed order volume
               event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order_first.VolumeCurrent());                          // Remaining (unexecuted) order volume
               event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);                                     // Executed position volume
               event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                             // Profit
               event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                                 // Order symbol
              //--- Decode the event code and set the event type
               event.SetTypeEvent();
              //--- Add the event object if it is not in the list
               if(!this.IsPresentEventInList(event))
                {
                 this.m_list_trade_events.InsertSort(event);
                 //--- Send a message about the event and set the value of the last trading event
                 this.m_trade_event=event.TradeEvent();
                 this.m_is_event=true;
                 event.SendEvent();
                 CBaseObjExt::EventAdd(this.m_trade_event,deal.Ticket(),deal.PriceOpen(),deal.Symbol());
                }
               //--- If the event is already present in the list, remove a new event object and display a debugging message
              else
                {
                 ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
                 delete event;
                }
             }
           }
        }
      //--- Market exit
       else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT)
        {
         this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_CLOSED;
         int reason=EVENT_REASON_DONE;
         //--- Take the first and last position orders from the list of all position orders
          COrder* order_first=this.GetFirstOrderFromList(list_history,deal.PositionID());
          COrder* order_last=this.GetLastOrderFromList(list_history,deal.PositionID());
         //--- Get an open position by ticket
          COrder* position=this.GetPositionByID(list_market,deal.PositionID());
          double vol_position=(position!=NULL ? position.Volume() : 0);
          if(order_first!=NULL && order_last!=NULL)
           {
             //--- Look for all position deals in the directions of its opening and closing, and count their total volume
              double volume_in=this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID());
              double volume_out=this.SummaryVolumeDealsOutByPosID(list_history,deal.PositionID());
             //--- Calculate the current volume of the closed position
              int dgl=(int)DigitsLots(deal.Symbol());
              double volume_current=::NormalizeDouble(volume_in-volume_out,dgl);
             //--- If the order volume is closed partially, this is a partial execution
              if(volume_current>0)
               {
                this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
               }
             //--- If the closing order is executed partially, set the closing order partial execution as an event reason
              if(order_last.VolumeCurrent()>0)
               {
                reason=EVENT_REASON_DONE_PARTIALLY;
               }
             //--- If the closing flag is set to StopLoss for a position's closing order, then closing is performed by StopLoss
             //--- If a StopLoss order is executed partially, set partial StopLoss order execution as the event reason
              if(order_last.IsCloseByStopLoss())
                {
                 this.m_trade_event_code+=TRADE_EVENT_FLAG_SL;
                 reason=(order_last.VolumeCurrent()>0 ? EVENT_REASON_DONE_SL_PARTIALLY : EVENT_REASON_DONE_SL);
                }
             //--- If the closing flag is set to TakeProfit for a position's closing order, then closing is performed by TakeProfit
             //--- If a TakeProfit order is executed partially, set partial TakeProfit order execution as the event reason
              else if(order_last.IsCloseByTakeProfit())
                {
                 this.m_trade_event_code+=TRADE_EVENT_FLAG_TP;
                 reason=(order_last.VolumeCurrent()>0 ? EVENT_REASON_DONE_TP_PARTIALLY : EVENT_REASON_DONE_TP);
                }
             //---
              CTradeEvent* event=new CTradeEventPositionClose(this.m_trade_event_code,deal.PositionID());
              if(event!=NULL)
               {
                 event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpen());                           // Event time (position close time)
                 event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                  // Event reason (from the ENUM_EVENT_REASON enumeration)
                 event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                     // Event deal type
                 event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                      // Event deal ticket
                 event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order_first.TypeOrder());          // Type of the order that triggered a position deal (the first position order)
                 event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order_last.TypeOrder());              // Type of the order that triggered an event deal (the last position order)
                 event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order_first.Ticket());           // Ticket of the order, based on which a position deal is opened (the first position order)
                 event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order_last.Ticket());               // Ticket of the order, based on which an event deal is opened (the last position order)
                 event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                        // Position ID
                 event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last.PositionByID());             // Opposite position ID
                 //---
                   event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                        // Opposite position magic number
                   event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order_first.TypeOrder());          // Position order type before changing direction
                   event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order_first.Ticket());           // Position order ticket before changing direction
                   event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order_first.TypeOrder());         // Current position order type
                   event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order_first.Ticket());          // Current position order ticket
                   event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order_last.Symbol());                     // Opposite position symbol
                 //---
                   event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first.PriceOpen());            // Order price before modification
                   event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first.StopLoss());               // StopLoss price before modification
                   event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first.TakeProfit());             // TakeProfit price before modification
                   event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                                  // Ask price during an event
                   event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                                  // Bid price during an event
                 //---
                   event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                             // Order/deal/position magic number
                   event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first.TimeOpen());           // Time of an order, based on which a position deal is opened (the first position order)
                   event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                         // Event price (position close price)
                   event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first.PriceOpen());                   // Order open price (position opening order price)
                   event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last.PriceClose());                  // Order close price (the last position order close price)
                   event.SetProperty(EVENT_PROP_PRICE_SL,order_first.StopLoss());                      // StopLoss price (Position order StopLoss price)
                   event.SetProperty(EVENT_PROP_PRICE_TP,order_first.TakeProfit());                    // TakeProfit price (Position order TakeProfit price)
                   event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last.Volume());                               // Requested order volume
                   event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order_last.Volume()-order_last.VolumeCurrent());   // Executed order volume
                   event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order_last.VolumeCurrent());                        // Remaining (current) order volume
                   event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);                                  // Remaining (current) position volume
                 //---
                  event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                             // Profit
                  event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                                 // Order symbol
                 //--- Decode the event code and set the event type
                  event.SetTypeEvent();
                 //--- Add the event object if it is not in the list
                  if(!this.IsPresentEventInList(event))
                    {
                    this.m_list_trade_events.InsertSort(event);
                    //--- Send a message about the event and set the value of the last trading event
                    this.m_trade_event=event.TradeEvent();
                    this.m_is_event=true;
                    event.SendEvent();
                    CBaseObjExt::EventAdd(this.m_trade_event,order_first.Ticket(),deal.PriceOpen(),deal.Symbol());
                    }
                  //--- If the event is already present in the list, remove a new event object and display a debugging message
                  else
                    {
                    ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
                    delete event;
                    }
               }
           }
        }
      //--- Opposite position
        else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT_BY)
          {
            this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_CLOSED;
            int reason=EVENT_REASON_DONE_BY_POS;
            //--- Take the first and closing position orders from the list of all position orders
            COrder* order_first=this.GetFirstOrderFromList(list_history,deal.PositionID());
            COrder* order_close=this.GetCloseByOrderFromList(list_history,deal.PositionID());
            //--- Get the open position by ID
            COrder* position=this.GetPositionByID(list_market,order_first.PositionID());
            double vol_position=(position!=NULL ? position.Volume() : 0);
            if(order_first!=NULL && order_close!=NULL)
              {
              //--- Add the flag of closing by an opposite position
              this.m_trade_event_code+=TRADE_EVENT_FLAG_BY_POS;
              //--- Take the first order of the closing position
              COrder* order_close_by=this.GetFirstOrderFromList(list_history,order_close.PositionByID());
              if(order_close_by==NULL)
                  return;
              //--- Look for all closed position deals in the direction of its opening and closing and count their total volume
              double volume_in=this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID());
              double volume_out=this.SummaryVolumeDealsOutByPosID(list_history,deal.PositionID());//+order_close.Volume();
              //--- Calculate the current volume of the closed position
              int dgl=(int)DigitsLots(deal.Symbol());
              double volume_current=::NormalizeDouble(volume_in-volume_out,dgl);
              //--- Look for all opposite position deals in the directions of its opening and closing and calculate their total volume
              double volume_opp_in=this.SummaryVolumeDealsInByPosID(list_history,order_close.PositionByID());
              double volume_opp_out=this.SummaryVolumeDealsOutByPosID(list_history,order_close.PositionByID());
              //--- Calculate the current volume of the opposite position
              double volume_opp_current=::NormalizeDouble(volume_opp_in-volume_opp_out,dgl);
              //--- If the closed position volume is closed partially, this is a partial closing
              if(volume_current>0 || order_close.VolumeCurrent()>0)
                {
                  //--- Add the partial closing flag
                  this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
                  //--- If the opposite position is closed partially, there is a partial closing by the part of the opposite position volume
                  reason=(volume_opp_current>0 ? EVENT_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY : EVENT_REASON_DONE_PARTIALLY_BY_POS);
                }
              //--- If the position volume is closed in full and there is a partial execution by the opposite one, there is a closing by the part of the opposite position volume
              else
                {
                  if(volume_opp_current>0)
                    {
                    reason=EVENT_REASON_DONE_BY_POS_PARTIALLY;
                    }
                }
              CTradeEvent* event=new CTradeEventPositionClose(this.m_trade_event_code,deal.PositionID());
              if(event!=NULL)
                {
                  event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpen());                           // Event time
                  event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                  // Event reason (from the ENUM_EVENT_REASON enumeration)
                  event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                     // Event deal type
                  event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                      // Event deal ticket
                  event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order_close.TypeOrder());             // Type of the order that triggered an event deal (the last position order)
                  event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order_close.Ticket());              // Ticket of the order, based on which an event deal is opened (the last position order)
                  event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first.TimeOpen());           // Time of an order, based on which a position deal is opened (the first position order)
                  event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order_first.TypeOrder());          // Type of the order that triggered a position deal (the first position order)
                  event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order_first.Ticket());           // Ticket of the order, based on which a position deal is opened (the first position order)
                  event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                        // Position ID
                  event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_close.PositionByID());            // Opposite position ID
                  //---
                  event.SetProperty(EVENT_PROP_MAGIC_BY_ID,order_close_by.Magic());                   // Opposite position magic number
                  event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order_first.TypeOrder());          // Position order type before changing direction
                  event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order_first.Ticket());           // Position order ticket before changing direction
                  event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order_first.TypeOrder());         // Current position order type
                  event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order_first.Ticket());          // Current position order ticket
                  event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order_close_by.Symbol());                 // Opposite position symbol
                  //---
                  event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first.PriceOpen());            // Order price before modification
                  event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first.StopLoss());               // StopLoss price before modification
                  event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first.TakeProfit());             // TakeProfit price before modification
                  event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                                  // Ask price during an event
                  event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                                  // Bid price during an event
                  //---
                  event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                             // Order/deal/position magic number
                  event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                         // Event price
                  event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first.PriceOpen());                   // Order/deal/position open price
                  event.SetProperty(EVENT_PROP_PRICE_CLOSE,deal.PriceClose());                        // Order/deal/position close price
                  event.SetProperty(EVENT_PROP_PRICE_SL,order_first.StopLoss());                      // StopLoss price (Position order StopLoss price)
                  event.SetProperty(EVENT_PROP_PRICE_TP,order_first.TakeProfit());                    // TakeProfit price (Position order TakeProfit price)
                  event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,::NormalizeDouble(volume_in,dgl));// Initial volume
                  event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,deal.Volume());                  // Closed volume
                  event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,volume_current);                  // Remaining (current) volume
                  event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);                // Remaining (current) volume
                  event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                             // Profit
                  event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                                 // Order symbol
                  //--- Decode the event code and set the event type
                  event.SetTypeEvent();
                  //--- Add the event object if it is not in the list
                  if(!this.IsPresentEventInList(event))
                    {
                    this.m_list_trade_events.InsertSort(event);
                    //--- Send a message about the event and set the value of the last trading event
                    this.m_trade_event=event.TradeEvent();
                    this.m_is_event=true;
                    event.SendEvent();
                    CBaseObjExt::EventAdd(this.m_trade_event,order_first.Ticket(),deal.PriceOpen(),deal.Symbol());
                    }
                  //--- If the event is already present in the list, remove a new event object and display a debugging message
                  else
                    {
                    ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
                    delete event;
                    }
                }
              }
          }
      #endif
    }
  //+------------------------------------------------------------------+
  //| Create an event for a netting account                            |
  //+------------------------------------------------------------------+
  void CTradeEventsCollection::NewDealEventNetto(COrder *deal,CArrayObj *list_history,CArrayObj *list_market)
   {
    #ifdef __MQL5__
      double ask=::SymbolInfoDouble(deal.Symbol(),SYMBOL_ASK);
      double bid=::SymbolInfoDouble(deal.Symbol(),SYMBOL_BID);
    //--- Prepare position history data
    //--- Lists of all deals and position direction changes
      CArrayObj list_deals,list_changes;
      if(!this.GetListAllDealsByPosID(list_history,deal.PositionID(),list_deals) ||
         !this.GetListAllDealsInOutByPosID(list_history,deal.PositionID(),list_changes))
          return;
      list_deals.Sort(SORT_BY_ORDER_TIME_OPEN);
      list_changes.Sort(SORT_BY_ORDER_TIME_OPEN);
      if(!list_changes.InsertSort(list_deals.At(0)))
          return;

    //--- Orders of the first and last position deals
      COrder* order_first_deal=this.GetFirstOrderFromList(list_history,deal.PositionID());
      COrder* order_last_deal=this.GetHistoryOrderByTicket(list_history,(ulong)deal.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET));
      if(order_first_deal==NULL || order_last_deal==NULL)
          return;
    //--- Type and tickets of the first and last position deals' orders
      ENUM_ORDER_TYPE type_order_first_deal=(ENUM_ORDER_TYPE)order_first_deal.TypeOrder();
      ENUM_ORDER_TYPE type_order_last_deal=(ENUM_ORDER_TYPE)order_last_deal.TypeOrder();
      ulong ticket_order_first_deal=order_first_deal.Ticket();
      ulong ticket_order_last_deal=order_last_deal.Ticket();

    //--- Current and previous positions
      COrder* position_current=list_changes.At(list_changes.Total()-1);
      COrder* position_previous=(list_changes.Total()>1 ? list_changes.At(list_changes.Total()-2) : position_current);
      if(position_current==NULL || position_previous==NULL)
          return;
      ENUM_ORDER_TYPE type_position_current=(ENUM_ORDER_TYPE)position_current.TypeOrder();
      ulong ticket_position_current=position_current.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET);
      ENUM_ORDER_TYPE type_position_previous=(ENUM_ORDER_TYPE)position_previous.TypeOrder();
      ulong ticket_position_previous=position_previous.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET);

    //--- Get an open position by the ticket and write its volume
      COrder* position=this.GetPositionByID(list_market,deal.PositionID());
      double vol_position=(position!=NULL ? position.Volume() : 0);
    //--- Executed order volume
      double vol_order_done=order_last_deal.Volume()-order_last_deal.VolumeCurrent();
    //--- Remaining (unexecuted) order volume
      double vol_order_current=order_last_deal.VolumeCurrent();

    //--- Market entry
      if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_IN)
        {
          this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED;
          int num_deals=list_deals.Total();
          int reason=(num_deals>1 ? EVENT_REASON_VOLUME_ADD : EVENT_REASON_DONE);
          //--- If this is not the first deal in the position, add the position change flag
          if(num_deals>1)
            {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_POSITION_CHANGED;
            }
          //--- If the order volume is opened partially, this is a partial execution
          if(order_last_deal.VolumeCurrent()>0)
            {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
            //--- If this is not the first position deal, the volume is added by partial execution, otherwise - partial opening
            reason=(num_deals>1 ? EVENT_REASON_VOLUME_ADD_PARTIALLY : EVENT_REASON_DONE_PARTIALLY);
            }
          //--- If an opening order is a pending one, the pending order is activated
          if(order_last_deal.TypeOrder()>ORDER_TYPE_SELL && order_last_deal.TypeOrder()<ORDER_TYPE_CLOSE_BY)
            {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_ACTIVATED;
            //--- If this is not the first position deal
            if(num_deals>1)
              {
                //--- If the order is executed partially, set adding the volume to the position by pending order partial execution as an event reason,
                //--- otherwise, the volume is added to the position by executing a pending order
                reason=
                  (order_last_deal.VolumeCurrent()>0 ?
                  EVENT_REASON_VOLUME_ADD_BY_PENDING_PARTIALLY  :
                  EVENT_REASON_VOLUME_ADD_BY_PENDING
                  );
              }
            //--- If this is a new position
            else
              {
                //--- If the order is executed partially, set pending order partial execution as an event reason,
                //--- otherwise, the position is opened by activating a pending order
                reason=
                  (order_last_deal.VolumeCurrent()>0 ?
                  EVENT_REASON_ACTIVATED_PENDING_PARTIALLY  :
                  EVENT_REASON_ACTIVATED_PENDING
                  );
              }
            }
          CTradeEvent* event=new CTradeEventPositionOpen(this.m_trade_event_code,deal.PositionID());
          if(event!=NULL)
            {
            //--- Event deal parameters
            event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpen());                        // Event time (position open time)
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                               // Event reason (from the ENUM_EVENT_REASON enumeration)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                  // Event deal type
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                   // Event deal ticket
            event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                          // Order/deal/position magic number
            event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                      // Event price (position open price)
            event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                          // Profit
            event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                              // Order symbol
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                        // Opposite position symbol
            event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                     // Position ID

            //--- Event order parameters
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,type_order_last_deal);             // Type of the order that triggered an event deal (the last position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,ticket_order_last_deal);         // Ticket of the order, based on which an event deal is opened (the last position order)
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last_deal.PositionByID());     // Opposite position ID
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last_deal.PriceClose());          // Order close price (the last position order close price)
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last_deal.Volume());     // Requested order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,vol_order_done);              // Executed order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,vol_order_current);            // Remaining (unexecuted) order volume
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                     // Opposite position magic number

            //--- Position parameters
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,type_order_first_deal);         // Type of the order that triggered the first position deal
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,ticket_order_first_deal);     // Ticket of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first_deal.TimeOpen());   // Time of an order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first_deal.PriceOpen());           // Position first order open price
            event.SetProperty(EVENT_PROP_PRICE_SL,order_first_deal.StopLoss());              // StopLoss price (Position order StopLoss price)
            event.SetProperty(EVENT_PROP_PRICE_TP,order_first_deal.TakeProfit());            // TakeProfit price (Position order TakeProfit price)
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,type_position_previous);        // Position type before changing the direction
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,ticket_position_previous);    // Position order ticket before changing direction
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,type_position_current);        // Current position order type
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,ticket_position_current);    // Current position order ticket
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);             // Executed position volume

            event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first_deal.PriceOpen());    // Order price before modification
            event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first_deal.StopLoss());       // StopLoss price before modification
            event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first_deal.TakeProfit());     // TakeProfit price before modification
            event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                               // Ask price during an event
            event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                               // Bid price during an event

            //--- Decode the event code and set the event type
            event.SetTypeEvent();
            //--- Add the event object if it is not in the list
            if(!this.IsPresentEventInList(event))
              {
                this.m_list_trade_events.InsertSort(event);
                //--- Send a message about the event and set the value of the last trading event
                this.m_trade_event=event.TradeEvent();
                this.m_is_event=true;
                event.SendEvent();
                CBaseObjExt::EventAdd(this.m_trade_event,deal.Ticket(),deal.PriceOpen(),deal.Symbol());
              }
            //--- If the event is already present in the list, remove a new event object and display a debugging message
            else
              {
                ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
                delete event;
              }
            }
        }
    //--- Position reversal
      else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_INOUT)
        {
          this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED+TRADE_EVENT_FLAG_POSITION_CHANGED+TRADE_EVENT_FLAG_POSITION_REVERSE;
          int reason=EVENT_REASON_REVERSE;
          //--- If the order volume is opened partially, this is a partial execution
          if(order_last_deal.VolumeCurrent()>0)
            {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
            reason=EVENT_REASON_REVERSE_PARTIALLY;
            }
          //--- If an opening order is a pending one, the pending order is activated
          if(order_last_deal.TypeOrder()>ORDER_TYPE_SELL && order_last_deal.TypeOrder()<ORDER_TYPE_CLOSE_BY)
            {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_ACTIVATED;
            //--- If the order is executed partially, set the position reversal by a pending order partial execution as the event reason
            reason=
              (order_last_deal.VolumeCurrent()>0 ?
                EVENT_REASON_REVERSE_BY_PENDING_PARTIALLY  :
                EVENT_REASON_REVERSE_BY_PENDING
              );
            }
          CTradeEvent* event=new CTradeEventPositionOpen(this.m_trade_event_code,deal.PositionID());
          if(event!=NULL)
            {
            //--- Event deal parameters
            event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpen());                        // Event time (position open time)
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                               // Event reason (from the ENUM_EVENT_REASON enumeration)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                  // Event deal type
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                   // Event deal ticket
            event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                          // Order/deal/position magic number
            event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                      // Event price (position open price)
            event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                          // Profit
            event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                              // Order symbol
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                        // Opposite position symbol
            event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                     // Position ID

            //--- Event order parameters
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,type_order_last_deal);             // Type of the order that triggered an event deal (the last position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,ticket_order_last_deal);         // Ticket of the order, based on which an event deal is opened (the last position order)
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last_deal.PositionByID());     // Opposite position ID
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last_deal.PriceClose());          // Order close price (the last position order close price)
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last_deal.Volume());     // Requested order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,vol_order_done);              // Executed order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,vol_order_current);            // Remaining (unexecuted) order volume
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                     // Opposite position magic number

            //--- Position parameters
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,type_order_first_deal);         // Type of the order that triggered the first position deal
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,ticket_order_first_deal);     // Ticket of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first_deal.TimeOpen());   // Time of an order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first_deal.PriceOpen());           // Position first order open price
            event.SetProperty(EVENT_PROP_PRICE_SL,order_first_deal.StopLoss());              // StopLoss price (Position order StopLoss price)
            event.SetProperty(EVENT_PROP_PRICE_TP,order_first_deal.TakeProfit());            // TakeProfit price (Position order TakeProfit price)
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,type_position_previous);        // Position order type before changing the direction
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,ticket_position_previous);    // Position order ticket before changing direction
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,type_position_current);        // Current position order type
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,ticket_position_current);    // Current position order ticket
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);             // Executed position volume

            event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first_deal.PriceOpen());    // Order price before modification
            event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first_deal.StopLoss());       // StopLoss price before modification
            event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first_deal.TakeProfit());     // TakeProfit price before modification
            event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                               // Ask price during an event
            event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                               // Bid price during an event

            //--- Decode the event code and set the event type
            event.SetTypeEvent();
            //--- Add the event object if it is not in the list
            if(!this.IsPresentEventInList(event))
              {
                this.m_list_trade_events.InsertSort(event);
                //--- Send a message about the event and set the value of the last trading event
                this.m_trade_event=event.TradeEvent();
                this.m_is_event=true;
                event.SendEvent();
                CBaseObjExt::EventAdd(this.m_trade_event,deal.Ticket(),deal.PriceOpen(),deal.Symbol());
              }
            //--- If the event is already present in the list, remove a new event object and display a debugging message
            else
              {
                ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
                delete event;
              }
            }
        }
    //--- Market exit
      else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT)
        {
          this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_CLOSED;
          int reason=EVENT_REASON_DONE;
          //--- If the position with the ID is still in the market, this means partial execution
          if(this.GetPositionByID(list_market,deal.PositionID())!=NULL)
            {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
            }
          //--- If the closing order is executed partially, set the closing order partial execution as an event reason
          if(order_last_deal.VolumeCurrent()>0)
            {
            reason=EVENT_REASON_DONE_PARTIALLY;
            }
          //--- If the closing flag is set to StopLoss for a position's closing order, then closing is performed by StopLoss
          //--- If a StopLoss order is executed partially, set partial StopLoss order execution as the event reason
          if(order_last_deal.IsCloseByStopLoss())
            {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_SL;
            reason=(order_last_deal.VolumeCurrent()>0 ? EVENT_REASON_DONE_SL_PARTIALLY : EVENT_REASON_DONE_SL);
            }
          //--- If the closing flag is set to TakeProfit for a position's closing order, then closing is performed by TakeProfit
          //--- If a TakeProfit order is executed partially, set partial TakeProfit order execution as the event reason
          else if(order_last_deal.IsCloseByTakeProfit())
            {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_TP;
            reason=(order_last_deal.VolumeCurrent()>0 ? EVENT_REASON_DONE_TP_PARTIALLY : EVENT_REASON_DONE_TP);
            }
          //---
          CTradeEvent* event=new CTradeEventPositionClose(this.m_trade_event_code,deal.PositionID());
          if(event!=NULL)
            {
            //--- Event deal parameters
            event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpen());                        // Event time (position open time)
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                               // Event reason (from the ENUM_EVENT_REASON enumeration)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                  // Event deal type
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                   // Event deal ticket
            event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                          // Order/deal/position magic number
            event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                      // Event price (position open price)
            event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                          // Profit
            event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                              // Order symbol
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                        // Opposite position symbol
            event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                     // Position ID

            //--- Event order parameters
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,type_order_last_deal);             // Type of the order that triggered an event deal (the last position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,ticket_order_last_deal);         // Ticket of the order, based on which an event deal is opened (the last position order)
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last_deal.PositionByID());     // Opposite position ID
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last_deal.PriceClose());          // Order close price (the last position order close price)
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last_deal.Volume());     // Requested order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,vol_order_done);              // Executed order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,vol_order_current);            // Remaining (unexecuted) order volume
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                     // Opposite position magic number

            //--- Position parameters
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,type_order_first_deal);         // Type of the order that triggered the first position deal
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,ticket_order_first_deal);     // Ticket of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first_deal.TimeOpen());   // Time of an order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first_deal.PriceOpen());           // Position first order open price
            event.SetProperty(EVENT_PROP_PRICE_SL,order_first_deal.StopLoss());              // StopLoss price (Position order StopLoss price)
            event.SetProperty(EVENT_PROP_PRICE_TP,order_first_deal.TakeProfit());            // TakeProfit price (Position order TakeProfit price)
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,type_position_previous);        // Position order type before changing the direction
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,ticket_position_previous);    // Position order ticket before changing direction
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,type_position_current);        // Current position order type
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,ticket_position_current);    // Current position order ticket
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);             // Executed position volume

            event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first_deal.PriceOpen());    // Order price before modification
            event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first_deal.StopLoss());       // StopLoss price before modification
            event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first_deal.TakeProfit());     // TakeProfit price before modification
            event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                               // Ask price during an event
            event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                               // Bid price during an event

            //--- Decode the event code and set the event type
            event.SetTypeEvent();
            //--- Add the event object if it is not in the list
            if(!this.IsPresentEventInList(event))
              {
                this.m_list_trade_events.InsertSort(event);
                //--- Send a message about the event and set the value of the last trading event
                this.m_trade_event=event.TradeEvent();
                this.m_is_event=true;
                event.SendEvent();
                CBaseObjExt::EventAdd(this.m_trade_event,deal.Ticket(),deal.PriceOpen(),deal.Symbol());
              }
            //--- If the event is already present in the list, remove a new event object and display a debugging message
            else
              {
                ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_EVENT_ALREADY_IN_LIST));
                delete event;
              }
            }
        }
    #endif
   }
  //+------------------------------------------------------------------+
  //| Fill the list with the market pending orders from the list       |
  //+------------------------------------------------------------------+
  bool CTradeEventsCollection::GetListMarketPendings(CArrayObj* list,CArrayObj &list_out)
    {
    if(list.Type()!=COLLECTION_MARKET_ID)
      {
        CMessage::ToLog(DFUN,MSG_LIB_SYS_ERROR_NOT_MARKET_LIST);
        return false;
      }
    list_out.FreeMode(false);
    for(int i=0;i<list.Total();i++)
      {
        COrder* order=list.At(i);
        if(order!=NULL && order.Status()==ORDER_STATUS_MARKET_PENDING)
           list_out.Add(order);
      }
    return true;
    }
  //+------------------------------------------------------------------+
  //| Fill the list with the removed pending orders from the list      |
  //+------------------------------------------------------------------+
  bool CTradeEventsCollection::GetListHistoryPendings(CArrayObj* list,CArrayObj &list_out)
    {
    if(list.Type()!=COLLECTION_HISTORY_ID)
      {
        CMessage::ToLog(DFUN,MSG_LIB_SYS_ERROR_NOT_HISTORY_LIST);
        return false;
      }
    list_out.FreeMode(false);
    for(int i=0;i<list.Total();i++)
      {
        COrder* order=list.At(i);
        if(order!=NULL && order.Status()==ORDER_STATUS_HISTORY_PENDING)
           list_out.Add(order);
      }
    return true;
    }
  //+------------------------------------------------------------------+
  //| Fill the list with the deals from the list                       |
  //+------------------------------------------------------------------+
  bool CTradeEventsCollection::GetListDeals(CArrayObj* list,CArrayObj &list_out)
    {
    if(list.Type()!=COLLECTION_HISTORY_ID)
      {
        CMessage::ToLog(DFUN,MSG_LIB_SYS_ERROR_NOT_HISTORY_LIST);
        return false;
      }
    list_out.FreeMode(false);
    for(int i=0;i<list.Total();i++)
      {
        COrder* deal=list.At(i);
        if(deal!=NULL && deal.Status()==ORDER_STATUS_DEAL)
           list_out.Add(deal);
      }
    return true;
    }
  //+------------------------------------------------------------------+
  //| Fill the list with all position deals by its ID                  |
  //+------------------------------------------------------------------+
  bool CTradeEventsCollection::GetListAllDealsByPosID(CArrayObj *list,const ulong position_id,CArrayObj &list_out)
   {
    if(list.Type()!=COLLECTION_HISTORY_ID)
      {
        CMessage::ToLog(DFUN,MSG_LIB_SYS_ERROR_NOT_HISTORY_LIST);
        return false;
      }
    list_out.FreeMode(false);
    for(int i=0;i<list.Total();i++)
      {
        COrder* deal=list.At(i);
        if(deal!=NULL && deal.Status()==ORDER_STATUS_DEAL && deal.PositionID()==position_id)
           list_out.Add(deal);
      }
    return true;
   }
  //+------------------------------------------------------------------+
  //| Fill the list with all reversal deals (IN_OUT)                   |
  //| by position ID                                                   |
  //+------------------------------------------------------------------+
  bool CTradeEventsCollection::GetListAllDealsInOutByPosID(CArrayObj *list,const ulong position_id,CArrayObj &list_out)
   {
    if(list.Type()!=COLLECTION_HISTORY_ID)
      {
        CMessage::ToLog(DFUN,MSG_LIB_SYS_ERROR_NOT_HISTORY_LIST);
        return false;
      }
    list_out.FreeMode(false);
    for(int i=0;i<list.Total();i++)
      {
        COrder* deal=list.At(i);
        if(deal!=NULL && deal.Status()==ORDER_STATUS_DEAL && deal.PositionID()==position_id &&
           deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_INOUT)
           list_out.Add(deal);
      }
    return true;
   }
  //+------------------------------------------------------------------+
  //| Return the total volume of all deals of IN position              |
  //| by its ID                                                        |
  //+------------------------------------------------------------------+
  double CTradeEventsCollection::SummaryVolumeDealsInByPosID(CArrayObj *list,const ulong position_id)
   {
    if(list.Type()!=COLLECTION_HISTORY_ID)
      {
        CMessage::ToLog(DFUN,MSG_LIB_SYS_ERROR_NOT_HISTORY_LIST);
        return 0;
      }
    double vol=0.0;
    for(int i=0;i<list.Total();i++)
      {
        COrder* deal=list.At(i);
        if(deal!=NULL && deal.Status()==ORDER_STATUS_DEAL && deal.PositionID()==position_id &&
           deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_IN)
           vol+=deal.Volume();
      }
    return vol;
   }
  //+--------------------------------------------------------------------+
  //| Return the total volume of all deals of OUT position by its        |
  //| ID (participation in closing by an opposite position is considered)|
  //+--------------------------------------------------------------------+
  double CTradeEventsCollection::SummaryVolumeDealsOutByPosID(CArrayObj *list,const ulong position_id)
   {
    if(list.Type()!=COLLECTION_HISTORY_ID)
      {
        CMessage::ToLog(DFUN,MSG_LIB_SYS_ERROR_NOT_HISTORY_LIST);
        return 0;
      }
    double vol=0.0;
    for(int i=0;i<list.Total();i++)
      {
        COrder* order=list.At(i);
        if(order==NULL)
           continue;
        if(order.Status()==ORDER_STATUS_DEAL && order.PositionID()==position_id &&
           order.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT)
           vol+=order.Volume();
        if(order.TypeOrder()==ORDER_TYPE_CLOSE_BY && (order.PositionID()==position_id || order.PositionByID()==position_id))
           vol+=order.Volume();
      }
    return vol;
   }
  //+------------------------------------------------------------------+
  //| Return the first order from the list of all position orders      |
  //+------------------------------------------------------------------+
  COrder* CTradeEventsCollection::GetFirstOrderFromList(CArrayObj* list,const ulong position_id)
   {
    COrder* first=NULL;
    for(int i=0;i<list.Total();i++)
      {
        COrder* order=list.At(i);
        if(order==NULL || order.PositionID()!=position_id || order.Status()==ORDER_STATUS_DEAL)
           continue;
        if(first==NULL || order.GetProperty(ORDER_PROP_TIME_OPEN)<first.GetProperty(ORDER_PROP_TIME_OPEN))
           first=order;
      }
    return first;
   }
  //+------------------------------------------------------------------+
  //| Return the last order from the list of all position orders       |
  //+------------------------------------------------------------------+
  COrder* CTradeEventsCollection::GetLastOrderFromList(CArrayObj* list,const ulong position_id)
   {
    COrder* last=NULL;
    for(int i=0;i<list.Total();i++)
      {
        COrder* order=list.At(i);
        if(order==NULL || order.PositionID()!=position_id || order.Status()==ORDER_STATUS_DEAL)
           continue;
        if(last==NULL || order.GetProperty(ORDER_PROP_TIME_OPEN)>=last.GetProperty(ORDER_PROP_TIME_OPEN))
           last=order;
      }
    return last;
   }
  //+------------------------------------------------------------------+
  //| Return the last closing order                                    |
  //| from the list of all position orders                             |
  //+------------------------------------------------------------------+
  COrder* CTradeEventsCollection::GetCloseByOrderFromList(CArrayObj *list,const ulong position_id)
   {
    COrder* last=NULL;
    for(int i=0;i<list.Total();i++)
      {
        COrder* order=list.At(i);
        if(order==NULL || order.PositionID()!=position_id || order.Status()==ORDER_STATUS_DEAL || order.TypeOrder()!=ORDER_TYPE_CLOSE_BY)
           continue;
        if(last==NULL || order.GetProperty(ORDER_PROP_TIME_OPEN)>=last.GetProperty(ORDER_PROP_TIME_OPEN))
           last=order;
      }
    return last;
   }
  //+------------------------------------------------------------------+
  //| Return the order by ticket                                       |
  //+------------------------------------------------------------------+
  COrder* CTradeEventsCollection::GetHistoryOrderByTicket(CArrayObj *list,const ulong order_ticket)
   {
    if(list.Type()!=COLLECTION_HISTORY_ID)
      {
        CMessage::ToLog(DFUN,MSG_LIB_SYS_ERROR_NOT_HISTORY_LIST);
        return NULL;
      }
    for(int i=0;i<list.Total();i++)
      {
        COrder* order=list.At(i);
        if(order!=NULL && order.Status()!=ORDER_STATUS_DEAL && order.Ticket()==order_ticket)
           return order;
      }
    return NULL;
   }
  //+------------------------------------------------------------------+
  //| Return a position by ID                                          |
  //+------------------------------------------------------------------+
  COrder* CTradeEventsCollection::GetPositionByID(CArrayObj *list,const ulong position_id)
   {
    if(list.Type()!=COLLECTION_MARKET_ID)
      {
        CMessage::ToLog(DFUN,MSG_LIB_SYS_ERROR_NOT_MARKET_LIST);
        return NULL;
      }
    for(int i=0;i<list.Total();i++)
      {
        COrder* order=list.At(i);
        if(order!=NULL && order.Status()==ORDER_STATUS_MARKET_POSITION && order.PositionID()==position_id)
           return order;
      }
    return NULL;
   }
  //+------------------------------------------------------------------+
  //| Return a control order by a position ticket (MQL4)               |
  //+------------------------------------------------------------------+
  COrderControl* CTradeEventsCollection::GetOrderControlByTicket(CArrayObj *list,const ulong ticket)
   {
    if(list==NULL)
        return NULL;
    int total=list.Total();
    for(int i=0;i<total;i++)
      {
        COrderControl* ctrl=list.At(i);
        if(ctrl==NULL)
          continue;
        if(ctrl.Ticket()==ticket)
          return ctrl;
      }
    return NULL;
   }
  //+-------------------------------------------------------------------+
  //| Return the type of the opening order by the position ticket (MQL4)|
  //+-------------------------------------------------------------------+
  ENUM_ORDER_TYPE CTradeEventsCollection::GetTypeFirst(CArrayObj* list,const ulong ticket)
   {
    if(list==NULL)
        return WRONG_VALUE;
    COrderControl* ctrl=this.GetOrderControlByTicket(list,ticket);
    if(ctrl==NULL)
        return WRONG_VALUE;
    return (ENUM_ORDER_TYPE)ctrl.TypeOrder();
   }
  //+------------------------------------------------------------------+
  //| Return the flag of the event object presence in the event list   |
  //+------------------------------------------------------------------+
  bool CTradeEventsCollection::IsPresentEventInList(CTradeEvent *compared_event)
   {
    int total=this.m_list_trade_events.Total();
    if(total==0)
        return false;
    for(int i=total-1;i>WRONG_VALUE;i--)
      {
        CTradeEvent* event=this.m_list_trade_events.At(i);
        if(event==NULL)
          continue;
        if(event.IsEqual(compared_event))
          return true;
      }
    return false;
   }
 #endif // CTRADEEVENTSCOLLECTION_MQH_IMPLEMENTATION
#endif // CTRADEEVENTSCOLLECTION_MQH