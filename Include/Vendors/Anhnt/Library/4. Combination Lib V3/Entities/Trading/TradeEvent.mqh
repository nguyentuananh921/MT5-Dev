//+------------------------------------------------------------------+
//|                                                    TradeEvent.mqh|
//|                                       Modify name from Event.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/6211                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
 //+------------------------------------------------------------------+
 //| Abstract event class modify name TradeEvent from Event.mqh       |
 //+------------------------------------------------------------------+
#ifndef CTRADEEVENT_MQH
#define CTRADEEVENT_MQH
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include <Object.mqh>
 #include "..\Defines\CommonDefines.mqh" 
 #include "..\Defines\TradingDefines.mqh"
 #include "..\..\Services\Message\Message.mqh"
 #include "..\..\Services\DELib\CommonDELib.mqh"
 #include "..\..\Services\DELib\TradingDELib.mqh"
#ifndef CTRADEEVENT_MQH_DECLARATION
#define CTRADEEVENT_MQH_DECLARATION
class CTradeEvent : public CObject
  {
   private:
      int               m_event_code;                                   // Event code
      //--- Return the index of the array the event's (1) double and (2) string properties are located at
      int               IndexProp(ENUM_EVENT_PROP_DOUBLE property)const { return(int)property-EVENT_PROP_INTEGER_TOTAL;                         }
      int               IndexProp(ENUM_EVENT_PROP_STRING property)const { return(int)property-EVENT_PROP_INTEGER_TOTAL-EVENT_PROP_DOUBLE_TOTAL; }
   protected:
      ENUM_TRADE_EVENT  m_trade_event;                                  // Trading event
      bool              m_is_hedge;                                     // Hedge account flag
      long              m_chart_id_main;                                // Control program chart ID
      int               m_type;                                         // Object type
      int               m_digits;                                       // Symbol's Digits()
      int               m_digits_acc;                                   // Number of decimal places for the account currency
      long              m_long_prop[EVENT_PROP_INTEGER_TOTAL];          // Event integer properties
      double            m_double_prop[EVENT_PROP_DOUBLE_TOTAL];         // Event real properties
      string            m_string_prop[EVENT_PROP_STRING_TOTAL];         // Event string properties
     //--- return the flag presence in the trading event
      bool              IsPresentEventFlag(const int event_code)  const { return (this.m_event_code & event_code)==event_code;                  }
     //--- Return (1) the specified magic number, the ID of (2) the first group, (3) second group, (4) pending request from the magic number value
      ushort            GetMagicID(void)                          const { return ushort(this.Magic() & 0xFFFF);                                 }
      uchar             GetGroupID1(void)                         const { return uchar(this.Magic()>>16) & 0x0F;                                }
      uchar             GetGroupID2(void)                         const { return uchar((this.Magic()>>16) & 0xF0)>>4;                           }
      uchar             GetPendReqID(void)                        const { return uchar(this.Magic()>>24) & 0xFF;                                }
     //--- Protected parametric constructor
      CTradeEvent(const ENUM_EVENT_STATUS event_status,const int event_code,const ulong ticket);
   public:
     //--- Default constructor
      CTradeEvent(void){ this.m_type=OBJECT_DE_TYPE_EVENT; }
 
     //--- Set event's (1) integer, (2) real and (3) string properties
      void              SetProperty(ENUM_EVENT_PROP_INTEGER property,long value) { this.m_long_prop[property]=value;                            }
      void              SetProperty(ENUM_EVENT_PROP_DOUBLE property,double value){ this.m_double_prop[this.IndexProp(property)]=value;          }
      void              SetProperty(ENUM_EVENT_PROP_STRING property,string value){ this.m_string_prop[this.IndexProp(property)]=value;          }
     //--- Return the event's (1) integer, (2) real and (3) string properties from the property array
      long              GetProperty(ENUM_EVENT_PROP_INTEGER property)      const { return this.m_long_prop[property];                           }
      double            GetProperty(ENUM_EVENT_PROP_DOUBLE property)       const { return this.m_double_prop[this.IndexProp(property)];         }
      string            GetProperty(ENUM_EVENT_PROP_STRING property)       const { return this.m_string_prop[this.IndexProp(property)];         }
     //--- Return the flag of the event supporting the property
      virtual bool      SupportProperty(ENUM_EVENT_PROP_INTEGER property)        { return true;       }
      virtual bool      SupportProperty(ENUM_EVENT_PROP_DOUBLE property)         { return true;       }
      virtual bool      SupportProperty(ENUM_EVENT_PROP_STRING property)         { return true;       }
     //--- Return an object type
      virtual int       Type(void)                                         const { return this.m_type;}

     //--- Decode the event code and set the trading event, (2) return the trading event
      void              SetTypeEvent(void);
      ENUM_TRADE_EVENT  TradeEvent(void)                                   const { return this.m_trade_event;                                   }
     //--- Send the event to the chart (implementation in descendant classes)
      virtual void      SendEvent(void) {;}

     //--- Compare CEvent objects by a specified property (to sort the lists by a specified event object property)
      virtual int       Compare(const CObject *node,const int mode=0) const;
     //--- Compare CEvent objects by all properties (to search for equal event objects)
      bool              IsEqual(CTradeEvent* compared_event);
     //+------------------------------------------------------------------+
     //| Methods of simplified access to event object properties          |
     //+------------------------------------------------------------------+
     //--- Return (1) event type, (2) event time in milliseconds, (3) event status, (4) event reason, (5) deal type, (6) deal ticket, 
     //--- (7) order type, based on which a deal was executed, (8) position opening order type, (9) position last order ticket, 
     //--- (10) position first order ticket, (11) position ID, (12) opposite position ID, (13) magic number, (14) opposite position magic number, (15) position open time
      ENUM_TRADE_EVENT  TypeEvent(void)                                    const { return (ENUM_TRADE_EVENT)this.GetProperty(EVENT_PROP_TYPE_EVENT);           }
      long              TimeEvent(void)                                    const { return this.GetProperty(EVENT_PROP_TIME_EVENT);                             }
      ENUM_EVENT_STATUS Status(void)                                       const { return (ENUM_EVENT_STATUS)this.GetProperty(EVENT_PROP_STATUS_EVENT);        }
      ENUM_EVENT_REASON Reason(void)                                       const { return (ENUM_EVENT_REASON)this.GetProperty(EVENT_PROP_REASON_EVENT);        }
      ENUM_DEAL_TYPE    TypeDeal(void)                                     const { return (ENUM_DEAL_TYPE)this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT);        }
      long              TicketDeal(void)                                   const { return this.GetProperty(EVENT_PROP_TICKET_DEAL_EVENT);                      }
      ENUM_ORDER_TYPE   TypeOrderEvent(void)                               const { return (ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORDER_EVENT);      }
      ENUM_ORDER_TYPE   TypeFirstOrderPosition(void)                       const { return (ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORDER_POSITION);   }
      long              TicketOrderEvent(void)                             const { return this.GetProperty(EVENT_PROP_TICKET_ORDER_EVENT);                     }
      long              TicketFirstOrderPosition(void)                     const { return this.GetProperty(EVENT_PROP_TICKET_ORDER_POSITION);                  }
      long              PositionID(void)                                   const { return this.GetProperty(EVENT_PROP_POSITION_ID);                            }
      long              PositionByID(void)                                 const { return this.GetProperty(EVENT_PROP_POSITION_BY_ID);                         }
      long              Magic(void)                                        const { return this.GetProperty(EVENT_PROP_MAGIC_ORDER);                            }
      long              MagicCloseBy(void)                                 const { return this.GetProperty(EVENT_PROP_MAGIC_BY_ID);                            }
      long              TimePosition(void)                                 const { return this.GetProperty(EVENT_PROP_TIME_ORDER_POSITION);                    }

     //--- When changing position direction, return (1) previous position order type, (2) previous position order ticket,
     //--- (3) current position order type, (4) current position order ticket,
     //--- (5) position type and (6) ticket before changing direction, (7) position type and (8) ticket after changing direction
      ENUM_ORDER_TYPE    TypeOrderPosPrevious(void)                         const { return (ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE);   }
      long               TicketOrderPosPrevious(void)                       const { return this.GetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE);                  }
      ENUM_ORDER_TYPE    TypeOrderPosCurrent(void)                          const { return (ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT);  }
      long               TicketOrderPosCurrent(void)                        const { return this.GetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT);                 }
      ENUM_POSITION_TYPE TypePositionPrevious(void)                        const { return PositionTypeByOrderType(this.TypeOrderPosPrevious());                }
      ulong              TicketPositionPrevious(void)                       const { return this.TicketOrderPosPrevious();                                       }
      ENUM_POSITION_TYPE TypePositionCurrent(void)                         const { return PositionTypeByOrderType(this.TypeOrderPosCurrent());                 }
      ulong              TicketPositionCurrent(void)                        const { return this.TicketOrderPosCurrent();                                        }
   
     //--- Return (1) the price the event occurred at, (2) open price, (3) close price,
     //--- (4) StopLoss price, (5) TakeProfit price, (6) profit, (7) requested order volume, 
     //--- (8) executed order volume, (9) remaining order volume, (10) executed position volume
      double            PriceEvent(void)                                   const { return this.GetProperty(EVENT_PROP_PRICE_EVENT);                            }
      double            PriceOpen(void)                                    const { return this.GetProperty(EVENT_PROP_PRICE_OPEN);                             }
      double            PriceClose(void)                                   const { return this.GetProperty(EVENT_PROP_PRICE_CLOSE);                            }
      double            PriceStopLoss(void)                                const { return this.GetProperty(EVENT_PROP_PRICE_SL);                               }
      double            PriceTakeProfit(void)                              const { return this.GetProperty(EVENT_PROP_PRICE_TP);                               }
      double            Profit(void)                                       const { return this.GetProperty(EVENT_PROP_PROFIT);                                 }
      double            VolumeOrderInitial(void)                           const { return this.GetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL);                   }
      double            VolumeOrderExecuted(void)                          const { return this.GetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED);                  }
      double            VolumeOrderCurrent(void)                           const { return this.GetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT);                   }
      double            VolumePositionExecuted(void)                       const { return this.GetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED);               }

     //--- When modifying prices, (1) the order price, (2) StopLoss and (3) TakeProfit before modification are returned
      double            PriceOpenBefore(void)                              const { return this.GetProperty(EVENT_PROP_PRICE_OPEN_BEFORE);                      }
      double            PriceStopLossBefore(void)                          const { return this.GetProperty(EVENT_PROP_PRICE_SL_BEFORE);                        }
      double            PriceTakeProfitBefore(void)                        const { return this.GetProperty(EVENT_PROP_PRICE_TP_BEFORE);                        }
      double            PriceEventAsk(void)                                const { return this.GetProperty(EVENT_PROP_PRICE_EVENT_ASK);                        }
      double            PriceEventBid(void)                                const { return this.GetProperty(EVENT_PROP_PRICE_EVENT_BID);                        }

     //--- Return the (1) symbol and (2) opposite position symbol
      string            Symbol(void)                                       const { return this.GetProperty(EVENT_PROP_SYMBOL);                                 }
      string            SymbolCloseBy(void)                                const { return this.GetProperty(EVENT_PROP_SYMBOL_BY_ID);                           }
      
     //+------------------------------------------------------------------+
     //| Descriptions of the order object properties                      |
     //+------------------------------------------------------------------+
     //--- Get description of an order's (1) integer, (2) real and (3) string property
      string            GetPropertyDescription(ENUM_EVENT_PROP_INTEGER property);
      string            GetPropertyDescription(ENUM_EVENT_PROP_DOUBLE property);
      string            GetPropertyDescription(ENUM_EVENT_PROP_STRING property);
     //--- Return the event's (1) status and (2) type
      string            StatusDescription(void)                const;
      string            TypeEventDescription(void)             const;
     //--- Return the name of an (1) event deal order, (2) position's parent order, (3) current position order and the (4) current position
     //--- Return the name of an (5) order and (6) position before the direction was changed
      string            TypeOrderDealDescription(void)         const;
      string            TypeOrderFirstDescription(void)        const;
      string            TypeOrderEventDescription(void)        const;
      string            TypePositionCurrentDescription(void)   const;
      string            TypeOrderPreviousDescription(void)     const;
      string            TypePositionPreviousDescription(void)  const;
     //--- Return the name of the deal/order/position reason
      string            ReasonDescription(void)                const;

     //--- Display (1) description of order properties (full_prop=true - all properties, false - only supported ones),
     //--- (2) short event message (implementation in the class descendants) in the journal
      void              Print(const bool full_prop=false);
      virtual void      PrintShort(void) {;}
  };
#endif // CTRADEEVENT_MQH_DECLARATION
#ifndef CTRADEEVENT_MQH_IMPLEMENTATION
#define CTRADEEVENT_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CTradeEvent::CTradeEvent(const ENUM_EVENT_STATUS event_status,const int event_code,const ulong ticket) : m_event_code(event_code),m_digits(0)
    {
     this.m_type=OBJECT_DE_TYPE_EVENT;
     this.m_long_prop[EVENT_PROP_STATUS_EVENT]       =  event_status;
     this.m_long_prop[EVENT_PROP_TICKET_ORDER_EVENT] =  (long)ticket;
     this.m_is_hedge=#ifdef __MQL4__ true #else bool(::AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) #endif;
     this.m_digits_acc=#ifdef __MQL4__ 2 #else (int)::AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS) #endif;
     this.m_chart_id_main=::ChartID();
    }
  //+------------------------------------------------------------------+
  //| Compare CEvent objects by a specified property                   |
  //+------------------------------------------------------------------+
  int CTradeEvent::Compare(const CObject *node,const int mode=0) const
    {
      const CTradeEvent *event_compared=node;
     //--- compare integer properties of two events
     if(mode<EVENT_PROP_INTEGER_TOTAL)
       {
        long value_compared=event_compared.GetProperty((ENUM_EVENT_PROP_INTEGER)mode);
        long value_current=this.GetProperty((ENUM_EVENT_PROP_INTEGER)mode);
        return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
       }
     //--- compare integer properties of two objects
      if(mode<EVENT_PROP_DOUBLE_TOTAL+EVENT_PROP_INTEGER_TOTAL)
        {
         double value_compared=event_compared.GetProperty((ENUM_EVENT_PROP_DOUBLE)mode);
         double value_current=this.GetProperty((ENUM_EVENT_PROP_DOUBLE)mode);
         return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
        }
     //--- compare string properties of two objects
      else if(mode<EVENT_PROP_DOUBLE_TOTAL+EVENT_PROP_INTEGER_TOTAL+EVENT_PROP_STRING_TOTAL)
        {
         string value_compared=event_compared.GetProperty((ENUM_EVENT_PROP_STRING)mode);
         string value_current=this.GetProperty((ENUM_EVENT_PROP_STRING)mode);
         return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
        }
    return 0;
   }
  //+------------------------------------------------------------------+
  //| Compare CEvent events by all properties                          |
  //+------------------------------------------------------------------+
  bool CTradeEvent::IsEqual(CTradeEvent *compared_event)
    {
     int begin=0, end=EVENT_PROP_INTEGER_TOTAL;
     for(int i=begin; i<end; i++)
       {
         ENUM_EVENT_PROP_INTEGER prop=(ENUM_EVENT_PROP_INTEGER)i;
         if(this.GetProperty(prop)!=compared_event.GetProperty(prop)) return false; 
       }
     begin=end; end+=EVENT_PROP_DOUBLE_TOTAL;
     for(int i=begin; i<end; i++)
       {
         ENUM_EVENT_PROP_DOUBLE prop=(ENUM_EVENT_PROP_DOUBLE)i;
         if(this.GetProperty(prop)!=compared_event.GetProperty(prop)) return false; 
       }
     begin=end; end+=EVENT_PROP_STRING_TOTAL;
     for(int i=begin; i<end; i++)
       {
         ENUM_EVENT_PROP_STRING prop=(ENUM_EVENT_PROP_STRING)i;
         if(this.GetProperty(prop)!=compared_event.GetProperty(prop)) return false; 
       }
     //---
     return true;
    }
  //+------------------------------------------------------------------+
  //| Decode the event code and set a trading event                    |
  //+------------------------------------------------------------------+
  void CTradeEvent::SetTypeEvent(void)
   {
    //--- Set event symbol's Digits()
      this.m_digits=(int)::SymbolInfoInteger(this.Symbol(),SYMBOL_DIGITS);
    //--- Pending order is set (check if the event code is matched since there can be only one flag here)
      if(this.m_event_code==TRADE_EVENT_FLAG_ORDER_PLASED)
        {
          this.m_trade_event=TRADE_EVENT_PENDING_ORDER_PLASED;
          this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
          return;
        }
    //--- Pending order is removed (check if the event code is matched since there can be only one flag here)
      if(this.m_event_code==TRADE_EVENT_FLAG_ORDER_REMOVED)
        {
          this.m_trade_event=TRADE_EVENT_PENDING_ORDER_REMOVED;
          this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
          return;
        }
    //--- Pending order is modified
      if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_ORDER_MODIFY))
        {
          //--- If the placement price is modified
          if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_PRICE))
            {
            this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_PRICE;
            //--- If StopLoss and TakeProfit are modified
            if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL) && this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
                this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_PRICE_SL_TP;
            //--- If StopLoss is modified
            else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL))
                this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_PRICE_SL;
            //--- If TakeProfit is modified
            else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
                this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_PRICE_TP;
            }
          //--- If the placement price is not modified
          else
            {
            //--- If StopLoss and TakeProfit are modified
            if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL) && this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
                this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_SL_TP;
            //--- If StopLoss is modified
            else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL))
                this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_SL;
            //--- If TakeProfit is modified
            else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
                this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_TP;
            }
          this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
          return;
        }
    //--- Position is modified
      if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_MODIFY))
        {
          //--- If StopLoss and TakeProfit are modified
          if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL) && this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
            this.m_trade_event=TRADE_EVENT_MODIFY_POSITION_SL_TP;
          //--- If StopLoss is modified
          else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL))
            this.m_trade_event=TRADE_EVENT_MODIFY_POSITION_SL;
          //--- If TakeProfit is modified
          else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
            this.m_trade_event=TRADE_EVENT_MODIFY_POSITION_TP;
          this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
          return;
        }
    //--- Position is opened (Check for multiple flags in the event code)
      if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_OPENED))
        {
          //--- If an existing position is changed
          if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_CHANGED))
            {
            //--- If this pending order is activated by the price
            if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_ORDER_ACTIVATED))
              {
                //--- If this is a position reversal
                if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_REVERSE))
                  {
                  //--- check the partial closure flag and set the 
                  //--- "position reversal by activation of a pending order" or "position reversal by partial activation of a pending order" trading event
                  this.m_trade_event=
                    (
                      !this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? 
                      TRADE_EVENT_POSITION_REVERSED_BY_PENDING : 
                      TRADE_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL
                    );
                  this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
                  return;
                  }
                //--- If this is adding a volume to a position
                else
                  {
                  //--- check the partial closure flag and set the 
                  //--- "added volume to a position by activating a pending order" or "added volume to a position by partially activating a pending order" trading event
                  this.m_trade_event=
                    (
                      !this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? 
                      TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING : 
                      TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL
                    );
                  this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
                  return;
                  }
              }
            //--- If a position was changed by a market deal
            else
              {
                //--- If this is a position reversal
                if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_REVERSE))
                  {
                  //--- check the partial opening flag and set the "position reversal" or "position reversal by partial execution" trading event
                  this.m_trade_event=
                    (
                      !this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? 
                      TRADE_EVENT_POSITION_REVERSED_BY_MARKET : 
                      TRADE_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL
                    );
                  this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
                  return;
                  }
                //--- If this is adding a volume to a position
                else
                  {
                  //--- check the partial opening flag and set "added volume to a position" or "added volume to a position by partial execution" trading event
                  this.m_trade_event=
                    (
                      !this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? 
                      TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET : 
                      TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET_PARTIAL
                    );
                  this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
                  return;
                  }
              }
            }
      //--- If a new position is opened
          else
            {
            //--- If this pending order is activated by the price
            if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_ORDER_ACTIVATED))
              {
                //--- check the partial closure flag and set the "pending order activated" or "pending order partially activated" trading event
                this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_PENDING_ORDER_ACTIVATED : TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL);
                this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
                return;
              }
            //--- check the partial opening flag and set the "Position opened" or "Position partially opened" trading event
            this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_OPENED : TRADE_EVENT_POSITION_OPENED_PARTIAL);
            this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
            return;
            }
        }
        
    //--- Position is closed (Check for multiple flags in the event code)
      if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_CLOSED))
        {
          //--- if the position is closed by StopLoss
          if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL))
            {
            //--- check the partial closing flag and set the "Position closed by StopLoss" or "Position closed by StopLoss partially" trading event
            this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_SL : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL);
            this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
            return;
            }
          //--- if the position is closed by TakeProfit
          else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
            {
            //--- check the partial closing flag and set the "Position closed by TakeProfit" or "Position closed by TakeProfit partially" trading event
            this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_TP : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP);
            this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
            return;
            }
          //--- if the position is closed by an opposite one
          else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_BY_POS))
            {
            //--- check the partial closing flag and set the "Position closed by opposite one" or "Position closed by opposite one partially" event
            this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_POS : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS);
            this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
            return;
            }
          //--- If the position is closed
          else
            {
            //--- check the partial closing flag and set the "Position closed" or "Position closed partially" event
            this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED : TRADE_EVENT_POSITION_CLOSED_PARTIAL);
            this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
            return;
            }
        }
    //--- Balance operation on the account (clarify the event by the deal type)
      if(this.m_event_code==TRADE_EVENT_FLAG_ACCOUNT_BALANCE)
        {
          //--- Initialize the trading event
          this.m_trade_event=TRADE_EVENT_NO_EVENT;
          //--- Take a deal type
          ENUM_DEAL_TYPE deal_type=(ENUM_DEAL_TYPE)this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT);
          //--- if the deal is a balance operation
          if(deal_type==DEAL_TYPE_BALANCE)
            {
            //--- check the deal profit and set the event (funds deposit or withdrawal)
            this.m_trade_event=(this.GetProperty(EVENT_PROP_PROFIT)>0 ? TRADE_EVENT_ACCOUNT_BALANCE_REFILL : TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL);
            }
          //--- Remaining balance operation types match the ENUM_DEAL_TYPE enumeration starting with DEAL_TYPE_CREDIT
          else if(deal_type>DEAL_TYPE_BALANCE)
            {
            //--- set the event
            this.m_trade_event=(ENUM_TRADE_EVENT)deal_type;
            }
          this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
          return;
        }
   }
  //+------------------------------------------------------------------+
  //| Return the description of the event's integer property           |
  //+------------------------------------------------------------------+
  string CTradeEvent::GetPropertyDescription(ENUM_EVENT_PROP_INTEGER property)
   {
    return
      (
      property==EVENT_PROP_TYPE_EVENT              ?  CMessage::Text(MSG_EVN_TYPE)+": "+this.TypeEventDescription()                                                       :
      property==EVENT_PROP_TIME_EVENT              ?  CMessage::Text(MSG_EVN_TIME)+": "+TimeMSCtoString(this.GetProperty(property))                                       :
      property==EVENT_PROP_STATUS_EVENT            ?  CMessage::Text(MSG_EVN_STATUS)+": \""+this.StatusDescription()+"\""                                                 :
      property==EVENT_PROP_REASON_EVENT            ?  CMessage::Text(MSG_EVN_REASON)+": "+this.ReasonDescription()                                                        :
      property==EVENT_PROP_TYPE_DEAL_EVENT         ?  CMessage::Text(MSG_EVN_TYPE_DEAL)+": "+DealTypeDescription((ENUM_DEAL_TYPE)this.GetProperty(property))              :
      property==EVENT_PROP_TICKET_DEAL_EVENT       ?  CMessage::Text(MSG_EVN_TICKET_DEAL)+": #"+(string)this.GetProperty(property)                                        :
      property==EVENT_PROP_TYPE_ORDER_EVENT        ?  CMessage::Text(MSG_EVN_TYPE_ORDER)+": "+OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(property))           :
      property==EVENT_PROP_TYPE_ORDER_POSITION     ?  CMessage::Text(MSG_EVN_TYPE_ORDER_POSITION)+": "+OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(property))  :
      property==EVENT_PROP_TICKET_ORDER_POSITION   ?  CMessage::Text(MSG_EVN_TICKET_ORDER_POSITION)+": #"+(string)this.GetProperty(property)                              :
      property==EVENT_PROP_TICKET_ORDER_EVENT      ?  CMessage::Text(MSG_EVN_TICKET_ORDER_EVENT)+": #"+(string)this.GetProperty(property)                                 :
      property==EVENT_PROP_POSITION_ID             ?  CMessage::Text(MSG_EVN_POSITION_ID)+": #"+(string)this.GetProperty(property)                                        :
      property==EVENT_PROP_POSITION_BY_ID          ?  CMessage::Text(MSG_EVN_POSITION_BY_ID)+": #"+(string)this.GetProperty(property)                                     :
      property==EVENT_PROP_MAGIC_ORDER             ?  CMessage::Text(MSG_ORD_MAGIC)+": "+(string)this.GetProperty(property)                                               :
      property==EVENT_PROP_MAGIC_BY_ID             ?  CMessage::Text(MSG_EVN_MAGIC_BY_ID)+": "+(string)this.GetProperty(property)                                         :
      property==EVENT_PROP_TIME_ORDER_POSITION     ?  CMessage::Text(MSG_EVN_TIME_ORDER_POSITION)+": "+TimeMSCtoString(this.GetProperty(property))                        :
      property==EVENT_PROP_TYPE_ORD_POS_BEFORE     ?  CMessage::Text(MSG_EVN_TYPE_ORD_POS_BEFORE)+": "+OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(property))  :
      property==EVENT_PROP_TICKET_ORD_POS_BEFORE   ?  CMessage::Text(MSG_EVN_TICKET_ORD_POS_BEFORE)+": #"+(string)this.GetProperty(property)                              :
      property==EVENT_PROP_TYPE_ORD_POS_CURRENT    ?  CMessage::Text(MSG_EVN_TYPE_ORD_POS_CURRENT)+": "+OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(property)) :
      property==EVENT_PROP_TICKET_ORD_POS_CURRENT  ?  CMessage::Text(MSG_EVN_TICKET_ORD_POS_CURRENT)+": #"+(string)this.GetProperty(property)                             :
      ::EnumToString(property)
      );
   }
  //+------------------------------------------------------------------+
  //| Return the description of the event's real property              |
  //+------------------------------------------------------------------+
  string CTradeEvent::GetPropertyDescription(ENUM_EVENT_PROP_DOUBLE property)
   {
    int dg=(int)::SymbolInfoInteger(this.GetProperty(EVENT_PROP_SYMBOL),SYMBOL_DIGITS);
    int dgl=(int)DigitsLots(this.GetProperty(EVENT_PROP_SYMBOL));
    return
      (
        property==EVENT_PROP_PRICE_EVENT             ?  CMessage::Text(MSG_EVN_PRICE_EVENT)+": "+::DoubleToString(this.GetProperty(property),dg)                 :
        property==EVENT_PROP_PRICE_OPEN              ?  CMessage::Text(MSG_ORD_PRICE_OPEN)+": "+::DoubleToString(this.GetProperty(property),dg)                  :
        property==EVENT_PROP_PRICE_CLOSE             ?  CMessage::Text(MSG_ORD_PRICE_CLOSE)+": "+::DoubleToString(this.GetProperty(property),dg)                 :
        property==EVENT_PROP_PRICE_SL                ?  CMessage::Text(MSG_LIB_PROP_PRICE_SL)+": "+::DoubleToString(this.GetProperty(property),dg)               :
        property==EVENT_PROP_PRICE_TP                ?  CMessage::Text(MSG_LIB_PROP_PRICE_TP)+": "+::DoubleToString(this.GetProperty(property),dg)               :
        property==EVENT_PROP_VOLUME_ORDER_INITIAL    ?  CMessage::Text(MSG_EVN_VOLUME_ORDER_INITIAL)+": "+::DoubleToString(this.GetProperty(property),dgl)       :
        property==EVENT_PROP_VOLUME_ORDER_EXECUTED   ?  CMessage::Text(MSG_EVN_VOLUME_ORDER_EXECUTED)+": "+::DoubleToString(this.GetProperty(property),dgl)      :
        property==EVENT_PROP_VOLUME_ORDER_CURRENT    ?  CMessage::Text(MSG_EVN_VOLUME_ORDER_CURRENT)+": "+::DoubleToString(this.GetProperty(property),dgl)       :
        property==EVENT_PROP_VOLUME_POSITION_EXECUTED ? CMessage::Text(MSG_EVN_VOLUME_POSITION_EXECUTED)+": "+::DoubleToString(this.GetProperty(property),dgl)   :
        property==EVENT_PROP_PROFIT                  ?  CMessage::Text(MSG_LIB_PROP_PROFIT)+": "+::DoubleToString(this.GetProperty(property),this.m_digits_acc)  :
        property==EVENT_PROP_PRICE_OPEN_BEFORE       ?  CMessage::Text(MSG_EVN_PRICE_OPEN_BEFORE)+": "+::DoubleToString(this.GetProperty(property),dg)           :
        property==EVENT_PROP_PRICE_SL_BEFORE         ?  CMessage::Text(MSG_EVN_PRICE_SL_BEFORE)+": "+::DoubleToString(this.GetProperty(property),dg)             :
        property==EVENT_PROP_PRICE_TP_BEFORE         ?  CMessage::Text(MSG_EVN_PRICE_TP_BEFORE)+": "+::DoubleToString(this.GetProperty(property),dg)             :
        property==EVENT_PROP_PRICE_EVENT_ASK         ?  CMessage::Text(MSG_EVN_PRICE_EVENT_ASK)+": "+::DoubleToString(this.GetProperty(property),dg)             :
        property==EVENT_PROP_PRICE_EVENT_BID         ?  CMessage::Text(MSG_EVN_PRICE_EVENT_BID)+": "+::DoubleToString(this.GetProperty(property),dg)             :
        ::EnumToString(property)
      );
   }
  //+------------------------------------------------------------------+
  //| Return the description of the event's string property            |
  //+------------------------------------------------------------------+
  string CTradeEvent::GetPropertyDescription(ENUM_EVENT_PROP_STRING property)
   {
      return
      (
      property==EVENT_PROP_SYMBOL ? CMessage::Text(MSG_LIB_PROP_SYMBOL)+": \""+this.GetProperty(property)+"\"" :
      CMessage::Text(MSG_EVN_SYMBOL_BY_POS)+": \""+this.GetProperty(property)+"\""
      );
   }
  //+------------------------------------------------------------------+
  //| Return the event status name                                     |
  //+------------------------------------------------------------------+
  string CTradeEvent::StatusDescription(void) const
   {
   ENUM_EVENT_STATUS status=(ENUM_EVENT_STATUS)this.GetProperty(EVENT_PROP_STATUS_EVENT);
      return
      (
      status==EVENT_STATUS_MARKET_PENDING    ?  CMessage::Text(MSG_EVN_STATUS_MARKET_PENDING)   :
      status==EVENT_STATUS_MARKET_POSITION   ?  CMessage::Text(MSG_EVN_STATUS_MARKET_POSITION)  :
      status==EVENT_STATUS_HISTORY_PENDING   ?  CMessage::Text(MSG_EVN_STATUS_HISTORY_PENDING)  :
      status==EVENT_STATUS_HISTORY_POSITION  ?  CMessage::Text(MSG_EVN_STATUS_HISTORY_POSITION) :
      status==EVENT_STATUS_BALANCE           ?  CMessage::Text(MSG_LIB_PROP_BALANCE)            :
      status==EVENT_STATUS_MODIFY            ?  CMessage::Text(MSG_EVN_REASON_MODIFY)           :
      CMessage::Text(MSG_EVN_STATUS_UNKNOWN)
      );
   }
  //+------------------------------------------------------------------+
  //| Return the trading event name                                    |
  //+------------------------------------------------------------------+
  string CTradeEvent::TypeEventDescription(void) const
   {
    ENUM_TRADE_EVENT event=this.TypeEvent();
        return
        (
        event==TRADE_EVENT_NO_EVENT                              ?  CMessage::Text(MSG_EVN_NO_EVENT)                            :
        event==TRADE_EVENT_PENDING_ORDER_PLASED                  ?  CMessage::Text(MSG_EVN_PENDING_ORDER_PLASED)                :
        event==TRADE_EVENT_PENDING_ORDER_REMOVED                 ?  CMessage::Text(MSG_EVN_PENDING_ORDER_REMOVED)               :
        event==TRADE_EVENT_ACCOUNT_CREDIT                        ?  CMessage::Text(MSG_EVN_ACCOUNT_CREDIT)                      :
        event==TRADE_EVENT_ACCOUNT_CHARGE                        ?  CMessage::Text(MSG_EVN_ACCOUNT_CHARGE)                      :
        event==TRADE_EVENT_ACCOUNT_CORRECTION                    ?  CMessage::Text(MSG_EVN_ACCOUNT_CORRECTION)                  :
        event==TRADE_EVENT_ACCOUNT_BONUS                         ?  CMessage::Text(MSG_EVN_ACCOUNT_BONUS)                       :
        event==TRADE_EVENT_ACCOUNT_COMISSION                     ?  CMessage::Text(MSG_EVN_ACCOUNT_COMISSION)                   :
        event==TRADE_EVENT_ACCOUNT_COMISSION_DAILY               ?  CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_DAILY)             :
        event==TRADE_EVENT_ACCOUNT_COMISSION_MONTHLY             ?  CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_MONTHLY)           :
        event==TRADE_EVENT_ACCOUNT_COMISSION_AGENT_DAILY         ?  CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_AGENT_DAILY)       :
        event==TRADE_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY       ?  CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_AGENT_MONTHLY)     :
        event==TRADE_EVENT_ACCOUNT_INTEREST                      ?  CMessage::Text(MSG_EVN_ACCOUNT_INTEREST)                    :
        event==TRADE_EVENT_BUY_CANCELLED                         ?  CMessage::Text(MSG_EVN_BUY_CANCELLED)                       :
        event==TRADE_EVENT_SELL_CANCELLED                        ?  CMessage::Text(MSG_EVN_SELL_CANCELLED)                      :
        event==TRADE_EVENT_DIVIDENT                              ?  CMessage::Text(MSG_EVN_DIVIDENT)                            :
        event==TRADE_EVENT_DIVIDENT_FRANKED                      ?  CMessage::Text(MSG_EVN_DIVIDENT_FRANKED)                    :
        event==TRADE_EVENT_TAX                                   ?  CMessage::Text(MSG_EVN_TAX)                                 :
        event==TRADE_EVENT_ACCOUNT_BALANCE_REFILL                ?  CMessage::Text(MSG_EVN_BALANCE_REFILL)                      :
        event==TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL            ?  CMessage::Text(MSG_EVN_BALANCE_WITHDRAWAL)                  :
        event==TRADE_EVENT_PENDING_ORDER_ACTIVATED               ?  CMessage::Text(MSG_EVN_ACTIVATED_PENDING)                   :
        event==TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL       ?  CMessage::Text(MSG_EVN_ACTIVATED_PENDING_PARTIALLY)         :
        event==TRADE_EVENT_POSITION_OPENED                       ?  CMessage::Text(MSG_EVN_STATUS_MARKET_POSITION)              :
        event==TRADE_EVENT_POSITION_OPENED_PARTIAL               ?  CMessage::Text(MSG_EVN_POSITION_OPENED_PARTIALLY)           :
        event==TRADE_EVENT_POSITION_CLOSED                       ?  CMessage::Text(MSG_EVN_STATUS_HISTORY_POSITION)             :
        event==TRADE_EVENT_POSITION_CLOSED_PARTIAL               ?  CMessage::Text(MSG_EVN_POSITION_CLOSED_PARTIALLY)           :
        event==TRADE_EVENT_POSITION_CLOSED_BY_POS                ?  CMessage::Text(MSG_EVN_POSITION_CLOSED_BY_POS)              :
        event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS        ?  CMessage::Text(MSG_EVN_POSITION_CLOSED_PARTIALLY_BY_POS)    :
        event==TRADE_EVENT_POSITION_CLOSED_BY_SL                 ?  CMessage::Text(MSG_EVN_POSITION_CLOSED_BY_SL)               :
        event==TRADE_EVENT_POSITION_CLOSED_BY_TP                 ?  CMessage::Text(MSG_EVN_POSITION_CLOSED_BY_TP)               :
        event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL         ?  CMessage::Text(MSG_EVN_POSITION_CLOSED_PARTIALLY_BY_SL)     :
        event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP         ?  CMessage::Text(MSG_EVN_POSITION_CLOSED_PARTIALLY_BY_TP)     :
        event==TRADE_EVENT_POSITION_REVERSED_BY_MARKET           ?  CMessage::Text(MSG_EVN_POSITION_REVERSED_BY_MARKET)         :
        event==TRADE_EVENT_POSITION_REVERSED_BY_PENDING          ?  CMessage::Text(MSG_EVN_POSITION_REVERSED_BY_PENDING)        :
        event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET         ?  CMessage::Text(MSG_EVN_POSITION_VOLUME_ADD_BY_MARKET)       :
        event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING        ?  CMessage::Text(MSG_EVN_POSITION_VOLUME_ADD_BY_PENDING)      :
        
        event==TRADE_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL   ?  CMessage::Text(MSG_EVN_POSITION_REVERSE_PARTIALLY)          :
        event==TRADE_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL  ?  CMessage::Text(MSG_EVN_REASON_REVERSE_BY_PENDING_PARTIALLY) :
        event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET_PARTIAL ?  CMessage::Text(MSG_EVN_REASON_ADD_PARTIALLY)                :
        event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL ? CMessage::Text(MSG_EVN_POSITION_VOLUME_ADD_BY_PENDING)      :

        event==TRADE_EVENT_TRIGGERED_STOP_LIMIT_ORDER            ?  CMessage::Text(MSG_EVN_REASON_STOPLIMIT_TRIGGERED)          :
        event==TRADE_EVENT_MODIFY_ORDER_PRICE                    ?  CMessage::Text(MSG_EVN_MODIFY_ORDER_PRICE)                  :
        event==TRADE_EVENT_MODIFY_ORDER_PRICE_SL                 ?  CMessage::Text(MSG_EVN_MODIFY_ORDER_PRICE_SL)               :
        event==TRADE_EVENT_MODIFY_ORDER_PRICE_TP                 ?  CMessage::Text(MSG_EVN_MODIFY_ORDER_PRICE_TP)               :
        event==TRADE_EVENT_MODIFY_ORDER_PRICE_SL_TP              ?  CMessage::Text(MSG_EVN_MODIFY_ORDER_PRICE_SL_TP)            :
        event==TRADE_EVENT_MODIFY_ORDER_SL_TP                    ?  CMessage::Text(MSG_EVN_MODIFY_ORDER_SL_TP)                  :
        event==TRADE_EVENT_MODIFY_ORDER_SL                       ?  CMessage::Text(MSG_EVN_MODIFY_ORDER_SL)                     :
        event==TRADE_EVENT_MODIFY_ORDER_TP                       ?  CMessage::Text(MSG_EVN_MODIFY_ORDER_TP)                     :
        event==TRADE_EVENT_MODIFY_POSITION_SL_TP                 ?  CMessage::Text(MSG_EVN_MODIFY_POSITION_SL_TP)               :
        event==TRADE_EVENT_MODIFY_POSITION_SL                    ?  CMessage::Text(MSG_EVN_MODIFY_POSITION_SL)                  :
        event==TRADE_EVENT_MODIFY_POSITION_TP                    ?  CMessage::Text(MSG_EVN_MODIFY_POSITION_TP)                  :
        ::EnumToString(event)
      );   
   }
  //+------------------------------------------------------------------+
  //| Return the name of the order/position/deal                       |
  //+------------------------------------------------------------------+
  string CTradeEvent::TypeOrderDealDescription(void) const
   {
    ENUM_EVENT_STATUS status=this.Status();
    return
      (
        status==EVENT_STATUS_MARKET_PENDING  || status==EVENT_STATUS_HISTORY_PENDING  ?  OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORDER_EVENT))      :
        status==EVENT_STATUS_MARKET_POSITION || status==EVENT_STATUS_HISTORY_POSITION ?  PositionTypeDescription((ENUM_POSITION_TYPE)this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT)) :
        status==EVENT_STATUS_BALANCE  ?  DealTypeDescription((ENUM_DEAL_TYPE)this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT))  :  
        CMessage::Text(MSG_ORD_UNKNOWN_TYPE)
      );
   }
   //+------------------------------------------------------------------+
   //| Return the name of the position's first order                    |
   //+------------------------------------------------------------------+
   string CTradeEvent::TypeOrderFirstDescription(void) const
   {
    return OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORDER_POSITION));
   }
   //+------------------------------------------------------------------+
   //| Return the name of the order that changed the position           |
   //+------------------------------------------------------------------+
   string CTradeEvent::TypeOrderEventDescription(void) const
   {
    return OrderTypeDescription(this.TypeOrderEvent());
   }
   //+------------------------------------------------------------------+
   //| Return the name of the current position                          |
   //+------------------------------------------------------------------+
   string CTradeEvent::TypePositionCurrentDescription(void) const
   {
    return PositionTypeDescription(this.TypePositionCurrent());
   }
   //+------------------------------------------------------------------+
   //| Return the name of the order before changing the direction       |
   //+------------------------------------------------------------------+
   string CTradeEvent::TypeOrderPreviousDescription(void) const
   {
    return OrderTypeDescription(this.TypeOrderPosPrevious());
   }
   //+------------------------------------------------------------------+
   //| Return the name of the position before changing the direction    |
   //+------------------------------------------------------------------+
   string CTradeEvent::TypePositionPreviousDescription(void) const
   {
    return PositionTypeDescription(this.TypePositionPrevious());
   }
   //+------------------------------------------------------------------+
   //| Return the name of the deal/order/position reason                |
   //+------------------------------------------------------------------+
   string CTradeEvent::ReasonDescription(void) const
   {
    ENUM_EVENT_REASON reason=this.Reason();
    return 
     (
      reason==EVENT_REASON_ACTIVATED_PENDING                ?  CMessage::Text(MSG_EVN_ACTIVATED_PENDING)                      :
      reason==EVENT_REASON_ACTIVATED_PENDING_PARTIALLY      ?  CMessage::Text(MSG_EVN_ACTIVATED_PENDING_PARTIALLY)            :
      reason==EVENT_REASON_STOPLIMIT_TRIGGERED              ?  CMessage::Text(MSG_EVN_REASON_STOPLIMIT_TRIGGERED)             :
      reason==EVENT_REASON_MODIFY                           ?  CMessage::Text(MSG_EVN_REASON_MODIFY)                          :
      reason==EVENT_REASON_CANCEL                           ?  CMessage::Text(MSG_EVN_REASON_CANCEL)                          :
      reason==EVENT_REASON_EXPIRED                          ?  CMessage::Text(MSG_EVN_REASON_EXPIRED)                         :
      reason==EVENT_REASON_DONE                             ?  CMessage::Text(MSG_EVN_REASON_DONE)                            :
      reason==EVENT_REASON_DONE_PARTIALLY                   ?  CMessage::Text(MSG_EVN_REASON_DONE_PARTIALLY)                  :
      reason==EVENT_REASON_VOLUME_ADD                       ?  CMessage::Text(MSG_EVN_REASON_ADD)                             :
      reason==EVENT_REASON_VOLUME_ADD_PARTIALLY             ?  CMessage::Text(MSG_EVN_REASON_ADD_PARTIALLY)                   :
      reason==EVENT_REASON_VOLUME_ADD_BY_PENDING            ?  CMessage::Text(MSG_EVN_POSITION_VOLUME_ADD_BY_PENDING)         :
      reason==EVENT_REASON_VOLUME_ADD_BY_PENDING_PARTIALLY  ?  CMessage::Text(MSG_EVN_REASON_ADD_BY_PENDING_PARTIALLY)        :
      reason==EVENT_REASON_REVERSE                          ?  CMessage::Text(MSG_EVN_REASON_REVERSE)                         :
      reason==EVENT_REASON_REVERSE_PARTIALLY                ?  CMessage::Text(MSG_EVN_POSITION_REVERSE_PARTIALLY)             :
      reason==EVENT_REASON_REVERSE_BY_PENDING               ?  CMessage::Text(MSG_EVN_POSITION_REVERSED_BY_PENDING)           :
      reason==EVENT_REASON_REVERSE_BY_PENDING_PARTIALLY     ?  CMessage::Text(MSG_EVN_REASON_REVERSE_BY_PENDING_PARTIALLY)    :
      reason==EVENT_REASON_DONE_SL                          ?  CMessage::Text(MSG_LIB_PROP_CLOSE_BY_SL)                       :
      reason==EVENT_REASON_DONE_SL_PARTIALLY                ?  CMessage::Text(MSG_EVN_REASON_DONE_SL_PARTIALLY)               :
      reason==EVENT_REASON_DONE_TP                          ?  CMessage::Text(MSG_LIB_PROP_CLOSE_BY_TP)                       :
      reason==EVENT_REASON_DONE_TP_PARTIALLY                ?  CMessage::Text(MSG_EVN_REASON_DONE_TP_PARTIALLY)               :
      reason==EVENT_REASON_DONE_BY_POS                      ?  CMessage::Text(MSG_EVN_REASON_DONE_BY_POS)                     :
      reason==EVENT_REASON_DONE_PARTIALLY_BY_POS            ?  CMessage::Text(MSG_EVN_REASON_DONE_PARTIALLY_BY_POS)           :
      reason==EVENT_REASON_DONE_BY_POS_PARTIALLY            ?  CMessage::Text(MSG_EVN_REASON_DONE_BY_POS_PARTIALLY)           :
      reason==EVENT_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY  ?  CMessage::Text(MSG_EVN_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY) :
      reason==EVENT_REASON_BALANCE_REFILL                   ?  CMessage::Text(MSG_EVN_BALANCE_REFILL)                         :
      reason==EVENT_REASON_BALANCE_WITHDRAWAL               ?  CMessage::Text(MSG_EVN_BALANCE_WITHDRAWAL)                     :
      reason==EVENT_REASON_ACCOUNT_CREDIT                   ?  CMessage::Text(MSG_EVN_ACCOUNT_CREDIT)                         :
      reason==EVENT_REASON_ACCOUNT_CHARGE                   ?  CMessage::Text(MSG_EVN_ACCOUNT_CHARGE)                         :
      reason==EVENT_REASON_ACCOUNT_CORRECTION               ?  CMessage::Text(MSG_EVN_ACCOUNT_CORRECTION)                     :
      reason==EVENT_REASON_ACCOUNT_BONUS                    ?  CMessage::Text(MSG_EVN_ACCOUNT_BONUS)                          :
      reason==EVENT_REASON_ACCOUNT_COMISSION                ?  CMessage::Text(MSG_EVN_ACCOUNT_COMISSION)                      :
      reason==EVENT_REASON_ACCOUNT_COMISSION_DAILY          ?  CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_DAILY)                :
      reason==EVENT_REASON_ACCOUNT_COMISSION_MONTHLY        ?  CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_MONTHLY)              :
      reason==EVENT_REASON_ACCOUNT_COMISSION_AGENT_DAILY    ?  CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_AGENT_DAILY)          :
      reason==EVENT_REASON_ACCOUNT_COMISSION_AGENT_MONTHLY  ?  CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_AGENT_MONTHLY)        :
      reason==EVENT_REASON_ACCOUNT_INTEREST                 ?  CMessage::Text(MSG_EVN_ACCOUNT_INTEREST)                       :
      reason==EVENT_REASON_BUY_CANCELLED                    ?  CMessage::Text(MSG_EVN_BUY_CANCELLED)                          :
      reason==EVENT_REASON_SELL_CANCELLED                   ?  CMessage::Text(MSG_EVN_SELL_CANCELLED)                         :
      reason==EVENT_REASON_DIVIDENT                         ?  CMessage::Text(MSG_EVN_DIVIDENT)                               :
      reason==EVENT_REASON_DIVIDENT_FRANKED                 ?  CMessage::Text(MSG_EVN_DIVIDENT_FRANKED)                       :
      reason==EVENT_REASON_TAX                              ?  CMessage::Text(MSG_EVN_TAX)                                    :
      ::EnumToString(reason)
     );
   }
  //+------------------------------------------------------------------+
  //| Display the event properties in the journal                      |
  //+------------------------------------------------------------------+
  void CTradeEvent::Print(const bool full_prop=false)
   {
    ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_BEG),": \"",this.StatusDescription(),"\" =============");
    int begin=0, end=EVENT_PROP_INTEGER_TOTAL;
    for(int i=begin; i<end; i++)
      {
        ENUM_EVENT_PROP_INTEGER prop=(ENUM_EVENT_PROP_INTEGER)i;
        if(!full_prop && !this.SupportProperty(prop)) continue;
        ::Print(this.GetPropertyDescription(prop));
      }
    ::Print("------");
    begin=end; end+=EVENT_PROP_DOUBLE_TOTAL;
    for(int i=begin; i<end; i++)
      {
        ENUM_EVENT_PROP_DOUBLE prop=(ENUM_EVENT_PROP_DOUBLE)i;
        if(!full_prop && !this.SupportProperty(prop)) continue;
        ::Print(this.GetPropertyDescription(prop));
      }
    ::Print("------");
    begin=end; end+=EVENT_PROP_STRING_TOTAL;
    for(int i=begin; i<end; i++)
      {
        ENUM_EVENT_PROP_STRING prop=(ENUM_EVENT_PROP_STRING)i;
        if(!full_prop && !this.SupportProperty(prop)) continue;
        ::Print(this.GetPropertyDescription(prop));
      }
    ::Print("================== ",CMessage::Text(MSG_LIB_PARAMS_LIST_END),": \"",this.StatusDescription(),"\" ==================\n");
   }
#endif // CTRADEEVENT_MQH_IMPLEMENTATION
#endif // CTRADEEVENT_MQH