//+------------------------------------------------------------------+
//|                                             MarketCollection.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/5724                 |
//|Lib https://www.mql5.com/en/articles/14710                        |

//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __MARKETCOLLECTION_MQH__
#define __MARKETCOLLECTION_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "ListObj.mqh"
 //#include "..\Services\Select\TradingSelect.mqh"
 #include "..\Entities\Trading\Orders\MarketOrder.mqh"
 #include "..\Entities\Trading\Orders\MarketPending.mqh"
 #include "..\Entities\Trading\Orders\MarketPosition.mqh"
 #include "..\Entities\Trading\OrderControl.mqh"
 #ifndef CMARKETCOLLECTION_MQH_DECLARATION
 #define CMARKETCOLLECTION_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Collection of market orders and positions                        |
  //+------------------------------------------------------------------+
  class CMarketCollection : public CObject
   {
    private:
      struct MqlDataMarket
       {
        ulong           hash_sum;               // Hash sum of all orders and positions on the account
        int             total_market;           // Number of market orders on the account
        int             total_pending;          // Number of pending orders on the account
        int             total_positions;        // Number of positions on the account
        double          total_volumes;          // Total volume of orders and positions on the account
       };
      MqlDataMarket     m_struct_curr_market;   // Current data on market orders and positions on the account
      MqlDataMarket     m_struct_prev_market;   // Previous data on market orders and positions on the account
      CListObj          m_list_all_orders;      // List of pending orders and positions on the account
      CArrayObj         m_list_control;         // List of control orders
      CArrayObj         m_list_changed;         // List of changed orders
      ENUM_CHANGE_TYPE  m_change_type;          // Order change type
      bool              m_is_trade_event;       // Trading event flag
      bool              m_is_change_volume;     // Total volume change flag
      double            m_change_volume_value;  // Total volume change value
      ulong             m_k_pow;                // Ratio for converting the price into a hash sum
      int               m_new_market_orders;    // Number of new market orders
      int               m_new_positions;        // Number of new positions
      int               m_new_pendings;         // Number of new pending orders
      int               m_type;                 // Object type
      //--- Save the current values of the account data status as previous ones
       void              SavePrevValues(void)    { this.m_struct_prev_market=this.m_struct_curr_market; }
      //--- Convert order data into a hash sum value
       ulong             ConvertToHS(COrder* order) const;
      //--- Add an order or a position to the list of pending orders and positions on an account and sets the data on market orders and positions on the account
       bool              AddToListMarket(COrder* order);
      //--- (1) Create and add a control order to the list of control orders, (2) a control order to the list of changed control orders
       bool              AddToListControl(COrder* order);
       bool              AddToListChanges(COrderControl* order_control);
      //--- Remove an order by a ticket or a position ID from the list of control orders
       bool              DeleteOrderFromListControl(const ulong ticket,const ulong id);
      //--- Return the control order index in the list by a position ticket and ID
       int               IndexControlOrder(const ulong ticket,const ulong id);
      //--- The handler of an existing order/position change event
       void              OnChangeEvent(COrder* order,const int index);
    public:
     //--- Return itself
       CMarketCollection *GetObject(void)          { return &this; }
     //--- Return the list of (1) all pending orders and open positions, (2) control orders and positions
       CArrayObj*        GetList(void)             { return &this.m_list_all_orders;}
       CArrayObj*        GetListChanges(void)      { return &this.m_list_changed;}
       CArrayObj*        GetListControl(void)      { return &this.m_list_control;}
     //--- Return the number of (1) new market orders, (2) new pending orders, (3) new positions,
     //--- (4) occurred trading event flag, (5) changed volume and (6) object type
       int               NewMarketOrders(void)    const { return this.m_new_market_orders;  }
       int               NewPendingOrders(void)   const { return this.m_new_pendings;       }
       int               NewPositions(void)       const { return this.m_new_positions;      }
       bool              IsTradeEvent(void)       const { return this.m_is_trade_event;     }
       double            ChangedVolumeValue(void) const { return this.m_change_volume_value;  }
       virtual int       Type(void)               const { return this.m_type;                 }

     //--- Constructor
                     CMarketCollection(void);
      //--- Update the list of pending orders and positions
        void              Refresh(void);
      //--- Sum of live floating profit over a position set - four overloads, same name (Anhnt,
      //--- 2026-09-16): (1) pos.Profit()+pos.Swap() over the live positions matching symbol/dir ("" / WRONG_VALUE = all).
      //--- (2) OrderCalcProfit() per real Position at a hypothetical target_price for (symbol,dir).
      //--- (3) same as (2) but for a HYPOTHETICAL lot/order not yet opened (no real Position to read).
      //--- (4) same as (3) but takes a raw point distance instead of an absolute target_price.
        double            SumFloatingProfit(const string symbol="", const ENUM_POSITION_TYPE dir=WRONG_VALUE);
        double            SumFloatingProfit(const string symbol, const ENUM_POSITION_TYPE dir, const double target_price);
        double            SumFloatingProfit(const string symbol, const ENUM_POSITION_TYPE dir, const double target_price, const double lot);
        double            SumFloatingProfit(const string symbol, const int distance_pts);
     //--- Sum of live Volume() over the positions matching symbol/dir - peer to SumFloatingProfit() above.
       double            SumVolume(const string symbol="", const ENUM_POSITION_TYPE dir=WRONG_VALUE);
     //--- (1) True if the order is an open position matching symbol/dir (""/WRONG_VALUE = any), (2) if symbol has an open position on the given side.
       bool              HasPosition(const COrder *order, const string symbol="", const ENUM_POSITION_TYPE dir=WRONG_VALUE);
       bool              HasPosition(const string symbol, const ENUM_POSITION_TYPE dir);
     //--- Live SL/TP of the first matching position on (symbol,dir), or 0 if none/not set.
       double            GetSL(const string symbol, const ENUM_POSITION_TYPE dir);
       double            GetTP(const string symbol, const ENUM_POSITION_TYPE dir);
     //--- Distinct (Symbol,Direction) pairs currently holding at least one open Position - moved
     //--- here from CTradingEngine (Anhnt/Claude, 2026-09-13), pure Collection-only data.
       int               GetDistinctSymbolsAndDirections(string &symbols[], ENUM_POSITION_TYPE &dirs[]);
   };
 #endif // CMARKETCOLLECTION_MQH_DECLARATION
 #ifndef CMARKETCOLLECTION_MQH_IMPLEMENTATION
 #define CMARKETCOLLECTION_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CMarketCollection::CMarketCollection(void) : m_is_trade_event(false),m_is_change_volume(false),m_change_volume_value(0)
   {
     this.m_type=COLLECTION_MARKET_ID;
     this.m_list_all_orders.Sort(SORT_BY_ORDER_TIME_OPEN);
     this.m_list_all_orders.Clear();
     //https://www.mql5.com/en/articles/6211
     //--- Collection list IDs in CommonDefines.mqh
      this.m_list_all_orders.Type(COLLECTION_MARKET_ID);
     ::ZeroMemory(this.m_struct_prev_market);
     this.m_struct_prev_market.hash_sum=WRONG_VALUE;
     this.m_list_control.Clear();
     this.m_list_control.Sort();
     this.m_list_changed.Clear();
     this.m_list_changed.Sort();
     this.m_k_pow=(ulong)pow(10,6);
   }
  //+------------------------------------------------------------------+
  //| Update the list of orders                                        |
  //+------------------------------------------------------------------+
  void CMarketCollection::Refresh(void)
   {
     ::ZeroMemory(this.m_struct_curr_market);
     this.m_is_trade_event=false;
     this.m_is_change_volume=false;
     this.m_new_pendings=0;
     this.m_new_positions=0;
     this.m_change_volume_value=0;
     this.m_list_all_orders.Clear();
     #ifdef __MQL4__
       int total=::OrdersTotal();
       for(int i=0; i<total; i++)
         {
          if(!::OrderSelect(i,SELECT_BY_POS)) continue;
          long ticket=::OrderTicket();
          ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::OrderType();
          //--- Position
          if(type==ORDER_TYPE_BUY || type==ORDER_TYPE_SELL)
            {
            CMarketPosition *position=new CMarketPosition(ticket);
            if(position==NULL) continue;
            //--- Get the control order index by a position ticket and ID
            int index=this.IndexControlOrder(ticket,position.PositionID());
            //--- Add a position object to the list of market orders and positions
            if(!this.AddToListMarket(position))
                continue;
            //--- If there is no order in the list of control orders and positions, add it
            if(index==WRONG_VALUE)
              {
                if(!this.AddToListControl(position))
                  {
                  //::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_FAILED_ADD_CTRL_ORDER_TO_LIST),position.TypeDescription()," #",position.Ticket());
                    string msg = DFUN_ERR_LINE + CMessage::Text(MSG_LIB_SYS_FAILED_ADD_CTRL_ORDER_TO...) + ":";
                    ::Print(msg);
                  }
              }
            //--- If the order is already present in the list of control orders, check it for changed properties
            if(index>WRONG_VALUE)
              {
                this.OnChangeEvent(position,index);
              }
            }
          //--- Pending order
          else if(type<ORDER_TYPE_BALANCE)
            {
            CMarketPending *order=new CMarketPending(ticket);
            if(order==NULL) continue;
            //--- Get the control order index by a position ticket and ID
            int index=this.IndexControlOrder(ticket,order.PositionID());
            //--- Add a pending order object to the list of market orders and positions
            if(!this.AddToListMarket(order))
                continue;
            //--- If there is no order in the list of control orders and positions, add it
            if(index==WRONG_VALUE)
              {
                if(!this.AddToListControl(order))
                  {
                  //::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_FAILED_ADD_CTRL_ORDER_TO_LIST),order.TypeDescription()," #",order.Ticket());
                    string msg = DFUN_ERR_LINE + CMessage::Text(MSG_LIB_SYS_FAILED_ADD_CTRL_ORDER_TO_LIST) + order.TypeDescription() + " #" + (string)order.Ticket();
                    ::Print(msg);
                  }
              }
            //--- If the order is already present in the list of control orders, check it for changed properties
            if(index>WRONG_VALUE)
              {
                this.OnChangeEvent(order,index);
              }
            }
        }
      //--- MQ5
      #else
      //--- Positions
       int total_positions=::PositionsTotal();
       for(int i=0; i<total_positions; i++)
        {
          ulong ticket=::PositionGetTicket(i);
          if(ticket==0) continue;
          CMarketPosition *position=new CMarketPosition(ticket);
          if(position==NULL) continue;
          //--- Add a position object to the list of market orders and positions
          if(!this.AddToListMarket(position))
            continue;
          //--- Get the control order index by a position ticket and ID
          int index=this.IndexControlOrder(ticket,position.PositionID());
          //--- If there is no order in the list of control orders, add it
          if(index==WRONG_VALUE)
            {
              if(!this.AddToListControl(position))
                {
                  //::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_FAILED_ADD_CTRL_POSITION_TO_LIST),position.TypeDescription()," #",position.Ticket());
                  string msg=DFUN_ERR_LINE+CMessage::Text(MSG_LIB_SYS_FAILED_ADD_CTRL_POSITION_TO_LIST)+position.TypeDescription()+" #"+(string)position.Ticket();
                  ::Print(msg);
                }
            }
          //--- If the order is already present in the list of control orders, check it for changed properties
          else if(index>WRONG_VALUE)
            {
              this.OnChangeEvent(position,index);
            }
        }
      //--- Orders
       int total_orders=::OrdersTotal();
       for(int i=0; i<total_orders; i++)
         {
          ulong ticket=::OrderGetTicket(i);
          if(ticket==0) continue;
          ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::OrderGetInteger(ORDER_TYPE);
          //--- Market order
          if(type<ORDER_TYPE_BUY_LIMIT)
            {
             CMarketOrder *order=new CMarketOrder(ticket);
             if(order==NULL) continue;
             //--- Add a market order object to the list of market orders and positions
             if(!this.AddToListMarket(order))
               continue;
            }
      //--- Pending order
       else
        {
         CMarketPending *order=new CMarketPending(ticket);
         if(order==NULL) continue;
         //--- Add a pending order object to the list of market orders and positions
         if(!this.AddToListMarket(order))
            continue;
         //--- Get the control order index by a position ticket and ID
         int index=this.IndexControlOrder(ticket,order.PositionID());
         //--- If there is no order in the list of control orders, add it
         if(index==WRONG_VALUE)
           {
            if(!this.AddToListControl(order))
              {
               //::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_FAILED_ADD_CTRL_ORDER_TO_LIST),order.TypeDescription()," #",order.Ticket());
               string msg=DFUN_ERR_LINE+CMessage::Text(MSG_LIB_SYS_FAILED_ADD_CTRL_ORDER_TO_LIST)+order.TypeDescription()+" #"+(string)order.Ticket();
               ::Print(msg);
              }
           }
         //--- If the order is already present in the list of control orders, check it for changed properties
         else if(index>WRONG_VALUE)
           {
            this.OnChangeEvent(order,index);
           }
        }
     }
    #endif
    //--- First launch
    if(this.m_struct_prev_market.hash_sum==WRONG_VALUE)
      {
      this.SavePrevValues();
      }
    //--- If the hash sum of all orders and positions changed
    if(this.m_struct_curr_market.hash_sum!=this.m_struct_prev_market.hash_sum)
     {
      this.m_new_market_orders=this.m_struct_curr_market.total_market-this.m_struct_prev_market.total_market;
      this.m_new_pendings=this.m_struct_curr_market.total_pending-this.m_struct_prev_market.total_pending;
      this.m_new_positions=this.m_struct_curr_market.total_positions-this.m_struct_prev_market.total_positions;
      this.m_change_volume_value=::NormalizeDouble(this.m_struct_curr_market.total_volumes-this.m_struct_prev_market.total_volumes,4);
      this.m_is_change_volume=(this.m_change_volume_value!=0 ? true : false);
      this.m_is_trade_event=true;
      this.SavePrevValues();
     }
   }
  //+------------------------------------------------------------------+
  //| The handler of an existing order/position change event           |
  //+------------------------------------------------------------------+
  void CMarketCollection::OnChangeEvent(COrder* order,const int index)
    {
      COrderControl* order_control=this.m_list_control.At(index);
      if(order_control==NULL)
       return;
      this.m_change_type=order_control.ChangeControl(order);
      ENUM_CHANGE_TYPE change_type=(order.Status()==ORDER_STATUS_MARKET_POSITION ? CHANGE_TYPE_ORDER_TAKE_PROFIT : CHANGE_TYPE_NO_CHANGE);
      if(this.m_change_type>change_type)
      {
        order_control.SetNewState(order);
        if(!this.AddToListChanges(order_control))
          {
          ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_ADD_MODIFIED_ORD_TO_LIST));
          }
      }
    }
  //+--------------------------------------------------------------------------------+
  //| Add an order or a position to the list of orders and positions on the account  |
  //+--------------------------------------------------------------------------------+
  bool CMarketCollection::AddToListMarket(COrder *order)
   {
    if(order==NULL)
     {
      return false;
     }
    ENUM_ORDER_STATUS status=order.Status();
    if(this.m_list_all_orders.InsertSort(order))
      {
       if(status==ORDER_STATUS_MARKET_POSITION)
        {
         this.m_struct_curr_market.hash_sum+=order.GetProperty(ORDER_PROP_TIME_UPDATE)+this.ConvertToHS(order);
         this.m_struct_curr_market.total_volumes+=order.Volume();
         this.m_struct_curr_market.total_positions++;
         return true;
        }
       if(status==ORDER_STATUS_MARKET_PENDING)
        {
         this.m_struct_curr_market.hash_sum+=this.ConvertToHS(order);
         this.m_struct_curr_market.total_volumes+=order.Volume();
         this.m_struct_curr_market.total_pending++;
         return true;
        }
      }
    else
     {
      //::Print(DFUN,order.TypeDescription()," #",order.Ticket()," ",CMessage::Text(MSG_LIB_TEXT_FAILED_ADD_TO_LIST));
      string msg=DFUN+order.TypeDescription()+" #"+(string)order.Ticket()+" "+CMessage::Text(MSG_LIB_TEXT_FAILED_ADD_TO_LIST);
      ::Print(msg);
      delete order;
     }
    return false;
   }
  //+------------------------------------------------------------------+
  //| Return an order index by a ticket in the list of control orders  |
  //+------------------------------------------------------------------+
  int CMarketCollection::IndexControlOrder(const ulong ticket,const ulong id)
   {
    int total=this.m_list_control.Total();
    for(int i=0;i<total;i++)
     {
      COrderControl* order=this.m_list_control.At(i);
      if(order==NULL)
         continue;
      if(order.PositionID()==id && order.Ticket()==ticket)
         return i;
     }
    return WRONG_VALUE;
   }
  //+------------------------------------------------------------------+
  //| Create and add an order to the list of control orders            |
  //+------------------------------------------------------------------+
  bool CMarketCollection::AddToListControl(COrder *order)
  {
    if(order==NULL)
      return false;
    COrderControl* order_control=new COrderControl(order.PositionID(),order.Ticket(),order.Magic(),order.Symbol());
    if(order_control==NULL)
      return false;
     order_control.SetTime(order.TimeOpen());
     order_control.SetTimePrev(order.TimeOpen());
     order_control.SetVolume(order.Volume());
     order_control.SetTime(order.TimeOpen());
     order_control.SetTypeOrder(order.TypeOrder());
     order_control.SetTypeOrderPrev(order.TypeOrder());
     order_control.SetPrice(order.PriceOpen());
     order_control.SetPricePrev(order.PriceOpen());
     order_control.SetStopLoss(order.StopLoss());
     order_control.SetStopLossPrev(order.StopLoss());
     order_control.SetTakeProfit(order.TakeProfit());
     order_control.SetTakeProfitPrev(order.TakeProfit());
     if(!this.m_list_control.Add(order_control))
      {
         delete order_control;
         return false;
      }
     return true;
  }
  //+------------------------------------------------------------------+
  //|Create and add a control order to the list of changed orders      |
  //+------------------------------------------------------------------+
  bool CMarketCollection::AddToListChanges(COrderControl* order_control)
   {
     if(order_control==NULL)
      return false;
     COrderControl* order_changed=new COrderControl(order_control.PositionID(),order_control.Ticket(),order_control.Magic(),order_control.Symbol());
     if(order_changed==NULL)
      return false;
     order_changed.SetTime(order_control.Time());
     order_changed.SetTimePrev(order_control.TimePrev());
     order_changed.SetVolume(order_control.Volume());
     order_changed.SetTypeOrder(order_control.TypeOrder());
     order_changed.SetTypeOrderPrev(order_control.TypeOrderPrev());
     order_changed.SetPrice(order_control.Price());
     order_changed.SetPricePrev(order_control.PricePrev());
     order_changed.SetStopLoss(order_control.StopLoss());
     order_changed.SetStopLossPrev(order_control.StopLossPrev());
     order_changed.SetTakeProfit(order_control.TakeProfit());
     order_changed.SetTakeProfitPrev(order_control.TakeProfitPrev());
     order_changed.SetChangedType(order_control.GetChangeType());
     if(!this.m_list_changed.Add(order_changed))
      {
         delete order_changed;
         return false;
      }
     return true;
   }
  //+----------------------------------------------------------------------+
  //| Convert the order price and its type into a number for the hash sum  |
  //+----------------------------------------------------------------------+
  ulong CMarketCollection::ConvertToHS(COrder *order) const
   {
   if(order==NULL)
      return 0;
   ulong price=ulong(order.PriceOpen()*this.m_k_pow);
   ulong stop=ulong(order.StopLoss()*this.m_k_pow);
   ulong take=ulong(order.TakeProfit()*this.m_k_pow);
   ulong type=order.TypeOrder();
   ulong ticket=order.Ticket();
   return price+stop+take+type+ticket;
   }
  //+------------------------------------------------------------------+

  //+------------------------------------------------------------------+
  //| Overload: money value if all (symbol,dir) positions closed at target_price - via native |
  //+------------------------------------------------------------------+
  double CMarketCollection::SumFloatingProfit(const string symbol, const ENUM_POSITION_TYPE dir, const double target_price)
   {
    double total = 0;
    for(int i = 0; i < this.m_list_all_orders.Total(); i++)
     {
      COrder *pos = this.m_list_all_orders.At(i);
      if(!this.HasPosition(pos, symbol, dir)) continue;
      double p = 0;
      if(OrderCalcProfit((ENUM_ORDER_TYPE)dir, symbol, pos.Volume(), pos.PriceOpen(), target_price, p))
         total += p;
     }
    return total;
   }
   //+------------------------------------------------------------------+
   //| Overload: money value if a HYPOTHETICAL new (symbol,dir) position |
   //| of the given lot, opened at the current Bid/Ask, closed at        |
   //| target_price - via native OrderCalcProfit(), same as the 3-arg    |
   //| overload above but for a NOT-YET-OPENED order (no real Position   |
   //| to read Volume()/PriceOpen() from), Anhnt/Claude 2026-09-16.       |
   //+------------------------------------------------------------------+
   double CMarketCollection::SumFloatingProfit(const string symbol, const ENUM_POSITION_TYPE dir, const double target_price, const double lot)
    {
     double open_price = (dir == POSITION_TYPE_BUY) ? ::SymbolInfoDouble(symbol, SYMBOL_BID) : ::SymbolInfoDouble(symbol, SYMBOL_ASK);
     double p = 0;
     if(!OrderCalcProfit((ENUM_ORDER_TYPE)dir, symbol, lot, open_price, target_price, p)) return 0;
     return p;
    }
   //+------------------------------------------------------------------+
   //| Overload: money value at SYMBOL_VOLUME_MIN if price moves          |
   //| distance_pts points against a hypothetical BUY - direction is      |
   //| arbitrary here (magnitude-only preview, no real Position/Direction |
   //| context, e.g. StopLost/Trailing Setting popups) - via native       |
   //| OrderCalcProfit(), Anhnt/Claude 2026-09-16.                        |
   //+------------------------------------------------------------------+
   double CMarketCollection::SumFloatingProfit(const string symbol, const int distance_pts)
    {
     if(distance_pts < 0) return EMPTY_VALUE;
     double point = ::SymbolInfoDouble(symbol, SYMBOL_POINT);
     double lot   = ::SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
     if(point <= 0 || lot <= 0) return EMPTY_VALUE;
     double open_price   = ::SymbolInfoDouble(symbol, SYMBOL_BID);
     double target_price = open_price - distance_pts * point;
     double p = 0;
     if(!OrderCalcProfit(ORDER_TYPE_BUY, symbol, lot, open_price, target_price, p)) return EMPTY_VALUE;
     return p;
    }
  //+------------------------------------------------------------------+
  //| Sum of live floating profit over a pre-filtered position list    |
  //+------------------------------------------------------------------+
  double CMarketCollection::SumFloatingProfit(const string symbol, const ENUM_POSITION_TYPE dir)
   {
    double total = 0;
    for(int i = 0; i < this.m_list_all_orders.Total(); i++)
     {
      COrder *pos = this.m_list_all_orders.At(i);
      if(this.HasPosition(pos, symbol, dir)) total += pos.Profit() + pos.Swap();
     }
    return total;
   }
  //+------------------------------------------------------------------+
  //| Sum of live Volume() over a pre-filtered position list           |
  //+------------------------------------------------------------------+
  double CMarketCollection::SumVolume(const string symbol, const ENUM_POSITION_TYPE dir)
   {
    double total = 0;
    for(int i = 0; i < this.m_list_all_orders.Total(); i++)
     {
      COrder *pos = this.m_list_all_orders.At(i);
      if(this.HasPosition(pos, symbol, dir)) total += pos.Volume();
     }
    return total;
   }

  //+------------------------------------------------------------------+
  //| True if symbol has an open market position on the given side     |
  //+------------------------------------------------------------------+
  bool CMarketCollection::HasPosition(const string symbol, const ENUM_POSITION_TYPE dir)
   {
    for(int i = 0; i < this.m_list_all_orders.Total(); i++)
     {
      COrder *order = this.m_list_all_orders.At(i);
      if(this.HasPosition(order, symbol, dir)) return true;
     }
    return false;
   }
  //+------------------------------------------------------------------+
  //| True if the order is an open position matching symbol/dir        |
  //+------------------------------------------------------------------+
  bool CMarketCollection::HasPosition(const COrder *order, const string symbol, const ENUM_POSITION_TYPE dir)
   {
    if(order == NULL || order.Status() != ORDER_STATUS_MARKET_POSITION) return false;
    if(symbol != "" && order.Symbol() != symbol) return false;
    if(dir != WRONG_VALUE && order.TypeOrder() != (long)dir) return false;
    return true;
   }
  //+------------------------------------------------------------------+
  //| Live SL of the first matching position on (symbol,dir)           |
  //+------------------------------------------------------------------+
  double CMarketCollection::GetSL(const string symbol, const ENUM_POSITION_TYPE dir)
   {
    for(int i = 0; i < this.m_list_all_orders.Total(); i++)
     {
      COrder *pos = this.m_list_all_orders.At(i);
      if(!this.HasPosition(pos, symbol, dir)) continue;
      double sl = pos.StopLoss();
      if(sl > 0) return sl;
     }
    return 0;
   }
  //+------------------------------------------------------------------+
  //| Live TP of the first matching position on (symbol,dir)           |
  //+------------------------------------------------------------------+
  double CMarketCollection::GetTP(const string symbol, const ENUM_POSITION_TYPE dir)
   {
    for(int i = 0; i < this.m_list_all_orders.Total(); i++)
     {
      COrder *pos = this.m_list_all_orders.At(i);
      if(!this.HasPosition(pos, symbol, dir)) continue;
      double tp = pos.TakeProfit();
      if(tp > 0) return tp;
     }
    return 0;
   }

  //+------------------------------------------------------------------+
  //| Distinct (Symbol,Direction) pairs currently holding at least one |
  //| open Position - moved from CTradingEngine (Anhnt/Claude,         |
  //| 2026-09-13), pure Collection-only data, no Engine state needed.  |
  //+------------------------------------------------------------------+
  int CMarketCollection::GetDistinctSymbolsAndDirections(string &symbols[], ENUM_POSITION_TYPE &dirs[])
   {
    ::ArrayResize(symbols, 0);
    ::ArrayResize(dirs, 0);
    for(int i = 0; i < this.m_list_all_orders.Total(); i++)
     {
      COrder *pos = this.m_list_all_orders.At(i);
      if(!this.HasPosition(pos)) continue;
      string sym = pos.Symbol();
      if(sym == "") continue;
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)pos.TypeOrder();
      bool already = false;
      for(int j = 0; j < ::ArraySize(symbols); j++)
        if(symbols[j] == sym && dirs[j] == type) { already = true; break; }
      if(already) continue;
      int n = ::ArraySize(symbols);
      ::ArrayResize(symbols, n + 1);
      ::ArrayResize(dirs, n + 1);
      symbols[n] = sym;
      dirs[n]    = type;
     }
    return ::ArraySize(symbols);
   }

#endif // CMARKETCOLLECTION_MQH_IMPLEMENTATION
#endif // __MARKETCOLLECTION_MQH__
