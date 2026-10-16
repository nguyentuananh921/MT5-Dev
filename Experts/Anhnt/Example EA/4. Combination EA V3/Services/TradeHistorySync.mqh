//+------------------------------------------------------------------+
//|                                              TradeHistorySync.mqh |
//| The deals and the history orders of CHistoryCollection go to     |
//| Python, which keeps them in a SQLite file of the account for the |
//| analysis. The EA only reports; Python writes (by ticket, so a    |
//| line sent twice changes nothing)                                 |
//+------------------------------------------------------------------+
#ifndef __TRADEHISTORYSYNC_MQH__
#define __TRADEHISTORYSYNC_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\HistoryCollection.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\MarketCollection.mqh>   // COrderControl: what changed in a live order
 #include "PythonBridge.mqh"
 #define TRADE_SYNC_BATCH        50      // lines in one message
 #define TRADE_SYNC_TAIL         10      // lines before the new ones sent again: the list is sorted by time, a new line can come in the middle
 //+------------------------------------------------------------------+
 //| Event driven: the whole history when Python is connected, then   |
 //| the new lines at each trade event of the terminal                |
 //+------------------------------------------------------------------+
 class CTradeHistorySync
  {
   private:
     CHistoryCollection m_history;
     CPythonBridge     *m_bridge;           // EA owns
     int                m_listed;           // lines of the collection at the last send
     string             Text(const string value) const;
     string             Number(const double value) const { return ::DoubleToString(value,8); }
     string             DealJson(COrder *order) const;
     string             OrderJson(COrder *order) const;
     bool               Flush(const string &deals[],const int deals_total,const string &orders[],const int orders_total);
     string             EventJson(COrderControl *control) const;
     bool               SendRange(const int from,const int to);
   public:
     void               OnInitEvent(CPythonBridge *bridge)    { this.m_bridge=bridge; this.m_listed=0; }
     void               OnTradeEvent(void);      // OnTrade of the terminal
     void               OnConnected(void);       // Python is connected
   //--- What the market collection saw changed in the live orders and positions (the list is cleared by the caller right after): Python keeps it
     void               OnMarketChanges(CArrayObj *changes);
     void               OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     CHistoryCollection *History(void)                         { return &this.m_history; }
                        CTradeHistorySync(void) : m_bridge(NULL),m_listed(0) {}
  };
 //--- A text inside a JSON string
 string CTradeHistorySync::Text(const string value) const
  {
   string text=value;
   ::StringReplace(text,"\\","\\\\");
   ::StringReplace(text,"\"","\\\"");
   ::StringReplace(text,"\r"," ");
   ::StringReplace(text,"\n"," ");
   ::StringReplace(text,"\t"," ");
   return "\""+text+"\"";
  }
 //--- What CHistoryCollection holds of a deal (times are in milliseconds)
 string CTradeHistorySync::DealJson(COrder *order) const
  {
   return "{\"ticket\":"+(string)order.Ticket()+
          ",\"order_ticket\":"+(string)order.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET)+
          ",\"position\":"+(string)order.PositionID()+
          ",\"time_msc\":"+(string)order.TimeOpen()+
          ",\"type\":"+(string)order.TypeOrder()+
          ",\"entry\":"+(string)order.GetProperty(ORDER_PROP_DEAL_ENTRY)+
          ",\"reason\":"+(string)order.Reason()+
          ",\"magic\":"+(string)order.Magic()+
          ",\"symbol\":"+this.Text(order.Symbol())+
          ",\"volume\":"+this.Number(order.Volume())+
          ",\"price\":"+this.Number(order.PriceOpen())+
          ",\"commission\":"+this.Number(order.Comission())+
          ",\"swap\":"+this.Number(order.Swap())+
          ",\"profit\":"+this.Number(order.Profit())+
          ",\"sl\":"+this.Number(order.StopLoss())+
          ",\"tp\":"+this.Number(order.TakeProfit())+
          ",\"comment\":"+this.Text(order.Comment())+"}";
  }
 //--- What CHistoryCollection holds of a history order
 string CTradeHistorySync::OrderJson(COrder *order) const
  {
   return "{\"ticket\":"+(string)order.Ticket()+
          ",\"position\":"+(string)order.PositionID()+
          ",\"time_setup_msc\":"+(string)order.TimeOpen()+
          ",\"time_done_msc\":"+(string)order.TimeClose()+
          ",\"type\":"+(string)order.TypeOrder()+
          ",\"state\":"+(string)(long)order.State()+
          ",\"reason\":"+(string)order.Reason()+
          ",\"magic\":"+(string)order.Magic()+
          ",\"symbol\":"+this.Text(order.Symbol())+
          ",\"volume\":"+this.Number(order.Volume())+
          ",\"volume_current\":"+this.Number(order.VolumeCurrent())+
          ",\"price\":"+this.Number(order.PriceOpen())+
          ",\"sl\":"+this.Number(order.StopLoss())+
          ",\"tp\":"+this.Number(order.TakeProfit())+
          ",\"expiration\":"+(string)(long)order.TimeExpiration()+
          ",\"comment\":"+this.Text(order.Comment())+"}";
  }
 //--- One message of the lines that are ready
 bool CTradeHistorySync::Flush(const string &deals[],const int deals_total,const string &orders[],const int orders_total)
  {
   if(deals_total==0 && orders_total==0)
      return true;
   string deals_text="",orders_text="";
   for(int i=0;i<deals_total;i++)
      deals_text+=(i>0 ? "," : "")+deals[i];
   for(int i=0;i<orders_total;i++)
      orders_text+=(i>0 ? "," : "")+orders[i];
   string text="{\"cmd\":\"trades\",\"account\":"+(string)::AccountInfoInteger(ACCOUNT_LOGIN)+
               ",\"server\":"+this.Text(::AccountInfoString(ACCOUNT_SERVER))+
               ",\"deals\":["+deals_text+"],\"orders\":["+orders_text+"]}\n";
   return this.m_bridge.SendLine(text);
  }
 //--- The lines from..to-1 of the collection, in messages of TRADE_SYNC_BATCH lines
 bool CTradeHistorySync::SendRange(const int from,const int to)
  {
   CArrayObj *list=this.m_history.GetList();
   string deals[],orders[];
   ::ArrayResize(deals,TRADE_SYNC_BATCH);
   ::ArrayResize(orders,TRADE_SYNC_BATCH);
   int deals_total=0,orders_total=0;
   for(int i=from;i<to;i++)
     {
      COrder *order=list.At(i);
      if(order==NULL)
         continue;
      switch(order.Status())
        {
         case ORDER_STATUS_DEAL:
            deals[deals_total++]=this.DealJson(order);
            break;
         case ORDER_STATUS_HISTORY_ORDER:
         case ORDER_STATUS_HISTORY_PENDING:
            orders[orders_total++]=this.OrderJson(order);
            break;
         default:
            break;
        }
      if(deals_total+orders_total>=TRADE_SYNC_BATCH)
        {
         if(!this.Flush(deals,deals_total,orders,orders_total))
            return false;
         deals_total=0;
         orders_total=0;
        }
     }
   return this.Flush(deals,deals_total,orders,orders_total);
  }
 //--- One change of a live order or position: before and after, with the last tick of the symbol (its time, bid, ask)
 string CTradeHistorySync::EventJson(COrderControl *control) const
  {
   MqlTick tick;
   bool has_tick=::SymbolInfoTick(control.Symbol(),tick);
   long time_msc=(has_tick && tick.time_msc>0 ? tick.time_msc : (long)::TimeTradeServer()*1000);
   double bid=(has_tick ? tick.bid : 0.0);
   double ask=(has_tick ? tick.ask : 0.0);
   double point=::SymbolInfoDouble(control.Symbol(),SYMBOL_POINT);
   string spread=(has_tick && point>0.0 ? this.Number((ask-bid)/point) : "null");
   return "{\"time_msc\":"+(string)time_msc+
          ",\"ticket\":"+(string)control.Ticket()+
          ",\"position\":"+(string)control.PositionID()+
          ",\"symbol\":"+this.Text(control.Symbol())+
          ",\"magic\":"+(string)control.Magic()+
          ",\"change\":"+(string)(int)control.GetChangeType()+
          ",\"type\":"+(string)control.TypeOrder()+
          ",\"type_prev\":"+(string)control.TypeOrderPrev()+
          ",\"price\":"+this.Number(control.Price())+
          ",\"price_prev\":"+this.Number(control.PricePrev())+
          ",\"sl\":"+this.Number(control.StopLoss())+
          ",\"sl_prev\":"+this.Number(control.StopLossPrev())+
          ",\"tp\":"+this.Number(control.TakeProfit())+
          ",\"tp_prev\":"+this.Number(control.TakeProfitPrev())+
          ",\"volume\":"+this.Number(control.Volume())+
          ",\"bid\":"+this.Number(bid)+
          ",\"ask\":"+this.Number(ask)+
          ",\"spread\":"+spread+"}";
  }
 void CTradeHistorySync::OnMarketChanges(CArrayObj *changes)
  {
   if(changes==NULL || changes.Total()==0 || this.m_bridge==NULL || !this.m_bridge.IsReady())
      return;
   string events="";
   for(int i=0;i<changes.Total();i++)
     {
      COrderControl *control=changes.At(i);
      if(control!=NULL)
         events+=(events=="" ? "" : ",")+this.EventJson(control);
     }
   if(events=="")
      return;
   string text="{\"cmd\":\"trades\",\"account\":"+(string)::AccountInfoInteger(ACCOUNT_LOGIN)+
               ",\"server\":"+this.Text(::AccountInfoString(ACCOUNT_SERVER))+
               ",\"events\":["+events+"]}\n";
   this.m_bridge.SendLine(text);
  }
 //+------------------------------------------------------------------+
 //| Python is connected (again): the whole history of the terminal;  |
 //| a line is written by its ticket, so what Python has is no harm   |
 //+------------------------------------------------------------------+
 void CTradeHistorySync::OnConnected(void)
  {
   this.m_history.Refresh();
   CArrayObj *list=this.m_history.GetList();
   int total=(list!=NULL ? list.Total() : 0);
   this.m_listed=0;
   if(this.SendRange(0,total))
      this.m_listed=total;
  }
 //+------------------------------------------------------------------+
 //| A trade event of the terminal (OnTrade): only the lines that are |
 //| new are sent (a few before them too: the list is sorted by time) |
 //+------------------------------------------------------------------+
 void CTradeHistorySync::OnTradeEvent(void)
  {
   if(this.m_bridge==NULL || !this.m_bridge.IsReady())
      return;
   this.m_history.Refresh();
   CArrayObj *list=this.m_history.GetList();
   int total=(list!=NULL ? list.Total() : 0);
   if(total==this.m_listed)
      return;
   if(this.SendRange(::MathMax(this.m_listed-TRADE_SYNC_TAIL,0),total))
      this.m_listed=total;
  }
 void CTradeHistorySync::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CUSTOM+ON_PYTHON_CONNECTED && this.m_bridge!=NULL && this.m_bridge.IsReady())
      this.OnConnected();
  }
#endif // __TRADEHISTORYSYNC_MQH__
