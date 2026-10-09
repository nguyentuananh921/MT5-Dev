//+------------------------------------------------------------------+
//|                                                        Order.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/5654                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __ORDER_MQH__
#define __ORDER_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\Defines\TradingDefines.mqh"
 #include "..\..\Services\DELib\CommonDELib.mqh"
 #include "..\..\Services\DELib\TradingDELib.mqh"
 #include "..\..\Entities\Bases\BaseObjExt.mqh"
 #ifndef CORDER_MQH_DECLARATION
 #define CORDER_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Abstract order class                                             |
  //+------------------------------------------------------------------+
  class COrder : public CBaseObjExt
   {
   private:
    ulong             m_ticket;                                    // Selected order/deal ticket (MQL5)
    long              m_long_prop[ORDER_PROP_INTEGER_TOTAL];       // Integer properties
    double            m_double_prop[ORDER_PROP_DOUBLE_TOTAL];      // Real properties
    string            m_string_prop[ORDER_PROP_STRING_TOTAL];      // String properties
    //--- Return the index of the array the order's (1) double and (2) string properties are located at
     int               IndexProp(ENUM_ORDER_PROP_DOUBLE property)      const { return(int)property-ORDER_PROP_INTEGER_TOTAL;                         }
     int               IndexProp(ENUM_ORDER_PROP_STRING property)      const { return(int)property-ORDER_PROP_INTEGER_TOTAL-ORDER_PROP_DOUBLE_TOTAL; }
    //--- Data location in the magic number int value
      //-----------------------------------------------------------
      //  bit   32|31       24|23       16|15        8|7         0|
      //-----------------------------------------------------------
      //  byte    |     3     |     2     |     1     |     0     |
      //-----------------------------------------------------------
      //  data    |   uchar   |   uchar   |         ushort        |
      //-----------------------------------------------------------
      //  descr   |pend req id| id2 | id1 |          magic        |
      //-----------------------------------------------------------
   public:
    //--- Default constructor
      COrder(void){ this.m_type=OBJECT_DE_TYPE_ORDER_DEAL_POSITION; }    
    //--- Protected parametric constructor
      COrder(ENUM_ORDER_STATUS order_status,const ulong ticket);
    //--- Get and return integer properties of a selected order from its parameters
      long              OrderMagicNumber(void)        const;
      long              OrderTicket(void)             const;
      long              OrderTicketFrom(void)         const;
      long              OrderTicketTo(void)           const;
      long              OrderPositionID(void)         const;
      long              OrderPositionByID(void)       const;
      long              OrderOpenTimeMSC(void)        const;
      long              OrderCloseTimeMSC(void)       const;
      long              OrderType(void)               const;
      long              OrderState(void)              const;
      long              OrderTypeByDirection(void)    const;
      long              OrderTypeFilling(void)        const;
      long              OrderTypeTime(void)           const;
      long              OrderReason(void)             const;
      long              DealOrderTicket(void)         const;
      long              DealEntry(void)               const;
      bool              OrderCloseByStopLoss(void)    const;
      bool              OrderCloseByTakeProfit(void)  const;
      datetime          OrderExpiration(void)         const;
      long              PositionTimeUpdateMSC(void)   const;
    //--- Get and return real properties of a selected order from its parameters: (1) open price, (2) close price, (3) profit,
    //---  (4) commission, (5) swap, (6) volume, (7) unexecuted volume (8) StopLoss price, (9) TakeProfit price (10) StopLimit order price
      double            OrderOpenPrice(void)          const;
      double            OrderClosePrice(void)         const;
      double            OrderProfit(void)             const;
      double            OrderCommission(void)         const;
      double            OrderSwap(void)               const;
      double            OrderVolume(void)             const;
      double            OrderVolumeCurrent(void)      const;
      double            OrderStopLoss(void)           const;
      double            OrderTakeProfit(void)         const;
      double            DealFee(void)                 const;
      double            OrderPriceStopLimit(void)     const;
    //--- Get and return string properties of a selected order from its parameters: (1) symbol, (2) comment, (3) ID at an exchange
      string            OrderSymbol(void)             const;
      string            OrderComment(void)            const;
      string            OrderExternalID(void)         const;
    //--- Return (1) reason, (2) direction, (3) deal type
      string            GetReasonDescription(const long reason)            const;
      string            GetEntryDescription(const long deal_entry)         const;
      string            GetTypeDealDescription(const long type_deal)       const;
    //--- Set (1) integer, (2) real and (3) string order property
      void              SetProperty(ENUM_ORDER_PROP_INTEGER property,long value) { this.m_long_prop[property]=value;                               }
      void              SetProperty(ENUM_ORDER_PROP_DOUBLE property,double value){ this.m_double_prop[this.IndexProp(property)]=value;             }
      void              SetProperty(ENUM_ORDER_PROP_STRING property,string value){ this.m_string_prop[this.IndexProp(property)]=value;             }
    //--- Return (1) integer, (2) real and (3) string order properties from the property array
      long              GetProperty(ENUM_ORDER_PROP_INTEGER property)      const { return this.m_long_prop[property];                              }
      double            GetProperty(ENUM_ORDER_PROP_DOUBLE property)       const { return this.m_double_prop[this.IndexProp(property)];            }
      string            GetProperty(ENUM_ORDER_PROP_STRING property)       const { return this.m_string_prop[this.IndexProp(property)];            }
    //--- Return the flag of the order supporting the property
      virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property)        { return true; }
      virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property)         { return true; }
      virtual bool      SupportProperty(ENUM_ORDER_PROP_STRING property)         { return true; }
    //--- Compare COrder objects by all possible properties (to sort the lists by a specified order object property)
      virtual int       Compare(const CObject *node,const int mode=0) const;
    //--- Compare COrder objects by all properties (to search for equal event objects)
      bool              IsEqual(COrder* compared_order) const;
    //+------------------------------------------------------------------+
    //| Methods of a simplified access to the order object properties    |
    //+------------------------------------------------------------------+
    //--- Return (1) ticket, (2) parent order ticket, (3) derived order ticket, (4) magic number, (5) order reason,
    //--- (6) position ID, (7) opposite position ID, (8) first group ID, (9) second group ID,
    //--- (10) pending request ID, (11) magic number ID, (12) type, (13) flag of closing by StopLoss,
    //--- (14) flag of closing by TakeProfit (15) open time, (16) close time,
    //--- (17) order expiration date, (18) state, (19) status, (20) type by direction, (21) execution type by remainder, (22) order lifetime
      long              Ticket(void)                                       const { return this.GetProperty(ORDER_PROP_TICKET);                     }
      long              TicketFrom(void)                                   const { return this.GetProperty(ORDER_PROP_TICKET_FROM);                }
      long              TicketTo(void)                                     const { return this.GetProperty(ORDER_PROP_TICKET_TO);                  }
      long              Magic(void)                                        const { return this.GetProperty(ORDER_PROP_MAGIC);                      }
      long              Reason(void)                                       const { return this.GetProperty(ORDER_PROP_REASON);                     }
      long              PositionID(void)                                   const { return this.GetProperty(ORDER_PROP_POSITION_ID);                }
      long              PositionByID(void)                                 const { return this.GetProperty(ORDER_PROP_POSITION_BY_ID);             }
      long              MagicID(void)                                      const { return this.GetProperty(ORDER_PROP_MAGIC_ID);                   }
      long              GroupID1(void)                                     const { return this.GetProperty(ORDER_PROP_GROUP_ID1);                  }
      long              GroupID2(void)                                     const { return this.GetProperty(ORDER_PROP_GROUP_ID2);                  }
      long              PendReqID(void)                                    const { return this.GetProperty(ORDER_PROP_PEND_REQ_ID);                }
      long              TypeOrder(void)                                    const { return this.GetProperty(ORDER_PROP_TYPE);                       }
      bool              IsCloseByStopLoss(void)                            const { return (bool)this.GetProperty(ORDER_PROP_CLOSE_BY_SL);          }
      bool              IsCloseByTakeProfit(void)                          const { return (bool)this.GetProperty(ORDER_PROP_CLOSE_BY_TP);          }
      long              TimeOpen(void)                                     const { return this.GetProperty(ORDER_PROP_TIME_OPEN);                  }
      long              TimeClose(void)                                    const { return this.GetProperty(ORDER_PROP_TIME_CLOSE);                 }
      datetime          TimeExpiration(void)                               const { return (datetime)this.GetProperty(ORDER_PROP_TIME_EXP);         }
      ENUM_ORDER_STATE  State(void)                                        const { return (ENUM_ORDER_STATE)this.GetProperty(ORDER_PROP_STATE);    }
      ENUM_ORDER_STATUS Status(void)                                       const { return (ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS);  }
      ENUM_ORDER_TYPE   TypeByDirection(void)                              const { return (ENUM_ORDER_TYPE)this.GetProperty(ORDER_PROP_DIRECTION); }
      ENUM_ORDER_TYPE_FILLING TypeFilling(void)                            const { return (ENUM_ORDER_TYPE_FILLING)this.GetProperty(ORDER_PROP_TYPE_FILLING);  }
      ENUM_ORDER_TYPE_TIME TypeTime(void)                                  const { return (ENUM_ORDER_TYPE_TIME)this.GetProperty(ORDER_PROP_TYPE_TIME);        }
   
    //--- Return (1) open price, (2) close price, (3) profit, (4) commission, (5) swap, (6) volume, 
    //--- (7) unexecuted volume (8) StopLoss and (9) TakeProfit, (10) deal fee and (11) StopLimit order price
      double            PriceOpen(void)                                    const { return this.GetProperty(ORDER_PROP_PRICE_OPEN);                 }
      double            PriceClose(void)                                   const { return this.GetProperty(ORDER_PROP_PRICE_CLOSE);                }
      double            Profit(void)                                       const { return this.GetProperty(ORDER_PROP_PROFIT);                     }
      double            Comission(void)                                    const { return this.GetProperty(ORDER_PROP_COMMISSION);                 }
      double            Swap(void)                                         const { return this.GetProperty(ORDER_PROP_SWAP);                       }
      double            Volume(void)                                       const { return this.GetProperty(ORDER_PROP_VOLUME);                     }
      double            VolumeCurrent(void)                                const { return this.GetProperty(ORDER_PROP_VOLUME_CURRENT);             }
      double            StopLoss(void)                                     const { return this.GetProperty(ORDER_PROP_SL);                         }
      double            TakeProfit(void)                                   const { return this.GetProperty(ORDER_PROP_TP);                         }
      double            Fee(void)                                          const { return this.GetProperty(ORDER_PROP_FEE);                        }
      double            PriceStopLimit(void)                               const { return this.GetProperty(ORDER_PROP_PRICE_STOP_LIMIT);           }
   
    //--- Return (1) symbol, (2) comment, (3) ID at an exchange
      string            Symbol(void)                                       const { return this.GetProperty(ORDER_PROP_SYMBOL);                     }
      string            Comment(void)                                      const { return this.GetProperty(ORDER_PROP_COMMENT);                    }
      string            CommentExt(void)                                   const { return this.GetProperty(ORDER_PROP_COMMENT_EXT);                }
      string            ExternalID(void)                                   const { return this.GetProperty(ORDER_PROP_EXT_ID);                     }

    //--- Get the full order profit
      double            ProfitFull(void)                                   const { return this.Profit()+this.Comission()+this.Swap();              }
    //--- Get order profit in points
      int               ProfitInPoints(void) const;
    //--- Set (1) the first group ID, (2) the second group ID, (3) the pending request ID, (4) custom comment
      void              SetGroupID1(const long group_id)                         { this.SetProperty(ORDER_PROP_GROUP_ID1,group_id);                }
      void              SetGroupID2(const long group_id)                         { this.SetProperty(ORDER_PROP_GROUP_ID2,group_id);                }
      void              SetPendReqID(const long req_id)                          { this.SetProperty(ORDER_PROP_PEND_REQ_ID,req_id);                }
      void              SetCommentExt(const string comment_ext)                  { this.SetProperty(ORDER_PROP_COMMENT_EXT,comment_ext);           }
   
    //+------------------------------------------------------------------+
    //| Descriptions of the order object properties                      |
    //+------------------------------------------------------------------+
    //--- Get description of an order's (1) integer, (2) real and (3) string property
      string            GetPropertyDescription(ENUM_ORDER_PROP_INTEGER property);
      string            GetPropertyDescription(ENUM_ORDER_PROP_DOUBLE property);
      string            GetPropertyDescription(ENUM_ORDER_PROP_STRING property);
    //--- Return order status name
      string            StatusDescription(void)    const;
    //--- Return order or position name
      string            TypeDescription(void)      const;
    //--- Return an order state description
      string            StateDescription(void)     const;
    //--- Return the deal direction name
      string            DealEntryDescription(void) const;
    //--- Return order/position direction
      string            DirectionDescription(void) const;
    //--- Display the description of the object properties in the journal (full_prop=true - all properties, false - supported ones only - implemented in descendant classes)
      virtual void      Print(const bool full_prop=false,const bool dash=false);
    //--- Display a short description of the object in the journal
      virtual void      PrintShort(const bool dash=false,const bool symbol=false);
  };
 #endif // CORDER_MQH_DECLARATION
 #ifndef CORDER_MQH_IMPLEMENTATION
 #define CORDER_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Class methods                                                    |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| Closed parametric constructor                                    |
 //+------------------------------------------------------------------+
 COrder::COrder(ENUM_ORDER_STATUS order_status,const ulong ticket)
  {
   //--- Set the object type
    this.m_type=OBJECT_DE_TYPE_ORDER_DEAL_POSITION; 
   //--- Save integer properties
    this.m_ticket=ticket;
    this.m_long_prop[ORDER_PROP_STATUS]                               = order_status;
    this.m_long_prop[ORDER_PROP_MAGIC]                                = this.OrderMagicNumber();
    this.m_long_prop[ORDER_PROP_TICKET]                               = this.OrderTicket();
    this.m_long_prop[ORDER_PROP_TIME_EXP]                             = this.OrderExpiration();
    this.m_long_prop[ORDER_PROP_TYPE_FILLING]                         = this.OrderTypeFilling();
    this.m_long_prop[ORDER_PROP_TYPE_TIME]                            = this.OrderTypeTime();
    this.m_long_prop[ORDER_PROP_TYPE]                                 = this.OrderType();
    this.m_long_prop[ORDER_PROP_STATE]                                = this.OrderState();
    this.m_long_prop[ORDER_PROP_DIRECTION]                            = this.OrderTypeByDirection();
    this.m_long_prop[ORDER_PROP_POSITION_ID]                          = this.OrderPositionID();
    this.m_long_prop[ORDER_PROP_REASON]                               = this.OrderReason();
    this.m_long_prop[ORDER_PROP_DEAL_ORDER_TICKET]                    = this.DealOrderTicket();
    this.m_long_prop[ORDER_PROP_DEAL_ENTRY]                           = this.DealEntry();
    this.m_long_prop[ORDER_PROP_POSITION_BY_ID]                       = this.OrderPositionByID();
    this.m_long_prop[ORDER_PROP_TIME_OPEN]                            = this.OrderOpenTimeMSC();
    this.m_long_prop[ORDER_PROP_TIME_CLOSE]                           = this.OrderCloseTimeMSC();
    this.m_long_prop[ORDER_PROP_TIME_UPDATE]                          = this.PositionTimeUpdateMSC();   
   //--- Save real properties
    this.m_double_prop[this.IndexProp(ORDER_PROP_PRICE_OPEN)]         = this.OrderOpenPrice();
    this.m_double_prop[this.IndexProp(ORDER_PROP_PRICE_CLOSE)]        = this.OrderClosePrice();
    this.m_double_prop[this.IndexProp(ORDER_PROP_PROFIT)]             = this.OrderProfit();
    this.m_double_prop[this.IndexProp(ORDER_PROP_COMMISSION)]         = this.OrderCommission();
    this.m_double_prop[this.IndexProp(ORDER_PROP_SWAP)]               = this.OrderSwap();
    this.m_double_prop[this.IndexProp(ORDER_PROP_VOLUME)]             = this.OrderVolume();
    this.m_double_prop[this.IndexProp(ORDER_PROP_SL)]                 = this.OrderStopLoss();
    this.m_double_prop[this.IndexProp(ORDER_PROP_TP)]                 = this.OrderTakeProfit();
    this.m_double_prop[this.IndexProp(ORDER_PROP_FEE)]                = this.DealFee();
    this.m_double_prop[this.IndexProp(ORDER_PROP_VOLUME_CURRENT)]     = this.OrderVolumeCurrent();
    this.m_double_prop[this.IndexProp(ORDER_PROP_PRICE_STOP_LIMIT)]   = this.OrderPriceStopLimit();
   //--- Save string properties
    this.m_string_prop[this.IndexProp(ORDER_PROP_SYMBOL)]             = this.OrderSymbol();
    this.m_string_prop[this.IndexProp(ORDER_PROP_COMMENT)]            = this.OrderComment();
    this.m_string_prop[this.IndexProp(ORDER_PROP_EXT_ID)]             = this.OrderExternalID();   
   //--- Save additional integer properties
    this.m_long_prop[ORDER_PROP_PROFIT_PT]                            = this.ProfitInPoints();
    this.m_long_prop[ORDER_PROP_TICKET_FROM]                          = this.OrderTicketFrom();
    this.m_long_prop[ORDER_PROP_TICKET_TO]                            = this.OrderTicketTo();
    this.m_long_prop[ORDER_PROP_CLOSE_BY_SL]                          = this.OrderCloseByStopLoss();
    this.m_long_prop[ORDER_PROP_CLOSE_BY_TP]                          = this.OrderCloseByTakeProfit();
    this.m_long_prop[ORDER_PROP_MAGIC_ID]                             = this.GetMagicID((uint)this.GetProperty(ORDER_PROP_MAGIC));
    this.m_long_prop[ORDER_PROP_GROUP_ID1]                            = this.GetGroupID1((uint)this.GetProperty(ORDER_PROP_MAGIC));
    this.m_long_prop[ORDER_PROP_GROUP_ID2]                            = this.GetGroupID2((uint)this.GetProperty(ORDER_PROP_MAGIC));
    this.m_long_prop[ORDER_PROP_PEND_REQ_ID]                          = this.GetPendReqID((uint)this.GetProperty(ORDER_PROP_MAGIC));   
   //--- Save additional real properties
    this.m_double_prop[this.IndexProp(ORDER_PROP_PROFIT_FULL)]        = this.ProfitFull();
   //--- Save additional string properties
    this.m_string_prop[this.IndexProp(ORDER_PROP_COMMENT_EXT)]        = "";
  }
 //+------------------------------------------------------------------+
 //| Compare COrder objects by all possible properties                |
 //+------------------------------------------------------------------+
 int COrder::Compare(const CObject *node,const int mode=0) const
  {
   const COrder *order_compared=node;
    //--- compare integer properties of two orders
    if(mode<ORDER_PROP_INTEGER_TOTAL)
     {
      long value_compared=order_compared.GetProperty((ENUM_ORDER_PROP_INTEGER)mode);
      long value_current=this.GetProperty((ENUM_ORDER_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
    //--- compare real properties of two orders
     else if(mode<ORDER_PROP_DOUBLE_TOTAL+ORDER_PROP_INTEGER_TOTAL)
     {
      double value_compared=order_compared.GetProperty((ENUM_ORDER_PROP_DOUBLE)mode);
      double value_current=this.GetProperty((ENUM_ORDER_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   //--- compare string properties of two orders
   else if(mode<ORDER_PROP_DOUBLE_TOTAL+ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_STRING_TOTAL)
     {
      string value_compared=order_compared.GetProperty((ENUM_ORDER_PROP_STRING)mode);
      string value_current=this.GetProperty((ENUM_ORDER_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| Compare COrder objects by all properties                         |
//+------------------------------------------------------------------+
bool COrder::IsEqual(COrder *compared_order) const
  {
   int begin=0, end=ORDER_PROP_INTEGER_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_ORDER_PROP_INTEGER prop=(ENUM_ORDER_PROP_INTEGER)i;
      if(this.GetProperty(prop)!=compared_order.GetProperty(prop)) return false; 
     }
   begin=end; end+=ORDER_PROP_DOUBLE_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_ORDER_PROP_DOUBLE prop=(ENUM_ORDER_PROP_DOUBLE)i;
      if(this.GetProperty(prop)!=compared_order.GetProperty(prop)) return false; 
     }
   begin=end; end+=ORDER_PROP_STRING_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_ORDER_PROP_STRING prop=(ENUM_ORDER_PROP_STRING)i;
      if(this.GetProperty(prop)!=compared_order.GetProperty(prop)) return false; 
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Integer properties                                               |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Return magic number                                              |
//+------------------------------------------------------------------+
long COrder::OrderMagicNumber(void) const
 {
  #ifdef __MQL4__
   return ::OrderMagicNumber();
  #else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_MAGIC);           break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_MAGIC);                 break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_MAGIC);   break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_MAGIC); break;
      default                             : res=0;                                              break;
     }
   return res;
  #endif
 }
//+------------------------------------------------------------------+
//| Return the ticket                                                |
//+------------------------------------------------------------------+
long COrder::OrderTicket(void) const
 {
   #ifdef __MQL4__
      return ::OrderTicket();
   #else
      long res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
        {
         case ORDER_STATUS_MARKET_POSITION   :
         case ORDER_STATUS_MARKET_ORDER      :
         case ORDER_STATUS_MARKET_PENDING    :
         case ORDER_STATUS_HISTORY_PENDING   :
         case ORDER_STATUS_HISTORY_ORDER     :
         case ORDER_STATUS_DEAL              : res=(long)m_ticket;                                 break;
         default                             : res=0;                                              break;
        }
      return res;
   #endif
  }
//+------------------------------------------------------------------+
//| Return the parent order ticket                                   |
//+------------------------------------------------------------------+
long COrder::OrderTicketFrom(void) const
 {
   long ticket=0;
   #ifdef __MQL4__
      string order_comment=::OrderComment();
      if(::StringFind(order_comment,"from #")>WRONG_VALUE) ticket=::StringToInteger(::StringSubstr(order_comment,6));
   #endif
   return ticket;
 }
//+------------------------------------------------------------------+
//| Return the derived order ticket                                  |
//+------------------------------------------------------------------+
long COrder::OrderTicketTo(void) const
 {
   long ticket=0;
   #ifdef __MQL4__
      string order_comment=::OrderComment();
      if(::StringFind(order_comment,"to #")>WRONG_VALUE) ticket=::StringToInteger(::StringSubstr(order_comment,4));
   #endif
   return ticket;
 }
//+------------------------------------------------------------------+
//| Return position ID                                               |
//+------------------------------------------------------------------+
long COrder::OrderPositionID(void) const
 {
   #ifdef __MQL4__
      return(this.Status()==ORDER_STATUS_MARKET_POSITION ? this.Ticket() : 0);
   #else
      long id=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
        {
         case ORDER_STATUS_MARKET_POSITION   : id=::PositionGetInteger(POSITION_IDENTIFIER);             break;
         case ORDER_STATUS_MARKET_ORDER      :
         case ORDER_STATUS_MARKET_PENDING    : id=::OrderGetInteger(ORDER_POSITION_ID);                  break;
         case ORDER_STATUS_HISTORY_PENDING   :
         case ORDER_STATUS_HISTORY_ORDER     : id=::HistoryOrderGetInteger(m_ticket,ORDER_POSITION_ID);  break;
         case ORDER_STATUS_DEAL              : id=::HistoryDealGetInteger(m_ticket,DEAL_POSITION_ID);    break;
         default                             : id=0;                                                     break;
        }
      return id;
   #endif
 }
//+------------------------------------------------------------------+
//| Return the opposite position ID                                  |
//+------------------------------------------------------------------+
long COrder::OrderPositionByID(void) const
  {  
   long ticket=0;
   #ifdef __MQL4__
      string order_comment=::OrderComment();
      if(::StringFind(order_comment,"close hedge by #")>WRONG_VALUE) ticket=::StringToInteger(::StringSubstr(order_comment,16));
   #else
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
        {
         case ORDER_STATUS_MARKET_ORDER      :
         case ORDER_STATUS_MARKET_PENDING    : ticket=::OrderGetInteger(ORDER_POSITION_BY_ID);                 break;
         case ORDER_STATUS_HISTORY_PENDING   :
         case ORDER_STATUS_HISTORY_ORDER     : ticket=::HistoryOrderGetInteger(m_ticket,ORDER_POSITION_BY_ID); break;
         default                             : ticket=0;                                                       break;
        }
   #endif
   return ticket;
  }
//+------------------------------------------------------------------+
//| Return open time in milliseconds                                 |
//+------------------------------------------------------------------+
long COrder::OrderOpenTimeMSC(void) const
 {
   #ifdef __MQL4__
      return (long)::OrderOpenTime()*1000;
   #else
      long res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
        {
         case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_TIME_MSC);                 break;
         case ORDER_STATUS_MARKET_ORDER      :
         case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TIME_SETUP_MSC);                 break;
         case ORDER_STATUS_HISTORY_PENDING   :
         case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TIME_SETUP_MSC); break;
         case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_TIME_MSC);         break;
         default                             : res=0;                                                       break;
        }
      return res;
   #endif
 }
//+------------------------------------------------------------------+
//| Return close time in milliseconds                                |
//+------------------------------------------------------------------+
long COrder::OrderCloseTimeMSC(void) const
  {  
   #ifdef __MQL4__
      return (long)::OrderCloseTime()*1000;
   #else
      long res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
        {
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TIME_DONE_MSC);     break;
      case ORDER_STATUS_DEAL              : res=(datetime)::HistoryDealGetInteger(m_ticket,DEAL_TIME_MSC);  break;
      default                             : res=0;                                                          break;
     }
   return res;
   #endif
  }
//+------------------------------------------------------------------+
//| Return the type                                                  |
//+------------------------------------------------------------------+
long COrder::OrderType(void) const
 {  
   #ifdef __MQL4__
      return (long)::OrderType();
   #else
      long res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
        {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_TYPE);            break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TYPE);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TYPE);  break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_TYPE);    break;
      default                             : res=0;                                              break;
     }
   return res;
   #endif
 }
//+------------------------------------------------------------------+
//| Return the order state                                           |
//+------------------------------------------------------------------+
long COrder::OrderState(void) const
 {  
   #ifdef __MQL4__
      return(this.Status()==ORDER_STATUS_HISTORY_ORDER ? ORDER_STATE_FILLED : ORDER_STATE_CANCELED);
   #else
      long res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
      {
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_STATE); break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_STATE);                 break;
      case ORDER_STATUS_MARKET_POSITION   : 
      case ORDER_STATUS_DEAL              : 
      default                             : res=0;                                              break;
      }
   return res;
   #endif
 }
//+------------------------------------------------------------------+
//| Return the type by direction                                     |
//+------------------------------------------------------------------+
long COrder::OrderTypeByDirection(void) const
 {
   ENUM_ORDER_STATUS status=(ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS);
   if(status==ORDER_STATUS_MARKET_POSITION)
     {
      return (ENUM_ORDER_TYPE)this.OrderType();
     }
   else if(status==ORDER_STATUS_MARKET_PENDING || status==ORDER_STATUS_HISTORY_PENDING)
     {
      return ENUM_ORDER_TYPE(this.OrderType()%2);
     }
   else if(status==ORDER_STATUS_MARKET_ORDER || status==ORDER_STATUS_HISTORY_ORDER)
     {
      return this.OrderType();
     }
   else if(status==ORDER_STATUS_DEAL)
     {
      return
        (
         (ENUM_DEAL_TYPE)this.TypeOrder()==DEAL_TYPE_BUY ? ORDER_TYPE_BUY   :
         (ENUM_DEAL_TYPE)this.TypeOrder()==DEAL_TYPE_SELL ? ORDER_TYPE_SELL : WRONG_VALUE
        );
     }
   return WRONG_VALUE;
 }
//+------------------------------------------------------------------+
//| Return execution type by residue                                 |
//+------------------------------------------------------------------+
long COrder::OrderTypeFilling(void) const
 {  
   #ifdef __MQL4__
      return (long)ORDER_FILLING_RETURN;
   #else 
      long res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
       {
         case ORDER_STATUS_MARKET_ORDER      :
         case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TYPE_FILLING);                break;
         case ORDER_STATUS_HISTORY_PENDING   :
         case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TYPE_FILLING);break;
         default                             : res=0;                                                    break;
       }
   return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return order lifetime                                            |
//+------------------------------------------------------------------+
long COrder::OrderTypeTime(void) const
 {  
   #ifdef __MQL4__
      return (long)ORDER_TIME_GTC;
   #else 
      long res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
      {
         case ORDER_STATUS_MARKET_ORDER      :
         case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TYPE_TIME);                break;
         case ORDER_STATUS_HISTORY_PENDING   :
         case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TYPE_TIME);break;
         default                             : res=0;                                                 break;
      }
   return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Order reason or source                                           |
//+------------------------------------------------------------------+
long COrder::OrderReason(void) const
 {
   #ifdef __MQL4__
      return
      (
         this.TypeOrder()==ORDER_TYPE_BALANCE   ?  ORDER_REASON_BALANCE :
         this.TypeOrder()==ORDER_TYPE_CREDIT    ?  ORDER_REASON_CREDIT  :
         this.OrderCloseByStopLoss()            ?  ORDER_REASON_SL      :
         this.OrderCloseByTakeProfit()          ?  ORDER_REASON_TP      :  
         this.OrderMagicNumber()!=0             ?  ORDER_REASON_EXPERT  : WRONG_VALUE
      );
   #else 
      long res=WRONG_VALUE;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
      {
         case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_REASON);          break;
         case ORDER_STATUS_MARKET_ORDER      :
         case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_REASON);                break;
         case ORDER_STATUS_HISTORY_PENDING   :
         case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_REASON);break;
         case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_REASON);  break;
         default                             : res=WRONG_VALUE;                                    break;
      }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Ticket of the order that triggered a deal                        |
//+------------------------------------------------------------------+
long COrder::DealOrderTicket(void) const
 {
   #ifdef __MQL4__
      return ::OrderTicket();
   #else 
      long res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
      {
         case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_IDENTIFIER);            break;
         case ORDER_STATUS_MARKET_ORDER      :
         case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_POSITION_ID);                 break;
         case ORDER_STATUS_HISTORY_PENDING   :
         case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_POSITION_ID); break;
         case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_ORDER);         break;
         default                             : res=0;                                                    break;
      }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Deal direction IN, OUT, IN/OUT                                   |
//+------------------------------------------------------------------+
long COrder::DealEntry(void) const
 {
   #ifdef __MQL4__
      return ::OrderType();
   #else 
      long res=WRONG_VALUE;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
      {
         case ORDER_STATUS_DEAL  : res=::HistoryDealGetInteger(m_ticket,DEAL_ENTRY);break;
         default                 : res=WRONG_VALUE;                                 break;
      }
      return res; 
   #endif 
 }
//+------------------------------------------------------------------+
//| Return the flag of closing a position by StopLoss                |
//+------------------------------------------------------------------+
bool COrder::OrderCloseByStopLoss(void) const
 {
   #ifdef __MQL4__
      return(::StringFind(::OrderComment(),"[sl")>WRONG_VALUE);
   #else 
      return
     (
      this.Status()==ORDER_STATUS_MARKET_ORDER  ? this.OrderReason()==ORDER_REASON_SL :
      this.Status()==ORDER_STATUS_HISTORY_ORDER ? this.OrderReason()==ORDER_REASON_SL : 
      this.Status()==ORDER_STATUS_DEAL ? this.OrderReason()==DEAL_REASON_SL : false
     );
   #endif 
 }
//+------------------------------------------------------------------+
//| Return the flag of closing position by TakeProfit                |
//+------------------------------------------------------------------+
bool COrder::OrderCloseByTakeProfit(void) const
 {
   #ifdef __MQL4__
      return(::StringFind(::OrderComment(),"[tp")>WRONG_VALUE);
   #else 
      return
     (
      this.Status()==ORDER_STATUS_MARKET_ORDER  ? this.OrderReason()==ORDER_REASON_TP : 
      this.Status()==ORDER_STATUS_HISTORY_ORDER ? this.OrderReason()==ORDER_REASON_TP : 
      this.Status()==ORDER_STATUS_DEAL ? this.OrderReason()==DEAL_REASON_TP : false
     );
   #endif 
 }
//+------------------------------------------------------------------+
//| Return expiration time                                           |
//+------------------------------------------------------------------+
datetime COrder::OrderExpiration(void) const
 {
   #ifdef __MQL4__
      return ::OrderExpiration();
   #else 
      datetime res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=(datetime)::OrderGetInteger(ORDER_TIME_EXPIRATION);                  break;
      case ORDER_STATUS_HISTORY_PENDING   : res=(datetime)::HistoryOrderGetInteger(m_ticket,ORDER_TIME_EXPIRATION);  break;
      default                             : res=0;                                                                   break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Position changing time in milliseconds                           |
//+------------------------------------------------------------------+
long COrder::PositionTimeUpdateMSC(void) const
 {
   #ifdef __MQL4__
      return 0;
   #else 
      datetime res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=(datetime)::PositionGetInteger(POSITION_TIME_UPDATE); break;
      default                             : res=0;                                                    break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Real properties                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Return open price                                                |
//+------------------------------------------------------------------+
double COrder::OrderOpenPrice(void) const
 {
   #ifdef __MQL4__
      return ::OrderOpenPrice();
   #else 
      double res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_PRICE_OPEN);          break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_PRICE_OPEN);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_PRICE_OPEN);break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_PRICE);       break;
      default                             : res=0;                                                 break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return close price                                               |
//+------------------------------------------------------------------+
double COrder::OrderClosePrice(void) const
 {
   #ifdef __MQL4__
      return ::OrderClosePrice();
   #else 
      double res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_PRICE_OPEN);break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_PRICE);       break;
      default                             : res=0;                                                 break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return profit                                                    |
//+------------------------------------------------------------------+
double COrder::OrderProfit(void) const
 {
   #ifdef __MQL4__
      return ::OrderProfit();
   #else 
      double res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_PROFIT);           break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_PROFIT);   break;
      default                             : res=0;                                              break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return commission                                                |
//+------------------------------------------------------------------+
double COrder::OrderCommission(void) const
 {
   #ifdef __MQL4__
      return ::OrderCommission();
   #else 
      double res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_DEAL  : res=::HistoryDealGetDouble(m_ticket,DEAL_COMMISSION);  break;
      default                 : res=0;                                                 break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return swap                                                      |
//+------------------------------------------------------------------+
double COrder::OrderSwap(void) const
 {
   #ifdef __MQL4__
      return ::OrderSwap();
   #else 
      double res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_SWAP);          break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_SWAP);  break;
      default                             : res=0;                                           break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return volume                                                    |
//+------------------------------------------------------------------+
double COrder::OrderVolume(void) const
 {
   #ifdef __MQL4__
      return ::OrderLots();
   #else 
      double res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_VOLUME);                    break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_VOLUME_INITIAL);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_VOLUME_INITIAL);  break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_VOLUME);            break;
      default                             : res=0;                                                       break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return unexecuted volume                                         |
//+------------------------------------------------------------------+
double COrder::OrderVolumeCurrent(void) const
 {
   #ifdef __MQL4__
      return(this.Status()==ORDER_STATUS_HISTORY_PENDING ? ::OrderLots() : 0);
   #else 
      double res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_VOLUME_CURRENT);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_VOLUME_CURRENT);  break;
      default                             : res=0;                                                       break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return StopLoss price                                            |
//+------------------------------------------------------------------+
double COrder::OrderStopLoss(void) const
 {
   #ifdef __MQL4__
      return ::OrderStopLoss();
   #else 
      double res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_SL);            break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_SL);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_SL);  break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_SL);    break;
      default                             : res=0;                                           break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return TakeProfit price                                          |
//+------------------------------------------------------------------+
double COrder::OrderTakeProfit(void) const
 {
   #ifdef __MQL4__
      return ::OrderTakeProfit();
   #else 
      double res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_TP);            break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_TP);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_TP);  break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_TP);    break;
      default                             : res=0;                                           break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return the deal fee                                              |
//+------------------------------------------------------------------+
double COrder::DealFee(void) const
 {  
   #ifdef __MQL4__
      return 0;
   #else 
      return ::HistoryDealGetDouble(m_ticket,DEAL_FEE);
   #endif 
 }
//+------------------------------------------------------------------+
//| Return Limit order price                                         |
//| when StopLimit order is activated                                |
//+------------------------------------------------------------------+
double COrder::OrderPriceStopLimit(void) const
 {
   #ifdef __MQL4__
      return 0;
   #else 
      double res=0;
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_PRICE_STOPLIMIT);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_PRICE_STOPLIMIT); break;
      default                             : res=0;                                                       break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| String properties                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Return symbol                                                    |
//+------------------------------------------------------------------+
string COrder::OrderSymbol(void) const
 {
   #ifdef __MQL4__
      return ::OrderSymbol();
   #else 
      string res="";
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetString(POSITION_SYMBOL);           break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetString(ORDER_SYMBOL);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetString(m_ticket,ORDER_SYMBOL); break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetString(m_ticket,DEAL_SYMBOL);   break;
      default                             : res="";                                             break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return comment                                                   |
//+------------------------------------------------------------------+
string COrder::OrderComment(void) const
 {  
   #ifdef __MQL4__
      return ::OrderComment();
   #else 
      string res="";
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetString(POSITION_COMMENT);          break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetString(ORDER_COMMENT);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetString(m_ticket,ORDER_COMMENT);break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetString(m_ticket,DEAL_COMMENT);  break;
      default                             : res="";                                             break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return ID used by an exchange                                    |
//+------------------------------------------------------------------+
string COrder::OrderExternalID(void) const
 {  
   #ifdef __MQL4__
      return "";
   #else 
      string res="";
      switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetString(ORDER_EXTERNAL_ID);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetString(m_ticket,ORDER_EXTERNAL_ID);  break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetString(m_ticket,DEAL_EXTERNAL_ID);    break;
      default                             : res="";                                                   break;
     }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Get order profit in points                                       |
//+------------------------------------------------------------------+
int COrder::ProfitInPoints(void) const
 {
   MqlTick tick={0};
   string symbol=this.Symbol();
   if(!::SymbolInfoTick(symbol,tick))
      return 0;
   ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)this.TypeOrder();
   double point=::SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(type==ORDER_TYPE_CLOSE_BY || point==0) return 0;
   if(this.Status()==ORDER_STATUS_HISTORY_ORDER)
      return int(type==ORDER_TYPE_BUY ? (::round(this.PriceClose()-this.PriceOpen())/point) : type==ORDER_TYPE_SELL ? ::round((this.PriceOpen()-this.PriceClose())/point) : 0);
   else if(this.Status()==ORDER_STATUS_MARKET_POSITION)
     {
      if(type==ORDER_TYPE_BUY)
         return (int)::round((tick.bid-this.PriceOpen())/point);
      else if(type==ORDER_TYPE_SELL)
         return (int)::round((this.PriceOpen()-tick.ask)/point);
     }
   else if(this.Status()==ORDER_STATUS_MARKET_PENDING)
     {
      if(type==ORDER_TYPE_BUY_LIMIT || type==ORDER_TYPE_BUY_STOP || type==ORDER_TYPE_BUY_STOP_LIMIT)
         return (int)fabs(::round((tick.bid-this.PriceOpen())/point));
      else if(type==ORDER_TYPE_SELL_LIMIT || type==ORDER_TYPE_SELL_STOP || type==ORDER_TYPE_SELL_STOP_LIMIT)
         return (int)fabs(::round((this.PriceOpen()-tick.ask)/point));
     }
   return 0;
 }
//+------------------------------------------------------------------+
//| Reason                                                           |
//+------------------------------------------------------------------+
string COrder::GetReasonDescription(const long reason) const
 {  
   #ifdef __MQL4__
      return
        (
         this.IsCloseByStopLoss()            ?  CMessage::Text(MSG_ORD_SL_ACTIVATED)                        :
         this.IsCloseByTakeProfit()          ?  CMessage::Text(MSG_ORD_TP_ACTIVATED)                        :
         this.Reason()==ORDER_REASON_EXPERT  ?  CMessage::Text(MSG_ORD_PLACED_FROM_MQL4)                    :
         this.Comment()=="cancelled"         ?  CMessage::Text(MSG_ORD_STATE_CANCELLED)                     :
         this.Reason()==ORDER_REASON_BALANCE ?  (
                                              this.Profit()>0 ? CMessage::Text(MSG_EVN_BALANCE_REFILL)   :
                                              CMessage::Text(MSG_EVN_BALANCE_WITHDRAWAL)
                                             )                                                           :
         this.Reason()==ORDER_REASON_CREDIT  ?  (
                                              this.Profit()>0 ? CMessage::Text(MSG_EVN_ACCOUNT_CREDIT)   :
                                              CMessage::Text(MSG_EVN_ACCOUNT_CREDIT_WITHDRAWAL)
                                             )                                                           :
         CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4)
        );
   #else 
   string res="";
   switch(this.Status())
     {
      case ORDER_STATUS_MARKET_POSITION      : 
         res=
           (
            reason==POSITION_REASON_CLIENT   ?  CMessage::Text(MSG_ORD_REASON_POS_CLIENT)    :
            reason==POSITION_REASON_MOBILE   ?  CMessage::Text(MSG_ORD_REASON_POS_MOBILE)    :
            reason==POSITION_REASON_WEB      ?  CMessage::Text(MSG_ORD_REASON_POS_WEB)       :
            reason==POSITION_REASON_EXPERT   ?  CMessage::Text(MSG_ORD_REASON_POS_EXPERT)    : ""
           );
         break;
      case ORDER_STATUS_MARKET_ORDER         :
      case ORDER_STATUS_MARKET_PENDING       :
      case ORDER_STATUS_HISTORY_PENDING      : 
      case ORDER_STATUS_HISTORY_ORDER        : 
         res=
           (
            reason==ORDER_REASON_CLIENT      ?  CMessage::Text(MSG_ORD_REASON_CLIENT)        :
            reason==ORDER_REASON_MOBILE      ?  CMessage::Text(MSG_ORD_REASON_MOBILE)        :
            reason==ORDER_REASON_WEB         ?  CMessage::Text(MSG_ORD_REASON_WEB)           :
            reason==ORDER_REASON_EXPERT      ?  CMessage::Text(MSG_ORD_REASON_EXPERT)        :
            reason==ORDER_REASON_SL          ?  CMessage::Text(MSG_ORD_SL_ACTIVATED)         :
            reason==ORDER_REASON_TP          ?  CMessage::Text(MSG_ORD_TP_ACTIVATED)         :
            reason==ORDER_REASON_SO          ?  CMessage::Text(MSG_ORD_REASON_SO)            : ""
           );
         break;
      case ORDER_STATUS_DEAL                 : 
         res=
           (
            reason==DEAL_REASON_CLIENT       ?  CMessage::Text(MSG_ORD_REASON_DEAL_CLIENT)   :
            reason==DEAL_REASON_MOBILE       ?  CMessage::Text(MSG_ORD_REASON_DEAL_MOBILE)   :
            reason==DEAL_REASON_WEB          ?  CMessage::Text(MSG_ORD_REASON_DEAL_WEB)      :
            reason==DEAL_REASON_EXPERT       ?  CMessage::Text(MSG_ORD_REASON_DEAL_EXPERT)   :
            reason==DEAL_REASON_SL           ?  CMessage::Text(MSG_ORD_SL_ACTIVATED)         :
            reason==DEAL_REASON_TP           ?  CMessage::Text(MSG_ORD_TP_ACTIVATED)         :
            reason==DEAL_REASON_SO           ?  CMessage::Text(MSG_ORD_REASON_DEAL_STOPOUT)  :
            reason==DEAL_REASON_ROLLOVER     ?  CMessage::Text(MSG_ORD_REASON_DEAL_ROLLOVER) :
            reason==DEAL_REASON_VMARGIN      ?  CMessage::Text(MSG_ORD_REASON_DEAL_VMARGIN)  :
            reason==DEAL_REASON_SPLIT        ?  CMessage::Text(MSG_ORD_REASON_DEAL_SPLIT)    : ""
           );
         break;
      default                                : res="";   break;
     }
    return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Deal direction description                                       |
//+------------------------------------------------------------------+
string COrder::GetEntryDescription(const long deal_entry) const
 { 
   #ifdef __MQL4__
      return CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4);
   #else 
      string res="";
      switch(this.Status())
      {
      case ORDER_STATUS_MARKET_POSITION   : 
         res=CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_POSITION); 
         break;
      case ORDER_STATUS_MARKET_PENDING    :
      case ORDER_STATUS_HISTORY_PENDING   : 
         res=CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_PENDING); 
         break;
      case ORDER_STATUS_MARKET_ORDER      :
         res=CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MARKET); 
         break;
      case ORDER_STATUS_HISTORY_ORDER     : 
         res=CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MARKET_HIST); 
         break;
      case ORDER_STATUS_DEAL              : 
         res=
           (
            deal_entry==DEAL_ENTRY_IN     ?  CMessage::Text(MSG_ORD_DEAL_IN)     :
            deal_entry==DEAL_ENTRY_OUT    ?  CMessage::Text(MSG_ORD_DEAL_OUT)    :
            deal_entry==DEAL_ENTRY_INOUT  ?  CMessage::Text(MSG_ORD_DEAL_INOUT)  :
            deal_entry==DEAL_ENTRY_OUT_BY ?  CMessage::Text(MSG_ORD_DEAL_OUT_BY) : ""
           );
         break;
      default                             : res=""; break;
      }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return deal type name                                            |
//+------------------------------------------------------------------+
string COrder::GetTypeDealDescription(const long deal_type) const
 {
   #ifdef __MQL4__
      return CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4);
   #else 
      string res="";
      switch(this.Status())
       {
         case ORDER_STATUS_DEAL              : 
            res=DealTypeDescription((ENUM_DEAL_TYPE)deal_type);
            break;
         case ORDER_STATUS_MARKET_POSITION   : 
            res=CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_POSITION); 
            break;
         case ORDER_STATUS_MARKET_PENDING    :
         case ORDER_STATUS_HISTORY_PENDING   : 
            res=CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_PENDING); 
            break;
         case ORDER_STATUS_MARKET_ORDER      :
            res=CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MARKET); 
            break;
         case ORDER_STATUS_HISTORY_ORDER     : 
            res=CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MARKET_HIST); 
            break;
         default  : res=""; break;
       }
      return res;
   #endif 
 }
//+------------------------------------------------------------------+
//| Return the order status name                                     |
//+------------------------------------------------------------------+
string COrder::StatusDescription(void) const
 {
   ENUM_ORDER_STATUS status=this.Status();
   ENUM_ORDER_TYPE   type=(ENUM_ORDER_TYPE)this.TypeOrder();
   return
     (
      status==ORDER_STATUS_BALANCE           ?  CMessage::Text(MSG_LIB_PROP_BALANCE)   :
      #ifdef __MQL5__
      status==ORDER_STATUS_MARKET_ORDER || status==ORDER_STATUS_HISTORY_ORDER ?  
         (
          type==ORDER_TYPE_BUY   ?  CMessage::Text(MSG_ORD_TO_BUY)  : 
          type==ORDER_TYPE_SELL  ?  CMessage::Text(MSG_ORD_TO_SELL) :
          CMessage::Text(MSG_ORD_CLOSE_BY)
         ) :
      #else 
      status==ORDER_STATUS_HISTORY_ORDER     ?  CMessage::Text(MSG_ORD_HISTORY)        :
      #endif 
      status==ORDER_STATUS_DEAL              ?  CMessage::Text(MSG_ORD_DEAL)           :
      status==ORDER_STATUS_MARKET_POSITION   ?  CMessage::Text(MSG_ORD_POSITION)       :
      status==ORDER_STATUS_MARKET_PENDING    ?  CMessage::Text(MSG_ORD_PENDING_ACTIVE) :
      status==ORDER_STATUS_HISTORY_PENDING   ?  CMessage::Text(MSG_ORD_PENDING)        :
      ::EnumToString(status)
     );
 }
//+------------------------------------------------------------------+
//| Return order or position name                                    |
//+------------------------------------------------------------------+
string COrder::TypeDescription(void) const
  {
   return
     (
      this.Status()==ORDER_STATUS_DEAL ? this.GetTypeDealDescription(this.TypeOrder()) :
      this.Status()==ORDER_STATUS_MARKET_POSITION ? this.DirectionDescription() :
      OrderTypeDescription((ENUM_ORDER_TYPE)this.TypeOrder())
     );
  }
//+------------------------------------------------------------------+
//| Return an order state description                                |
//+------------------------------------------------------------------+
string COrder::StateDescription(void) const
  {
   if(this.Status()==ORDER_STATUS_DEAL || this.Status()==ORDER_STATUS_MARKET_POSITION)
      return "";
   else switch(this.State())
     {
      case ORDER_STATE_STARTED         :  return CMessage::Text(MSG_ORD_STATE_STARTED);
      case ORDER_STATE_PLACED          :  return CMessage::Text(MSG_ORD_STATE_PLACED);
      case ORDER_STATE_CANCELED        :  return #ifdef __MQL5__ CMessage::Text(MSG_ORD_STATE_CANCELLED_CLIENT) #else CMessage::Text(MSG_ORD_STATE_CANCELLED) #endif ;
      case ORDER_STATE_PARTIAL         :  return CMessage::Text(MSG_ORD_STATE_PARTIAL);
      case ORDER_STATE_FILLED          :  return CMessage::Text(MSG_ORD_STATE_FILLED);
      case ORDER_STATE_REJECTED        :  return CMessage::Text(MSG_ORD_STATE_REJECTED);
      case ORDER_STATE_EXPIRED         :  return CMessage::Text(MSG_ORD_STATE_EXPIRED);
      case ORDER_STATE_REQUEST_ADD     :  return CMessage::Text(MSG_ORD_STATE_REQUEST_ADD);
      case ORDER_STATE_REQUEST_MODIFY  :  return CMessage::Text(MSG_ORD_STATE_REQUEST_MODIFY);
      case ORDER_STATE_REQUEST_CANCEL  :  return CMessage::Text(MSG_ORD_STATE_REQUEST_CANCEL);
      default                          :  return CMessage::Text(MSG_ORD_STATE_UNKNOWN);
     }
  }
//+------------------------------------------------------------------+
//| Return deal direction name                                       |
//+------------------------------------------------------------------+
string COrder::DealEntryDescription(void) const
  {
   return(this.Status()==ORDER_STATUS_DEAL ? this.GetEntryDescription(this.GetProperty(ORDER_PROP_DEAL_ENTRY)) : "");
  }
//+------------------------------------------------------------------+
//| Return order/position direction type                             |
//+------------------------------------------------------------------+
string COrder::DirectionDescription(void) const
  {
   if(this.Status()==ORDER_STATUS_DEAL)
      return 
        (
         this.OrderType()==DEAL_TYPE_BALANCE ? 
           (
            this.OrderProfit()>0 ? CMessage::Text(MSG_EVN_BALANCE_REFILL)  : 
            CMessage::Text(MSG_EVN_BALANCE_WITHDRAWAL)
           )                                          :
         this.OrderType()==DEAL_TYPE_BUY     ? "Buy"  : 
         this.OrderType()==DEAL_TYPE_SELL    ? "Sell" :
         this.TypeDescription()
        );
   switch(this.TypeByDirection())
     {
      case ORDER_TYPE_BUY  :  return "Buy";
      case ORDER_TYPE_SELL :  return "Sell";
      default              :  return CMessage::Text(MSG_ORD_UNKNOWN_TYPE);
     }
  }
//+------------------------------------------------------------------+
//| Send order properties to the journal                             |
//+------------------------------------------------------------------+
void COrder::Print(const bool full_prop=false,const bool dash=false)
  {
   ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_BEG),": \"",this.StatusDescription(),"\" =============");
   int begin=0, end=ORDER_PROP_INTEGER_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_ORDER_PROP_INTEGER prop=(ENUM_ORDER_PROP_INTEGER)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   begin=end; end+=ORDER_PROP_DOUBLE_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_ORDER_PROP_DOUBLE prop=(ENUM_ORDER_PROP_DOUBLE)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   begin=end; end+=ORDER_PROP_STRING_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_ORDER_PROP_STRING prop=(ENUM_ORDER_PROP_STRING)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("================== ",CMessage::Text(MSG_LIB_PARAMS_LIST_END),": \"",this.StatusDescription(),"\" ==================\n");
  }
//+------------------------------------------------------------------+
//| Return description of an order's integer property                |
//+------------------------------------------------------------------+
string COrder::GetPropertyDescription(ENUM_ORDER_PROP_INTEGER property)
  {
   return
     (
   //--- General properties
      property==ORDER_PROP_MAGIC             ?  CMessage::Text(MSG_ORD_MAGIC)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TICKET            ?  CMessage::Text(MSG_ORD_TICKET)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          " #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TICKET_FROM       ?  CMessage::Text(MSG_ORD_TICKET_FROM)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          " #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TICKET_TO         ?  CMessage::Text(MSG_ORD_TICKET_TO)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          " #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TIME_EXP          ?  CMessage::Text(MSG_ORD_TIME_EXP)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          (this.GetProperty(property)==0     ?  CMessage::Text(MSG_LIB_PROP_NOT_SET)            :
          ": "+::TimeToString(this.GetProperty(property),TIME_DATE|TIME_MINUTES|TIME_SECONDS))
         )  :
      property==ORDER_PROP_TYPE_FILLING      ?  CMessage::Text(MSG_ORD_TYPE_FILLING)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+OrderTypeFillingDescription((ENUM_ORDER_TYPE_FILLING)this.GetProperty(property))
         )  :
      property==ORDER_PROP_TYPE_TIME         ?  CMessage::Text(MSG_ORD_TYPE_TIME)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+OrderTypeTimeDescription((ENUM_ORDER_TYPE_TIME)this.GetProperty(property))
         )  :
      property==ORDER_PROP_TYPE              ?  CMessage::Text(MSG_ORD_TYPE)+": "+this.TypeDescription()   :
      property==ORDER_PROP_DIRECTION         ?  CMessage::Text(MSG_ORD_TYPE_BY_DIRECTION)+": "+this.DirectionDescription() :
      
      property==ORDER_PROP_REASON            ?  CMessage::Text(MSG_ORD_REASON)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetReasonDescription(this.GetProperty(property))
         )  :
      property==ORDER_PROP_POSITION_ID       ?  CMessage::Text(MSG_ORD_POSITION_ID)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_DEAL_ORDER_TICKET ?  CMessage::Text(MSG_ORD_DEAL_ORDER_TICKET)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_DEAL_ENTRY        ?  CMessage::Text(MSG_ORD_DEAL_ENTRY)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetEntryDescription(this.GetProperty(property))
         )  :
      property==ORDER_PROP_POSITION_BY_ID    ?  CMessage::Text(MSG_ORD_POSITION_BY_ID)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TIME_OPEN         ?  CMessage::Text(MSG_ORD_TIME_OPEN)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+TimeMSCtoString(this.GetProperty(property))+" ("+(string)this.GetProperty(property)+")"
         )  :
      property==ORDER_PROP_TIME_CLOSE        ?  CMessage::Text(MSG_ORD_TIME_CLOSE)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+TimeMSCtoString(this.GetProperty(property))+" ("+(string)this.GetProperty(property)+")"
         )  :
      property==ORDER_PROP_TIME_UPDATE       ?  CMessage::Text(MSG_ORD_TIME_UPDATE)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)!=0 ? TimeMSCtoString(this.GetProperty(property))+" ("+(string)this.GetProperty(property)+")" : "0")
         )  :
      property==ORDER_PROP_STATE             ?  CMessage::Text(MSG_ORD_STATE)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": \""+this.StateDescription()+"\""
         )  :
   //--- Additional property
      property==ORDER_PROP_STATUS            ?  CMessage::Text(MSG_ORD_STATUS)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": \""+this.StatusDescription()+"\""
         )  :
      property==ORDER_PROP_PROFIT_PT         ?  (
                                                 this.Status()==ORDER_STATUS_MARKET_PENDING ? 
                                                 CMessage::Text(MSG_ORD_DISTANCE_PT)  : 
                                                 CMessage::Text(MSG_ORD_PROFIT_PT)
                                                )+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_CLOSE_BY_SL       ?  CMessage::Text(MSG_LIB_PROP_CLOSE_BY_SL)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)   ?  CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==ORDER_PROP_CLOSE_BY_TP       ?  CMessage::Text(MSG_LIB_PROP_CLOSE_BY_TP)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)   ?  CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==ORDER_PROP_MAGIC_ID          ?  CMessage::Text(MSG_ORD_MAGIC_ID)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_GROUP_ID1         ?  CMessage::Text(MSG_ORD_GROUP_ID1)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_GROUP_ID2         ?  CMessage::Text(MSG_ORD_GROUP_ID2)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_PEND_REQ_ID       ?  CMessage::Text(MSG_ORD_PEND_REQ_ID)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      ""
     );
  }
//+------------------------------------------------------------------+
//| Return description of order's real property                      |
//+------------------------------------------------------------------+
string COrder::GetPropertyDescription(ENUM_ORDER_PROP_DOUBLE property)
  {
   int dg=(int)::SymbolInfoInteger(this.GetProperty(ORDER_PROP_SYMBOL),SYMBOL_DIGITS);
   int dgl=(int)DigitsLots(this.GetProperty(ORDER_PROP_SYMBOL));
   return
     (
      //--- General properties
      property==ORDER_PROP_PRICE_CLOSE       ?  CMessage::Text(MSG_ORD_PRICE_CLOSE)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==ORDER_PROP_PRICE_OPEN        ?  CMessage::Text(MSG_ORD_PRICE_OPEN)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==ORDER_PROP_SL                ?  CMessage::Text(MSG_LIB_PROP_PRICE_SL)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          (this.GetProperty(property)==0     ?  CMessage::Text(MSG_LIB_PROP_EMPTY) : ": "+::DoubleToString(this.GetProperty(property),dg))
         )  :
      property==ORDER_PROP_TP                ?  CMessage::Text(MSG_LIB_PROP_PRICE_TP)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          (this.GetProperty(property)==0     ?  CMessage::Text(MSG_LIB_PROP_EMPTY) : ": "+::DoubleToString(this.GetProperty(property),dg))
         )  :
      property==ORDER_PROP_FEE               ?  CMessage::Text(MSG_LIB_PROP_DEAL_FEE)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          (this.GetProperty(property)==0     ?  CMessage::Text(MSG_LIB_PROP_EMPTY) : ": "+::DoubleToString(this.GetProperty(property),dg))
         )  :
      property==ORDER_PROP_PROFIT            ?  CMessage::Text(MSG_LIB_PROP_PROFIT)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==ORDER_PROP_COMMISSION        ?  CMessage::Text(MSG_ORD_COMMISSION)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==ORDER_PROP_SWAP              ?  CMessage::Text(MSG_ORD_SWAP)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==ORDER_PROP_VOLUME            ?  CMessage::Text(MSG_ORD_VOLUME)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dgl)
          ) :
      property==ORDER_PROP_VOLUME_CURRENT    ?  CMessage::Text(MSG_ORD_VOLUME_CURRENT)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dgl)
          ) :
      property==ORDER_PROP_PRICE_STOP_LIMIT  ?  CMessage::Text(MSG_ORD_PRICE_STOP_LIMIT)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
          ) :
      //--- Additional property
      property==ORDER_PROP_PROFIT_FULL       ?  CMessage::Text(MSG_ORD_PROFIT_FULL)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),2)
          ) :
      ""
     );
  }
//+------------------------------------------------------------------+
//| Return description of the order's string property                |
//+------------------------------------------------------------------+
string COrder::GetPropertyDescription(ENUM_ORDER_PROP_STRING property)
  {
   return
     (
      property==ORDER_PROP_SYMBOL         ?  CMessage::Text(MSG_LIB_PROP_SYMBOL)+": \""+this.GetProperty(property)+"\""          :
      property==ORDER_PROP_COMMENT        ?  CMessage::Text(MSG_ORD_COMMENT)+
         (this.GetProperty(property)==""  ?  ": "+CMessage::Text(MSG_LIB_PROP_EMPTY) : ": \""+this.GetProperty(property)+"\"")   :
      property==ORDER_PROP_COMMENT_EXT    ?  CMessage::Text(MSG_ORD_COMMENT_EXT)+
         (this.GetProperty(property)==""  ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SET) : ": \""+this.GetProperty(property)+"\"") :
      property==ORDER_PROP_EXT_ID         ?  CMessage::Text(MSG_ORD_EXT_ID)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED)   :
         (this.GetProperty(property)==""  ?  CMessage::Text(MSG_LIB_PROP_EMPTY) : ": \""+this.GetProperty(property)+"\""))       :
      ""
     );
  }
//+------------------------------------------------------------------+

 #endif // CORDER_MQH_IMPLEMENTATION
#endif // __ORDER_MQH__