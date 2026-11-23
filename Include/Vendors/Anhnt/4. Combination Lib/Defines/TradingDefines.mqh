//+------------------------------------------------------------------+
//|                                               TradingDefines.mqh
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh             |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __TRADING_DEFINES_MQH__
#define __TRADING_DEFINES_MQH__
#include "EventDefines.mqh"
//+------------------------------------------------------------------+
//| Data for working with orders                                     |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Abstract order type (status)                                     |
//+------------------------------------------------------------------+
enum ENUM_ORDER_STATUS
  {
   ORDER_STATUS_MARKET_PENDING,                             // Market pending order
   ORDER_STATUS_MARKET_ORDER,                               // Market order
   ORDER_STATUS_MARKET_POSITION,                            // Market position
   ORDER_STATUS_HISTORY_ORDER,                              // History market order
   ORDER_STATUS_HISTORY_PENDING,                            // Removed pending order
   ORDER_STATUS_BALANCE,                                    // Balance operation
   ORDER_STATUS_DEAL,                                       // Deal
   ORDER_STATUS_UNKNOWN                                     // Unknown status
  };
//+------------------------------------------------------------------+
//| Order, deal, position integer properties                         |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_INTEGER
  {
   ORDER_PROP_TICKET = 0,                                   // Order ticket
   ORDER_PROP_MAGIC,                                        // Real order magic number
   ORDER_PROP_TIME_OPEN,                                    // Open time in milliseconds (MQL5 Deal time)
   ORDER_PROP_TIME_CLOSE,                                   // Close time in milliseconds (MQL5 Execution or removal time - ORDER_TIME_DONE)
   ORDER_PROP_TIME_EXP,                                     // Order expiration date (for pending orders)
   ORDER_PROP_TYPE_FILLING,                                 // Type of execution by remainder
   ORDER_PROP_TYPE_TIME,                                    // Order lifetime
   ORDER_PROP_STATUS,                                       // Order status (from the ENUM_ORDER_STATUS enumeration)
   ORDER_PROP_TYPE,                                         // Order/deal type
   ORDER_PROP_REASON,                                       // Deal/order/position reason or source
   ORDER_PROP_STATE,                                        // Order status (from the ENUM_ORDER_STATE enumeration)
   ORDER_PROP_POSITION_ID,                                  // Position ID
   ORDER_PROP_POSITION_BY_ID,                               // Opposite position ID
   ORDER_PROP_DEAL_ORDER_TICKET,                            // Ticket of the order that triggered a deal
   ORDER_PROP_DEAL_ENTRY,                                   // Deal direction – IN, OUT or IN/OUT
   ORDER_PROP_TIME_UPDATE,                                  // Position change time in milliseconds
   ORDER_PROP_TICKET_FROM,                                  // Parent order ticket
   ORDER_PROP_TICKET_TO,                                    // Derived order ticket
   ORDER_PROP_PROFIT_PT,                                    // Profit in points
   ORDER_PROP_CLOSE_BY_SL,                                  // Flag of closing by StopLoss
   ORDER_PROP_CLOSE_BY_TP,                                  // Flag of closing by TakeProfit
   ORDER_PROP_MAGIC_ID,                                     // Order's "magic number" ID
   ORDER_PROP_GROUP_ID1,                                    // First order/position group ID
   ORDER_PROP_GROUP_ID2,                                    // Second order/position group ID
   ORDER_PROP_PEND_REQ_ID,                                  // Pending request ID
   ORDER_PROP_DIRECTION,                                    // Direction (Buy, Sell)
  }; 
#define ORDER_PROP_INTEGER_TOTAL    (26)                    // Total number of integer properties
#define ORDER_PROP_INTEGER_SKIP     (0)                     // Number of order properties not used in sorting
//+------------------------------------------------------------------+
//| Order, deal, position real properties                            |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_DOUBLE
  {
   ORDER_PROP_PRICE_OPEN = ORDER_PROP_INTEGER_TOTAL,        // Open price (MQL5 deal price)
   ORDER_PROP_PRICE_CLOSE,                                  // Close price
   ORDER_PROP_SL,                                           // StopLoss price
   ORDER_PROP_TP,                                           // TaleProfit price
   ORDER_PROP_FEE,                                          // Deal fee (DEAL_FEE from ENUM_DEAL_PROPERTY_DOUBLE)
   ORDER_PROP_PROFIT,                                       // Profit
   ORDER_PROP_COMMISSION,                                   // Commission
   ORDER_PROP_SWAP,                                         // Swap
   ORDER_PROP_VOLUME,                                       // Volume
   ORDER_PROP_VOLUME_CURRENT,                               // Unexecuted volume
   ORDER_PROP_PROFIT_FULL,                                  // Profit+commission+swap
   ORDER_PROP_PRICE_STOP_LIMIT,                             // Limit order price when StopLimit order is activated
  };
#define ORDER_PROP_DOUBLE_TOTAL     (12)                    // Total number of real properties
//+------------------------------------------------------------------+
//| Order, deal, position string properties                          |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_STRING
  {
   ORDER_PROP_SYMBOL = (ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_DOUBLE_TOTAL), // Order symbol
   ORDER_PROP_COMMENT,                                      // Order comment
   ORDER_PROP_COMMENT_EXT,                                  // Order custom comment
   ORDER_PROP_EXT_ID                                        // Order ID in an external trading system
  };
#define ORDER_PROP_STRING_TOTAL     (4)                     // Total number of string properties
//+------------------------------------------------------------------+
//| Possible criteria of sorting orders and deals                    |
//+------------------------------------------------------------------+
#define FIRST_ORD_DBL_PROP          (ORDER_PROP_INTEGER_TOTAL-ORDER_PROP_INTEGER_SKIP)
#define FIRST_ORD_STR_PROP          (ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_DOUBLE_TOTAL-ORDER_PROP_INTEGER_SKIP)
enum ENUM_SORT_ORDERS_MODE
  {
   //--- Sort by integer properties
    SORT_BY_ORDER_TICKET = 0,                                // Sort by an order ticket
    SORT_BY_ORDER_MAGIC,                                     // Sort by an order magic number
    SORT_BY_ORDER_TIME_OPEN,                                 // Sort by an order open time in milliseconds
    SORT_BY_ORDER_TIME_CLOSE,                                // Sort by an order close time in milliseconds
    SORT_BY_ORDER_TIME_EXP,                                  // Sort by an order expiration date
    SORT_BY_ORDER_TYPE_FILLING,                              // Sort by execution type by remainder
    SORT_BY_ORDER_TYPE_TIME,                                 // Sort by order lifetime
    SORT_BY_ORDER_STATUS,                                    // Sort by an order status (market order/pending order/deal/balance and credit operation)
    SORT_BY_ORDER_TYPE,                                      // Sort by an order type
    SORT_BY_ORDER_REASON,                                    // Sort by a deal/order/position reason/source
    SORT_BY_ORDER_STATE,                                     // Sort by an order status
    SORT_BY_ORDER_POSITION_ID,                               // Sort by a position ID
    SORT_BY_ORDER_POSITION_BY_ID,                            // Sort by an opposite position ID
    SORT_BY_ORDER_DEAL_ORDER,                                // Sort by the order a deal is based on
    SORT_BY_ORDER_DEAL_ENTRY,                                // Sort by a deal direction – IN, OUT or IN/OUT
    SORT_BY_ORDER_TIME_UPDATE,                               // Sort by position change time in seconds
    SORT_BY_ORDER_TICKET_FROM,                               // Sort by a parent order ticket
    SORT_BY_ORDER_TICKET_TO,                                 // Sort by a derived order ticket
    SORT_BY_ORDER_PROFIT_PT,                                 // Sort by order profit in points
    SORT_BY_ORDER_CLOSE_BY_SL,                               // Sort by the flag of closing an order by StopLoss
    SORT_BY_ORDER_CLOSE_BY_TP,                               // Sort by the flag of closing an order by TakeProfit
    SORT_BY_ORDER_MAGIC_ID,                                  // Sort by an order/position "magic number" ID
    SORT_BY_ORDER_GROUP_ID1,                                 // Sort by the first order/position group ID
    SORT_BY_ORDER_GROUP_ID2,                                 // Sort by the second order/position group ID
    SORT_BY_ORDER_PEND_REQ_ID,                               // Sort by a pending request ID
    SORT_BY_ORDER_DIRECTION,                                 // Sort by direction (Buy, Sell)
    //--- Sort by real properties
    SORT_BY_ORDER_PRICE_OPEN = FIRST_ORD_DBL_PROP,           // Sort by open price
    SORT_BY_ORDER_PRICE_CLOSE,                               // Sort by close price
    SORT_BY_ORDER_SL,                                        // Sort by StopLoss price
    SORT_BY_ORDER_TP,                                        // Sort by TakeProfit price
    SORT_BY_ORDER_FEE,                                       // Sort by deal fee
    SORT_BY_ORDER_PROFIT,                                    // Sort by profit
    SORT_BY_ORDER_COMMISSION,                                // Sort by commission
    SORT_BY_ORDER_SWAP,                                      // Sort by swap
    SORT_BY_ORDER_VOLUME,                                    // Sort by volume
    SORT_BY_ORDER_VOLUME_CURRENT,                            // Sort by unexecuted volume
    SORT_BY_ORDER_PROFIT_FULL,                               // Sort by profit+commission+swap
    SORT_BY_ORDER_PRICE_STOP_LIMIT,                          // Sort by Limit order when StopLimit order is activated
    //--- Sort by string properties
    SORT_BY_ORDER_SYMBOL = FIRST_ORD_STR_PROP,               // Sort by symbol
    SORT_BY_ORDER_COMMENT,                                   // Sort by comment
    SORT_BY_ORDER_COMMENT_EXT,                               // Sort by custom comment
    SORT_BY_ORDER_EXT_ID                                     // Sort by order ID in an external trading system
  };
//+------------------------------------------------------------------+
//| Event status                                                     |
//+------------------------------------------------------------------+
enum ENUM_EVENT_STATUS
  {
   EVENT_STATUS_MARKET_POSITION,                            // Market position event (opening, partial opening, partial closing, adding volume, reversal)
   EVENT_STATUS_MARKET_PENDING,                             // Market pending order event (placing)
   EVENT_STATUS_HISTORY_PENDING,                            // Historical pending order event (removal)
   EVENT_STATUS_HISTORY_POSITION,                           // Historical position event (closing)
   EVENT_STATUS_BALANCE,                                    // Balance operation event (accruing balance, withdrawing funds and events from the ENUM_DEAL_TYPE enumeration)
   EVENT_STATUS_MODIFY                                      // Order/position modification event
  };
//+------------------------------------------------------------------+
//| Event reason                                                     |
//+------------------------------------------------------------------+
enum ENUM_EVENT_REASON
  {
    EVENT_REASON_REVERSE,                                    // Position reversal (netting)
    EVENT_REASON_REVERSE_PARTIALLY,                          // Position reversal by partial request execution (netting)
    EVENT_REASON_REVERSE_BY_PENDING,                         // Position reversal by pending order activation (netting)
    EVENT_REASON_REVERSE_BY_PENDING_PARTIALLY,               // Position reversal in case of a pending order partial execution (netting)
    //--- All constants related to a position reversal should be located in the above list
    EVENT_REASON_ACTIVATED_PENDING,                          // Pending order activation
    EVENT_REASON_ACTIVATED_PENDING_PARTIALLY,                // Pending order partial activation
    EVENT_REASON_STOPLIMIT_TRIGGERED,                        // StopLimit order activation
    EVENT_REASON_MODIFY,                                     // Modification
    EVENT_REASON_CANCEL,                                     // Cancelation
    EVENT_REASON_EXPIRED,                                    // Order expiration
    EVENT_REASON_DONE,                                       // Request executed in full
    EVENT_REASON_DONE_PARTIALLY,                             // Request executed partially
    EVENT_REASON_VOLUME_ADD,                                 // Add volume to a position (netting)
    EVENT_REASON_VOLUME_ADD_PARTIALLY,                       // Add volume to a position by a partial request execution (netting)
    EVENT_REASON_VOLUME_ADD_BY_PENDING,                      // Add volume to a position when a pending order is activated (netting)
    EVENT_REASON_VOLUME_ADD_BY_PENDING_PARTIALLY,            // Add volume to a position when a pending order is partially executed (netting)
    EVENT_REASON_DONE_SL,                                    // Closing by StopLoss
    EVENT_REASON_DONE_SL_PARTIALLY,                          // Partial closing by StopLoss
    EVENT_REASON_DONE_TP,                                    // Closing by TakeProfit
    EVENT_REASON_DONE_TP_PARTIALLY,                          // Partial closing by TakeProfit
    EVENT_REASON_DONE_BY_POS,                                // Closing by an opposite position
    EVENT_REASON_DONE_PARTIALLY_BY_POS,                      // Partial closing by an opposite position
    EVENT_REASON_DONE_BY_POS_PARTIALLY,                      // Closing an opposite position by a partial volume
    EVENT_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY,            // Partial closing of an opposite position by a partial volume
    //--- Constants related to DEAL_TYPE_BALANCE deal type from the ENUM_DEAL_TYPE enumeration
    EVENT_REASON_BALANCE_REFILL,                             // Refilling the balance
    EVENT_REASON_BALANCE_WITHDRAWAL,                         // Withdrawing funds from the account
    //--- List of constants is relevant to TRADE_EVENT_ACCOUNT_CREDIT from the ENUM_TRADE_EVENT enumeration and shifted to +13 relative to ENUM_DEAL_TYPE (EVENT_REASON_ACCOUNT_CREDIT-3)
     EVENT_REASON_ACCOUNT_CREDIT,                             // Accruing credit
     EVENT_REASON_ACCOUNT_CHARGE,                             // Additional charges
     EVENT_REASON_ACCOUNT_CORRECTION,                         // Correcting entry
     EVENT_REASON_ACCOUNT_BONUS,                              // Accruing bonuses
     EVENT_REASON_ACCOUNT_COMISSION,                          // Additional commissions
     EVENT_REASON_ACCOUNT_COMISSION_DAILY,                    // Commission charged at the end of a trading day
     EVENT_REASON_ACCOUNT_COMISSION_MONTHLY,                  // Commission charged at the end of a trading month
     EVENT_REASON_ACCOUNT_COMISSION_AGENT_DAILY,              // Agent commission charged at the end of a trading day
     EVENT_REASON_ACCOUNT_COMISSION_AGENT_MONTHLY,            // Agent commission charged at the end of a month
     EVENT_REASON_ACCOUNT_INTEREST,                           // Accruing interest on free funds
     EVENT_REASON_BUY_CANCELLED,                              // Canceled buy deal
     EVENT_REASON_SELL_CANCELLED,                             // Canceled sell deal
     EVENT_REASON_DIVIDENT,                                   // Accruing dividends
     EVENT_REASON_DIVIDENT_FRANKED,                           // Accruing franked dividends
     EVENT_REASON_TAX                                         // Tax
  };
#define REASON_EVENT_SHIFT    (EVENT_REASON_ACCOUNT_CREDIT-3)
//+------------------------------------------------------------------+
//| Event's integer properties                                       |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_INTEGER
  {
    EVENT_PROP_TYPE_EVENT = 0,                               // Account trading event type (from the ENUM_TRADE_EVENT enumeration)
    EVENT_PROP_TIME_EVENT,                                   // Event time in milliseconds
    EVENT_PROP_STATUS_EVENT,                                 // Event status (from the ENUM_EVENT_STATUS enumeration)
    EVENT_PROP_REASON_EVENT,                                 // Event reason (from the ENUM_EVENT_REASON enumeration)
   //---
    EVENT_PROP_TYPE_DEAL_EVENT,                              // Deal event type
    EVENT_PROP_TICKET_DEAL_EVENT,                            // Deal event ticket
    EVENT_PROP_TYPE_ORDER_EVENT,                             // Type of the order, based on which a deal event is opened (the last position order)
    EVENT_PROP_TICKET_ORDER_EVENT,                           // Ticket of the order, based on which a deal event is opened (the last position order)
   //---
    EVENT_PROP_TIME_ORDER_POSITION,                          // Time of the order, based on which the first position deal is opened (the first position order on a hedge account)
    EVENT_PROP_TYPE_ORDER_POSITION,                          // Type of the order, based on which the first position deal is opened (the first position order on a hedge account)
    EVENT_PROP_TICKET_ORDER_POSITION,                        // Ticket of the order, based on which the first position deal is opened (the first position order on a hedge account)
    EVENT_PROP_POSITION_ID,                                  // Position ID
   //---
    EVENT_PROP_POSITION_BY_ID,                               // Opposite position ID
    EVENT_PROP_MAGIC_ORDER,                                  // Order/deal/position magic number
    EVENT_PROP_MAGIC_BY_ID,                                  // Opposite position magic number
   //---
    EVENT_PROP_TYPE_ORD_POS_BEFORE,                          // Position type before changing the direction
    EVENT_PROP_TICKET_ORD_POS_BEFORE,                        // Position order ticket before changing direction
    EVENT_PROP_TYPE_ORD_POS_CURRENT,                         // Current position type
    EVENT_PROP_TICKET_ORD_POS_CURRENT,                       // Current position order ticket
  }; 
#define EVENT_PROP_INTEGER_TOTAL (19)                       // Total number of integer event properties
#define EVENT_PROP_INTEGER_SKIP  (4)                        // Number of order properties not used in sorting
//+------------------------------------------------------------------+
//| Event's real properties                                          |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_DOUBLE
  {
    EVENT_PROP_PRICE_EVENT = EVENT_PROP_INTEGER_TOTAL,       // Price an event occurred at
    EVENT_PROP_PRICE_OPEN,                                   // Order/deal/position open price
    EVENT_PROP_PRICE_CLOSE,                                  // Order/deal/position close price
    EVENT_PROP_PRICE_SL,                                     // StopLoss order/deal/position price
    EVENT_PROP_PRICE_TP,                                     // TakeProfit Order/deal/position
    EVENT_PROP_VOLUME_ORDER_INITIAL,                         // Requested order volume
    EVENT_PROP_VOLUME_ORDER_EXECUTED,                        // Executed order volume
    EVENT_PROP_VOLUME_ORDER_CURRENT,                         // Remaining (unexecuted) order volume
    EVENT_PROP_VOLUME_POSITION_EXECUTED,                     // Current executed position volume after a deal
    EVENT_PROP_PROFIT,                                       // Profit
   //---
    EVENT_PROP_PRICE_OPEN_BEFORE,                            // Order price before modification
    EVENT_PROP_PRICE_SL_BEFORE,                              // StopLoss price before modification
    EVENT_PROP_PRICE_TP_BEFORE,                              // TakeProfit price before modification
    EVENT_PROP_PRICE_EVENT_ASK,                              // Ask price during an event
    EVENT_PROP_PRICE_EVENT_BID,                              // Bid price during an event
  };
#define EVENT_PROP_DOUBLE_TOTAL  (15)                       // Total number of event's real properties
#define EVENT_PROP_DOUBLE_SKIP   (5)                        // Number of order properties not used in sorting
//+------------------------------------------------------------------+
//| Event's string properties                                        |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_STRING
  {
   EVENT_PROP_SYMBOL = (EVENT_PROP_INTEGER_TOTAL+EVENT_PROP_DOUBLE_TOTAL), // Order symbol
   EVENT_PROP_SYMBOL_BY_ID                                  // Opposite position symbol
  };
#define EVENT_PROP_STRING_TOTAL     (2)                     // Total number of event's string properties
//+------------------------------------------------------------------+
//| Possible event sorting criteria                                  |
//+------------------------------------------------------------------+
#define FIRST_EVN_DBL_PROP       (EVENT_PROP_INTEGER_TOTAL-EVENT_PROP_INTEGER_SKIP)
#define FIRST_EVN_STR_PROP       (EVENT_PROP_INTEGER_TOTAL-EVENT_PROP_INTEGER_SKIP+EVENT_PROP_DOUBLE_TOTAL-EVENT_PROP_DOUBLE_SKIP)
enum ENUM_SORT_EVENTS_MODE
  {
   //--- Sort by integer properties
    SORT_BY_EVENT_TYPE_EVENT = 0,                            // Sort by event type
    SORT_BY_EVENT_TIME_EVENT,                                // Sort by event time
    SORT_BY_EVENT_STATUS_EVENT,                              // Sort by event status (from the ENUM_EVENT_STATUS enumeration)
    SORT_BY_EVENT_REASON_EVENT,                              // Sort by event reason (from the ENUM_EVENT_REASON enumeration)
    SORT_BY_EVENT_TYPE_DEAL_EVENT,                           // Sort by deal event type
    SORT_BY_EVENT_TICKET_DEAL_EVENT,                         // Sort by deal event ticket
    SORT_BY_EVENT_TYPE_ORDER_EVENT,                          // Sort by type of an order, based on which a deal event is opened (the last position order)
    SORT_BY_EVENT_TICKET_ORDER_EVENT,                        // Sort by a ticket of an order, based on which a deal event is opened (the last position order)
    SORT_BY_EVENT_TIME_ORDER_POSITION,                       // Sort by time of an order, based on which a position deal is opened (the first position order)
    SORT_BY_EVENT_TYPE_ORDER_POSITION,                       // Sort by type of an order, based on which a position deal is opened (the first position order)
    SORT_BY_EVENT_TICKET_ORDER_POSITION,                     // Sort by a ticket of an order, based on which a position deal is opened (the first position order)
    SORT_BY_EVENT_POSITION_ID,                               // Sort by position ID
    SORT_BY_EVENT_POSITION_BY_ID,                            // Sort by opposite position ID
    SORT_BY_EVENT_MAGIC_ORDER,                               // Sort by order/deal/position magic number
    SORT_BY_EVENT_MAGIC_BY_ID,                               // Sort by an opposite position magic number
   //--- Sort by real properties
    SORT_BY_EVENT_PRICE_EVENT = FIRST_EVN_DBL_PROP,          // Sort by a price an event occurred at
    SORT_BY_EVENT_PRICE_OPEN,                                // Sort by position open price
    SORT_BY_EVENT_PRICE_CLOSE,                               // Sort by position close price
    SORT_BY_EVENT_PRICE_SL,                                  // Sort by position StopLoss price
    SORT_BY_EVENT_PRICE_TP,                                  // Sort by position TakeProfit price
    SORT_BY_EVENT_VOLUME_ORDER_INITIAL,                      // Sort by initial volume
    SORT_BY_EVENT_VOLUME_ORDER_EXECUTED,                     // Sort by the current volume
    SORT_BY_EVENT_VOLUME_ORDER_CURRENT,                      // Sort by remaining volume
    SORT_BY_EVENT_VOLUME_POSITION_EXECUTED,                  // Sort by the current executed position volume after a deal
    SORT_BY_EVENT_PROFIT,   // Sort by profit
   //--- Sort by string properties
    SORT_BY_EVENT_SYMBOL = FIRST_EVN_STR_PROP,               // Sort by order/position/deal symbol
    SORT_BY_EVENT_SYMBOL_BY_ID                               // Sort by an opposite position symbol
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with accounts                                   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Account integer properties                                       |
//+------------------------------------------------------------------+
enum ENUM_ACCOUNT_PROP_INTEGER
  {
   ACCOUNT_PROP_LOGIN,                                      // Account number
   ACCOUNT_PROP_TRADE_MODE,                                 // Trading account type
   ACCOUNT_PROP_LEVERAGE,                                   // Leverage
   ACCOUNT_PROP_LIMIT_ORDERS,                               // Maximum allowed number of active pending orders
   ACCOUNT_PROP_MARGIN_SO_MODE,                             // Mode of setting the minimum available margin level
   ACCOUNT_PROP_TRADE_ALLOWED,                              // Permission to trade for the current account from the server side
   ACCOUNT_PROP_TRADE_EXPERT,                               // Permission to trade for an EA from the server side
   ACCOUNT_PROP_MARGIN_MODE,                                // Margin calculation mode
   ACCOUNT_PROP_CURRENCY_DIGITS,                            // Number of digits for an account currency necessary for accurate display of trading results
   ACCOUNT_PROP_SERVER_TYPE,                                // Trade server type (MetaTrader 5, MetaTrader 4)
   ACCOUNT_PROP_FIFO_CLOSE,                                 // Flag of a position closure by FIFO rule only
   ACCOUNT_PROP_HEDGE_ALLOWED                               // Permission to open opposite positions and set pending orders
  };
#define ACCOUNT_PROP_INTEGER_TOTAL    (12)                  // Total number of integer properties
#define ACCOUNT_PROP_INTEGER_SKIP     (0)                   // Number of integer account properties not used in sorting
//+------------------------------------------------------------------+
//| Account real properties                                          |
//+------------------------------------------------------------------+
enum ENUM_ACCOUNT_PROP_DOUBLE
  {
   ACCOUNT_PROP_BALANCE = ACCOUNT_PROP_INTEGER_TOTAL,       // Account balance in a deposit currency
   ACCOUNT_PROP_CREDIT,                                     // Credit in a deposit currency
   ACCOUNT_PROP_PROFIT,                                     // Current profit on an account in the account currency
   ACCOUNT_PROP_EQUITY,                                     // Equity on an account in the deposit currency
   ACCOUNT_PROP_MARGIN,                                     // Reserved margin on an account in the deposit currency
   ACCOUNT_PROP_MARGIN_FREE,                                // Free funds available for opening a position on an account in the deposit currency
   ACCOUNT_PROP_MARGIN_LEVEL,                               // Margin level on an account in %
   ACCOUNT_PROP_MARGIN_SO_CALL,                             // Margin Call level
   ACCOUNT_PROP_MARGIN_SO_SO,                               // Stop Out level
   ACCOUNT_PROP_MARGIN_INITIAL,                             // Funds reserved on an account to ensure a guarantee amount for all pending orders 
   ACCOUNT_PROP_MARGIN_MAINTENANCE,                         // Funds reserved on an account to ensure a minimum amount for all open positions
   ACCOUNT_PROP_ASSETS,                                     // Current assets on an account
   ACCOUNT_PROP_LIABILITIES,                                // Current liabilities on an account
   ACCOUNT_PROP_COMMISSION_BLOCKED                          // Current sum of blocked commissions on an account
  };
#define ACCOUNT_PROP_DOUBLE_TOTAL     (14)                  // Total number of account real properties
#define ACCOUNT_PROP_DOUBLE_SKIP      (0)                   // Number of real account properties not used in sorting
//+------------------------------------------------------------------+
//| Account string properties                                        |
//+------------------------------------------------------------------+
enum ENUM_ACCOUNT_PROP_STRING
  {
   ACCOUNT_PROP_NAME = (ACCOUNT_PROP_INTEGER_TOTAL+ACCOUNT_PROP_DOUBLE_TOTAL), // Client name
   ACCOUNT_PROP_SERVER,                                     // Trade server name
   ACCOUNT_PROP_CURRENCY,                                   // Deposit currency
   ACCOUNT_PROP_COMPANY                                     // Name of a company serving an account
  };
#define ACCOUNT_PROP_STRING_TOTAL     (4)                   // Total number of account string properties
#define ACCOUNT_PROP_STRING_SKIP      (0)                   // Number of string account properties not used in sorting
//+------------------------------------------------------------------+
//| Possible account sorting criteria                                |
//+------------------------------------------------------------------+
#define FIRST_ACC_DBL_PROP            (ACCOUNT_PROP_INTEGER_TOTAL-ACCOUNT_PROP_INTEGER_SKIP)
#define FIRST_ACC_STR_PROP            (ACCOUNT_PROP_INTEGER_TOTAL-ACCOUNT_PROP_INTEGER_SKIP+ACCOUNT_PROP_DOUBLE_TOTAL-ACCOUNT_PROP_DOUBLE_SKIP)
enum ENUM_SORT_ACCOUNT_MODE
  {
   //--- Sort by integer properties
    SORT_BY_ACCOUNT_LOGIN = 0,                               // Sort by account number
    SORT_BY_ACCOUNT_TRADE_MODE,                              // Sort by trading account type
    SORT_BY_ACCOUNT_LEVERAGE,                                // Sort by leverage
    SORT_BY_ACCOUNT_LIMIT_ORDERS,                            // Sort by maximum acceptable number of existing pending orders
    SORT_BY_ACCOUNT_MARGIN_SO_MODE,                          // Sort by mode for setting the minimum acceptable margin level
    SORT_BY_ACCOUNT_TRADE_ALLOWED,                           // Sort by permission to trade for the current account
    SORT_BY_ACCOUNT_TRADE_EXPERT,                            // Sort by permission to trade for an EA
    SORT_BY_ACCOUNT_MARGIN_MODE,                             // Sort by margin calculation mode
    SORT_BY_ACCOUNT_CURRENCY_DIGITS,                         // Sort by number of digits for an account currency
    SORT_BY_ACCOUNT_SERVER_TYPE,                             // Sort by trade server type (MetaTrader 5, MetaTrader 4)
    SORT_BY_ACCOUNT_FIFO_CLOSE,                              // Sort by the flag of a position closure by FIFO rule only
    SORT_BY_ACCOUNT_HEDGE_ALLOWED,                           // Sort by permission to open opposite positions and set pending orders
   //--- Sort by real properties
    SORT_BY_ACCOUNT_BALANCE = FIRST_ACC_DBL_PROP,            // Sort by an account balance in the deposit currency
    SORT_BY_ACCOUNT_CREDIT,                                  // Sort by credit in a deposit currency
    SORT_BY_ACCOUNT_PROFIT,                                  // Sort by the current profit on an account in the deposit currency
    SORT_BY_ACCOUNT_EQUITY,                                  // Sort by an account equity in the deposit currency
    SORT_BY_ACCOUNT_MARGIN,                                  // Sort by an account reserved margin in the deposit currency
    SORT_BY_ACCOUNT_MARGIN_FREE,                             // Sort by account free funds available for opening a position in the deposit currency
    SORT_BY_ACCOUNT_MARGIN_LEVEL,                            // Sort by account margin level in %
    SORT_BY_ACCOUNT_MARGIN_SO_CALL,                          // Sort by margin level requiring depositing funds to an account (Margin Call)
    SORT_BY_ACCOUNT_MARGIN_SO_SO,                            // Sort by margin level, at which the most loss-making position is closed (Stop Out)
    SORT_BY_ACCOUNT_MARGIN_INITIAL,                          // Sort by funds reserved on an account to ensure a guarantee amount for all pending orders 
    SORT_BY_ACCOUNT_MARGIN_MAINTENANCE,                      // Sort by funds reserved on an account to ensure a minimum amount for all open positions
    SORT_BY_ACCOUNT_ASSETS,                                  // Sort by the amount of the current assets on an account
    SORT_BY_ACCOUNT_LIABILITIES,                             // Sort by the current liabilities on an account
    SORT_BY_ACCOUNT_COMMISSION_BLOCKED,                      // Sort by the current amount of blocked commissions on an account
   //--- Sort by string properties
    SORT_BY_ACCOUNT_NAME = FIRST_ACC_STR_PROP,               // Sort by a client name
    SORT_BY_ACCOUNT_SERVER,                                  // Sort by a trade server name
    SORT_BY_ACCOUNT_CURRENCY,                                // Sort by a deposit currency
    SORT_BY_ACCOUNT_COMPANY                                  // Sort by a name of a company serving an account
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with symbols                                    |
//+------------------------------------------------------------------+
//| Abstract symbol type (status)                                    |
//+------------------------------------------------------------------+
enum ENUM_SYMBOL_STATUS
  {
   SYMBOL_STATUS_FX,                                        // Forex symbol
   SYMBOL_STATUS_FX_MAJOR,                                  // Major Forex symbol
   SYMBOL_STATUS_FX_MINOR,                                  // Minor Forex symbol
   SYMBOL_STATUS_FX_EXOTIC,                                 // Exotic Forex symbol
   SYMBOL_STATUS_FX_RUB,                                    // Forex symbol/RUR
   SYMBOL_STATUS_METAL,                                     // Metal
   SYMBOL_STATUS_INDEX,                                     // Index
   SYMBOL_STATUS_INDICATIVE,                                // Indicative
   SYMBOL_STATUS_CRYPTO,                                    // Cryptocurrency symbol
   SYMBOL_STATUS_COMMODITY,                                 // Commodity symbol
   SYMBOL_STATUS_EXCHANGE,                                  // Exchange symbol
   SYMBOL_STATUS_FUTURES,                                   // Futures
   SYMBOL_STATUS_CFD,                                       // CFD
   SYMBOL_STATUS_STOCKS,                                    // Stock
   SYMBOL_STATUS_BONDS,                                     // Bond
   SYMBOL_STATUS_OPTION,                                    // Option
   SYMBOL_STATUS_COLLATERAL,                                // Non-tradable asset
   SYMBOL_STATUS_CUSTOM,                                    // Custom symbol
   SYMBOL_STATUS_COMMON                                     // General category
  };
//+------------------------------------------------------------------+
//| Symbol integer properties                                        |
//+------------------------------------------------------------------+
enum ENUM_SYMBOL_PROP_INTEGER
  {
    SYMBOL_PROP_STATUS = 0,                                  // Symbol status
    SYMBOL_PROP_INDEX_MW,                                    // Symbol index in the Market Watch window
    SYMBOL_PROP_SECTOR,                                      // Economy sector the asset belongs to
    SYMBOL_PROP_INDUSTRY,                                    // Industry or the economy branch the symbol belongs to
    SYMBOL_PROP_CUSTOM,                                      // Custom symbol flag
    SYMBOL_PROP_CHART_MODE,                                  // The price type used for generating bars – Bid or Last (from the ENUM_SYMBOL_CHART_MODE enumeration)
    SYMBOL_PROP_EXIST,                                       // Flag indicating that the symbol under this name exists
    SYMBOL_PROP_SELECT,                                      // An indication that the symbol is selected in Market Watch
    SYMBOL_PROP_VISIBLE,                                     // An indication that the symbol is displayed in Market Watch
    SYMBOL_PROP_SESSION_DEALS,                               // The number of deals in the current session 
    SYMBOL_PROP_SESSION_BUY_ORDERS,                          // The total number of Buy orders at the moment
    SYMBOL_PROP_SESSION_SELL_ORDERS,                         // The total number of Sell orders at the moment
    SYMBOL_PROP_VOLUME,                                      // Last deal volume
    SYMBOL_PROP_VOLUMEHIGH,                                  // Maximum volume within a day
    SYMBOL_PROP_VOLUMELOW,                                   // Minimum volume within a day
    SYMBOL_PROP_TIME,                                        // Latest quote time
    SYMBOL_PROP_TIME_MSC,                                    // Time of the last quote in milliseconds
    SYMBOL_PROP_DIGITS,                                      // Number of decimal places
    SYMBOL_PROP_DIGITS_LOTS,                                 // Number of decimal places for a lot
    SYMBOL_PROP_SPREAD,                                      // Spread in points
    SYMBOL_PROP_SPREAD_FLOAT,                                // Floating spread flag
    SYMBOL_PROP_TICKS_BOOKDEPTH,                             // Maximum number of orders displayed in the Depth of Market
    SYMBOL_PROP_BOOKDEPTH_STATE,                             // Flag of subscription to DOM
    SYMBOL_PROP_TRADE_CALC_MODE,                             // Contract price calculation method (from the ENUM_SYMBOL_CALC_MODE enumeration)
    SYMBOL_PROP_TRADE_MODE,                                  // Order execution type (from the ENUM_SYMBOL_TRADE_MODE enumeration)
    SYMBOL_PROP_START_TIME,                                  // Symbol trading start date (usually used for futures)
    SYMBOL_PROP_EXPIRATION_TIME,                             // Symbol trading end date (usually used for futures)
    SYMBOL_PROP_TRADE_STOPS_LEVEL,                           // Minimum distance in points from the current close price for setting Stop orders
    SYMBOL_PROP_TRADE_FREEZE_LEVEL,                          // Freeze distance for trading operations (in points)
    SYMBOL_PROP_TRADE_EXEMODE,                               // Deal execution mode (from the ENUM_SYMBOL_TRADE_EXECUTION enumeration)
    SYMBOL_PROP_SWAP_MODE,                                   // Swap calculation model (from the ENUM_SYMBOL_SWAP_MODE enumeration)
    SYMBOL_PROP_SWAP_ROLLOVER3DAYS,                          // Triple-day swap (from the ENUM_DAY_OF_WEEK enumeration)
    SYMBOL_PROP_MARGIN_HEDGED_USE_LEG,                       // Calculating hedging margin using the larger leg (Buy or Sell)
    SYMBOL_PROP_EXPIRATION_MODE,                             // Flags of allowed order expiration modes
    SYMBOL_PROP_FILLING_MODE,                                // Flags of allowed order filling modes
    SYMBOL_PROP_ORDER_MODE,                                  // The flags of allowed order types
    SYMBOL_PROP_ORDER_GTC_MODE,                              // Expiration of Stop Loss and Take Profit orders if SYMBOL_EXPIRATION_MODE=SYMBOL_EXPIRATION_GTC (from the ENUM_SYMBOL_ORDER_GTC_MODE enumeration)
    SYMBOL_PROP_OPTION_MODE,                                 // Option type (from the ENUM_SYMBOL_OPTION_MODE enumeration)
    SYMBOL_PROP_OPTION_RIGHT,                                // Option right (Call/Put) (from the ENUM_SYMBOL_OPTION_RIGHT enumeration)
    SYMBOL_PROP_SUBSCRIPTION_DELAY,                          // Delay for quotes passed by symbol for instruments working on subscription basis
   //--- skipped property
    SYMBOL_PROP_BACKGROUND_COLOR                             // The color of the background used for the symbol in Market Watch
  }; 
#define SYMBOL_PROP_INTEGER_TOTAL    (41)                   // Total number of integer properties
#define SYMBOL_PROP_INTEGER_SKIP     (1)                    // Number of symbol integer properties not used in sorting
//+------------------------------------------------------------------+
//| Symbol real properties                                           |
//+------------------------------------------------------------------+
enum ENUM_SYMBOL_PROP_DOUBLE
  {
   SYMBOL_PROP_BID = SYMBOL_PROP_INTEGER_TOTAL,             // Bid - the best price at which a symbol can be sold
   SYMBOL_PROP_BIDHIGH,                                     // The highest Bid price of the day
   SYMBOL_PROP_BIDLOW,                                      // The lowest Bid price of the day
   SYMBOL_PROP_ASK,                                         // Ask - best price, at which an instrument can be bought
   SYMBOL_PROP_ASKHIGH,                                     // The highest Ask price of the day
   SYMBOL_PROP_ASKLOW,                                      // The lowest Ask price of the day
   SYMBOL_PROP_LAST,                                        // The price at which the last deal was executed
   SYMBOL_PROP_LASTHIGH,                                    // The highest Last price of the day
   SYMBOL_PROP_LASTLOW,                                     // The lowest Last price of the day
   SYMBOL_PROP_VOLUME_REAL,                                 // Volume of the day
   SYMBOL_PROP_VOLUMEHIGH_REAL,                             // Maximum volume within a day
   SYMBOL_PROP_VOLUMELOW_REAL,                              // Minimum volume within a day
   SYMBOL_PROP_OPTION_STRIKE,                               // Option execution price
   SYMBOL_PROP_POINT,                                       // One point value
   SYMBOL_PROP_TRADE_TICK_VALUE,                            // SYMBOL_TRADE_TICK_VALUE_PROFIT value
   SYMBOL_PROP_TRADE_TICK_VALUE_PROFIT,                     // Calculated tick value for a winning position
   SYMBOL_PROP_TRADE_TICK_VALUE_LOSS,                       // Calculated tick value for a losing position
   SYMBOL_PROP_TRADE_TICK_SIZE,                             // Minimal price change
   SYMBOL_PROP_TRADE_CONTRACT_SIZE,                         // Trade contract size
   SYMBOL_PROP_TRADE_ACCRUED_INTEREST,                      // Accrued interest
   SYMBOL_PROP_TRADE_FACE_VALUE,                            // Face value – initial bond value set by an issuer
   SYMBOL_PROP_TRADE_LIQUIDITY_RATE,                        // Liquidity rate – the share of an asset that can be used for a margin
   SYMBOL_PROP_VOLUME_MIN,                                  // Minimum volume for a deal
   SYMBOL_PROP_VOLUME_MAX,                                  // Maximum volume for a deal
   SYMBOL_PROP_VOLUME_STEP,                                 // Minimum volume change step for deal execution
   SYMBOL_PROP_VOLUME_LIMIT,                                // The maximum allowed total volume of an open position and pending orders in one direction (either buy or sell)
   SYMBOL_PROP_SWAP_LONG,                                   // Long swap value
   SYMBOL_PROP_SWAP_SHORT,                                  // Short swap value
   SYMBOL_PROP_MARGIN_INITIAL,                              // Initial margin
   SYMBOL_PROP_MARGIN_MAINTENANCE,                          // Maintenance margin for an instrument
   SYMBOL_PROP_MARGIN_LONG_INITIAL,                         // Initial margin requirement applicable to long positions
   SYMBOL_PROP_MARGIN_BUY_STOP_INITIAL,                     // Initial margin requirement applicable to BuyStop orders
   SYMBOL_PROP_MARGIN_BUY_LIMIT_INITIAL,                    // Initial margin requirement applicable to BuyLimit orders
   SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_INITIAL,                // Initial margin requirement applicable to BuyStopLimit orders
   SYMBOL_PROP_MARGIN_LONG_MAINTENANCE,                     // Maintenance margin requirement applicable to long positions
   SYMBOL_PROP_MARGIN_BUY_STOP_MAINTENANCE,                 // Maintenance margin requirement applicable to BuyStop orders
   SYMBOL_PROP_MARGIN_BUY_LIMIT_MAINTENANCE,                // Maintenance margin requirement applicable to BuyLimit orders
   SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_MAINTENANCE,            // Maintenance margin requirement applicable to BuyStopLimit orders
   SYMBOL_PROP_MARGIN_SHORT_INITIAL,                        // Initial margin requirement applicable to short positions
   SYMBOL_PROP_MARGIN_SELL_STOP_INITIAL,                    // Initial margin requirement applicable to SellStop orders
   SYMBOL_PROP_MARGIN_SELL_LIMIT_INITIAL,                   // Initial margin requirement applicable to SellLimit orders
   SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_INITIAL,               // Initial margin requirement applicable to SellStopLimit orders
   SYMBOL_PROP_MARGIN_SHORT_MAINTENANCE,                    // Maintenance margin requirement applicable to short positions
   SYMBOL_PROP_MARGIN_SELL_STOP_MAINTENANCE,                // Maintenance margin requirement applicable to SellStop orders
   SYMBOL_PROP_MARGIN_SELL_LIMIT_MAINTENANCE,               // Maintenance margin requirement applicable to SellLimit orders
   SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_MAINTENANCE,           // Maintenance margin requirement applicable to SellStopLimit orders
   SYMBOL_PROP_SESSION_VOLUME,                              // The total volume of deals in the current session
   SYMBOL_PROP_SESSION_TURNOVER,                            // The total turnover in the current session
   SYMBOL_PROP_SESSION_INTEREST,                            // The total volume of open positions
   SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME,                   // The total volume of Buy orders at the moment
   SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME,                  // The total volume of Sell orders at the moment
   SYMBOL_PROP_SESSION_OPEN,                                // Open price of the session
   SYMBOL_PROP_SESSION_CLOSE,                               // Close price of the session
   SYMBOL_PROP_SESSION_AW,                                  // The average weighted price of the session
   SYMBOL_PROP_SESSION_PRICE_SETTLEMENT,                    // The settlement price of the current session
   SYMBOL_PROP_SESSION_PRICE_LIMIT_MIN,                     // Minimum allowable price value for the session 
   SYMBOL_PROP_SESSION_PRICE_LIMIT_MAX,                     // Maximum allowable price value for the session
   SYMBOL_PROP_MARGIN_HEDGED,                               // Size of a contract or margin for one lot of hedged positions (oppositely directed positions at one symbol).
   SYMBOL_PROP_PRICE_CHANGE,                                // Change of the current price relative to the end of the previous trading day in %
   SYMBOL_PROP_PRICE_VOLATILITY,                            // Price volatility in %
   SYMBOL_PROP_PRICE_THEORETICAL,                           // Theoretical option price
   SYMBOL_PROP_PRICE_DELTA,                                 // Option/warrant delta. Shows the value the option price changes by, when the underlying asset price changes by 1
   SYMBOL_PROP_PRICE_THETA,                                 // Option/warrant theta. Number of points the option price is to lose every day due to a temporary breakup, i.e. when the expiration date approaches
   SYMBOL_PROP_PRICE_GAMMA,                                 // Option/warrant gamma. Shows the change rate of delta – how quickly or slowly the option premium changes
   SYMBOL_PROP_PRICE_VEGA,                                  // Option/warrant vega. Shows the number of points the option price changes by when the volatility changes by 1%
   SYMBOL_PROP_PRICE_RHO,                                   // Option/warrant rho. Reflects the sensitivity of the theoretical option price to the interest rate changing by 1%
   SYMBOL_PROP_PRICE_OMEGA,                                 // Option/warrant omega. Option elasticity – a relative percentage change of the option price by the percentage change of the underlying asset price
   SYMBOL_PROP_PRICE_SENSITIVITY,                           // Option/warrant sensitivity.  Shows by how many points the price of the option's underlying asset should change so that the price of the option changes by one point
   SYMBOL_PROP_SWAP_SUNDAY,                                 // Swap accrual ratio (Sunday)
   SYMBOL_PROP_SWAP_MONDAY,                                 // Swap accrual ratio (Monday)
   SYMBOL_PROP_SWAP_TUESDAY,                                // Swap accrual ratio (Tuesday)
   SYMBOL_PROP_SWAP_WEDNESDAY,                              // Swap accrual ratio (Wednesday)
   SYMBOL_PROP_SWAP_THURSDAY,                               // Swap accrual ratio (Thursday)
   SYMBOL_PROP_SWAP_FRIDAY,                                 // Swap accrual ratio (Friday)
   SYMBOL_PROP_SWAP_SATURDAY,                               // Swap accrual ratio (Saturday)
  };
#define SYMBOL_PROP_DOUBLE_TOTAL     (75)                   // Total number of real properties
#define SYMBOL_PROP_DOUBLE_SKIP      (0)                    // Number of real symbol properties not used in sorting
//+------------------------------------------------------------------+
//| Symbol string properties                                         |
//+------------------------------------------------------------------+
enum ENUM_SYMBOL_PROP_STRING
  {
   SYMBOL_PROP_NAME = (SYMBOL_PROP_INTEGER_TOTAL+SYMBOL_PROP_DOUBLE_TOTAL),   // Symbol name
   SYMBOL_PROP_BASIS,                                       // The name of the underlaying asset for a derivative symbol
   SYMBOL_PROP_CURRENCY_BASE,                               // Instrument base currency
   SYMBOL_PROP_CURRENCY_PROFIT,                             // Profit currency
   SYMBOL_PROP_CURRENCY_MARGIN,                             // Margin currency
   SYMBOL_PROP_BANK,                                        // The source of the current quote
   SYMBOL_PROP_DESCRIPTION,                                 // String description of a symbol
   SYMBOL_PROP_FORMULA,                                     // The formula used for custom symbol pricing
   SYMBOL_PROP_ISIN,                                        // The name of a trading symbol in the international system of securities identification numbers (ISIN)
   SYMBOL_PROP_PAGE,                                        // The web page containing symbol information
   SYMBOL_PROP_PATH,                                        // Location in the symbol tree
   SYMBOL_PROP_CATEGORY,                                    // Symbol category
   SYMBOL_PROP_EXCHANGE,                                    // Name of an exchange a symbol is traded on
   SYMBOL_PROP_COUNTRY,                                     // Country the trading instrument belongs to
   SYMBOL_PROP_SECTOR_NAME,                                 // Economy sector the trading instrument belongs to
   SYMBOL_PROP_INDUSTRY_NAME,                               // Economy or industry branch the trading instrument belongs to
  };
#define SYMBOL_PROP_STRING_TOTAL     (16)                   // Total number of string properties
//+------------------------------------------------------------------+
//| Possible symbol sorting criteria                                 |
//+------------------------------------------------------------------+
#define FIRST_SYM_DBL_PROP          (SYMBOL_PROP_INTEGER_TOTAL-SYMBOL_PROP_INTEGER_SKIP)
#define FIRST_SYM_STR_PROP          (SYMBOL_PROP_INTEGER_TOTAL-SYMBOL_PROP_INTEGER_SKIP+SYMBOL_PROP_DOUBLE_TOTAL-SYMBOL_PROP_DOUBLE_SKIP)
enum ENUM_SORT_SYMBOLS_MODE
  {
   //--- Sort by integer properties
    SORT_BY_SYMBOL_STATUS = 0,                               // Sort by symbol status
    SORT_BY_SYMBOL_INDEX_MW,                                 // Sort by index in the Market Watch window
    SORT_BY_SYMBOL_SECTOR,                                   // Sort by economic sector
    SORT_BY_SYMBOL_INDUSTRY,                                 // Sort by industry or economy sector
    SORT_BY_SYMBOL_CUSTOM,                                   // Sort by custom symbol property
    SORT_BY_SYMBOL_CHART_MODE,                               // Sort by price type for constructing bars – Bid or Last (from the ENUM_SYMBOL_CHART_MODE enumeration)
    SORT_BY_SYMBOL_EXIST,                                    // Sort by the flag that a symbol with such a name exists
    SORT_BY_SYMBOL_SELECT,                                   // Sort by the flag indicating that a symbol is selected in Market Watch
    SORT_BY_SYMBOL_VISIBLE,                                  // Sort by the flag indicating that a selected symbol is displayed in Market Watch
    SORT_BY_SYMBOL_SESSION_DEALS,                            // Sort by the number of deals in the current session 
    SORT_BY_SYMBOL_SESSION_BUY_ORDERS,                       // Sort by the total number of current buy orders
    SORT_BY_SYMBOL_SESSION_SELL_ORDERS,                      // Sort by the total number of current sell orders
    SORT_BY_SYMBOL_VOLUME,                                   // Sort by last deal volume
    SORT_BY_SYMBOL_VOLUMEHIGH,                               // Sort by maximum volume for a day
    SORT_BY_SYMBOL_VOLUMELOW,                                // Sort by minimum volume for a day
    SORT_BY_SYMBOL_TIME,                                     // Sort by the last quote time
    SORT_BY_SYMBOL_TIME_MSC,                                 // Sort by the last quote time in milliseconds
    SORT_BY_SYMBOL_DIGITS,                                   // Sort by a number of decimal places
    SORT_BY_SYMBOL_DIGITS_LOT,                               // Sort by a number of decimal places in a lot
    SORT_BY_SYMBOL_SPREAD,                                   // Sort by spread in points
    SORT_BY_SYMBOL_SPREAD_FLOAT,                             // Sort by floating spread
    SORT_BY_SYMBOL_TICKS_BOOKDEPTH,                          // Sort by a maximum number of requests displayed in the market depth
    SORT_BY_SYMBOL_BOOKDEPTH_STATE,                          // Sort by the DOM subscription flag
    SORT_BY_SYMBOL_TRADE_CALC_MODE,                          // Sort by contract price calculation method (from the ENUM_SYMBOL_CALC_MODE enumeration)
    SORT_BY_SYMBOL_TRADE_MODE,                               // Sort by order execution type (from the ENUM_SYMBOL_TRADE_MODE enumeration)
    SORT_BY_SYMBOL_START_TIME,                               // Sort by an instrument trading start date (usually used for futures)
    SORT_BY_SYMBOL_EXPIRATION_TIME,                          // Sort by an instrument trading end date (usually used for futures)
    SORT_BY_SYMBOL_TRADE_STOPS_LEVEL,                        // Sort by the minimum indent from the current close price (in points) for setting Stop orders
    SORT_BY_SYMBOL_TRADE_FREEZE_LEVEL,                       // Sort by trade operation freeze distance (in points)
    SORT_BY_SYMBOL_TRADE_EXEMODE,                            // Sort by trade execution mode (from the ENUM_SYMBOL_TRADE_EXECUTION enumeration)
    SORT_BY_SYMBOL_SWAP_MODE,                                // Sort by swap calculation model (from the ENUM_SYMBOL_SWAP_MODE enumeration)
    SORT_BY_SYMBOL_SWAP_ROLLOVER3DAYS,                       // Sort by week day for accruing a triple swap (from the ENUM_DAY_OF_WEEK enumeration)
    SORT_BY_SYMBOL_MARGIN_HEDGED_USE_LEG,                    // Sort by the calculation mode of a hedged margin using the larger leg (Buy or Sell)
    SORT_BY_SYMBOL_EXPIRATION_MODE,                          // Sort by flags of allowed order expiration modes
    SORT_BY_SYMBOL_FILLING_MODE,                             // Sort by flags of allowed order filling modes
    SORT_BY_SYMBOL_ORDER_MODE,                               // Sort by flags of allowed order types
    SORT_BY_SYMBOL_ORDER_GTC_MODE,                           // Sort by StopLoss and TakeProfit orders lifetime
    SORT_BY_SYMBOL_OPTION_MODE,                              // Sort by option type (from the ENUM_SYMBOL_OPTION_MODE enumeration)
    SORT_BY_SYMBOL_OPTION_RIGHT,                             // Sort by option right (Call/Put) (from the ENUM_SYMBOL_OPTION_RIGHT enumeration)
    SORT_BY_SYMBOL_SUBSCRIPTION_DELAY,                       // Sort by delay for quotes passed by symbol for instruments working on subscription basis
   //--- Sort by real properties
    SORT_BY_SYMBOL_BID = FIRST_SYM_DBL_PROP,                 // Sort by Bid
    SORT_BY_SYMBOL_BIDHIGH,                                  // Sort by maximum Bid for a day
    SORT_BY_SYMBOL_BIDLOW,                                   // Sort by minimum Bid for a day
    SORT_BY_SYMBOL_ASK,                                      // Sort by Ask
    SORT_BY_SYMBOL_ASKHIGH,                                  // Sort by maximum Ask for a day
    SORT_BY_SYMBOL_ASKLOW,                                   // Sort by minimum Ask for a day
    SORT_BY_SYMBOL_LAST,                                     // Sort by the last deal price
    SORT_BY_SYMBOL_LASTHIGH,                                 // Sort by maximum Last for a day
    SORT_BY_SYMBOL_LASTLOW,                                  // Sort by minimum Last for a day
    SORT_BY_SYMBOL_VOLUME_REAL,                              // Sort by Volume for a day
    SORT_BY_SYMBOL_VOLUMEHIGH_REAL,                          // Sort by maximum Volume for a day
    SORT_BY_SYMBOL_VOLUMELOW_REAL,                           // Sort by minimum Volume for a day
    SORT_BY_SYMBOL_OPTION_STRIKE,                            // Sort by an option execution price
    SORT_BY_SYMBOL_POINT,                                    // Sort by a single point value
    SORT_BY_SYMBOL_TRADE_TICK_VALUE,                         // Sort by SYMBOL_TRADE_TICK_VALUE_PROFIT value
    SORT_BY_SYMBOL_TRADE_TICK_VALUE_PROFIT,                  // Sort by a calculated tick price for a profitable position
    SORT_BY_SYMBOL_TRADE_TICK_VALUE_LOSS,                    // Sort by a calculated tick price for a loss-making position
    SORT_BY_SYMBOL_TRADE_TICK_SIZE,                          // Sort by a minimum price change
    SORT_BY_SYMBOL_TRADE_CONTRACT_SIZE,                      // Sort by a trading contract size
    SORT_BY_SYMBOL_TRADE_ACCRUED_INTEREST,                   // Sort by accrued interest
    SORT_BY_SYMBOL_TRADE_FACE_VALUE,                         // Sort by face value
    SORT_BY_SYMBOL_TRADE_LIQUIDITY_RATE,                     // Sort by liquidity rate
    SORT_BY_SYMBOL_VOLUME_MIN,                               // Sort by a minimum volume for performing a deal
    SORT_BY_SYMBOL_VOLUME_MAX,                               // Sort by a maximum volume for performing a deal
    SORT_BY_SYMBOL_VOLUME_STEP,                              // Sort by a minimum volume change step for deal execution
    SORT_BY_SYMBOL_VOLUME_LIMIT,                             // Sort by a maximum allowed aggregate volume of an open position and pending orders in one direction
    SORT_BY_SYMBOL_SWAP_LONG,                                // Sort by a long swap value
    SORT_BY_SYMBOL_SWAP_SHORT,                               // Sort by a short swap value
    SORT_BY_SYMBOL_MARGIN_INITIAL,                           // Sort by an initial margin
    SORT_BY_SYMBOL_MARGIN_MAINTENANCE,                       // Sort by a maintenance margin for an instrument
    SORT_BY_SYMBOL_MARGIN_LONG_INITIAL,                      // Sort by initial margin requirement applicable to Long orders
    SORT_BY_SYMBOL_MARGIN_BUY_STOP_INITIAL,                  // Sort by initial margin requirement applicable to BuyStop orders
    SORT_BY_SYMBOL_MARGIN_BUY_LIMIT_INITIAL,                 // Sort by initial margin requirement applicable to BuyLimit orders
    SORT_BY_SYMBOL_MARGIN_BUY_STOPLIMIT_INITIAL,             // Sort by initial margin requirement applicable to BuyStopLimit orders
    SORT_BY_SYMBOL_MARGIN_LONG_MAINTENANCE,                  // Sort by maintenance margin requirement applicable to Long orders
    SORT_BY_SYMBOL_MARGIN_BUY_STOP_MAINTENANCE,              // Sort by maintenance margin requirement applicable to BuyStop orders
    SORT_BY_SYMBOL_MARGIN_BUY_LIMIT_MAINTENANCE,             // Sort by maintenance margin requirement applicable to BuyLimit orders
    SORT_BY_SYMBOL_MARGIN_BUY_STOPLIMIT_MAINTENANCE,         // Sort by maintenance margin requirement applicable to BuyStopLimit orders
    SORT_BY_SYMBOL_MARGIN_SHORT_INITIAL,                     // Sort by initial margin requirement applicable to Short orders
    SORT_BY_SYMBOL_MARGIN_SELL_STOP_INITIAL,                 // Sort by initial margin requirement applicable to SellStop orders
    SORT_BY_SYMBOL_MARGIN_SELL_LIMIT_INITIAL,                // Sort by initial margin requirement applicable to SellLimit orders
    SORT_BY_SYMBOL_MARGIN_SELL_STOPLIMIT_INITIAL,            // Sort by initial margin requirement applicable to SellStopLimit orders
    SORT_BY_SYMBOL_MARGIN_SHORT_MAINTENANCE,                 // Sort by maintenance margin requirement applicable to Short orders
    SORT_BY_SYMBOL_MARGIN_SELL_STOP_MAINTENANCE,             // Sort by maintenance margin requirement applicable to SellStop orders
    SORT_BY_SYMBOL_MARGIN_SELL_LIMIT_MAINTENANCE,            // Sort by maintenance margin requirement applicable to SellLimit orders
    SORT_BY_SYMBOL_MARGIN_SELL_STOPLIMIT_MAINTENANCE,        // Sort by maintenance margin requirement applicable to SellStopLimit orders
    SORT_BY_SYMBOL_SESSION_VOLUME,                           // Sort by summary volume of the current session deals
    SORT_BY_SYMBOL_SESSION_TURNOVER,                         // Sort by the summary turnover of the current session
    SORT_BY_SYMBOL_SESSION_INTEREST,                         // Sort by the summary open interest
    SORT_BY_SYMBOL_SESSION_BUY_ORDERS_VOLUME,                // Sort by the current volume of Buy orders
    SORT_BY_SYMBOL_SESSION_SELL_ORDERS_VOLUME,               // Sort by the current volume of Sell orders
    SORT_BY_SYMBOL_SESSION_OPEN,                             // Sort by an Open price of the current session
    SORT_BY_SYMBOL_SESSION_CLOSE,                            // Sort by a Close price of the current session
    SORT_BY_SYMBOL_SESSION_AW,                               // Sort by an average weighted price of the current session
    SORT_BY_SYMBOL_SESSION_PRICE_SETTLEMENT,                 // Sort by a settlement price of the current session
    SORT_BY_SYMBOL_SESSION_PRICE_LIMIT_MIN,                  // Sort by a minimum price of the current session 
    SORT_BY_SYMBOL_SESSION_PRICE_LIMIT_MAX,                  // Sort by a maximum price of the current session
    SORT_BY_SYMBOL_MARGIN_HEDGED,                            // Sort by a contract size or a margin value per one lot of hedged positions
    SORT_BY_SYMBOL_PRICE_CHANGE,                             // Sort by change of the current price relative to the end of the previous trading day
    SORT_BY_SYMBOL_PRICE_VOLATILITY,                         // Sort by price volatility in %
    SORT_BY_SYMBOL_PRICE_THEORETICAL,                        // Sort by theoretical option price
    SORT_BY_SYMBOL_PRICE_DELTA,                              // Sort by option/warrant delta
    SORT_BY_SYMBOL_PRICE_THETA,                              // Sort by option/warrant theta
    SORT_BY_SYMBOL_PRICE_GAMMA,                              // Sort by option/warrant gamma
    SORT_BY_SYMBOL_PRICE_VEGA,                               // Sort by option/warrant vega
    SORT_BY_SYMBOL_PRICE_RHO,                                // Sort by option/warrant rho
    SORT_BY_SYMBOL_PRICE_OMEGA,                              // Sort by option/warrant omega
    SORT_BY_SYMBOL_PRICE_SENSITIVITY,                        // Sort by option/warrant sensitivity
    SORT_BY_SYMBOL_SWAP_SUNDAY,                              // Sort by swap accrual ratio (Sunday)
    SORT_BY_SYMBOL_SWAP_MONDAY,                              // Sort by swap accrual ratio (Monday)
    SORT_BY_SYMBOL_SWAP_TUESDAY,                             // Sort by swap accrual ratio (Tuesday)
    SORT_BY_SYMBOL_SWAP_WEDNESDAY,                           // Sort by swap accrual ratio (Wednesday)
    SORT_BY_SYMBOL_SWAP_THURSDAY,                            // Sort by swap accrual ratio (Thursday)
    SORT_BY_SYMBOL_SWAP_FRIDAY,                              // Sort by swap accrual ratio (Friday)
    SORT_BY_SYMBOL_SWAP_SATURDAY,                            // Sort by swap accrual ratio (Saturday)
   //--- Sort by string properties
    SORT_BY_SYMBOL_NAME = FIRST_SYM_STR_PROP,                // Sort by a symbol name
    SORT_BY_SYMBOL_BASIS,                                    // Sort by an underlying asset of a derivative
    SORT_BY_SYMBOL_CURRENCY_BASE,                            // Sort by a base currency of a symbol
    SORT_BY_SYMBOL_CURRENCY_PROFIT,                          // Sort by a profit currency
    SORT_BY_SYMBOL_CURRENCY_MARGIN,                          // Sort by a margin currency
    SORT_BY_SYMBOL_BANK,                                     // Sort by a feeder of the current quote
    SORT_BY_SYMBOL_DESCRIPTION,                              // Sort by a symbol string description
    SORT_BY_SYMBOL_FORMULA,                                  // Sort by the formula used for custom symbol pricing
    SORT_BY_SYMBOL_ISIN,                                     // Sort by the name of a symbol in the ISIN system
    SORT_BY_SYMBOL_PAGE,                                     // Sort by an address of the web page containing symbol information
    SORT_BY_SYMBOL_PATH,                                     // Sort by a path in the symbol tree
    SORT_BY_SYMBOL_CATEGORY,                                 // Sort by a symbol category
    SORT_BY_SYMBOL_EXCHANGE,                                 // Sort by a name of an exchange a symbol is traded on
    SORT_BY_SYMBOL_COUNTRY,                                  // Sort by country the trading instrument belongs to
    SORT_BY_SYMBOL_SECTOR_NAME,                              // Sort by economy sector the trading instrument belongs to
    SORT_BY_SYMBOL_INDUSTRY_NAME,                            // Sort by economy or industry branch the trading instrument belongs to
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with program resource data                      |
//+------------------------------------------------------------------+
enum ENUM_FILE_TYPE
  {
   FILE_TYPE_WAV,                                           // wav file
   FILE_TYPE_BMP,                                           // bmp file
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with trading classes                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| EA behavior when handling errors                                 |
//+------------------------------------------------------------------+
enum ENUM_ERROR_HANDLING_BEHAVIOR
  {
   ERROR_HANDLING_BEHAVIOR_BREAK,                           // Abort trading attempt
   ERROR_HANDLING_BEHAVIOR_CORRECT,                         // Correct invalid parameters
  };
//+------------------------------------------------------------------+
//| Flags indicating the trading request error handling methods      |
//+------------------------------------------------------------------+
enum ENUM_TRADE_REQUEST_ERR_FLAGS
  {
   TRADE_REQUEST_ERR_FLAG_NO_ERROR                 =  0x0,  // No error
   TRADE_REQUEST_ERR_FLAG_FATAL_ERROR              =  0x1,  // Disable trading for an EA (critical error) - exit
   TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR             =  0x2,  // Library internal error - exit
   TRADE_REQUEST_ERR_FLAG_ERROR_IN_LIST            =  0x4,  // Error in the list - handle (ENUM_ERROR_CODE_PROCESSING_METHOD)
   TRADE_REQUEST_ERR_FLAG_PRICE_ERROR              =  0x8,  // Placement price error
   TRADE_REQUEST_ERR_FLAG_LIMIT_ERROR              =  0x10, // Limit order price error
  };
//+------------------------------------------------------------------+
//| The methods of handling errors and server return codes           |
//+------------------------------------------------------------------+
enum ENUM_ERROR_CODE_PROCESSING_METHOD
  {
   ERROR_CODE_PROCESSING_METHOD_OK,                         // No error
   ERROR_CODE_PROCESSING_METHOD_DISABLE,                    // Disable trading for the EA
   ERROR_CODE_PROCESSING_METHOD_EXIT,                       // Exit the trading method
   ERROR_CODE_PROCESSING_METHOD_CORRECT,                    // Correct trading request parameters and repeat
   ERROR_CODE_PROCESSING_METHOD_REFRESH,                    // Update data and repeat
   ERROR_CODE_PROCESSING_METHOD_WAIT,                       // Wait and repeat
  };
//+------------------------------------------------------------------+
//| Types of performed operations                                    |
//+------------------------------------------------------------------+
enum ENUM_ACTION_TYPE
  {
   ACTION_TYPE_BUY               =  ORDER_TYPE_BUY,               // Open Buy
   ACTION_TYPE_SELL              =  ORDER_TYPE_SELL,              // Open Sell
   ACTION_TYPE_BUY_LIMIT         =  ORDER_TYPE_BUY_LIMIT,         // Place BuyLimit
   ACTION_TYPE_SELL_LIMIT        =  ORDER_TYPE_SELL_LIMIT,        // Place SellLimit
   ACTION_TYPE_BUY_STOP          =  ORDER_TYPE_BUY_STOP,          // Place BuyStop
   ACTION_TYPE_SELL_STOP         =  ORDER_TYPE_SELL_STOP,         // Place SellStop
   ACTION_TYPE_BUY_STOP_LIMIT    =  ORDER_TYPE_BUY_STOP_LIMIT,    // Place BuyStopLimit
   ACTION_TYPE_SELL_STOP_LIMIT   =  ORDER_TYPE_SELL_STOP_LIMIT,   // Place SellStopLimit
   ACTION_TYPE_CLOSE_BY          =  ORDER_TYPE_CLOSE_BY,          // Close a position by an opposite one
   ACTION_TYPE_CLOSE             =  ACTION_TYPE_CLOSE_BY+3,       // Close/remove
   ACTION_TYPE_MODIFY            =  ACTION_TYPE_CLOSE_BY+4,       // Modify
  };
//+------------------------------------------------------------------+
//| Sound setting mode                                               |
//+------------------------------------------------------------------+
enum ENUM_MODE_SET_SOUND
  {
   MODE_SET_SOUND_OPEN,                                     // Opening/placing sound setting mode
   MODE_SET_SOUND_CLOSE,                                    // Closing/removal sound setting mode
   MODE_SET_SOUND_MODIFY_SL,                                // StopLoss modification sound setting mode
   MODE_SET_SOUND_MODIFY_TP,                                // TakeProfit modification sound setting mode
   MODE_SET_SOUND_MODIFY_PRICE,                             // Placing price modification sound setting mode
   MODE_SET_SOUND_ERROR_OPEN,                               // Opening/placing error sound setting mode
   MODE_SET_SOUND_ERROR_CLOSE,                              // Closing/removal error sound setting mode
   MODE_SET_SOUND_ERROR_MODIFY_SL,                          // StopLoss modification error sound setting mode
   MODE_SET_SOUND_ERROR_MODIFY_TP,                          // TakeProfit modification error sound setting mode
   MODE_SET_SOUND_ERROR_MODIFY_PRICE,                       // Placing price modification error sound setting mode
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with pending trading requests                   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Pending request status                                           |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_STATUS
  {
   PEND_REQ_STATUS_OPEN,                                    // Pending request to open a market position
   PEND_REQ_STATUS_CLOSE,                                   // Pending request to close a position
   PEND_REQ_STATUS_SLTP,                                    // Pending request to modify open position stop orders
   PEND_REQ_STATUS_PLACE,                                   // Pending request to place a pending order
   PEND_REQ_STATUS_REMOVE,                                  // Pending request to delete a pending order
   PEND_REQ_STATUS_MODIFY                                   // Pending request to modify a placed pending order
  };
//+------------------------------------------------------------------+
//| Pending request type                                             |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_TYPE
  {
   PEND_REQ_TYPE_ERROR=PENDING_REQUEST_ID_TYPE_ERR,         // Pending request created based on the return code or error
   PEND_REQ_TYPE_REQUEST=PENDING_REQUEST_ID_TYPE_REQ,       // Pending request created by request
  };
//+------------------------------------------------------------------+
//| Pending request activation source                                |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_ACTIVATION_SOURCE
  {
   PEND_REQ_ACTIVATION_SOURCE_ACCOUNT,                      // Pending request activated by account data
   PEND_REQ_ACTIVATION_SOURCE_SYMBOL,                       // Pending request activated by symbol data
   PEND_REQ_ACTIVATION_SOURCE_EVENT,                        // Pending request activated by trading event data
  };
//+------------------------------------------------------------------+
//| Integer properties of a pending trading request                  |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_PROP_INTEGER
  {
    PEND_REQ_PROP_STATUS = 0,                                // Trading request status (from the ENUM_PEND_REQ_STATUS enumeration)
    PEND_REQ_PROP_TYPE,                                      // Trading request type (from the ENUM_PEND_REQ_TYPE enumeration)
    PEND_REQ_PROP_ID,                                        // Trading request ID
    PEND_REQ_PROP_RETCODE,                                   // Result a request is based on
    PEND_REQ_PROP_TIME_CREATE,                               // Request creation time
    PEND_REQ_PROP_TIME_ACTIVATE,                             // Next attempt activation time
    PEND_REQ_PROP_WAITING,                                   // Waiting time between requests
    PEND_REQ_PROP_CURRENT_ATTEMPT,                           // Current attempt index
    PEND_REQ_PROP_TOTAL,                                     // Number of attempts
    PEND_REQ_PROP_ACTUAL_TYPE_FILLING,                       // Actual order filling type
    PEND_REQ_PROP_ACTUAL_TYPE_TIME,                          // Actual order expiration type
    PEND_REQ_PROP_ACTUAL_EXPIRATION,                         // Actual order lifetime
   //--- MqlTradeRequest
    PEND_REQ_PROP_MQL_REQ_ACTION,                            // Type of a performed action in the request structure
    PEND_REQ_PROP_MQL_REQ_TYPE,                              // Order type in the request structure
    PEND_REQ_PROP_MQL_REQ_MAGIC,                             // EA stamp (magic number ID) in the request structure
    PEND_REQ_PROP_MQL_REQ_ORDER,                             // Order ticket in the request structure
    PEND_REQ_PROP_MQL_REQ_POSITION,                          // Position ticket in the request structure
    PEND_REQ_PROP_MQL_REQ_POSITION_BY,                       // Opposite position ticket in the request structure
    PEND_REQ_PROP_MQL_REQ_DEVIATION,                         // Maximum acceptable deviation from a requested price in the request structure
    PEND_REQ_PROP_MQL_REQ_EXPIRATION,                        // Order expiration time (for ORDER_TIME_SPECIFIED type orders) in the request structure
    PEND_REQ_PROP_MQL_REQ_TYPE_FILLING,                      // Order filling type in the request structure
    PEND_REQ_PROP_MQL_REQ_TYPE_TIME,                         // Order lifetime type in the request structure
  }; 
#define PEND_REQ_PROP_INTEGER_TOTAL (22)                    // Total number of integer event properties
#define PEND_REQ_PROP_INTEGER_SKIP  (0)                     // Number of request properties not used in sorting
//+------------------------------------------------------------------+
//| Real properties of a pending trading request                     |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_PROP_DOUBLE
  {
    PEND_REQ_PROP_PRICE_CREATE = PEND_REQ_PROP_INTEGER_TOTAL,// Price at the moment of a request generation
    PEND_REQ_PROP_ACTUAL_VOLUME,                             // Actual volume
    PEND_REQ_PROP_ACTUAL_PRICE,                              // Actual order price
    PEND_REQ_PROP_ACTUAL_STOPLIMIT,                          // Actual stoplimit order price
    PEND_REQ_PROP_ACTUAL_SL,                                 // Actual stoploss order price
    PEND_REQ_PROP_ACTUAL_TP,                                 // Actual takeprofit order price
   //--- MqlTradeRequest
    PEND_REQ_PROP_MQL_REQ_VOLUME,                            // Requested volume of a deal in lots in the request structure
    PEND_REQ_PROP_MQL_REQ_PRICE,                             // Price in the request structure
    PEND_REQ_PROP_MQL_REQ_STOPLIMIT,                         // StopLimit level in the request structure
    PEND_REQ_PROP_MQL_REQ_SL,                                // Stop Loss level in the request structure
    PEND_REQ_PROP_MQL_REQ_TP,                                // Take Profit level in the request structure
  };
#define PEND_REQ_PROP_DOUBLE_TOTAL  (11)                    // Total number of event's real properties
#define PEND_REQ_PROP_DOUBLE_SKIP   (0)                     // Number of order properties not used in sorting
//+------------------------------------------------------------------+
//| String properties of a pending trading request                   |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_PROP_STRING
  {
   //--- MqlTradeRequest
    PEND_REQ_PROP_MQL_REQ_SYMBOL = (PEND_REQ_PROP_INTEGER_TOTAL+PEND_REQ_PROP_DOUBLE_TOTAL),  // Trading instrument name in the request structure
    PEND_REQ_PROP_MQL_REQ_COMMENT                            // Order comment in the request structure
  };
#define PEND_REQ_PROP_STRING_TOTAL  (2)                     // Total number of event's string properties
//+------------------------------------------------------------------+
//| Possible pending request sorting criteria                        |
//+------------------------------------------------------------------+
#define FIRST_PREQ_DBL_PROP         (PEND_REQ_PROP_INTEGER_TOTAL-PEND_REQ_PROP_INTEGER_SKIP)
#define FIRST_PREQ_STR_PROP         (PEND_REQ_PROP_INTEGER_TOTAL-PEND_REQ_PROP_INTEGER_SKIP+PEND_REQ_PROP_DOUBLE_TOTAL-PEND_REQ_PROP_DOUBLE_SKIP)
enum ENUM_SORT_PEND_REQ_MODE
  {
   //--- Sort by integer properties
    SORT_BY_PEND_REQ_STATUS = 0,                             // Sort by a trading request status (from the ENUM_PEND_REQ_STATUS enumeration)
    SORT_BY_PEND_REQ_TYPE,                                   // Sort by a trading request type (from the ENUM_PEND_REQ_TYPE enumeration)
    SORT_BY_PEND_REQ_ID,                                     // Sort by a trading request ID
    SORT_BY_PEND_REQ_RETCODE,                                // Sort by a result a request is based on
    SORT_BY_PEND_REQ_TIME_CREATE,                            // Sort by a request generation time
    SORT_BY_PEND_REQ_TIME_ACTIVATE,                          // Sort by next attempt activation time
    SORT_BY_PEND_REQ_WAITING,                                // Sort by a waiting time between requests
    SORT_BY_PEND_REQ_CURENT,                                 // Sort by the current attempt index
    SORT_BY_PEND_REQ_TOTAL,                                  // Sort by a number of attempts
    SORT_BY_PEND_REQ_ACTUAL_TYPE_FILLING,                    // Sort by actual order filling type
    SORT_BY_PEND_REQ_ACTUAL_TYPE_TIME,                       // Sort by actual order expiration type
    SORT_BY_PEND_REQ_ACTUAL_EXPIRATION,                      // Sort by actual order lifetime
   //--- MqlTradeRequest
    SORT_BY_PEND_REQ_MQL_REQ_ACTION,                         // Sort by a type of a performed action in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_TYPE,                           // Sort by an order type in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_MAGIC,                          // Sort by an EA stamp (magic number ID) in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_ORDER,                          // Sort by an order ticket in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_POSITION,                       // Sort by a position ticket in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_POSITION_BY,                    // Sort by an opposite position ticket in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_DEVIATION,                      // Sort by a maximum acceptable deviation from a requested price in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_EXPIRATION,                     // Sort by an order expiration time (for ORDER_TIME_SPECIFIED type orders) in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_TYPE_FILLING,                   // Sort by an order filling type in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_TYPE_TIME,                      // Sort by order lifetime type in the request structure
   //--- Sort by real properties
    SORT_BY_PEND_REQ_PRICE_CREATE = FIRST_PREQ_DBL_PROP,     // Sort by a price at the moment of a request generation
    SORT_BY_PEND_REQ_ACTUAL_VOLUME,                          // Sort by actual volume
    SORT_BY_PEND_REQ_ACTUAL_PRICE,                           // Sort by actual order price
    SORT_BY_PEND_REQ_ACTUAL_STOPLIMIT,                       // Sort by actual stoplimit order price
    SORT_BY_PEND_REQ_ACTUAL_SL,                              // Sort by actual stoploss order price
    SORT_BY_PEND_REQ_ACTUAL_TP,                              // Sort by actual takeprofit order price
   //--- MqlTradeRequest
    SORT_BY_PEND_REQ_MQL_REQ_VOLUME,                         // Sort by a requested volume of a deal in lots in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_PRICE,                          // Sort by a price in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_STOPLIMIT,                      // Sort by StopLimit order level in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_SL,                             // Sort by StopLoss order level in the request structure
    SORT_BY_PEND_REQ_MQL_REQ_TP,                             // Sort by TakeProfit order level in the request structure
   //--- Sort by string properties
   //--- MqlTradeRequest
    SORT_BY_PEND_REQ_MQL_SYMBOL = FIRST_PREQ_STR_PROP,       // Sort by a trading instrument name in the request structure
    SORT_BY_PEND_REQ_MQL_COMMENT                             // Sort by an order comment in the request structure
  };
//+------------------------------------------------------------------+
//| Possible criteria for activating requests by account properties  |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_ACTIVATE_BY_ACCOUNT_PROP
  {
   //--- long
    PEND_REQ_ACTIVATE_BY_ACCOUNT_EMPTY                    =  MSG_LIB_PROP_NOT_SET,                     // Value not set
    PEND_REQ_ACTIVATE_BY_ACCOUNT_LEVERAGE                 =  MSG_ACC_PROP_LEVERAGE,                    // Activate by a provided leverage
    PEND_REQ_ACTIVATE_BY_ACCOUNT_LIMIT_ORDERS             =  MSG_ACC_PROP_LIMIT_ORDERS,                // Activate by a maximum allowed number of active pending orders
    PEND_REQ_ACTIVATE_BY_ACCOUNT_TRADE_ALLOWED            =  MSG_ACC_PROP_TRADE_ALLOWED,               // Activate by the permission to trade for the current account from the server side
    PEND_REQ_ACTIVATE_BY_ACCOUNT_TRADE_EXPERT             =  MSG_ACC_PROP_TRADE_EXPERT,                // Activate by the permission to trade for an EA from the server side
   //--- double
    PEND_REQ_ACTIVATE_BY_ACCOUNT_BALANCE                  =  MSG_ACC_PROP_BALANCE,                     // Activate by an account balance in the deposit currency
    PEND_REQ_ACTIVATE_BY_ACCOUNT_CREDIT                   =  MSG_ACC_PROP_CREDIT,                      // Activate by credit in a deposit currency
    PEND_REQ_ACTIVATE_BY_ACCOUNT_PROFIT                   =  MSG_ACC_PROP_PROFIT,                      // Activate by the current profit on the account in the deposit currency
    PEND_REQ_ACTIVATE_BY_ACCOUNT_EQUITY                   =  MSG_ACC_PROP_EQUITY,                      // Sort by an account equity in the deposit currency
    PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN                   =  MSG_ACC_PROP_MARGIN,                      // Activate by an account reserved margin in the deposit currency
    PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_FREE              =  MSG_ACC_PROP_MARGIN_FREE,                 // Activate by account free funds available for opening a position in the deposit currency
    PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_LEVEL             =  MSG_ACC_PROP_MARGIN_LEVEL,                // Activate by account margin level in %
    PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_INITIAL           =  MSG_ACC_PROP_MARGIN_INITIAL,              // Activate by funds reserved on an account to ensure a guarantee amount for all pending orders
    PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_MAINTENANCE       =  MSG_ACC_PROP_MARGIN_MAINTENANCE,          // Activate by funds reserved on an account to ensure a minimum amount for all open positions
    PEND_REQ_ACTIVATE_BY_ACCOUNT_ASSETS                   =  MSG_ACC_PROP_ASSETS,                      // Activate by the current assets on the account
    PEND_REQ_ACTIVATE_BY_ACCOUNT_LIABILITIES              =  MSG_ACC_PROP_LIABILITIES,                 // Activate by the current liabilities on the account
    PEND_REQ_ACTIVATE_BY_ACCOUNT_COMMISSION_BLOCKED       =  MSG_ACC_PROP_COMMISSION_BLOCKED           // Activate by the current amount of blocked commissions on the account
  };
//+------------------------------------------------------------------+
//| Possible criteria for activating requests by symbol properties   |
//+------------------------------------------------------------------+
enum ENUM_PEND_REQ_ACTIVATE_BY_SYMBOL_PROP
  {
   PEND_REQ_ACTIVATE_BY_SYMBOL_EMPTY                     =  MSG_LIB_PROP_NOT_SET,                     // Value not set
   //--- double
    PEND_REQ_ACTIVATE_BY_SYMBOL_BID                       =  MSG_LIB_PROP_BID,                         // Activate by Bid - the best price at which a symbol can be sold
    PEND_REQ_ACTIVATE_BY_SYMBOL_ASK                       =  MSG_LIB_PROP_ASK,                         // Activate by Ask - best price, at which an instrument can be bought
    PEND_REQ_ACTIVATE_BY_SYMBOL_LAST                      =  MSG_LIB_PROP_LAST,                        // Activate by the last deal price
   //--- long
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_DEALS             =  MSG_SYM_PROP_SESSION_DEALS,               // Activate by number of deals in the current session
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_BUY_ORDERS        =  MSG_SYM_PROP_SESSION_BUY_ORDERS,          // Activate by number of Buy orders at the moment
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_SELL_ORDERS       =  MSG_SYM_PROP_SESSION_SELL_ORDERS,         // Activate by number of Sell orders at the moment
    PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUME                    =  MSG_SYM_PROP_VOLUME,                      // Activate by the last deal volume
    PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMEHIGH                =  MSG_SYM_PROP_VOLUMEHIGH,                  // Activate by maximum Volume per day
    PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMELOW                 =  MSG_SYM_PROP_VOLUMELOW,                   // Activate by minimum Volume per day
    PEND_REQ_ACTIVATE_BY_SYMBOL_TIME                      =  MSG_SYM_PROP_TIME,                        // Activate by the last quote time
    PEND_REQ_ACTIVATE_BY_SYMBOL_SPREAD                    =  MSG_SYM_PROP_SPREAD,                      // Activate by spread in points
    PEND_REQ_ACTIVATE_BY_SYMBOL_START_TIME                =  MSG_SYM_PROP_START_TIME,                  // Activate by an instrument trading start date (usually used for futures)
    PEND_REQ_ACTIVATE_BY_SYMBOL_EXPIRATION_TIME           =  MSG_SYM_PROP_EXPIRATION_TIME,             // Activate by an instrument trading completion date (usually used for futures)
    PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_STOPS_LEVEL         =  MSG_SYM_PROP_TRADE_STOPS_LEVEL,           // Activate by the minimum indent from the current close price (in points) for setting Stop orders
    PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_FREEZE_LEVEL        =  MSG_SYM_PROP_TRADE_FREEZE_LEVEL,          // Activate by trade operation freeze distance (in points)
   //--- double
    PEND_REQ_ACTIVATE_BY_SYMBOL_BIDHIGH                   =  MSG_SYM_PROP_BIDHIGH,                     // Activate by a maximum Bid of the day
    PEND_REQ_ACTIVATE_BY_SYMBOL_BIDLOW                    =  MSG_SYM_PROP_BIDLOW,                      // Activate by a minimum Bid of the day
    PEND_REQ_ACTIVATE_BY_SYMBOL_ASKHIGH                   =  MSG_SYM_PROP_ASKHIGH,                     // Activate by a maximum Ask of the day
    PEND_REQ_ACTIVATE_BY_SYMBOL_ASKLOW                    =  MSG_SYM_PROP_ASKLOW,                      // Activate by a minimum Ask of the day
    PEND_REQ_ACTIVATE_BY_SYMBOL_LASTHIGH                  =  MSG_SYM_PROP_LASTHIGH,                    // Activate by the maximum Last of the day
    PEND_REQ_ACTIVATE_BY_SYMBOL_LASTLOW                   =  MSG_SYM_PROP_LASTLOW,                     // Activate by the minimum Last of the day
    PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUME_REAL               =  MSG_SYM_PROP_VOLUME_REAL,                 // Activate by Volume of the day
    PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMEHIGH_REAL           =  MSG_SYM_PROP_VOLUMEHIGH_REAL,             // Activate by a maximum Volume of the day
    PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMELOW_REAL            =  MSG_SYM_PROP_VOLUMELOW_REAL,              // Activate by a minimum Volume of the day
    PEND_REQ_ACTIVATE_BY_SYMBOL_OPTION_STRIKE             =  MSG_SYM_PROP_OPTION_STRIKE,               // Activate by an option execution price
    PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_ACCRUED_INTEREST    =  MSG_SYM_PROP_TRADE_ACCRUED_INTEREST,      // Activate by an accrued interest
    PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_FACE_VALUE          =  MSG_SYM_PROP_TRADE_FACE_VALUE,            // Activate by a face value – initial bond value set by an issuer
    PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_LIQUIDITY_RATE      =  MSG_SYM_PROP_TRADE_LIQUIDITY_RATE,        // Activate by a liquidity rate – the share of an asset that can be used for a margin
    PEND_REQ_ACTIVATE_BY_SYMBOL_SWAP_LONG                 =  MSG_SYM_PROP_SWAP_LONG,                   // Activate by a long swap value
    PEND_REQ_ACTIVATE_BY_SYMBOL_SWAP_SHORT                =  MSG_SYM_PROP_SWAP_SHORT,                  // Activate by a short swap value
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_VOLUME            =  MSG_SYM_PROP_SESSION_VOLUME,              // Activate by a summary volume of the current session deals
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_TURNOVER          =  MSG_SYM_PROP_SESSION_TURNOVER,            // Activate by a summary turnover of the current session
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_INTEREST          =  MSG_SYM_PROP_SESSION_INTEREST,            // Activate by a summary open interest
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_BUY_ORDERS_VOLUME =  MSG_SYM_PROP_SESSION_BUY_ORDERS_VOLUME,   // Activate by the current volume of Buy orders
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_SELL_ORDERS_VOLUME=  MSG_SYM_PROP_SESSION_SELL_ORDERS_VOLUME,  // Activate by the current volume of Sell orders
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_OPEN              =  MSG_SYM_PROP_SESSION_OPEN,                // Activate by an open price of the current session
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_CLOSE             =  MSG_SYM_PROP_SESSION_CLOSE,               // Activate by a close price of the current session
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_AW                =  MSG_SYM_PROP_SESSION_AW,                  // Activate by an average weighted session price
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_PRICE_SETTLEMENT  =  MSG_SYM_PROP_SESSION_PRICE_SETTLEMENT,    // Activate by a settlement price of the current session
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_PRICE_LIMIT_MIN   =  MSG_SYM_PROP_SESSION_PRICE_LIMIT_MIN,     // Activate by a minimum session price 
    PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_PRICE_LIMIT_MAX   =  MSG_SYM_PROP_SESSION_PRICE_LIMIT_MAX,     // Activate by a maximum session price
  };
//+------------------------------------------------------------------+
//| Possible criteria for activating requests by events              |
//+------------------------------------------------------------------+

enum ENUM_PEND_REQ_ACTIVATE_BY_EVENT
  {
   PEND_REQ_ACTIVATE_BY_EVENT_EMPTY                               =  MSG_LIB_PROP_NOT_SET,                        // Value not set
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_OPENED                     =  MSG_EVN_STATUS_MARKET_POSITION,              // Position opened
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED                     =  MSG_EVN_STATUS_HISTORY_POSITION,             // Position closed
   PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_PLASED                =  MSG_EVN_PENDING_ORDER_PLASED,                // Pending order placed
   PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_REMOVED               =  MSG_EVN_PENDING_ORDER_REMOVED,               // Pending order removed
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_CREDIT                      =  MSG_EVN_ACCOUNT_CREDIT,                      // Accruing credit (3)
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_CHARGE                      =  MSG_EVN_ACCOUNT_CHARGE,                      // Additional charges
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_CORRECTION                  =  MSG_EVN_ACCOUNT_CORRECTION,                  // Correcting entry
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_BONUS                       =  MSG_EVN_ACCOUNT_BONUS,                       // Charging bonuses
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION                   =  MSG_EVN_ACCOUNT_COMISSION,                   // Additional commissions
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_DAILY             =  MSG_EVN_ACCOUNT_COMISSION_DAILY,             // Commission charged at the end of a day
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_MONTHLY           =  MSG_EVN_ACCOUNT_COMISSION_MONTHLY,           // Commission charged at the end of a trading month
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_AGENT_DAILY       =  MSG_EVN_ACCOUNT_COMISSION_AGENT_DAILY,       // Agent commission charged at the end of a trading day
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY     =  MSG_EVN_ACCOUNT_COMISSION_AGENT_MONTHLY,     // Agent commission charged at the end of a month
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_INTEREST                    =  MSG_EVN_ACCOUNT_INTEREST,                    // Accruing interest on free funds
   PEND_REQ_ACTIVATE_BY_EVENT_BUY_CANCELLED                       =  MSG_EVN_BUY_CANCELLED,                       // Canceled buy deal
   PEND_REQ_ACTIVATE_BY_EVENT_SELL_CANCELLED                      =  MSG_EVN_SELL_CANCELLED,                      // Canceled sell deal
   PEND_REQ_ACTIVATE_BY_EVENT_DIVIDENT                            =  MSG_EVN_DIVIDENT,                            // Accruing dividends
   PEND_REQ_ACTIVATE_BY_EVENT_DIVIDENT_FRANKED                    =  MSG_EVN_DIVIDENT_FRANKED,                    // Accrual of franked dividend
   PEND_REQ_ACTIVATE_BY_EVENT_TAX                                 =  MSG_EVN_TAX,                                 // Tax accrual
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_BALANCE_REFILL              =  MSG_EVN_BALANCE_REFILL,                      // Replenishing account balance
   PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_BALANCE_WITHDRAWAL          =  MSG_EVN_BALANCE_WITHDRAWAL,                  // Withdrawing funds from an account
   PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_ACTIVATED             =  MSG_EVN_ACTIVATED_PENDING,                   // Pending order activated by price
   PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL     =  MSG_EVN_ACTIVATED_PENDING_PARTIALLY,         // Pending order partially activated by price
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_OPENED_PARTIAL             =  MSG_EVN_POSITION_OPENED_PARTIALLY,           // Position opened partially
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL             =  MSG_EVN_POSITION_CLOSED_PARTIALLY,           // Position closed partially
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_BY_POS              =  MSG_EVN_POSITION_CLOSED_BY_POS,              // Position closed by an opposite one
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL_BY_POS      =  MSG_EVN_POSITION_CLOSED_PARTIALLY_BY_POS,    // Position partially closed by an opposite one
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_BY_SL               =  MSG_EVN_POSITION_CLOSED_BY_SL,               // Position closed by StopLoss
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_BY_TP               =  MSG_EVN_POSITION_CLOSED_BY_TP,               // Position closed by TakeProfit
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL_BY_SL       =  MSG_EVN_POSITION_CLOSED_PARTIALLY_BY_SL,     // Position closed partially by StopLoss
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL_BY_TP       =  MSG_EVN_POSITION_CLOSED_PARTIALLY_BY_TP,     // Position closed partially by TakeProfit
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_MARKET         =  MSG_EVN_POSITION_REVERSED_BY_MARKET,         // Position reversal by a new deal (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_PENDING        =  MSG_EVN_POSITION_REVERSED_BY_PENDING,        // Position reversal by activating a pending order (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL =  MSG_EVN_POSITION_REVERSE_PARTIALLY,          // Position reversal by partial market order execution (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOLUME_ADD_BY_MARKET       =  MSG_EVN_POSITION_VOLUME_ADD_BY_MARKET,       // Added volume to a position by a new deal (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOLUME_ADD_BY_PENDING      =  MSG_EVN_POSITION_VOLUME_ADD_BY_PENDING,      // Added volume to a position by activating a pending order (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE                  =  MSG_EVN_MODIFY_ORDER_PRICE,                  // Changing order price
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE_SL               =  MSG_EVN_MODIFY_ORDER_PRICE_SL,               // Changing order and StopLoss price 
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE_TP               =  MSG_EVN_MODIFY_ORDER_PRICE_TP,               // Changing order and TakeProfit price
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE_SL_TP            =  MSG_EVN_MODIFY_ORDER_PRICE_SL_TP,            // Changing order, StopLoss and TakeProfit price
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_SL_TP                  =  MSG_EVN_MODIFY_ORDER_SL_TP,                  // Changing order's StopLoss and TakeProfit price
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_SL                     =  MSG_EVN_MODIFY_ORDER_SL,                     // Changing order's StopLoss
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_TP                     =  MSG_EVN_MODIFY_ORDER_TP,                     // Changing order's TakeProfit
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_POSITION_SL_TP               =  MSG_EVN_MODIFY_POSITION_SL_TP,               // Changing position's StopLoss and TakeProfit
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_POSITION_SL                  =  MSG_EVN_MODIFY_POSITION_SL,                  // Change position's StopLoss
   PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_POSITION_TP                  =  MSG_EVN_MODIFY_POSITION_TP,                  // Changing position's TakeProfit
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOL_ADD_BY_MARKET_PARTIAL  =  MSG_EVN_REASON_ADD_PARTIALLY,                // Added volume to a position by partial execution of a market order (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOL_ADD_BY_PENDING_PARTIAL =  MSG_EVN_REASON_ADD_BY_PENDING_PARTIALLY,     // Added volume to a position by partial activation of a pending order (netting)
   PEND_REQ_ACTIVATE_BY_EVENT_TRIGGERED_STOP_LIMIT_ORDER          =  MSG_EVN_REASON_STOPLIMIT_TRIGGERED,          // StopLimit order activation
   PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL=  MSG_EVN_REASON_REVERSE_BY_PENDING_PARTIALLY, // Position reversal by activating a pending order (netting)
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Data for working with DOM                                        |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Abstract DOM type (status)                                       |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_ORD_STATUS
  {
   MBOOK_ORD_STATUS_BUY,                              // Buy side
   MBOOK_ORD_STATUS_SELL,                             // Sell side
  };
//+------------------------------------------------------------------+
//| Integer properties of DOM order                                  |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_ORD_PROP_INTEGER
  {
   MBOOK_ORD_PROP_STATUS = 0,                         // Order status
   MBOOK_ORD_PROP_TYPE,                               // Order type
   MBOOK_ORD_PROP_VOLUME,                             // Order volume
   MBOOK_ORD_PROP_TIME_MSC,                           // Time of making a DOM snapshot in milliseconds
  }; 
#define MBOOK_ORD_PROP_INTEGER_TOTAL (4)              // Total number of integer properties
#define MBOOK_ORD_PROP_INTEGER_SKIP  (0)              // Number of integer DOM properties not used in sorting
//+------------------------------------------------------------------+
//| Real properties of DOM order                                     |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_ORD_PROP_DOUBLE
  {
   MBOOK_ORD_PROP_PRICE = MBOOK_ORD_PROP_INTEGER_TOTAL, // Order price
   MBOOK_ORD_PROP_VOLUME_REAL,                        // Extended accuracy order volume
  };
#define MBOOK_ORD_PROP_DOUBLE_TOTAL  (2)              // Total number of real properties
#define MBOOK_ORD_PROP_DOUBLE_SKIP   (0)              // Number of real properties not used in sorting
//+------------------------------------------------------------------+
//| String properties of DOM order                                   |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_ORD_PROP_STRING
  {
   MBOOK_ORD_PROP_SYMBOL = (MBOOK_ORD_PROP_INTEGER_TOTAL+MBOOK_ORD_PROP_DOUBLE_TOTAL), // Order symbol name
  };
#define MBOOK_ORD_PROP_STRING_TOTAL  (1)              // Total number of string properties
//+------------------------------------------------------------------+
//| Possible sorting criteria of DOM orders                          |
//+------------------------------------------------------------------+
#define FIRST_MB_DBL_PROP  (MBOOK_ORD_PROP_INTEGER_TOTAL-MBOOK_ORD_PROP_INTEGER_SKIP)
#define FIRST_MB_STR_PROP  (MBOOK_ORD_PROP_INTEGER_TOTAL-MBOOK_ORD_PROP_INTEGER_SKIP+MBOOK_ORD_PROP_DOUBLE_TOTAL-MBOOK_ORD_PROP_DOUBLE_SKIP)
enum ENUM_SORT_MBOOK_ORD_MODE
  {
   //--- Sort by integer properties
    SORT_BY_MBOOK_ORD_STATUS = 0,                      // Sort by order status
    SORT_BY_MBOOK_ORD_TYPE,                            // Sort by order type
    SORT_BY_MBOOK_ORD_VOLUME,                          // Sort by order volume
    SORT_BY_MBOOK_ORD_TIME_MSC,                        // Sort by time of making a DOM snapshot in milliseconds
   //--- Sort by real properties
    SORT_BY_MBOOK_ORD_PRICE = FIRST_MB_DBL_PROP,       // Sort by order price
    SORT_BY_MBOOK_ORD_VOLUME_REAL,                     // Sort by extended accuracy order volume
   //--- Sort by string properties
    SORT_BY_MBOOK_ORD_SYMBOL = FIRST_MB_STR_PROP,      // Sort by symbol name
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

#endif // __TRADING_DEFINES_MQH__